import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';
  // Reemplaza este apiKey con el tuyo después de registrarte en OpenWeatherMap
  static const String apiKey =
      '419ddbc13e81de0bc95ad3542003e2fc'; // Obtén tu API key en openweathermap.org

  // Configuración para control de datos simulados/reales
  bool _useSimulatedData = true; // Cambia a false cuando tu API key esté activa

  // Getter para saber si estamos usando datos simulados
  bool get isUsingSimulatedData => _useSimulatedData;

  // Método para cambiar entre datos simulados y reales
  void toggleDataMode(bool useSimulated) {
    _useSimulatedData = useSimulated;
  }

  final Random _random = Random();

  Future<WeatherModel> getCurrentWeather(String city) async {
    // Si estamos usando datos simulados, devolver directamente
    if (_useSimulatedData) {
      return _getSimulatedWeather(city);
    }

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
          print('API key aún no activada, usando datos simulados por ahora');
          return _getSimulatedWeather(city);
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
    // Si estamos usando datos simulados, devolver directamente
    if (_useSimulatedData) {
      return _getSimulatedForecast(city);
    }

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
          print('API key aún no activada, usando datos simulados por ahora');
          return _getSimulatedForecast(city);
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

    // Personalizar según la ciudad
    final isCartagena = city.toLowerCase().contains('cartagena');
    final baseTemp = isCartagena ? 28.0 : 22.0;

    // Tendencias de clima para simular patrones realistas
    final weatherPatterns = [
      // Patrón estable
      ['☀️', '☀️', '🌤️', '☀️', '☀️'],
      // Patrón empeorando
      ['☀️', '🌤️', '⛅', '☁️', '🌧️'],
      // Patrón mejorando
      ['🌧️', '⛅', '🌤️', '☀️', '☀️'],
      // Patrón variable
      ['☀️', '⛅', '🌦️', '⛅', '☀️'],
      // Patrón con tormenta
      ['⛅', '🌩️', '�️', '⛅', '�️'],
    ];

    // Descripciones divertidas para cada ícono
    final iconDescriptions = {
      '☀️': [
        'Soleado como el escudo de Captain America',
        'Brillante como el reactor de Iron Man',
        'Resplandeciente como Vision'
      ],
      '🌤️': [
        'Parcialmente nublado, como el humor de Hulk',
        'Algunas nubes, estilo Thor mode'
      ],
      '⛅': [
        'Nubes intermitentes, como las apariciones de Loki',
        'Mitad sol, mitad nubes, como Two-Face'
      ],
      '☁️': [
        'Nublado como los pensamientos de Vision',
        'Gris como el traje de War Machine'
      ],
      '🌦️': [
        'Lluvia leve con sol, estilo Storm contenida',
        'Chispas como los rayos de Thor'
      ],
      '🌧️': [
        'Lluvia como las lágrimas de Black Widow',
        'Diluvio estilo Namor'
      ],
      '🌩️': [
        'Tormenta eléctrica, Thor está enojado',
        'Relámpagos tipo Shazam!'
      ],
    };

    // Elegir un patrón basado en la ciudad
    final cityHash = city.toLowerCase().codeUnits.fold(0, (a, b) => a + b);
    final pattern = weatherPatterns[cityHash % weatherPatterns.length];

    for (int i = 0; i < 5; i++) {
      // Temperatura con tendencia realista
      final tempVariation = isCartagena ? 4.0 : 6.0;
      final dayTemp = baseTemp +
          (sin(i * 0.8) * tempVariation) +
          (_random.nextDouble() * 2 - 1);

      // Obtener ícono del patrón
      final icon = pattern[i];

      // Obtener descripción aleatoria para el ícono
      final descriptions =
          iconDescriptions[icon] ?? ['Clima impredecible como Doctor Strange'];
      final description = descriptions[_random.nextInt(descriptions.length)];

      // Humedad relacionada con el ícono (más humedad con lluvia, menos con sol)
      double humidity = 60;
      if (icon.contains('☀️'))
        humidity = 50 + _random.nextDouble() * 15;
      else if (icon.contains('🌧️') || icon.contains('🌩️'))
        humidity = 75 + _random.nextDouble() * 15;
      else
        humidity = 60 + _random.nextDouble() * 20;

      // Viento variable pero relacionado con tormentas
      double windSpeed = 10;
      if (icon.contains('🌩️'))
        windSpeed = 20 + _random.nextDouble() * 10;
      else
        windSpeed = 8 + _random.nextDouble() * 12;

      // Precipitación basada en el ícono
      double precipitation = 0;
      if (icon.contains('🌧️'))
        precipitation = 2 + _random.nextDouble() * 3;
      else if (icon.contains('🌦️'))
        precipitation = 0.5 + _random.nextDouble() * 1.5;
      else if (icon.contains('🌩️'))
        precipitation = 3 + _random.nextDouble() * 5;
      else
        precipitation = _random.nextDouble() * 0.5;

      forecast.add(WeatherModel(
        cityName: _cleanCityName(city),
        temperature: dayTemp,
        description: description,
        icon: icon,
        humidity: humidity,
        windSpeed: windSpeed,
        feelsLike: dayTemp + (_random.nextDouble() * 4) - 2,
        precipitation: precipitation,
        pressure: 1010 + _random.nextInt(20) - 10,
        visibility: 7000 + _random.nextInt(5000),
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
    // Si estamos usando datos simulados, devolver directamente
    if (_useSimulatedData) {
      return _getSimulatedWeather('Ubicación actual');
    }

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

        // Si es error de API key
        if (response.statusCode == 401) {
          print('API key aún no activada, usando datos simulados por ahora');
        }

        return _getSimulatedWeather('Ubicación actual');
      }
    } catch (e) {
      print('Error al obtener clima por coords: $e');
      return _getSimulatedWeather('Ubicación actual');
    }
  }

  /// Verifica si la API key configurada es válida y establece el modo de datos automáticamente
  Future<Map<String, dynamic>> checkApiKeyAndSetMode(
      {bool autoSet = true}) async {
    try {
      // Intenta obtener el clima de una ciudad conocida
      final response = await http.get(
        Uri.parse('$baseUrl/weather?q=London&appid=$apiKey'),
        headers: {'User-Agent': 'OrusWeatherApp/1.0'},
      ).timeout(const Duration(seconds: 5));

      // Si el código es 200, la API key es válida
      final bool isValid = response.statusCode == 200;

      // Si autoSet está activado, cambiar el modo de datos
      if (autoSet) {
        toggleDataMode(!isValid); // Usar datos simulados si la API no es válida
      }

      String message = '';
      if (isValid) {
        message = 'API key válida. Usando datos reales del clima.';
      } else if (response.statusCode == 401) {
        message =
            'API key aún no activada. Puede tomar hasta 2 horas. Usando datos simulados por ahora.';
      } else {
        message =
            'Error al verificar API key: ${response.statusCode}. Usando datos simulados.';
      }

      return {
        'isValid': isValid,
        'message': message,
        'statusCode': response.statusCode,
        'usingSimulatedData': _useSimulatedData
      };
    } catch (e) {
      print('Error al verificar API key: $e');

      // Si autoSet está activado, cambiar a datos simulados en caso de error
      if (autoSet) {
        toggleDataMode(true);
      }

      return {
        'isValid': false,
        'message':
            'Error de conexión al verificar API key. Usando datos simulados.',
        'error': e.toString(),
        'usingSimulatedData': _useSimulatedData
      };
    }
  }

  /// Método anterior para compatibilidad
  Future<bool> isApiKeyValid() async {
    final result = await checkApiKeyAndSetMode(autoSet: false);
    return result['isValid'] as bool;
  }
}
