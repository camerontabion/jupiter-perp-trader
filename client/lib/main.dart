import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:jupiter_perp_trader_client/services/auth.dart';
import 'package:jupiter_perp_trader_client/pages/home.dart';
import 'package:jupiter_perp_trader_client/pages/login.dart';
import 'package:jupiter_perp_trader_client/pages/profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  final authService = AuthService();
  await authService.initializeAuth();
  
  runApp(MyApp(authService: authService));
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  
  const MyApp({
    super.key,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: authService.authState,
        ),
      ],
      child: MaterialApp(
        title: 'Jupiter Perp Trader',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xffff68ff),
          ),
          useMaterial3: true,
        ),
        home: const HomePage(),
        routes: {
          '/login': (context) => const LoginPage(),
          '/profile': (context) => const ProfilePage(),
        },
      ),
    );
  }
}

class LifecycleEventHandler extends WidgetsBindingObserver {
  final Future<void> Function()? detached;

  LifecycleEventHandler({
    this.detached,
  });

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.detached:
        if (detached != null) {
          await detached!();
        }
        break;
      default:
        break;
    }
  }
}
