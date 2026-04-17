import 'package:flutter/material.dart';
import 'package:forra_store/presentation/screens/profile/profile_screen.dart';
import 'package:provider/provider.dart';

import 'core/theme/theme_provider.dart';
import 'core/theme/light_theme.dart';
import 'core/theme/dark_theme.dart';

import 'core/utils/AuthProvider.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        // 🌙 Theme
        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        // 🔐 Auth
        ChangeNotifierProvider(create: (_) => AuthProvider()),
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
      themeMode: themeProvider.mode, // Mantiene la selección de tema
      // 🚦 Inicial
      home: const SplashScreen(),

      // 🛣 Rutas nombradas (para logout)
      routes: {
        "/login": (_) => const LoginScreen(),
        "/profile": (_) => const ProfileScreen(),
        // Otras rutas que uses
      },

      // Fallback para rutas no definidas
      onUnknownRoute:
          (settings) => MaterialPageRoute(builder: (_) => const SplashScreen()),
    );
  }
}
