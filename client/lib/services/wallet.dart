import 'package:jupiter_perp_trader_client/helpers/constants.dart';
import 'package:solana/dto.dart';
import 'package:solana/solana.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class WalletService {
  static final WalletService _instance = WalletService._internal();
  factory WalletService() => _instance;
  
  final _storage = const FlutterSecureStorage();
  Ed25519HDKeyPair? _keyPair;
  String? _currentEmail;
  
  late final RpcClient _rpcClient;
  
  WalletService._internal() {
    _rpcClient = RpcClient(solanaRpcUrl!);
  }

  // Get the public key if wallet exists
  String? get publicKey => _keyPair?.publicKey.toBase58();

  // Set current email context
  void setEmail(String email) {
    _currentEmail = email;
  }

  // Get storage keys for current email
  String get _mnemonicKey => 'wallet_mnemonic_${_currentEmail ?? ""}';
  String get _publicKeyKey => 'wallet_public_key_${_currentEmail ?? ""}';

  // Check if wallet exists
  Future<bool> hasWallet() async {
    if (_currentEmail == null) {
      throw Exception('Email context not set');
    }
    final mnemonic = await _storage.read(key: _mnemonicKey);
    return mnemonic != null;
  }

  // Create a new wallet
  Future<void> createWallet() async {
    if (_currentEmail == null) {
      throw Exception('Email context not set');
    }

    try {
      // Generate a new 12-word mnemonic
      final mnemonic = bip39.generateMnemonic(strength: 128); // 12 words
      
      // Validate the mnemonic
      if (!bip39.validateMnemonic(mnemonic)) {
        throw Exception('Generated invalid mnemonic');
      }
      
      // Create the key pair
      _keyPair = await Ed25519HDKeyPair.fromMnemonic(mnemonic);
      
      // Store the mnemonic and public key
      await _storage.write(
        key: _mnemonicKey,
        value: mnemonic,
      );
      
      await _storage.write(
        key: _publicKeyKey,
        value: _keyPair!.publicKey.toBase58(),
      );
    } catch (e) {
      throw Exception('Failed to create wallet: $e');
    }
  }

  // Load existing wallet
  Future<void> loadWallet() async {
    if (_currentEmail == null) {
      throw Exception('Email context not set');
    }

    try {
      final mnemonic = await _storage.read(key: _mnemonicKey);
      if (mnemonic == null) {
        throw Exception('No wallet found');
      }
      
      if (!bip39.validateMnemonic(mnemonic)) {
        throw Exception('Stored mnemonic is invalid');
      }
      
      _keyPair = await Ed25519HDKeyPair.fromMnemonic(mnemonic);
      
      // Verify the public key matches stored value
      final storedPublicKey = await _storage.read(key: _publicKeyKey);
      if (storedPublicKey != _keyPair!.publicKey.toBase58()) {
        throw Exception('Wallet public key mismatch');
      }
    } catch (e) {
      throw Exception('Failed to load wallet: $e');
    }
  }

  // Export mnemonic (secret phrase)
  Future<String> exportMnemonic() async {
    if (_currentEmail == null) {
      throw Exception('Email context not set');
    }

    try {
      final mnemonic = await _storage.read(key: _mnemonicKey);
      if (mnemonic == null) {
        throw Exception('No wallet found');
      }
      
      if (!bip39.validateMnemonic(mnemonic)) {
        throw Exception('Stored mnemonic is invalid');
      }
      
      return mnemonic;
    } catch (e) {
      throw Exception('Failed to export mnemonic: $e');
    }
  }

  // Import wallet from mnemonic
  Future<void> importWallet(String mnemonic) async {
    if (_currentEmail == null) {
      throw Exception('Email context not set');
    }

    try {
      // Validate the mnemonic
      if (!bip39.validateMnemonic(mnemonic)) {
        throw Exception('Invalid mnemonic provided');
      }
      
      // Create the key pair
      final newKeyPair = await Ed25519HDKeyPair.fromMnemonic(mnemonic);
      
      // Store the mnemonic and public key
      await _storage.write(
        key: _mnemonicKey,
        value: mnemonic,
      );
      
      await _storage.write(
        key: _publicKeyKey,
        value: newKeyPair.publicKey.toBase58(),
      );
      
      _keyPair = newKeyPair;
    } catch (e) {
      throw Exception('Failed to import wallet: $e');
    }
  }

  // Delete the wallet
  Future<void> deleteWallet() async {
    if (_currentEmail == null) {
      throw Exception('Email context not set');
    }

    try {
      await _storage.delete(key: _mnemonicKey);
      await _storage.delete(key: _publicKeyKey);
      _keyPair = null;
    } catch (e) {
      throw Exception('Failed to delete wallet: $e');
    }
  }

  // Clear current email context
  void clearEmail() {
    _currentEmail = null;
    _keyPair = null;
  }

  // Sign a message
  Future<Signature> signMessage(List<int> message) async {
    if (_currentEmail == null) {
      throw Exception('Email context not set');
    }
    if (_keyPair == null) {
      throw Exception('Wallet not initialized');
    }
    
    try {
      return await _keyPair!.sign(message);
    } catch (e) {
      throw Exception('Failed to sign message: $e');
    }
  }

  // Get wallet balance
  Future<double> getBalance(SolanaClient client) async {
    if (_currentEmail == null) {
      throw Exception('Email context not set');
    }
    if (_keyPair == null) {
      throw Exception('Wallet not initialized');
    }
    
    try {
      final balance = await client.rpcClient.getBalance(
        _keyPair!.publicKey.toBase58(),
        commitment: Commitment.confirmed,
      );
      
      return balance.value / lamportsPerSol;
    } catch (e) {
      throw Exception('Failed to get balance: $e');
    }
  }

  Future<double> getSolBalance() async {
    if (_keyPair == null) {
      throw Exception('Wallet not initialized');
    }

    try {
      final balance = await _rpcClient.getBalance(
        _keyPair!.publicKey.toBase58(),
        commitment: Commitment.confirmed,
      );
      
      // Convert lamports to SOL (1 SOL = 1e9 lamports)
      return balance.value / lamportsPerSol;
    } catch (e) {
      throw Exception('Failed to get SOL balance: $e');
    }
  }

  Future<double> getTokenBalance(String mintAddress) async {
    if (_keyPair == null) {
      return 0.0;
    }

    try {
      // For native SOL
      if (mintAddress == 'So11111111111111111111111111111111111111112') {
        final balance = await _rpcClient.getBalance(
          _keyPair!.publicKey.toBase58(),
          commitment: Commitment.confirmed,
        );
        return balance.value / lamportsPerSol;
      }

      // For other SPL tokens
      final response = await _rpcClient.getTokenAccountsByOwner(
        _keyPair!.publicKey.toBase58(),
        TokenAccountsFilter.byMint(mintAddress),
        commitment: Commitment.confirmed,
        encoding: Encoding.jsonParsed,
      );

      if (response.value.isEmpty) {
        return 0.0;
      }

      // Get the first token account (usually there's only one per token)
      final tokenAccount = response.value.first;
      final data = tokenAccount.account.data as ParsedAccountData;
      if (data.parsed is! Map) {
        return 0.0;
      }

      final info = data.parsed as Map;
      final tokenAmount = info['tokenAmount'] as Map;
      final uiAmount = tokenAmount['uiAmount'] as double?;
      
      return uiAmount ?? 0.0;
    } catch (e) {
      print('Error getting token balance: $e');
      return 0.0;
    }
  }
}
