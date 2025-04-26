import 'package:dio/dio.dart';

class MarketStats {
  final String price;
  final String priceChange24H;
  final String priceHigh24H;
  final String priceLow24H;
  final String volume;

  MarketStats({
    required this.price,
    required this.priceChange24H,
    required this.priceHigh24H,
    required this.priceLow24H,
    required this.volume,
  });

  factory MarketStats.fromJson(Map<String, dynamic> json) {
    return MarketStats(
      price: json['price'],
      priceChange24H: json['priceChange24H'],
      priceHigh24H: json['priceHigh24H'],
      priceLow24H: json['priceLow24H'],
      volume: json['volume'],
    );
  }
}

class PoolInfo {
  final String longAvailableLiquidity;
  final String longBorrowRatePercent;
  final String longUtilizationPercent;
  final String shortAvailableLiquidity;
  final String shortBorrowRatePercent;
  final String shortUtilizationPercent;
  final String openFeePercent;
  final String maxRequestExecutionSec;
  final String maxPriceImpactFeePercent;

  PoolInfo({
    required this.longAvailableLiquidity,
    required this.longBorrowRatePercent,
    required this.longUtilizationPercent,
    required this.shortAvailableLiquidity,
    required this.shortBorrowRatePercent,
    required this.shortUtilizationPercent,
    required this.openFeePercent,
    required this.maxRequestExecutionSec,
    required this.maxPriceImpactFeePercent,
  });

  factory PoolInfo.fromJson(Map<String, dynamic> json) {
    return PoolInfo(
      longAvailableLiquidity: json['longAvailableLiquidity'],
      longBorrowRatePercent: json['longBorrowRatePercent'],
      longUtilizationPercent: json['longUtilizationPercent'],
      shortAvailableLiquidity: json['shortAvailableLiquidity'],
      shortBorrowRatePercent: json['shortBorrowRatePercent'],
      shortUtilizationPercent: json['shortUtilizationPercent'],
      openFeePercent: json['openFeePercent'],
      maxRequestExecutionSec: json['maxRequestExecutionSec'],
      maxPriceImpactFeePercent: json['maxPriceImpactFeePercent'],
    );
  }
}

class Position {
  final String borrowFees;
  final String borrowFeesUsd;
  final String closeFees;
  final String closeFeesUsd;
  final String collateral;
  final String collateralMint;
  final int createdTime;
  final String entryPrice;
  final String leverage;
  final String liquidationPrice;
  final String marketMint;
  final String markPrice;
  final String openFees;
  final String openFeesUsd;
  final String pnlAfterFees;
  final String pnlAfterFeesUsd;
  final String pnlBeforeFees;
  final String pnlBeforeFeesUsd;
  final String pnlChangePctAfterFees;
  final String pnlChangePctBeforeFees;
  final String positionPubkey;
  final String side;
  final String size;
  final String sizeTokenAmount;
  final String totalFees;
  final String totalFeesUsd;
  final int updatedTime;
  final String value;
  final List<dynamic>? tpslRequests;

  Position({
    required this.borrowFees,
    required this.borrowFeesUsd,
    required this.closeFees,
    required this.closeFeesUsd,
    required this.collateral,
    required this.collateralMint,
    required this.createdTime,
    required this.entryPrice,
    required this.leverage,
    required this.liquidationPrice,
    required this.marketMint,
    required this.markPrice,
    required this.openFees,
    required this.openFeesUsd,
    required this.pnlAfterFees,
    required this.pnlAfterFeesUsd,
    required this.pnlBeforeFees,
    required this.pnlBeforeFeesUsd,
    required this.pnlChangePctAfterFees,
    required this.pnlChangePctBeforeFees,
    required this.positionPubkey,
    required this.side,
    required this.size,
    required this.sizeTokenAmount,
    required this.totalFees,
    required this.totalFeesUsd,
    required this.updatedTime,
    required this.value,
    this.tpslRequests,
  });

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      borrowFees: json['borrowFees'],
      borrowFeesUsd: json['borrowFeesUsd'],
      closeFees: json['closeFees'],
      closeFeesUsd: json['closeFeesUsd'],
      collateral: json['collateral'],
      collateralMint: json['collateralMint'],
      createdTime: json['createdTime'],
      entryPrice: json['entryPrice'],
      leverage: json['leverage'],
      liquidationPrice: json['liquidationPrice'],
      marketMint: json['marketMint'],
      markPrice: json['markPrice'],
      openFees: json['openFees'],
      openFeesUsd: json['openFeesUsd'],
      pnlAfterFees: json['pnlAfterFees'],
      pnlAfterFeesUsd: json['pnlAfterFeesUsd'],
      pnlBeforeFees: json['pnlBeforeFees'],
      pnlBeforeFeesUsd: json['pnlBeforeFeesUsd'],
      pnlChangePctAfterFees: json['pnlChangePctAfterFees'],
      pnlChangePctBeforeFees: json['pnlChangePctBeforeFees'],
      positionPubkey: json['positionPubkey'],
      side: json['side'],
      size: json['size'],
      sizeTokenAmount: json['sizeTokenAmount'],
      totalFees: json['totalFees'],
      totalFeesUsd: json['totalFeesUsd'],
      updatedTime: json['updatedTime'],
      value: json['value'],
      tpslRequests: json['tpslRequests'],
    );
  }
}

class TPSLRequest {
  final String desiredMint;
  final String positionRequestPubkey;
  final String requestType; // 'tp' or 'sl'
  final String sizeUsd;
  final String sizeUsdFormatted;
  final String sizePercentage;
  final String? triggerPrice;
  final String? triggerPriceUsd;

  TPSLRequest({
    required this.desiredMint,
    required this.positionRequestPubkey,
    required this.requestType,
    required this.sizeUsd,
    required this.sizeUsdFormatted,
    required this.sizePercentage,
    this.triggerPrice,
    this.triggerPriceUsd,
  });

  factory TPSLRequest.fromJson(Map<String, dynamic> json) {
    return TPSLRequest(
      desiredMint: json['desiredMint'],
      positionRequestPubkey: json['positionRequestPubkey'],
      requestType: json['requestType'],
      sizeUsd: json['sizeUsd'],
      sizeUsdFormatted: json['sizeUsdFormatted'],
      sizePercentage: json['sizePercentage'],
      triggerPrice: json['triggerPrice'],
      triggerPriceUsd: json['triggerPriceUsd'],
    );
  }
}

class JupiterPerpService {
  static final JupiterPerpService _instance = JupiterPerpService._internal();
  factory JupiterPerpService() => _instance;

  late final Dio _dio;
  static const String baseUrl = 'https://perps-api.jup.ag/v1';

  JupiterPerpService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          print('API Error: ${error.message}');
          print('API Error Response: ${error.response?.data}');
          print('API Error Type: ${error.type}');
          return handler.next(error);
        },
        onRequest: (request, handler) async {
          print('API Request: ${request.method} ${request.uri}');
          print('API Request Headers: ${request.headers}');
          return handler.next(request);
        },
        onResponse: (response, handler) async {
          print('API Response: ${response.statusCode}');
          print('API Response Data: ${response.data}');
          return handler.next(response);
        },
      ),
    );
  }

  // Get market stats for a specific token
  Future<MarketStats> getMarketStats(String mint) async {
    try {
      final response = await _dio.get(
        '/market-stats',
        queryParameters: {'mint': mint},
      );
      return MarketStats.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get pool info for a specific token
  Future<PoolInfo> getPoolInfo(String mint) async {
    try {
      final response = await _dio.get(
        '/pool-info',
        queryParameters: {'mint': mint},
      );
      return PoolInfo.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get positions for a wallet
  Future<List<Position>> getPositions(String walletAddress) async {
    try {
      final response = await _dio.get(
        '/positions',
        queryParameters: {'walletAddress': walletAddress},
      );
      final List<dynamic> dataList = response.data['dataList'];
      return dataList.map((json) => Position.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Close all positions for a wallet
  Future<Map<String, dynamic>> closeAllPositions({
    required String walletAddress,
    String? slippageBps,
  }) async {
    try {
      final response = await _dio.post(
        '/positions/close-all',
        data: {
          'walletAddress': walletAddress,
          if (slippageBps != null) 'slippageBps': slippageBps,
        },
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Get all open positions for a wallet
  Future<List<Position>> getOpenPositions(String walletAddress) async {
    try {
      final response = await _dio.get(
        '/positions',
        queryParameters: {'walletAddress': walletAddress},
      );

      // Extract the dataList from the response
      final List<dynamic> dataList = response.data['dataList'] ?? [];
      
      // Map each position data to a Position object
      return dataList.map((json) => Position.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching positions: $e');
      // Return empty list instead of throwing to handle errors gracefully
      return [];
    }
  }

  // Set take profit / stop loss for a position
  Future<Map<String, dynamic>> setTPSL({
    required String walletAddress,
    required String positionPubkey,
    required String triggerPrice,
    required String size,
    required String triggerType, // 'takeProfit' or 'stopLoss'
    String? slippageBps,
  }) async {
    try {
      final response = await _dio.post(
        '/tpsl',
        data: {
          'walletAddress': walletAddress,
          'positionPubkey': positionPubkey,
          'triggerPrice': triggerPrice,
          'size': size,
          'triggerType': triggerType,
          if (slippageBps != null) 'slippageBps': slippageBps,
        },
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Cancel a take profit / stop loss order
  Future<Map<String, dynamic>> cancelTPSL({
    required String walletAddress,
    required String orderPubkey,
  }) async {
    try {
      final response = await _dio.post(
        '/tpsl/cancel',
        data: {'walletAddress': walletAddress, 'orderPubkey': orderPubkey},
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Increase an existing position
  Future<Map<String, dynamic>> increasePosition({
    required String walletAddress,
    required String collateralMint,
    required String collateralTokenDelta,
    required String inputMint,
    required String marketMint,
    required String maxSlippageBps,
    required String side,
    String? leverage,
    String? sizeUsdDelta,
    bool includeSerializedTx = true,
  }) async {
    try {
      final response = await _dio.post(
        '/positions/increase',
        data: {
          'walletAddress': walletAddress,
          'collateralMint': collateralMint,
          'collateralTokenDelta': collateralTokenDelta,
          'inputMint': inputMint,
          'marketMint': marketMint,
          'maxSlippageBps': maxSlippageBps,
          'side': side,
          if (leverage != null) 'leverage': leverage,
          if (sizeUsdDelta != null) 'sizeUsdDelta': sizeUsdDelta,
          'includeSerializedTx': includeSerializedTx,
        },
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Decrease an existing position
  Future<Map<String, dynamic>> decreasePosition({
    required String collateralUsdDelta,
    required String desiredMint,
    required String positionPubkey,
    required String sizeUsdDelta,
    bool entirePosition = false,
    String? maxSlippageBps,
  }) async {
    try {
      final response = await _dio.post(
        '/positions/decrease',
        data: {
          'collateralUsdDelta': collateralUsdDelta,
          'desiredMint': desiredMint,
          'positionPubkey': positionPubkey,
          'sizeUsdDelta': sizeUsdDelta,
          'entirePosition': entirePosition,
          if (maxSlippageBps != null) 'maxSlippageBps': maxSlippageBps,
        },
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<TPSLRequest>> getTPSLRequests(Position position) async {
    try {
      // TPSL requests are stored in the position object
      final List<dynamic> tpslRequests = position.tpslRequests ?? [];
      return tpslRequests.map((json) => TPSLRequest.fromJson(json)).toList();
    } catch (e) {
      print('Error getting TPSL requests: $e');
      return [];
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception(
            'Connection timeout. Please check your internet connection.',
          );
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final message =
              error.response?.data?['message'] ?? 'Unknown error occurred';
          return Exception('Server error ($statusCode): $message');
        default:
          return Exception('Network error: ${error.message}');
      }
    }
    return Exception('Unexpected error: $error');
  }
}
