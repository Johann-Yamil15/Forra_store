import 'package:flutter/material.dart';
import 'package:forra_store/core/theme/neumorphic_colors.dart';
import 'package:forra_store/core/theme/theme_provider.dart';
import 'package:forra_store/core/utils/AuthProvider.dart';
import 'package:forra_store/core/utils/neumorphic_style.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Elegir colores según el tema
    final colors = isDark ? NeumorphicColors.dark : NeumorphicColors.light;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          'Mi Perfil',
          style: GoogleFonts.nunitoSans(
            fontWeight: FontWeight.bold,
            color: colors.text,
          ),
        ),
        elevation: 0,
        backgroundColor: colors.background,
        iconTheme: IconThemeData(color: colors.text),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: colors.background,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
      ),
      body: Column(
        children: [
          // Encabezado de Perfil
          _buildProfileHeader(colors),

          // Opciones del menú
          Expanded(child: _buildMenuOptions(context, colors)),
        ],
      ),
    );
  }

  /// Encabezado de Perfil con Avatar y Datos del Usuario
  Widget _buildProfileHeader(NeumorphicColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: NeumorphicStyle.elevated(colors),
      child: Row(
        children: [
          // Avatar
          Container(
            decoration: NeumorphicStyle.elevated(colors, radius: 30, depth: 4),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: colors.secondary.withAlpha((0.2 * 255).round()),
              backgroundImage: const NetworkImage(
                'https://randomuser.me/api/portraits/men/41.jpg',
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Información del Usuario
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Usuario ForraControl',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'correo@ejemplo.com',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 14,
                    color: colors.text.withAlpha((0.6 * 255).round()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Lista de Opciones del Menú
  Widget _buildMenuOptions(BuildContext context, NeumorphicColors colors) {
    final List<Map<String, dynamic>> opciones = [
      {
        "icon": Icons.settings,
        "title": "Configuración",
        "action": () => _showSettingsModal(context, colors),
      },
      {
        "icon": Icons.help_outline,
        "title": "Ayuda y Soporte",
        "action": () => _showHelpModal(context, colors),
      },
      {
        "icon": Icons.info_outline,
        "title": "Acerca de",
        "action": () => _showAboutModal(context, colors),
      },
      {
        "icon": Icons.exit_to_app,
        "title": "Cerrar sesión",
        "action": () => _handleLogout(context, colors),
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: opciones.length,
      itemBuilder: (context, index) {
        final isLogout = opciones[index]["title"] == "Cerrar sesión";

        return GestureDetector(
          onTap: opciones[index]["action"],
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration:
                isLogout
                    ? NeumorphicStyle.elevated(colors, depth: 4, radius: 12)
                    : NeumorphicStyle.elevated(colors, radius: 12),
            child: Row(
              children: [
                Icon(
                  opciones[index]["icon"],
                  color: isLogout ? colors.error : colors.primary,
                  size: 28,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    opciones[index]["title"],
                    style: GoogleFonts.nunitoSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: isLogout ? colors.error : colors.text,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: colors.text.withAlpha((0.6 * 255).round()),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Modal Configuración
  void _showSettingsModal(BuildContext context, NeumorphicColors colors) {
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configuración',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: colors.text,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Modo Oscuro
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Modo Oscuro',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 16,
                          color: colors.text,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => themeProvider.toggleTheme(),
                        child: Container(
                          decoration:
                              themeProvider.isDark
                                  ? NeumorphicStyle.inset(
                                    colors,
                                    radius: 20,
                                  ) // Inset para modo oscuro
                                  : NeumorphicStyle.elevated(
                                    colors,
                                    radius: 20,
                                  ), // Elevado para claro
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Switch(
                            value: themeProvider.isDark,
                            onChanged: (v) => themeProvider.toggleTheme(),
                            activeColor: colors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Botón Guardar Configuración Neumórfico
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 14,
                        ),
                        decoration: NeumorphicStyle.elevated(
                          colors,
                          radius: 12,
                          depth: 4,
                        ),
                        child: Text(
                          'GUARDAR CONFIGURACIÓN',
                          style: GoogleFonts.nunitoSans(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: colors.text,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Modal Ayuda
  void _showHelpModal(BuildContext context, NeumorphicColors colors) {
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ayuda y Soporte',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: colors.text,
                ),
              ),
              const SizedBox(height: 16),
              _buildHelpItem(
                colors,
                Icons.phone,
                'Llámanos',
                '+52 55 1234 5678',
              ),
              _buildHelpItem(
                colors,
                Icons.email,
                'Correo electrónico',
                'soporte@forracontrol.com',
              ),
              _buildHelpItem(
                colors,
                Icons.chat_bubble,
                'Chat en vivo',
                'Disponible 24/7',
              ),
              const SizedBox(height: 24),
              Text(
                'Preguntas frecuentes',
                style: GoogleFonts.nunitoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• ¿Cómo registrar nuevo ganado?\n'
                '• ¿Cómo gestionar el inventario de forraje?\n'
                '• ¿Cómo generar reportes?',
                style: GoogleFonts.nunitoSans(
                  color: colors.text.withAlpha((0.6 * 255).round()),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHelpItem(
    NeumorphicColors colors,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: colors.primary),
      title: Text(
        title,
        style: GoogleFonts.nunitoSans(
          fontWeight: FontWeight.w600,
          color: colors.text,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.nunitoSans(
          color: colors.text.withAlpha((0.6 * 255).round()),
        ),
      ),
      onTap: () {},
    );
  }

  void _showAboutModal(BuildContext context, NeumorphicColors colors) {
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: NeumorphicStyle.elevated(colors, radius: 40),
                padding: const EdgeInsets.all(12),
                child: Icon(Icons.agriculture, size: 40, color: colors.primary),
              ),
              const SizedBox(height: 16),
              Text(
                'ForraControl App',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: colors.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Versión 1.0.0',
                style: GoogleFonts.nunitoSans(
                  color: colors.text.withAlpha((0.6 * 255).round()),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'La mejor solución para gestionar el forraje y la ganadería.',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(color: colors.text),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                '© 2025 ForraControl. Todos los derechos reservados.',
                style: GoogleFonts.nunitoSans(
                  fontSize: 12,
                  color: colors.text.withAlpha((0.6 * 255).round()),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  /// Cierre de sesión neumórfico
  Future<void> _handleLogout(
    BuildContext context,
    NeumorphicColors colors,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            backgroundColor: colors.background,
            title: Text(
              '¿Cerrar sesión?',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: colors.text,
              ),
            ),
            content: Text(
              '¿Estás seguro de que deseas cerrar sesión?',
              style: GoogleFonts.nunitoSans(color: colors.text),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              GestureDetector(
                onTap: () => Navigator.of(dialogContext).pop(false),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: NeumorphicStyle.elevated(colors, radius: 8),
                  child: Text(
                    'Cancelar',
                    style: GoogleFonts.nunitoSans(color: colors.text),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => Navigator.of(dialogContext).pop(true),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: NeumorphicStyle.elevated(
                    colors,
                    radius: 8,
                    depth: 4,
                  ),
                  child: Text(
                    'Cerrar sesión',
                    style: GoogleFonts.nunitoSans(color: colors.error),
                  ),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.logout();
        if (context.mounted) Navigator.pushReplacementNamed(context, "/login");
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error al cerrar sesión: $e',
                style: GoogleFonts.nunitoSans(),
              ),
              backgroundColor: colors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    }
  }
}
