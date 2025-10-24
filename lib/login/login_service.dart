import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // Para detectar plataforma
import 'login_model.dart';

class LoginService {
  // URLs para diferentes plataformas
  static const String localhostUrl = 'http://localhost:8000';
  static const String localNetworkUrl = 'http://192.168.92.178:8000';

  // Elegir URL según la plataforma
  String get _baseUrl {
    // En web, usar localhost (se ejecuta en el navegador de la PC)
    if (kIsWeb) {
      return localhostUrl;
    }
    // En móvil/desktop, usar IP de red local
    return localNetworkUrl;
  }

  // Método para realizar el login
  Future<Map<String, dynamic>> login(LoginModel loginModel) async {
    final url = Uri.parse('$_baseUrl/users/api/loginUser/');
    print('LoginService: Intentando conectar a $url');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': loginModel.username,
              'password': loginModel.password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('LoginService: Status code: ${response.statusCode}');
      print('LoginService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Asumiendo que la respuesta es JSON con token o datos del usuario
        final data = jsonDecode(response.body);
        print('LoginService: Respuesta decodificada: $data');
        return data;
      } else {
        print(
            'LoginService: Error HTTP ${response.statusCode}: ${response.body}');
        throw Exception(
            'Error en el login: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('LoginService: Excepción en login: $e');
      rethrow;
    }
  }

  // Método para obtener un usuario aleatorio
  Future<Map<String, dynamic>> getRandomUser() async {
    final url = Uri.parse('$_baseUrl/users/api/getRandomUser/');
    print('LoginService: Intentando obtener usuario aleatorio de $url');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      print('LoginService: Status code getRandomUser: ${response.statusCode}');
      print('LoginService: Response body getRandomUser: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('LoginService: Usuario aleatorio decodificado: $data');
        return data;
      } else {
        print(
            'LoginService: Error HTTP getRandomUser ${response.statusCode}: ${response.body}');
        throw Exception(
            'Error al obtener usuario aleatorio: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('LoginService: Excepción en getRandomUser: $e');
      rethrow;
    }
  }
}
