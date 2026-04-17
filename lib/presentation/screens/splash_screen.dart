import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:forra_store/core/utils/AuthProvider.dart';
import 'package:forra_store/core/theme/neumorphic_colors.dart';
import 'package:forra_store/core/utils/neumorphic_style.dart';

import 'package:forra_store/presentation/screens/login_screen.dart';
import 'package:forra_store/presentation/screens/main/main_admin.dart';
import 'package:forra_store/presentation/screens/main/main_trabajador.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);

    _controller.forward();
    _init();
  }

  Future<void> _init() async {
    final auth = context.read<AuthProvider>();

    // 🔐 cargar sesión
    await auth.loadSession();

    // ⏳ pequeño delay para UX
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    if (auth.isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) =>
                  auth.role == 'admin'
                      ? const MainScreenAdmin()
                      : const MainScreenTrabajador(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? NeumorphicColors.dark : NeumorphicColors.light;

    return Scaffold(
      backgroundColor: colors.background,
      body: Center(
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: NeumorphicStyle.elevated(colors),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🌱 Ícono
                Container(
                  width: 110,
                  height: 110,
                  decoration: NeumorphicStyle.inset(colors),
                  child: Icon(Icons.grass, size: 56, color: colors.primary),
                ),

                const SizedBox(height: 24),

                // 🏷 Nombre
                Text(
                  'Forra Store',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),

                const SizedBox(height: 8),

                // 🧠 Subtítulo
                Text(
                  'Gestión inteligente forrajera',
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.text.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
