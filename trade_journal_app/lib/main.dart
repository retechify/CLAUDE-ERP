import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/trade_provider.dart';
import 'services/auth_service.dart';
import 'services/trade_service.dart';
import 'views/auth/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TradeJournalApp());
}

class TradeJournalApp extends StatelessWidget {
  const TradeJournalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<TradeService>(create: (_) => TradeService()),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(context.read<AuthService>()),
        ),
        ChangeNotifierProxyProvider2<AuthProvider, TradeService, TradeProvider>(
          create: (context) =>
              TradeProvider(tradeService: context.read<TradeService>()),
          update: (_, auth, tradeService, provider) {
            final tradeProvider =
                provider ?? TradeProvider(tradeService: tradeService);
            tradeProvider.bindUser(auth.userId);
            return tradeProvider;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Trade Journal',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF16697A),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF6F8FA),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF16697A),
                width: 1.4,
              ),
            ),
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        home: const AuthGate(),
      ),
    );
  }
}
