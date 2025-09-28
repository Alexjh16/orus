class WeatherModel {
  final String cityName;
  final double temperature;
  final String description;
  final String icon;
  final double humidity;
  final double windSpeed;
  final double feelsLike;
  final double precipitation;
  final int pressure;
  final int visibility;
  final DateTime dateTime;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.feelsLike,
    this.precipitation = 0.0,
    this.pressure = 1013,
    this.visibility = 10000,
    DateTime? dateTime,
  }) : dateTime = dateTime ?? DateTime.now();

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'] ?? 'Desconocida',
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['description'] ?? 'Sin descripción',
      icon: _getWeatherIcon(json['weather'][0]['main']),
      humidity: (json['main']['humidity'] as num).toDouble(),
      windSpeed: (json['wind']['speed'] as num).toDouble() * 3.6, // m/s a km/h
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      precipitation: _getPrecipitation(json),
      pressure: json['main']['pressure'] ?? 1013,
      visibility: json['visibility'] ?? 10000,
      dateTime: json['dt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000)
          : DateTime.now(),
    );
  }

  static String _getWeatherIcon(String weatherMain) {
    switch (weatherMain.toLowerCase()) {
      case 'clear':
        return '☀️';
      case 'clouds':
        return '☁️';
      case 'rain':
        return '🌧️';
      case 'drizzle':
        return '🌦️';
      case 'thunderstorm':
        return '⛈️';
      case 'snow':
        return '❄️';
      case 'mist':
      case 'fog':
        return '🌫️';
      case 'haze':
        return '🌫️';
      default:
        return '��️';
    }
  }

  static double _getPrecipitation(Map<String, dynamic> json) {
    if (json.containsKey('rain') && json['rain'] != null) {
      return (json['rain']['1h'] ?? json['rain']['3h'] ?? 0.0).toDouble();
    }
    if (json.containsKey('snow') && json['snow'] != null) {
      return (json['snow']['1h'] ?? json['snow']['3h'] ?? 0.0).toDouble();
    }
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'cityName': cityName,
      'temperature': temperature,
      'description': description,
      'icon': icon,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'feelsLike': feelsLike,
      'precipitation': precipitation,
      'pressure': pressure,
      'visibility': visibility,
      'dateTime': dateTime.millisecondsSinceEpoch,
    };
  }
}
