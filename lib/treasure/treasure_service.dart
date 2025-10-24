import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/treasure_model.dart';

class TreasureService {
  // URLs para diferentes plataformas
  static const String localhostUrl = 'http://localhost:8000';
  static const String localNetworkUrl = 'http://192.168.92.178:8000';

  // Elegir URL según la plataforma
  String get _baseUrl {
    if (kIsWeb) {
      return localhostUrl;
    }
    return localNetworkUrl;
  }

  // Obtener tesoros cercanos a una ubicación
  Future<List<Treasure>> getNearbyTreasures(
      double lat, double lng, double radiusKm) async {
    try {
      final url = Uri.parse(
          '$_baseUrl/api/treasures/nearby/?lat=$lat&lng=$lng&radius=$radiusKm');
      print('TreasureService: Buscando tesoros en $url');

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final treasures = (data['treasures'] as List)
            .map((json) => Treasure.fromJson(json))
            .toList();
        print('TreasureService: Encontrados ${treasures.length} tesoros');
        return treasures;
      } else {
        print(
            'TreasureService: Error ${response.statusCode}: ${response.body}');
        throw Exception('Error al obtener tesoros cercanos');
      }
    } catch (e) {
      print('TreasureService: Error en getNearbyTreasures: $e');
      rethrow;
    }
  }

  // Crear un nuevo tesoro
  Future<Treasure> createTreasure({
    required String creatorId,
    required String creatorName,
    required String title,
    required String description,
    String? imageUrl,
    required double latitude,
    required double longitude,
    required String hint,
    required int difficulty,
    required List<String> clues,
    required int points,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/api/treasures/');
      print('TreasureService: Creando tesoro en $url');

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'creator_id': creatorId,
              'creator_name': creatorName,
              'title': title,
              'description': description,
              'image_url': imageUrl,
              'latitude': latitude,
              'longitude': longitude,
              'hint': hint,
              'difficulty': difficulty,
              'clues': clues,
              'points': points,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('TreasureService: Tesoro creado exitosamente');
        return Treasure.fromJson(data);
      } else {
        print(
            'TreasureService: Error ${response.statusCode}: ${response.body}');
        throw Exception('Error al crear tesoro');
      }
    } catch (e) {
      print('TreasureService: Error en createTreasure: $e');
      rethrow;
    }
  }

  // Reclamar un tesoro encontrado
  Future<bool> claimTreasure(String treasureId, String userId) async {
    try {
      final url = Uri.parse('$_baseUrl/api/treasures/$treasureId/claim/');
      print('TreasureService: Reclamando tesoro $treasureId');

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'user_id': userId,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        print('TreasureService: Tesoro reclamado exitosamente');
        return true;
      } else {
        print(
            'TreasureService: Error ${response.statusCode}: ${response.body}');
        return false;
      }
    } catch (e) {
      print('TreasureService: Error en claimTreasure: $e');
      return false;
    }
  }

  // Obtener tesoros creados por un usuario
  Future<List<Treasure>> getUserTreasures(String userId) async {
    try {
      final url = Uri.parse('$_baseUrl/api/treasures/user/$userId/');
      print('TreasureService: Obteniendo tesoros del usuario $userId');

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final treasures = (data['treasures'] as List)
            .map((json) => Treasure.fromJson(json))
            .toList();
        return treasures;
      } else {
        print(
            'TreasureService: Error ${response.statusCode}: ${response.body}');
        throw Exception('Error al obtener tesoros del usuario');
      }
    } catch (e) {
      print('TreasureService: Error en getUserTreasures: $e');
      rethrow;
    }
  }

  // Obtener estadísticas del usuario
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      final url = Uri.parse('$_baseUrl/api/users/$userId/stats/');
      print('TreasureService: Obteniendo estadísticas del usuario $userId');

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('TreasureService: Respuesta del servidor: $data');
        // Extraer el objeto 'stats' de la respuesta
        if (data['success'] == true && data['stats'] != null) {
          final stats = data['stats'] as Map<String, dynamic>;
          print('TreasureService: Estadísticas extraídas: $stats');
          return stats;
        } else {
          print('TreasureService: Respuesta inválida del servidor: $data');
          return {
            'treasures_created': 0,
            'treasures_found': 0,
            'total_points': 0,
            'rank': 'Novato'
          };
        }
      } else {
        print(
            'TreasureService: Error ${response.statusCode}: ${response.body}');
        return {
          'treasures_created': 0,
          'treasures_found': 0,
          'total_points': 0,
          'rank': 'Novato'
        };
      }
    } catch (e) {
      print('TreasureService: Error en getUserStats: $e');
      return {
        'treasures_created': 0,
        'treasures_found': 0,
        'total_points': 0,
        'rank': 'Novato'
      };
    }
  }
}
