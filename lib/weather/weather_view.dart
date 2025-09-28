import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/weather_model.dart';
import 'weather_service.dart';

class WeatherView extends StatefulWidget {
  const WeatherView({super.key});

  @override
  State<WeatherView> createState() => _WeatherViewState();
}

class _WeatherViewState extends State<WeatherView> {
  final WeatherService _weatherService = WeatherService();
  final TextEditingController _cityController = TextEditingController();
  
  WeatherModel? _currentWeather;
  List<WeatherModel>? _forecast;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDefaultWeather();
  }

  Future<void> _loadDefaultWeather() async {
    await _searchWeather('Cartagena,CO');
  }

  Future<void> _searchWeather(String city) async {
    if (city.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final weather = await _weatherService.getCurrentWeather(city);
      final forecast = await _weatherService.getForecast(city);
      
      setState(() {
        _currentWeather = weather;
        _forecast = forecast;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F11),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _searchWeather(_currentWeather?.cityName ?? 'Cartagena,CO'),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Buscador de ciudad
                _buildCitySearch(),
                const SizedBox(height: 24),

                if (_isLoading)
                  _buildLoadingIndicator()
                else if (_error != null)
                  _buildErrorWidget()
                else if (_currentWeather != null) ...[
                  // Información principal del clima
                  _buildMainWeatherCard(),
                  const SizedBox(height: 20),
                  
                  // Métricas detalladas
                  _buildWeatherMetrics(),
                  const SizedBox(height: 20),
                  
                  // Pronóstico
                  if (_forecast != null && _forecast!.isNotEmpty)
                    _buildForecastSection(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCitySearch() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.indigo.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _cityController,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.indigo.shade800,
            ),
            decoration: InputDecoration(
              hintText: 'Buscar ciudad...',
              hintStyle: GoogleFonts.inter(color: Colors.grey[500]),
              prefixIcon: Icon(Icons.search, color: Colors.blue.shade600),
              suffixIcon: IconButton(
                icon: Icon(Icons.send, color: Colors.blue.shade600),
                onPressed: () => _searchWeather(_cityController.text.trim()),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            onSubmitted: (value) => _searchWeather(value.trim()),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Obteniendo datos del clima...',
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 48),
          const SizedBox(height: 16),
          Text(
            'Error al obtener datos',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Error desconocido',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.red.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _searchWeather(_cityController.text.trim().isEmpty 
                ? 'Cartagena,CO' 
                : _cityController.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildMainWeatherCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade400,
            Colors.indigo.shade500,
            Colors.purple.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _currentWeather!.cityName,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _currentWeather!.icon,
                style: const TextStyle(fontSize: 80),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_currentWeather!.temperature.round()}°C',
                    style: GoogleFonts.inter(
                      fontSize: 64,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _currentWeather!.description.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detalles del Clima',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.4,
          children: [
            _buildMetricCard(
              icon: Icons.thermostat,
              title: 'Sensación Térmica',
              value: '${_currentWeather!.feelsLike.round()}°C',
              color: Colors.orange,
            ),
            _buildMetricCard(
              icon: Icons.water_drop,
              title: 'Humedad',
              value: '${_currentWeather!.humidity.round()}%',
              color: Colors.blue,
            ),
            _buildMetricCard(
              icon: Icons.air,
              title: 'Viento',
              value: '${_currentWeather!.windSpeed.round()} km/h',
              color: Colors.teal,
            ),
            _buildMetricCard(
              icon: Icons.umbrella,
              title: 'Precipitación',
              value: '${_currentWeather!.precipitation.toStringAsFixed(1)} mm',
              color: Colors.indigo,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    // Obtenemos el fondo creativo basado en el tipo de métrica y el valor
    final backgroundData = _getCreativeCardBackground(title, value);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: backgroundData['gradient'],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Emoji/ícono temático de fondo
          Positioned(
            top: -10,
            right: -10,
            child: Opacity(
              opacity: 0.2,
              child: Text(
                backgroundData['backgroundEmoji'],
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),
          // Contenido principal
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              // Mensaje temático
              const SizedBox(height: 4),
              Text(
                backgroundData['themeMessage'],
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: Colors.white60,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getCreativeCardBackground(String metricType, String value) {
    final numericValue = double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    
    switch (metricType) {
      case 'Sensación Térmica':
        if (numericValue > 35) {
          return {
            'gradient': LinearGradient(
              colors: [Colors.red.shade600, Colors.orange.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            'backgroundEmoji': '🔥',
            'themeMessage': 'Human Torch mode!',
          };
        } else if (numericValue > 30) {
          return {
            'gradient': LinearGradient(
              colors: [Colors.orange.shade500, Colors.red.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            'backgroundEmoji': '😎',
            'themeMessage': 'Tony Stark vibes',
          };
        } else if (numericValue < 15) {
          return {
            'gradient': LinearGradient(
              colors: [Colors.cyan.shade600, Colors.blue.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            'backgroundEmoji': '🧊',
            'themeMessage': 'Iceman territory',
          };
        }
        break;
        
      case 'Humedad':
        if (numericValue > 85) {
          return {
            'gradient': LinearGradient(
              colors: [Colors.teal.shade600, Colors.cyan.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            'backgroundEmoji': '🌊',
            'themeMessage': 'Aquaman vibes',
          };
        } else if (numericValue > 70) {
          return {
            'gradient': LinearGradient(
              colors: [Colors.blue.shade500, Colors.teal.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            'backgroundEmoji': '💧',
            'themeMessage': 'Namor approved',
          };
        }
        break;
        
      case 'Viento':
        if (numericValue > 25) {
          return {
            'gradient': LinearGradient(
              colors: [Colors.grey.shade600, Colors.blueGrey.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            'backgroundEmoji': '🌪️',
            'themeMessage': 'Storm unleashed',
          };
        } else if (numericValue > 15) {
          return {
            'gradient': LinearGradient(
              colors: [Colors.lightBlue.shade500, Colors.blue.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            'backgroundEmoji': '💨',
            'themeMessage': 'Flash running by',
          };
        }
        break;
        
      case 'Precipitación':
        if (numericValue > 10) {
          return {
            'gradient': LinearGradient(
              colors: [Colors.indigo.shade700, Colors.purple.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            'backgroundEmoji': '⛈️',
            'themeMessage': 'Thor incoming!',
          };
        } else if (numericValue > 2) {
          return {
            'gradient': LinearGradient(
              colors: [Colors.blue.shade600, Colors.indigo.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            'backgroundEmoji': '🌧️',
            'themeMessage': 'Rain dance time',
          };
        }
        break;
    }
    
    // Default fallback con tema de superhéroe
    return {
      'gradient': LinearGradient(
        colors: [Colors.purple.shade500, Colors.indigo.shade600],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'backgroundEmoji': '⭐',
      'themeMessage': 'Hero weather',
    };
  }

  Widget _buildForecastSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pronóstico de 5 Días',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        
        Container(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _forecast!.length,
            itemBuilder: (context, index) {
              final weather = _forecast![index];
              final dayName = _getDayName(weather.dateTime);
              
              return Container(
                width: 100,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dayName,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      weather.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                    Text(
                      '${weather.temperature.round()}°',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.white,
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

  String _getDayName(DateTime date) {
    final days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return days[date.weekday - 1];
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }
}
