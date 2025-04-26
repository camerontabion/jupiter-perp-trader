import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jupiter_perp_trader_client/services/jupiter_perp.dart';
import 'package:jupiter_perp_trader_client/services/auth.dart';
import 'package:jupiter_perp_trader_client/models/token.dart';
import 'dart:math';

class TradingForm extends StatefulWidget {
  final Token selectedToken;
  final double? tokenBalance;
  final MarketStats? marketStats;
  final JupiterPerpService perpService;
  final List<Position> positions;

  const TradingForm({
    super.key,
    required this.selectedToken,
    required this.tokenBalance,
    required this.marketStats,
    required this.perpService,
    required this.positions,
  });

  @override
  State<TradingForm> createState() => _TradingFormState();
}

class _TradingFormState extends State<TradingForm> {
  final _formKey = GlobalKey<FormState>();
  final _paymentAmountController = TextEditingController();
  final _leverageController = TextEditingController(text: '10');
  final _slippageController = TextEditingController(text: '2.0');
  TradeType _tradeType = TradeType.long;

  @override
  void dispose() {
    _paymentAmountController.dispose();
    _leverageController.dispose();
    _slippageController.dispose();
    super.dispose();
  }

  String? _validatePaymentAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an amount';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    if (double.parse(value) <= 0) {
      return 'Amount must be greater than 0';
    }
    return null;
  }

  String? _validateLeverage(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter leverage';
    }
    final leverage = double.tryParse(value);
    if (leverage == null) {
      return 'Please enter a valid number';
    }
    if (leverage < 1 || leverage > 100) {
      return 'Leverage must be between 1x and 100x';
    }
    return null;
  }

  String? _validateSlippage(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter slippage';
    }
    final slippage = double.tryParse(value);
    if (slippage == null) {
      return 'Please enter a valid number';
    }
    if (slippage < 0.1 || slippage > 5.0) {
      return 'Slippage must be between 0.1% and 5%';
    }
    return null;
  }

  Future<void> _submitTrade() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final amount = double.parse(_paymentAmountController.text);
      final leverage = double.parse(_leverageController.text);
      final slippage = double.parse(_slippageController.text);

      // Convert amount to token decimals
      final tokenAmount = (amount * pow(10, widget.selectedToken.decimals)).toInt().toString();

      final authState = Provider.of<AuthState>(context, listen: false);
      final walletAddress = authState.walletPublicKey;
      
      if (walletAddress == null) {
        throw Exception('Wallet not initialized');
      }

      await widget.perpService.increasePosition(
        walletAddress: walletAddress,
        collateralMint: widget.selectedToken.mintAddress,
        collateralTokenDelta: tokenAmount,
        inputMint: widget.selectedToken.mintAddress,
        marketMint: widget.selectedToken.mintAddress,
        maxSlippageBps: (slippage * 100).toString(),
        side: _tradeType == TradeType.long ? 'long' : 'short',
        leverage: leverage.toString(),
        includeSerializedTx: true,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trade submitted successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting trade: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthState>(context);
    final isLoggedIn = authState.isLoggedIn;

    String usdValue = '';
    if (widget.marketStats != null && _paymentAmountController.text.isNotEmpty) {
      final amount = double.tryParse(_paymentAmountController.text);
      if (amount != null) {
        final usdAmount = amount * double.parse(widget.marketStats!.price);
        usdValue = '\$${usdAmount.toStringAsFixed(2)}';
      }
    }

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTradeTypeSelector(),
            const SizedBox(height: 16),
            _buildPaymentField(usdValue),
            const SizedBox(height: 16),
            _buildLeverageField(),
            const SizedBox(height: 16),
            _buildSlippageField(),
            const SizedBox(height: 24),
            _buildSubmitButton(isLoggedIn),
          ],
        ),
      ),
    );
  }

  Widget _buildTradeTypeSelector() {
    return SegmentedButton<TradeType>(
      segments: const [
        ButtonSegment<TradeType>(
          value: TradeType.long,
          label: Text('Long'),
        ),
        ButtonSegment<TradeType>(
          value: TradeType.short,
          label: Text('Short'),
        ),
      ],
      selected: {_tradeType},
      onSelectionChanged: (Set<TradeType> newSelection) {
        setState(() => _tradeType = newSelection.first);
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return _tradeType == TradeType.long
                  ? Colors.green
                  : Colors.red;
            }
            return Theme.of(context).colorScheme.surface;
          },
        ),
        foregroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.white;
            }
            return Theme.of(context).colorScheme.onSurfaceVariant;
          },
        ),
      ),
    );
  }

  Widget _buildPaymentField(String usdValue) {
    return TextFormField(
      controller: _paymentAmountController,
      decoration: InputDecoration(
        labelText: "You're Paying $usdValue",
        border: const OutlineInputBorder(),
        helperText: 'Available: ${widget.tokenBalance?.toStringAsFixed(4) ?? '0.0000'} ${widget.selectedToken.name}',
        helperStyle: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
        suffixText: widget.selectedToken.name,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: _validatePaymentAmount,
      onChanged: (value) => setState(() {}),
    );
  }

  Widget _buildLeverageField() {
    return TextFormField(
      controller: _leverageController,
      decoration: const InputDecoration(
        labelText: 'Leverage',
        border: OutlineInputBorder(),
        helperText: 'Enter leverage (1x - 100x)',
        suffixText: 'x',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: _validateLeverage,
    );
  }

  Widget _buildSlippageField() {
    return TextFormField(
      controller: _slippageController,
      decoration: const InputDecoration(
        labelText: 'Slippage Tolerance',
        border: OutlineInputBorder(),
        helperText: 'Enter slippage (0.1% - 5%)',
        suffixText: '%',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: _validateSlippage,
    );
  }

  Widget _buildSubmitButton(bool isLoggedIn) {
    return ElevatedButton(
      onPressed: isLoggedIn 
        ? _submitTrade 
        : () => Navigator.pushNamed(context, '/login'),
      style: ElevatedButton.styleFrom(
        backgroundColor: isLoggedIn
          ? (_tradeType == TradeType.long ? Colors.green : Colors.red)
          : Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Text(
        isLoggedIn
          ? (_tradeType == TradeType.long ? 'Submit Long Order' : 'Submit Short Order')
          : 'Login to Trade',
      ),
    );
  }
} 