import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jupiter_perp_trader_client/helpers/constants.dart';
import 'dart:async';
import 'package:jupiter_perp_trader_client/services/wallet.dart';

// Make AuthState a ChangeNotifier to notify listeners of state changes
class AuthState extends ChangeNotifier {
  String _email = '';
  bool _isLoggedIn = false;
  String _accessToken = '';
  String? _walletPublicKey;
  bool _isWalletInitialized = false;

  // Getters for the private fields
  String get email => _email;
  bool get isLoggedIn => _isLoggedIn;
  String get accessToken => _accessToken;
  String? get walletPublicKey => _walletPublicKey;
  bool get isWalletInitialized => _isWalletInitialized;

  // Update method that notifies listeners
  void update({
    String? email,
    bool? isLoggedIn,
    String? accessToken,
    String? walletPublicKey,
    bool? isWalletInitialized,
  }) {
    if (email != null) _email = email;
    if (isLoggedIn != null) _isLoggedIn = isLoggedIn;
    if (accessToken != null) _accessToken = accessToken;
    if (walletPublicKey != null) _walletPublicKey = walletPublicKey;
    if (isWalletInitialized != null) _isWalletInitialized = isWalletInitialized;
    notifyListeners();
  }

  // Clear all auth state
  void clear() {
    _email = '';
    _isLoggedIn = false;
    _accessToken = '';
    _walletPublicKey = null;
    _isWalletInitialized = false;
    notifyListeners();
  }
}

// Make AuthService a singleton that can be accessed globally
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  
  final _dio = Dio();
  final authState = AuthState();
  final _walletService = WalletService();
  final _storage = const FlutterSecureStorage();
  Timer? _refreshTimer;
  bool _isRefreshing = false;

  static const String _emailKey = 'auth_email';
  static const String _accessTokenKey = 'auth_access_token';

  AuthService._internal() {
    _setupDioInterceptors();
  }

  // Make initialization public
  Future<void> initializeAuth() async {
    try {
      final email = await _storage.read(key: _emailKey);
      final accessToken = await _storage.read(key: _accessTokenKey);

      if (email != null && accessToken != null) {
        // Set wallet email context
        _walletService.setEmail(email);

        authState.update(
          email: email,
          accessToken: accessToken,
          isLoggedIn: true,
        );

        // Initialize wallet if auth is restored
        if (await _walletService.hasWallet()) {
          await _walletService.loadWallet();
          authState.update(
            walletPublicKey: _walletService.publicKey,
            isWalletInitialized: true,
          );
        }

        // Start refresh timer
        _startRefreshTimer();
        
        // Verify token is still valid
        _silentRefresh();
      }
    } catch (e) {
      print('Failed to restore auth state: $e');
      await logout();
    }
  }

  void _setupDioInterceptors() {
    _dio.options.extra["withCredentials"] = true;

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add token to request if available
          if (authState.accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer ${authState.accessToken}';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // Token expired
            if (!_isRefreshing && authState.isLoggedIn) {
              try {
                await _refreshToken();
                // Retry the original request
                final response = await _dio.request(
                  error.requestOptions.path,
                  data: error.requestOptions.data,
                  queryParameters: error.requestOptions.queryParameters,
                  options: Options(
                    method: error.requestOptions.method,
                    headers: {
                      'Authorization': 'Bearer ${authState.accessToken}',
                    },
                  ),
                );
                return handler.resolve(response);
              } catch (e) {
                // If refresh fails, logout and redirect to login
                await logout();
                return handler.reject(error);
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 4),
      (_) => _silentRefresh(),
    );
  }

  void _stopRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  Future<void> _silentRefresh() async {
    if (!authState.isLoggedIn || _isRefreshing) return;

    try {
      _isRefreshing = true;
      final response = await _dio.post(
        '$serverUrl/auth/refresh',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${authState.accessToken}',
          },
        ),
      );
      
      // Update stored token
      await _storage.write(key: _accessTokenKey, value: response.data['accessToken']);
      
      authState.update(
        accessToken: response.data['accessToken'],
      );
    } catch (e) {
      // If silent refresh fails, logout user
      await logout();
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _refreshToken() async {
    if (_isRefreshing) return;
    
    try {
      _isRefreshing = true;
      final response = await _dio.post(
        '$serverUrl/auth/refresh',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${authState.accessToken}',
          },
        ),
      );
      
      authState.update(
        accessToken: response.data['accessToken'],
      );
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> requestLogin(String email) async {
    await _dio.post(
      '$serverUrl/auth/request-login',
      data: {'email': email},
    );
  }

  Future<void> login(String email, String oneTimeCode) async {
    final response = await _dio.post(
      '$serverUrl/auth/login',
      data: {'email': email, 'code': oneTimeCode},
    );
    
    // Store auth data
    await _storage.write(key: _emailKey, value: email);
    await _storage.write(key: _accessTokenKey, value: response.data['accessToken']);

    // Set wallet email context
    _walletService.setEmail(email);

    // Update auth state
    authState.update(
      email: email,
      isLoggedIn: true,
      accessToken: response.data['accessToken'],
      isWalletInitialized: false,
    );

    // Initialize wallet
    try {
      if (await _walletService.hasWallet()) {
        await _walletService.loadWallet();
      } else {
        await _walletService.createWallet();
      }
      
      authState.update(
        walletPublicKey: _walletService.publicKey,
        isWalletInitialized: true,
      );
    } catch (e) {
      print('Failed to initialize wallet: $e');
      authState.update(isWalletInitialized: false);
    }

    _startRefreshTimer();
  }

  Future<void> logout() async {
    try {
      await _dio.post('$serverUrl/auth/logout');
    } finally {
      _stopRefreshTimer();
      // Clear stored auth data
      await _storage.delete(key: _emailKey);
      await _storage.delete(key: _accessTokenKey);
      _walletService.clearEmail(); // Clear wallet email context
      authState.clear();
    }
  }

  Future<void> logoutAll() async {
    try {
      await _dio.post('$serverUrl/auth/logout-all-sessions');
    } finally {
      // Stop refresh timer and clear auth state
      _stopRefreshTimer();
      // Clear stored auth data
      await _storage.delete(key: _emailKey);
      await _storage.delete(key: _accessTokenKey);
      authState.clear();
    }
  }

  // Cleanup method to be called when the app is disposed
  void dispose() {
    _stopRefreshTimer();
  }
}
