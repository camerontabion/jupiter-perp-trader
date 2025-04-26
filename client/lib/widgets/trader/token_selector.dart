// Token selection buttons
import 'package:flutter/material.dart';
import 'package:jupiter_perp_trader_client/models/token.dart';

class TokenSelector extends StatelessWidget {
  final Token selectedToken;
  final Function(Token) onTokenSelected;

  const TokenSelector({
    super.key,
    required this.selectedToken,
    required this.onTokenSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: Token.values.map((token) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildTokenButton(context, token),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTokenButton(BuildContext context, Token token) {
    final isSelected = selectedToken == token;
    
    return SizedBox(
      width: 100,
      child: ElevatedButton(
        onPressed: () => onTokenSelected(token),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected 
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surfaceContainerHighest,
          foregroundColor: isSelected
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurfaceVariant,
          minimumSize: const Size(100, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: isSelected ? 2 : 0,
        ),
        child: Text(
          token.name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
} 