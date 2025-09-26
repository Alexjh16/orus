import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Datos simulados del clima
  final Map<String, dynamic> _weatherData = {
    'city': 'Lima, Perú',
    'temperature': 22,
    'condition': 'Parcialmente nublado',
    'humidity': 65,
    'windSpeed': 12,
    'uvIndex': 6,
    'visibility': 10,
    'pressure': 1013,
    'icon': Icons.wb_cloudy_rounded,
  };

  final List<Map<String, dynamic>> _forecast = [
    {'day': 'Hoy', 'high': 24, 'low': 18, 'icon': Icons.wb_cloudy_rounded},
    {'day': 'Mañana', 'high': 26, 'low': 19, 'icon': Icons.wb_sunny_rounded},
    {'day': 'Viernes', 'high': 23, 'low': 17, 'icon': Icons.cloud_rounded},
    {'day': 'Sábado', 'high': 25, 'low': 20, 'icon': Icons.wb_sunny_rounded},
    {'day': 'Domingo', 'high': 22, 'low': 16, 'icon': Icons.grain_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3A8A), // Blue-900
              Color(0xFF3B82F6), // Blue-500
              Color(0xFF06B6D4), // Cyan-500
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con ubicación
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _weatherData['city'],
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Temperatura principal
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          _weatherData['icon'],
                          size: 120,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${_weatherData['temperature']}°',
                          style: GoogleFonts.inter(
                            fontSize: 72,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _weatherData['condition'],
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Detalles del clima
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _buildWeatherDetail(
                              icon: Icons.water_drop_rounded,
                              label: 'Humedad',
                              value: '${_weatherData['humidity']}%',
                            ),
                            _buildWeatherDetail(
                              icon: Icons.air_rounded,
                              label: 'Viento',
                              value: '${_weatherData['windSpeed']} km/h',
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            _buildWeatherDetail(
                              icon: Icons.wb_sunny_rounded,
                              label: 'UV Index',
                              value: '${_weatherData['uvIndex']}',
                            ),
                            _buildWeatherDetail(
                              icon: Icons.visibility_rounded,
                              label: 'Visibilidad',
                              value: '${_weatherData['visibility']} km',
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            _buildWeatherDetail(
                              icon: Icons.speed_rounded,
                              label: 'Presión',
                              value: '${_weatherData['pressure']} hPa',
                            ),
                            const Expanded(child: SizedBox()),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Pronóstico de 5 días
                  Text(
                    'Pronóstico de 5 días',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: _forecast.map((day) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 80,
                                child: Text(
                                  day['day'],
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Icon(
                                day['icon'],
                                color: Colors.white,
                                size: 24,
                              ),
                              const Spacer(),
                              Text(
                                '${day['low']}°',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: Colors.white60,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                '${day['high']}°',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherDetail({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white70,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}