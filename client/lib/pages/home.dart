import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jupiter_perp_trader_client/services/auth.dart';
import 'package:jupiter_perp_trader_client/widgets/trader/trader_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthState>(
      builder: (context, authState, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Jupiter Perp Trader'),
            actions: [
              if (authState.isLoggedIn)
                IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
            ],
          ),
          body: const Center(
            child: TraderWidgetContent(),
          ),
        );
      },
    );
  }
}
