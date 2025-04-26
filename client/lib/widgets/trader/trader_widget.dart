// Main widget file - contains the core trader widget structure
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:jupiter_perp_trader_client/services/jupiter_perp.dart';
import 'package:jupiter_perp_trader_client/services/auth.dart';
import 'package:jupiter_perp_trader_client/services/wallet.dart';
import 'package:jupiter_perp_trader_client/widgets/trader/trading_form.dart';
import 'package:jupiter_perp_trader_client/widgets/trader/market_stats.dart';
import 'package:jupiter_perp_trader_client/widgets/trader/token_selector.dart';
import 'package:jupiter_perp_trader_client/widgets/trader/positions_orders.dart';
import 'package:jupiter_perp_trader_client/models/token.dart';

class TraderWidgetContent extends StatefulWidget {
  const TraderWidgetContent({super.key});

  @override
  State<TraderWidgetContent> createState() => _TraderWidgetContentState();
}

class _TraderWidgetContentState extends State<TraderWidgetContent> {
  Token _selectedToken = Token.SOL;
  final _perpService = JupiterPerpService();
  final _walletService = WalletService();
  MarketStats? _marketStats;
  Timer? _refreshTimer;
  bool _isInitialLoad = true;
  double? _tokenBalance;
  List<Position> _positions = [];

  @override
  void initState() {
    super.initState();
    _fetchMarketStats();
    _fetchTokenBalance();
    _fetchPositions();
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) {
        _fetchMarketStats();
        _fetchTokenBalance();
        _fetchPositions();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchMarketStats() async {
    if (!mounted) return;
    try {
      final stats = await _perpService.getMarketStats(_selectedToken.mintAddress);
      if (!mounted) return;
      setState(() {
        _marketStats = stats;
        _isInitialLoad = false;
      });
    } catch (e) {
      print('Error fetching market stats: $e');
    }
  }

  Future<void> _fetchTokenBalance() async {
    if (!mounted) return;
    try {
      final balance = await _walletService.getTokenBalance(_selectedToken.mintAddress);
      if (!mounted) return;
      setState(() => _tokenBalance = balance);
    } catch (e) {
      print('Error fetching token balance: $e');
      if (mounted) setState(() => _tokenBalance = 0.0);
    }
  }

  Future<void> _fetchPositions() async {
    if (!mounted) return;
    try {
      final positions = await _perpService.getOpenPositions(
        Provider.of<AuthState>(context, listen: false).walletPublicKey ?? '',
      );
      if (!mounted) return;
      setState(() => _positions = positions);
    } catch (e) {
      print('Error fetching positions: $e');
    }
  }

  void _onTokenSelected(Token token) {
    if (!mounted) return;
    setState(() {
      _selectedToken = token;
      _isInitialLoad = true;
    });
    _fetchMarketStats();
    _fetchTokenBalance();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          TokenSelector(
            selectedToken: _selectedToken,
            onTokenSelected: _onTokenSelected,
          ),
          MarketStatsWidget(
            marketStats: _marketStats,
            isLoading: _isInitialLoad,
          ),
          TradingForm(
            selectedToken: _selectedToken,
            tokenBalance: _tokenBalance,
            marketStats: _marketStats,
            perpService: _perpService,
            positions: _positions,
          ),
          if (Provider.of<AuthState>(context).isLoggedIn)
            PositionsOrdersTabs(
              positions: _positions,
              perpService: _perpService,
            ),
        ],
      ),
    );
  }
} 