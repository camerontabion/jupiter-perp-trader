import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jupiter_perp_trader_client/services/jupiter_perp.dart';
import 'package:jupiter_perp_trader_client/services/auth.dart';
import 'package:jupiter_perp_trader_client/models/token.dart';

class PositionsOrdersTabs extends StatelessWidget {
  final List<Position> positions;
  final JupiterPerpService perpService;

  const PositionsOrdersTabs({
    super.key,
    required this.positions,
    required this.perpService,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                  child: TabBar(
                    tabs: [
                      Tab(text: 'Positions'),
                      Tab(text: 'Open Orders'),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 32,
                  child: ElevatedButton.icon(
                    onPressed: () => _showCloseAllConfirmation(context),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Close All', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[100],
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 200,
              child: TabBarView(
                children: [
                  _buildPositionsTab(context),
                  _buildOpenOrdersTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionsTab(BuildContext context) {
    if (positions.isEmpty) {
      return const Center(child: Text('No open positions'));
    }

    return ListView.builder(
      itemCount: positions.length,
      itemBuilder: (context, index) {
        final position = positions[index];
        final isProfit = (double.tryParse(position.pnlAfterFeesUsd) ?? 0) > 0;
        
        String tokenName = 'Unknown';
        for (Token token in Token.values) {
          if (token.mintAddress == position.marketMint) {
            tokenName = token.name;
            break;
          }
        }
        
        return ListTile(
          title: Text('$tokenName ${position.side.toUpperCase()}'),
          subtitle: Text(
            'Size: \$${double.parse(position.size).toStringAsFixed(2)} • Leverage: ${double.parse(position.leverage).toStringAsFixed(1)}x',
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${double.parse(position.pnlAfterFeesUsd).toStringAsFixed(2)}',
                style: TextStyle(
                  color: isProfit ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${double.parse(position.pnlChangePctAfterFees).toStringAsFixed(2)}%',
                style: TextStyle(
                  color: isProfit ? Colors.green : Colors.red,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOpenOrdersTab(BuildContext context) {
    final List<TPSLRequest> allOrders = [];
    for (var position in positions) {
      if (position.tpslRequests != null) {
        allOrders.addAll(
          position.tpslRequests!.map((json) => TPSLRequest.fromJson(json))
        );
      }
    }

    if (allOrders.isEmpty) {
      return const Center(child: Text('No open orders'));
    }

    return ListView.builder(
      itemCount: allOrders.length,
      itemBuilder: (context, index) {
        final order = allOrders[index];
        final isTP = order.requestType == 'tp';
        
        String tokenName = 'Unknown';
        for (Token token in Token.values) {
          if (token.mintAddress == order.desiredMint) {
            tokenName = token.name;
            break;
          }
        }
        
        return ListTile(
          title: Text(
            '${isTP ? 'Take Profit' : 'Stop Loss'} • $tokenName',
            style: TextStyle(
              color: isTP ? Colors.green : Colors.red,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Trigger: \$${double.parse(order.triggerPriceUsd ?? "0").toStringAsFixed(2)}'),
              Text('Size: ${order.sizePercentage}% (\$${order.sizeUsdFormatted})'),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _cancelOrder(context, order.positionRequestPubkey),
            color: Colors.red,
          ),
        );
      },
    );
  }

  Future<void> _showCloseAllConfirmation(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Close All Positions'),
          content: const Text('Are you sure you want to close all positions?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _closeAllPositions(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Close All'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _closeAllPositions(BuildContext context) async {
    try {
      final authState = Provider.of<AuthState>(context, listen: false);
      final walletAddress = authState.walletPublicKey;
      
      if (walletAddress == null) {
        throw Exception('Wallet not initialized');
      }

      await perpService.closeAllPositions(walletAddress: walletAddress);
      
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All positions closed successfully')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error closing positions: $e')),
      );
    }
  }

  Future<void> _cancelOrder(BuildContext context, String orderPubkey) async {
    try {
      final authState = Provider.of<AuthState>(context, listen: false);
      final walletAddress = authState.walletPublicKey;
      
      if (walletAddress == null) {
        throw Exception('Wallet not initialized');
      }

      await perpService.cancelTPSL(
        walletAddress: walletAddress,
        orderPubkey: orderPubkey,
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order cancelled successfully')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cancelling order: $e')),
      );
    }
  }
} 