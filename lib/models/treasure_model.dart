import 'dart:math' as math;

class Treasure {
  final String id;
  final String creatorId;
  final String creatorName;
  final String title;
  final String description;
  final String? imageUrl;
  final double latitude;
  final double longitude;
  final String hint;
  final int difficulty; // 1-5
  final List<String> clues;
  bool isFound;
  String? foundBy;
  final DateTime createdAt;
  DateTime? foundAt;
  final int points;

  Treasure({
    required this.id,
    required this.creatorId,
    required this.creatorName,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.hint,
    required this.difficulty,
    required this.clues,
    this.isFound = false,
    this.foundBy,
    required this.createdAt,
    this.foundAt,
    required this.points,
  });

  factory Treasure.fromJson(Map<String, dynamic> json) {
    return Treasure(
      id: json['id'] ?? '',
      creatorId: json['creator_id'] ?? '',
      creatorName: json['creator_name'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      hint: json['hint'] ?? '',
      difficulty: json['difficulty'] ?? 1,
      clues: List<String>.from(json['clues'] ?? []),
      isFound: json['is_found'] ?? false,
      foundBy: json['found_by'],
      createdAt: DateTime.parse(json['created_at']),
      foundAt:
          json['found_at'] != null ? DateTime.parse(json['found_at']) : null,
      points: json['points'] ?? 10,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      'is_found': isFound,
      'found_by': foundBy,
      'created_at': createdAt.toIso8601String(),
      'found_at': foundAt?.toIso8601String(),
      'points': points,
    };
  }

  // Calcular distancia desde una posición
  double distanceFrom(double lat, double lng) {
    const double earthRadius = 6371000; // metros
    final double dLat = (lat - latitude) * (math.pi / 180);
    final double dLng = (lng - longitude) * (math.pi / 180);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(latitude * (math.pi / 180)) *
            math.cos(lat * (math.pi / 180)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  // Obtener pista basada en la distancia
  String getDistanceHint(double userLat, double userLng) {
    final distance = distanceFrom(userLat, userLng);

    if (distance < 10) {
      return "¡Estás muy cerca! Busca en los alrededores.";
    } else if (distance < 50) {
      return "Estás a menos de 50 metros. ¡Sigue buscando!";
    } else if (distance < 200) {
      return "Estás a pocos cientos de metros. ¡Calentito!";
    } else if (distance < 1000) {
      return "Estás a menos de 1km. ¡Continúa explorando!";
    } else {
      return "Estás algo lejos. ¡Sigue las pistas!";
    }
  }
}
