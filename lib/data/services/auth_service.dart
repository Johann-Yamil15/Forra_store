import 'package:forra_store/data/services/api_client.dart';

class LoginResult {
  final int idUsuario;
  final String nombre;
  final String username;
  final String rol; // 'admin' | 'trabajador'

  LoginResult({
    required this.idUsuario,
    required this.nombre,
    required this.username,
    required this.rol,
  });

  factory LoginResult.fromJson(Map<String, dynamic> json) => LoginResult(
    idUsuario: json['idUsuario'],
    nombre: json['nombre'],
    username: json['username'],
    rol: json['rol'],
  );
}

class AuthService {
  static Future<LoginResult> login(String username, String password) async {
    final data = await ApiClient.post('/api/auth/login', {
      'username': username,
      'password': password,
    });
    return LoginResult.fromJson(data as Map<String, dynamic>);
  }
}
