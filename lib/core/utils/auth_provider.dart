import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:forra_store/data/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  DateTime? _expiryDate;
  String? _username;
  String? _role;
  int? _idUsuario;

  bool get isLoggedIn => _isLoggedIn;
  String? get username => _username;
  String? get role => _role;
  int? get idUsuario => _idUsuario;

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('session_token');
    final expiryString = prefs.getString('session_expiry');
    _username = prefs.getString('session_username');
    _role = prefs.getString('session_role');
    _idUsuario = prefs.getInt('session_id_usuario');

    if (token != null && expiryString != null) {
      final expiry = DateTime.tryParse(expiryString);
      if (expiry != null && DateTime.now().isBefore(expiry)) {
        _isLoggedIn = true;
        _expiryDate = expiry;
      } else {
        await logout();
      }
    }
    notifyListeners();
  }

  /// Login contra la API. Lanza [ApiException] si las credenciales fallan.
  Future<void> loginWithApi(String username, String password) async {
    final result = await AuthService.login(username, password);
    final prefs = await SharedPreferences.getInstance();
    _expiryDate = DateTime.now().add(const Duration(hours: 8));

    await prefs.setString('session_token', 'api_session');
    await prefs.setString('session_expiry', _expiryDate!.toIso8601String());
    await prefs.setString('session_username', result.username);
    await prefs.setString('session_role', result.rol);
    await prefs.setInt('session_id_usuario', result.idUsuario);

    _idUsuario = result.idUsuario;
    _username = result.username;
    _role = result.rol;
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    // Solo las claves de sesión: prefs.clear() borraba TODO el almacenamiento
    // local (carrito, listas del admin, tema), no solo la sesión.
    await prefs.remove('session_token');
    await prefs.remove('session_expiry');
    await prefs.remove('session_username');
    await prefs.remove('session_role');
    await prefs.remove('session_id_usuario');

    _isLoggedIn = false;
    _expiryDate = null;
    _username = null;
    _role = null;
    _idUsuario = null;
    notifyListeners();
  }
}
