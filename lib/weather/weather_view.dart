import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'dart:math'; // Importar para usar min()
import '../models/weather_model.dart';

import 'weather_service.dart';

class WeatherView extends StatefulWidget {
  const WeatherView({super.key});

  @override
  State<WeatherView> createState() => _WeatherViewState();
}

class _WeatherViewState extends State<WeatherView>
    with SingleTickerProviderStateMixin {
  final WeatherService _weatherService = WeatherService();
  final TextEditingController _cityController = TextEditingController();
  WeatherModel? _currentWeather;
  List<WeatherModel>? _forecast;
  bool _isLoading = false;
  String? _error;
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Variables para el autocompletado
  List<String> _suggestedCities = [];
  final List<String> _popularCities = [
    // Ciudades colombianas (nombres con tildes para mostrar correctamente)
    'Bogotá',
    'Medellín',
    'Cali',
    'Barranquilla',
    'Cartagena',
    'Santa Marta',
    'Bucaramanga',
    'Pereira',
    'Manizales',
    'Armenia',
    'Villavicencio',
    'Pasto',
    'Neiva',
    'Popayán',
    'Tunja',
    'Valledupar',
    'Montería',
    'Sincelejo',
    // Ciudades internacionales populares
    'Ciudad de México',
    'Guadalajara',
    'Monterrey',
    'Cancún',
    'Madrid',
    'Barcelona',
    'París',
    'Londres',
    'Roma',
    'Berlín',
    'Tokio',
    'Nueva York',
    'Miami',
    'Los Ángeles',
    'Buenos Aires',
    'Santiago',
    'Lima',
    'Quito',
    'Río de Janeiro',
    'São Paulo',
    'Caracas',
    'La Habana',
    'Toronto'
  ];
  bool _showSuggestions = false;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Configurar listener para autocompletado
    _cityController.addListener(_onSearchChanged);

    // Configurar listener para el foco (muestra/oculta sugerencias)
    _searchFocusNode.addListener(() {
      print('=== FOCUS CHANGE ===');
      print('Nuevo foco: ${_searchFocusNode.hasFocus}');

      if (_searchFocusNode.hasFocus) {
        // Cuando recibe foco, mostrar sugerencias inmediatamente
        _onSearchChanged();
      } else {
        // Cuando pierde foco, ocultar sugerencias después de un delay
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) {
            setState(() {
              _showSuggestions = false;
            });
            print('Ocultando sugerencias por pérdida de foco');
          }
        });
      }
      print('====================');
    });

    // Iniciar con un valor predeterminado
    _getWeatherForCity("Cartagena");
  }

  @override
  void dispose() {
    _cityController.removeListener(_onSearchChanged);
    _cityController.dispose();
    _animationController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // Método para filtrar sugerencias cuando cambia el texto
  void _onSearchChanged() {
    final query = _cityController.text.trim();

    print('=== _onSearchChanged ===');
    print('Texto: "$query"');
    print('Focus: ${_searchFocusNode.hasFocus}');
    print('ShowSuggestions actual: $_showSuggestions');

    // Filtrar ciudades
    List<String> suggestions = [];

    if (query.isEmpty) {
      suggestions =
          _popularCities.take(5).toList(); // Solo las primeras 5 para prueba
    } else {
      final normalizedQuery = _normalizeText(query).toLowerCase();
      suggestions = _popularCities
          .where((city) =>
              _normalizeText(city).toLowerCase().contains(normalizedQuery))
          .take(5)
          .toList();
    }

    print('Sugerencias encontradas: ${suggestions.length}');
    print('Lista de sugerencias: $suggestions');

    // FORZAR actualización del estado
    setState(() {
      _suggestedCities = suggestions;
      _showSuggestions = suggestions.isNotEmpty;
    });

    print('ShowSuggestions después de setState: $_showSuggestions');
    print('========================');
  } // Método para seleccionar una ciudad de las sugerencias

  void _selectCity(String city) {
    print('Seleccionando ciudad: $city');

    // Primero ocultar las sugerencias para una transición suave
    setState(() {
      _showSuggestions = false;
    });

    // Actualizar el texto inmediatamente
    _cityController.text = city;

    // Quitar el foco del campo de texto
    _searchFocusNode.unfocus();

    // Buscar el clima para la ciudad seleccionada
    _getWeatherForCity(city);

    print('Ciudad seleccionada: $city');
  }

  // Método para normalizar texto (eliminar tildes y caracteres especiales)
  String _normalizeText(String text) {
    // Mapa de reemplazos para caracteres especiales
    final Map<String, String> replacements = {
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'Á': 'A',
      'É': 'E',
      'Í': 'I',
      'Ó': 'O',
      'Ú': 'U',
      'ñ': 'n',
      'Ñ': 'N',
      'ü': 'u',
      'Ü': 'U',
    };

    String normalized = text;
    replacements.forEach((key, value) {
      normalized = normalized.replaceAll(key, value);
    });

    return normalized;
  } // Método para construir texto con la parte buscada resaltada

  Widget _buildHighlightedText(String text, String query) {
    if (query.isEmpty) {
      return Text(
        text,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 16,
        ),
      );
    }

    // Normalizar tanto el texto como la consulta para buscar sin acentos
    final normalizedText = _normalizeText(text).toLowerCase();
    final normalizedQuery = _normalizeText(query).toLowerCase();

    if (!normalizedText.contains(normalizedQuery)) {
      return Text(
        text,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 16,
        ),
      );
    }

    final int startIndex = normalizedText.indexOf(normalizedQuery);
    // Asegurar que endIndex no exceda el tamaño del texto
    final int endIndex = min(startIndex + normalizedQuery.length, text.length);

    return RichText(
      text: TextSpan(
        children: [
          // Texto antes del match
          if (startIndex > 0)
            TextSpan(
              text: text.substring(0, startIndex),
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
              ),
            ),

          // Texto resaltado (match) con mejor visualización
          TextSpan(
            text: text.substring(startIndex, endIndex),
            style: GoogleFonts.inter(
              color: Colors.black, // Texto en negro para mejor contraste
              fontWeight: FontWeight.bold,
              fontSize: 16,
              backgroundColor: Colors.yellowAccent
                  .withOpacity(0.7), // Resaltado amarillo más visible
            ),
          ),

          // Texto después del match
          if (endIndex < text.length)
            TextSpan(
              text: text.substring(endIndex),
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _getWeatherForCity(String city) async {
    if (city.isEmpty) {
      setState(() {
        _error = "Por favor ingresa el nombre de una ciudad";
      });
      return;
    }

    // Eliminar tildes y caracteres especiales para mayor compatibilidad con la API
    final normalizedCity = _normalizeText(city);
    print('Buscando clima para: $normalizedCity');

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final weather = await _weatherService.getCurrentWeather(normalizedCity);
      final forecast = await _weatherService.getForecast(normalizedCity);

      setState(() {
        _currentWeather = weather;
        _forecast = forecast;
        _isLoading = false;
        _error = null;
      });

      _animationController.reset();
      _animationController.forward();
    } catch (e) {
      setState(() {
        _error = "Error al obtener el clima: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  // Diálogo para configurar API key y modo de datos
  void _showApiKeySettingsDialog() {
    bool useSimulatedData = _weatherService.isUsingSimulatedData;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(
              'Configuración de API',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'La API key puede tardar hasta 2 horas en activarse después del registro.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),

                // Selector de modo de datos
                Row(
                  children: [
                    Text(
                      'Usar datos simulados:',
                      style: GoogleFonts.inter(),
                    ),
                    const Spacer(),
                    Switch(
                      value: useSimulatedData,
                      activeColor: const Color(0xFF4052B6),
                      onChanged: (value) {
                        setDialogState(() {
                          useSimulatedData = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Cancelar',
                  style: GoogleFonts.inter(
                    color: Colors.grey[700],
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);

                  // Mostrar indicador de carga
                  setState(() {
                    _isLoading = true;
                  });

                  // Aplicar cambios de modo de datos
                  _weatherService.toggleDataMode(useSimulatedData);

                  // Primero, actualizar el clima con el nuevo modo (esto es síncrono)
                  final String cityToSearch = _cityController.text.isNotEmpty
                      ? _cityController.text
                      : 'Cartagena';

                  // Luego, si estamos usando datos reales, verificar la API key
                  if (!useSimulatedData) {
                    // Iniciar la actualización del clima primero
                    _getWeatherForCity(cityToSearch);

                    // Luego, verificar la API key (esto es asíncrono)
                    try {
                      final result =
                          await _weatherService.checkApiKeyAndSetMode();

                      // Solo mostrar el SnackBar si el widget aún está montado
                      if (mounted) {
                        // Usar Future.microtask para asegurar que esto se ejecute en un momento seguro
                        Future.microtask(() {
                          // Verificar nuevamente si el widget sigue montado
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result['message']),
                                backgroundColor: result['isValid']
                                    ? Colors.green
                                    : Colors.orange,
                                duration: const Duration(seconds: 5),
                              ),
                            );
                          }
                        });
                      }
                    } catch (e) {
                      print('Error al verificar API key: $e');
                    }
                  } else {
                    // Si usamos datos simulados, simplemente actualizar el clima
                    _getWeatherForCity(cityToSearch);
                  }
                },
                child: Text(
                  'Guardar y Verificar',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF4052B6),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Cerrar el teclado y las sugerencias al tocar fuera
        FocusScope.of(context).unfocus();
        setState(() {
          _showSuggestions = false;
        });
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF4052B6),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // Título con estilo y botón de configuración
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Clima',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.settings,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: _showApiKeySettingsDialog,
                      tooltip: 'Configurar API',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Consulta el clima en cualquier ciudad',
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
                // Indicador de modo simulado
                if (_weatherService.isUsingSimulatedData)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Usando datos simulados',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),

                // Buscador con estilo moderno y autocompletado
                Stack(
                  children: [
                    // Campo de búsqueda
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _cityController,
                                  focusNode: _searchFocusNode,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Buscar ciudad...',
                                    hintStyle: GoogleFonts.inter(
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                  ),
                                  onChanged: (value) {
                                    print('TextField onChanged: "$value"');
                                    _onSearchChanged();
                                  },
                                  onSubmitted: (value) {
                                    setState(() {
                                      _showSuggestions = false;
                                    });
                                    _getWeatherForCity(value);
                                  },
                                  // Mostrar sugerencias al dar clic
                                  onTap: () {
                                    print('TextField onTap ejecutado');
                                    // Mostrar sugerencias inmediatamente
                                    _onSearchChanged();
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.search_rounded,
                                  color: Colors.white,
                                ),
                                onPressed: () =>
                                    _getWeatherForCity(_cityController.text),
                              ),
                              // BOTÓN DE PRUEBA TEMPORAL - ELIMINAR DESPUÉS DE DEPURAR
                              IconButton(
                                icon: const Icon(
                                  Icons.visibility,
                                  color: Colors.yellow,
                                  size: 20,
                                ),
                                onPressed: () {
                                  print('=== BOTÓN DE PRUEBA PRESIONADO ===');
                                  setState(() {
                                    _showSuggestions = !_showSuggestions;
                                    _suggestedCities = [
                                      'Bogotá',
                                      'Medellín',
                                      'Cali',
                                      'Barranquilla',
                                      'Cartagena'
                                    ];
                                  });
                                  print('ShowSuggestions: $_showSuggestions');
                                  print('SuggestedCities: $_suggestedCities');
                                  print(
                                      '======================================');
                                },
                                tooltip: 'Mostrar/Ocultar sugerencias',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Lista de sugerencias - VERSIÓN SIMPLIFICADA Y MUY VISIBLE
                    if (_showSuggestions && _suggestedCities.isNotEmpty)
                      Positioned(
                        top: 65,
                        left: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors
                                .white, // FONDO BLANCO COMPLETAMENTE OPACO
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          constraints: const BoxConstraints(maxHeight: 250),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Encabezado
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Ciudades sugeridas (${_suggestedCities.length})',
                                  style: GoogleFonts.inter(
                                    color: Colors.blue.shade800,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // Lista de ciudades
                              Flexible(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  itemCount: _suggestedCities.length,
                                  itemBuilder: (context, index) {
                                    final city = _suggestedCities[index];
                                    return InkWell(
                                      onTap: () {
                                        print('CITY TAPPED: $city');
                                        _selectCity(city);
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.grey.shade200,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.location_on,
                                              color: Colors.blue.shade600,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                city,
                                                style: GoogleFonts.inter(
                                                  color: Colors.black87,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 24),

                // Contenido principal
                Expanded(
                  child: _buildMainContent(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_isLoading) {
      return _buildLoadingIndicator();
    }

    if (_error != null) {
      return _buildErrorMessage();
    }

    if (_currentWeather == null) {
      return Center(
        child: Text(
          'Busca una ciudad para ver su clima',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _animation,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tarjeta principal del clima actual
            _buildWeatherCard(),

            const SizedBox(height: 24),

            // Pronóstico para los próximos días
            if (_forecast != null && _forecast!.isNotEmpty)
              _buildForecastSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Consultando el clima...',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.red.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.red,
              size: 50,
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: GoogleFonts.inter(
                color: Colors.red,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF4052B6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () => _getWeatherForCity(_cityController.text),
              child: Text(
                'Reintentar',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard() {
    final weather = _currentWeather!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weather.cityName,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${weather.dateTime.day}/${weather.dateTime.month}/${weather.dateTime.year} · ${weather.dateTime.hour.toString().padLeft(2, '0')}:${weather.dateTime.minute.toString().padLeft(2, '0')}',
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  // Ícono animado que pulsa ligeramente
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0.8, end: 1.0),
                    duration: const Duration(seconds: 2),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Text(
                          weather.icon,
                          style: const TextStyle(fontSize: 50),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${weather.temperature.toStringAsFixed(1)}°',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weather.description,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                          ),
                        ),
                        Text(
                          'Sensación térmica: ${weather.feelsLike.toStringAsFixed(1)}°',
                          style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Detalles adicionales
              _buildWeatherDetails(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherDetails() {
    final weather = _currentWeather!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildDetailItem(
            Icons.water_drop_outlined,
            '${weather.humidity.toStringAsFixed(0)}%',
            'Humedad',
          ),
          _buildDetailItem(
            Icons.air,
            '${weather.windSpeed.toStringAsFixed(1)} km/h',
            'Viento',
          ),
          _buildDetailItem(
            Icons.visibility_outlined,
            '${(weather.visibility / 1000).toStringAsFixed(1)} km',
            'Visibilidad',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildForecastSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Próximos días',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _forecast!.length,
            itemBuilder: (context, index) {
              final day = _forecast![index];
              return Container(
                margin: EdgeInsets.only(
                    right: index < _forecast!.length - 1 ? 12 : 0),
                padding: const EdgeInsets.all(16),
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${day.dateTime.day}/${day.dateTime.month}',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      day.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                    Text(
                      '${day.temperature.toStringAsFixed(1)}°',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
