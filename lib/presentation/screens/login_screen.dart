import 'package:flutter/material.dart';
import 'package:forra_store/core/utils/AuthProvider.dart';
import 'package:forra_store/core/utils/validators.dart';
import 'package:forra_store/presentation/screens/main/main_admin.dart';
import 'package:forra_store/presentation/screens/main/main_trabajador.dart';
import 'package:provider/provider.dart';

import '../../core/theme/neumorphic_colors.dart';
import '../../core/utils/neumorphic_style.dart';

import '../widgets/neumorphic_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _obscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? NeumorphicColors.dark : NeumorphicColors.light;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: NeumorphicStyle.elevated(colors),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Forra Store',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),

                  const SizedBox(height: 32),

                  _input(
                    controller: _userCtrl,
                    hint: 'Usuario',
                    colors: colors,
                    validator: Validators.validateUsername,
                    icon: Icons.person_outline,
                  ),

                  const SizedBox(height: 16),

                  _input(
                    controller: _passCtrl,
                    hint: 'Contraseña',
                    colors: colors,
                    validator: Validators.validatePassword,
                    obscure: _obscure,
                    icon: Icons.lock_outline,
                    suffix: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: colors.text.withOpacity(0.6),
                      ),
                      onPressed: () {
                        setState(() => _obscure = !_obscure);
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  NeumorphicButton(
                    text: _isLoading ? 'CARGANDO...' : 'INGRESAR',
                    colors: colors,
                    onTap: () {
                      if (_isLoading) return;
                      _login();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
    required NeumorphicColors colors,
    String? Function(String?)? validator,
    bool obscure = false,
    IconData? icon,
    Widget? suffix,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: NeumorphicStyle.inset(colors),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        validator: validator,
        style: TextStyle(color: colors.text),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(color: colors.text.withOpacity(0.6)),
          icon: icon != null ? Icon(icon, color: colors.primary) : null,
          suffixIcon: suffix,
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    final username = _userCtrl.text.trim();
    final password = _passCtrl.text.trim();

    if (username == 'usuario' && password == '123456789') {
      final auth = Provider.of<AuthProvider>(context, listen: false);

      final role = username == 'admin' ? 'admin' : 'trabajador';

      await auth.login('token_simulado', username, role);

      _snack('Login correcto', success: true);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) =>
                  role == 'admin'
                      ? const MainScreenAdmin()
                      : const MainScreenTrabajador(),
        ),
      );
    } else {
      _snack('Usuario o contraseña incorrectos');
    }
  }

  void _snack(String text, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: success ? Colors.green : Colors.red.shade600,
      ),
    );
  }
}
