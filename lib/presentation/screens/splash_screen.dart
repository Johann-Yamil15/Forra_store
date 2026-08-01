import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:forra_store/core/utils/auth_provider.dart';
import 'package:forra_store/core/theme/neumorphic_colors.dart';
import 'package:forra_store/presentation/widgets/brand_mark.dart';

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
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.6, curve: Curves.easeOut),
    );

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
          builder: (_) => auth.role == 'admin'
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
      // Fondo fijo en blanco: el logo del splash trae fondo blanco opaco
      // (no transparente), así que se fija el color en vez de usar el fondo
      // del tema para que no se note una caja blanca en modo oscuro.
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: FadeTransition(
                  opacity: _fade,
                  child: ScaleTransition(
                    scale: _scale,
                    // 🌾 Logo completo del splash (marca + nombre + slogan ya
                    // incluidos en la imagen). Si el archivo no existe, cae
                    // a la marca genérica + texto como respaldo.
                    child: Image.asset(
                      'assets/images/logo_splash.png',
                      width: 260,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          BrandMark(
                            size: 128,
                            glyphColor: colors.primary,
                            tileColor: colors.primary.withValues(alpha: 0.10),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            'Forra Store',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.6,
                              color: colors.text,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Gestión inteligente forrajera',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: colors.text.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Indicador de carga sutil ──
            Padding(
              padding: const EdgeInsets.only(bottom: 36),
              child: FadeTransition(
                opacity: _fade,
                child: SizedBox(
                  width: 120,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      minHeight: 3,
                      backgroundColor: colors.primary.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
