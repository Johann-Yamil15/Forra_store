import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  DateTime? _expiryDate;
  String? _username;
  String? _role;

  bool get isLoggedIn => _isLoggedIn;
  String? get username => _username;
  String? get role => _role;

  /// Inicializar sesión guardada
  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("session_token");
    final expiryString = prefs.getString("session_expiry");
    _username = prefs.getString("session_username");
    _role = prefs.getString("session_role");

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

  /// Guardar sesión (usuario + rol + token)
  Future<void> login(String token, String username, String role) async {
    final prefs = await SharedPreferences.getInstance();
    _expiryDate = DateTime.now().add(const Duration(hours: 8));

    await prefs.setString("session_token", token);
    await prefs.setString("session_expiry", _expiryDate!.toIso8601String());
    await prefs.setString("session_username", username);
    await prefs.setString("session_role", role);

    _username = username;
    _role = role;
    _isLoggedIn = true;
    notifyListeners();
  }

  /// Cerrar sesión
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _isLoggedIn = false;
    _expiryDate = null;
    _username = null;
    _role = null;
    notifyListeners();
  }
}
