import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';
  // Reemplaza este apiKey con el tuyo después de registrarte en OpenWeatherMap
  static const String apiKey =
      '308047a37b50a9adfee7e3c80b12d201'; // Obtén tu API key en openweathermap.org

  final Random _random = Random();

  Future<WeatherModel> getCurrentWeather(String city) async {
    try {
      // Intentar usar la API real
      final response = await http.get(
        Uri.parse(
            '$baseUrl/weather?q=$city&appid=$apiKey&units=metric&lang=es'),
        headers: {'User-Agent': 'OrusWeatherApp/1.0'},
      ).timeout(
          const Duration(seconds: 10)); // Aumentamos el timeout a 10 segundos

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherModel.fromJson(data);
      } else {
        // Si la API devuelve un error
        print(
            'Error API OpenWeatherMap: ${response.statusCode} - ${response.body}');

        // Si es error de API key
        if (response.statusCode == 401) {
          throw Exception(
              'API key inválida. Por favor registra tu API key en openweathermap.org');
        }

        // Si la ciudad no existe
        if (response.statusCode == 404) {
          throw Exception('Ciudad no encontrada. Intenta con otra ciudad.');
        }

        // Otros errores, usar datos simulados como respaldo
        return _getSimulatedWeather(city);
      }
    } catch (e) {
      // Si hay error de conexión o cualquier otro error
      print('Error al obtener clima: $e');
      return _getSimulatedWeather(city);
    }
  }

  Future<List<WeatherModel>> getForecast(String city) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/forecast?q=$city&appid=$apiKey&units=metric&lang=es'),
        headers: {'User-Agent': 'OrusWeatherApp/1.0'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> list = data['list'];

        List<WeatherModel> forecast = [];
        for (int i = 0; i < list.length && forecast.length < 5; i += 8) {
          forecast.add(WeatherModel.fromJson(list[i]));
        }

        return forecast;
      } else {
        // Si la API devuelve un error
        print(
            'Error API OpenWeatherMap (Pronóstico): ${response.statusCode} - ${response.body}');

        // Si es error de API key
        if (response.statusCode == 401) {
          throw Exception(
              'API key inválida. Por favor registra tu API key en openweathermap.org');
        }

        // Si la ciudad no existe
        if (response.statusCode == 404) {
          throw Exception('Ciudad no encontrada. Intenta con otra ciudad.');
        }

        return _getSimulatedForecast(city);
      }
    } catch (e) {
      print('Error al obtener pronóstico: $e');
      return _getSimulatedForecast(city);
    }
  }

  WeatherModel _getSimulatedWeather(String city) {
    // Datos específicos para Cartagena o datos genéricos
    final isCartagena = city.toLowerCase().contains('cartagena');

    final temp = isCartagena
        ? 28 + _random.nextDouble() * 6
        : 20 + _random.nextDouble() * 15;
    final humidity = isCartagena
        ? 75 + _random.nextDouble() * 15
        : 50 + _random.nextDouble() * 30;
    final windSpeed = isCartagena
        ? 15 + _random.nextDouble() * 10
        : 10 + _random.nextDouble() * 20;
    final feelsLike = temp + (_random.nextDouble() * 4) - 2;

    // ¡Aquí viene la magia! Íconos creativos según las condiciones
    final weatherData =
        _getCreativeWeatherIcon(temp, humidity, windSpeed, feelsLike);

    return WeatherModel(
      cityName: _cleanCityName(city),
      temperature: temp,
      description: weatherData['description']!,
      icon: weatherData['icon']!,
      humidity: humidity,
      windSpeed: windSpeed,
      feelsLike: feelsLike,
      precipitation: _random.nextDouble() * 2,
      pressure: 1010 + _random.nextInt(20),
      visibility: 8000 + _random.nextInt(4000),
      dateTime: DateTime.now(),
    );
  }

  Map<String, String> _getCreativeWeatherIcon(
      double temp, double humidity, double windSpeed, double feelsLike) {
    // Condiciones extremas primero
    if (temp > 35) {
      return {
        'icon': '🔥', // Human Torch de los 4 Fantásticos
        'description': 'Modo Human Torch - ¡Está que arde!'
      };
    }

    if (feelsLike > 40) {
      return {
        'icon': '🥵', // Meme de calor extremo
        'description': 'Derritiéndose como un helado'
      };
    }

    if (windSpeed > 25) {
      return {
        'icon': '🌪️', // Storm de X-Men
        'description': 'Modo Storm - Vientos épicos'
      };
    }

    if (humidity > 85) {
      return {
        'icon': '💧', // Aquaman vibes
        'description': 'Modo Aquaman - Súper húmedo'
      };
    }

    // Condiciones tropicales de Cartagena
    if (temp >= 30 && humidity > 70) {
      final tropicalIcons = [
        {'icon': '�️', 'description': 'Perfecto para la playa'},
        {'icon': '🌴', 'description': 'Vibes caribeños total'},
        {'icon': '🦩', 'description': 'Rosa flamingo style'},
        {'icon': '🏄‍♂️', 'description': 'Silver Surfer approved'},
      ];
      return tropicalIcons[_random.nextInt(tropicalIcons.length)];
    }

    // Calor intenso
    if (temp >= 28 && temp < 30) {
      final hotIcons = [
        {'icon': '😎', 'description': 'Tony Stark coolness'},
        {'icon': '🔆', 'description': 'Brillo de Iron Man'},
        {'icon': '☀️', 'description': 'Soleado y genial'},
      ];
      return hotIcons[_random.nextInt(hotIcons.length)];
    }

    // Viento moderado
    if (windSpeed > 15 && windSpeed <= 25) {
      final windyIcons = [
        {'icon': '💨', 'description': 'Flash corriendo cerca'},
        {'icon': '🍃', 'description': 'Brisa refrescante'},
        {'icon': '🪁', 'description': 'Perfecto para volar cometas'},
      ];
      return windyIcons[_random.nextInt(windyIcons.length)];
    }

    // Humedad alta pero no extrema
    if (humidity > 70 && humidity <= 85) {
      final humidIcons = [
        {'icon': '💦', 'description': 'Iceman se está derritiendo'},
        {'icon': '🌊', 'description': 'Namor se siente en casa'},
        {'icon': '☁️', 'description': 'Nublado y húmedo'},
      ];
      return humidIcons[_random.nextInt(humidIcons.length)];
    }

    // Temperatura perfecta
    if (temp >= 22 && temp < 28) {
      final perfectIcons = [
        {'icon': '😊', 'description': 'Captain America approved'},
        {'icon': '👌', 'description': 'Perfecto como Wakanda'},
        {'icon': '🌤️', 'description': 'Parcialmente nublado'},
        {'icon': '🦸‍♂️', 'description': 'Clima de superhéroe'},
      ];
      return perfectIcons[_random.nextInt(perfectIcons.length)];
    }

    // Fresco
    if (temp < 22) {
      final coolIcons = [
        {'icon': '🧊', 'description': 'Iceman territory'},
        {'icon': '❄️', 'description': 'Frost Giant vibes'},
        {'icon': '🐧', 'description': 'Penguin approved'},
      ];
      return coolIcons[_random.nextInt(coolIcons.length)];
    }

    // Default fallback
    return {
      'icon': '🌟',
      'description': 'Clima misterioso como Doctor Strange'
    };
  }

  List<WeatherModel> _getSimulatedForecast(String city) {
    List<WeatherModel> forecast = [];
    final baseTemp = city.toLowerCase().contains('cartagena') ? 28.0 : 22.0;

    for (int i = 0; i < 5; i++) {
      final dayTemp = baseTemp + (_random.nextDouble() * 8) - 4;
      final weatherIcons = ['☀️', '🌤️', '☁️', '🌦️', '⛅'];
      final descriptions = [
        'Soleado',
        'Parcialmente nublado',
        'Nublado',
        'Lluvia ligera',
        'Variable'
      ];

      final conditionIndex = _random.nextInt(weatherIcons.length);

      forecast.add(WeatherModel(
        cityName: _cleanCityName(city),
        temperature: dayTemp,
        description: descriptions[conditionIndex],
        icon: weatherIcons[conditionIndex],
        humidity: 60 + _random.nextDouble() * 25,
        windSpeed: 10 + _random.nextDouble() * 15,
        feelsLike: dayTemp + (_random.nextDouble() * 4) - 2,
        precipitation: _random.nextDouble() * 3,
        dateTime: DateTime.now().add(Duration(days: i + 1)),
      ));
    }

    return forecast;
  }

  String _cleanCityName(String city) {
    // Limpiar el nombre de la ciudad para mostrar
    if (city.toLowerCase().contains('cartagena')) {
      return 'Cartagena, Colombia';
    }

    // Remover códigos de país y limpiar
    final cleaned = city.replaceAll(RegExp(r',\w{2}$'), '');
    return cleaned.split(',').first.trim();
  }

  Future<WeatherModel> getCurrentWeatherByCoords(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=es'),
        headers: {'User-Agent': 'OrusWeatherApp/1.0'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherModel.fromJson(data);
      } else {
        print(
            'Error API OpenWeatherMap (Coords): ${response.statusCode} - ${response.body}');
        return _getSimulatedWeather('Ubicación actual');
      }
    } catch (e) {
      print('Error al obtener clima por coords: $e');
      return _getSimulatedWeather('Ubicación actual');
    }
  }

  /// Verifica si la API key configurada es válida
  Future<bool> isApiKeyValid() async {
    try {
      // Intenta obtener el clima de una ciudad conocida
      final response = await http.get(
        Uri.parse('$baseUrl/weather?q=London&appid=$apiKey'),
        headers: {'User-Agent': 'OrusWeatherApp/1.0'},
      ).timeout(const Duration(seconds: 5));

      // Si el código es 200, la API key es válida
      return response.statusCode == 200;
    } catch (e) {
      print('Error al verificar API key: $e');
      return false;
    }
  }
}
