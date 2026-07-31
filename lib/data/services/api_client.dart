import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:forra_store/core/constants/api_constants.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => message;
}

class ApiClient {
  static final _client = http.Client();

  static Map<String, String> _headers() => {
    HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
    HttpHeaders.acceptHeader: 'application/json',
  };

  static Uri _uri(String path) => Uri.parse('${ApiConstants.baseUrl}$path');

  // Parsea el sobre { ok, data } y extrae data (o lanza excepción)
  static dynamic _parse(http.Response res) {
    if (res.statusCode == 204) return null;
    final body = jsonDecode(utf8.decode(res.bodyBytes));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (body is Map && body.containsKey('ok')) {
        if (body['ok'] == true) return body['data'];
        throw ApiException(body['error']?.toString() ?? 'Error desconocido', statusCode: res.statusCode);
      }
      return body; // respuesta sin envoltorio
    }
    final msg = body is Map ? (body['error'] ?? body['message'] ?? res.reasonPhrase) : res.reasonPhrase;
    throw ApiException(msg?.toString() ?? 'Error ${res.statusCode}', statusCode: res.statusCode);
  }

  static Future<dynamic> get(String path) async {
    final res = await _client.get(_uri(path), headers: _headers()).timeout(ApiConstants.timeout);
    return _parse(res);
  }

  static Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final res = await _client.post(_uri(path), headers: _headers(), body: jsonEncode(body)).timeout(ApiConstants.timeout);
    return _parse(res);
  }

  static Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final res = await _client.put(_uri(path), headers: _headers(), body: jsonEncode(body)).timeout(ApiConstants.timeout);
    return _parse(res);
  }

  static Future<dynamic> patch(String path, Map<String, dynamic> body) async {
    final res = await _client.patch(_uri(path), headers: _headers(), body: jsonEncode(body)).timeout(ApiConstants.timeout);
    return _parse(res);
  }

  static Future<dynamic> delete(String path) async {
    final res = await _client.delete(_uri(path), headers: _headers()).timeout(ApiConstants.timeout);
    return _parse(res);
  }
}
