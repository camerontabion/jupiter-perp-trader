import 'package:flutter/material.dart';
import 'package:jupiter_perp_trader_client/services/jupiter_perp.dart';

class MarketStatsWidget extends StatelessWidget {
  final MarketStats? marketStats;
  final bool isLoading;

  const MarketStatsWidget({
    super.key,
    required this.marketStats,
    required this.isLoading,
  });

  String _formatNumber(String value) {
    try {
      return double.parse(value).toStringAsFixed(2);
    } catch (e) {
      return value;
    }
  }

  String _formatVolume(String volume) {
    try {
      final double vol = double.parse(volume);
      if (vol >= 1000000) {
        return '${(vol / 1000000).toStringAsFixed(2)}M';
      } else if (vol >= 1000) {
        return '${(vol / 1000).toStringAsFixed(2)}K';
      }
      return vol.toStringAsFixed(2);
    } catch (e) {
      return volume;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: isLoading
        ? const Center(child: CircularProgressIndicator())
        : marketStats != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildMainStats(context),
                      const Divider(height: 24),
                      _buildDetailedStats(context),
                    ],
                  ),
                ),
              ),
            )
          : const SizedBox(),
    );
  }

  Widget _buildMainStats(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '\$${_formatNumber(marketStats!.price)}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '24h Change',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '${_formatNumber(marketStats!.priceChange24H)}%',
              style: TextStyle(
                color: double.parse(marketStats!.priceChange24H) >= 0
                    ? Colors.green
                    : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailedStats(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatItem(
          context,
          'High 24h',
          '\$${_formatNumber(marketStats!.priceHigh24H)}',
        ),
        _buildStatItem(
          context,
          'Low 24h',
          '\$${_formatNumber(marketStats!.priceLow24H)}',
        ),
        _buildStatItem(
          context,
          'Volume 24h',
          '\$${_formatVolume(marketStats!.volume)}',
        ),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ],
    );
  }
} 