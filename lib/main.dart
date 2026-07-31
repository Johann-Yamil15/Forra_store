import 'dart:io';
import 'package:flutter/material.dart';
import 'package:forra_store/presentation/screens/profile/profile_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/theme/theme_provider.dart';
import 'core/theme/light_theme.dart';
import 'core/theme/dark_theme.dart';
import 'core/utils/auth_provider.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/providers/cart_provider.dart';
import 'presentation/providers/pedidos_provider.dart';
import 'presentation/providers/admin_provider.dart';

// Permite conexión a IIS Express con certificado auto-firmado en debug
class _DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      super.createHttpClient(context)
        ..badCertificateCallback = (_, __, ___) => true;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = _DevHttpOverrides();
  await initializeDateFormatting('es_MX', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => PedidosProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: const ForraStoreApp(),
    ),
  );
}

class ForraStoreApp extends StatelessWidget {
  const ForraStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.mode,
      home: const SplashScreen(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/profile': (_) => const ProfileScreen(),
      },
      onUnknownRoute: (settings) =>
          MaterialPageRoute(builder: (_) => const SplashScreen()),
    );
  }
}
