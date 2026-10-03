import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'screens/auth_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'services/socket_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize WebSocket client for live social feed events
  SocketService().connect();

  runApp(
    const ProviderScope(
      child: FitFlowApp(),
    ),
  );
}

class FitFlowApp extends StatelessWidget {
  const FitFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitFlow — Intelligent Fitness Redesign',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigationScreen(),
      routes: {
        '/auth': (context) => const AuthScreen(),
        '/home': (context) => const MainNavigationScreen(),
      },
    );
  }
}
