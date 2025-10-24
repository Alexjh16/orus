import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';

class MapPage extends StatefulWidget {
  final String name;
  final String lastName;
  final String estado;

  const MapPage({
    super.key,
    required this.name,
    required this.lastName,
    required this.estado,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  bool _locationPermissionGranted = false;
  Position? _currentPosition;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si el servicio de ubicación está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Los servicios de ubicación están deshabilitados.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Verificar permisos
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permiso de ubicación denegado.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Permiso de ubicación denegado permanentemente. Habilítalo en configuración.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Permiso concedido
    setState(() {
      _locationPermissionGranted = true;
    });

    // Obtener posición actual
    try {
      _currentPosition = await Geolocator.getCurrentPosition();
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al obtener ubicación: $e'),
          backgroundColor: Colors.orange,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mapa',
          style: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF4052B6),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4052B6), Color(0xFF6A82FB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Bienvenido, ${widget.name} ${widget.lastName}',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Estado: ${widget.estado}',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Mapa - Próximamente',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? Column(
                    children: [
                      const CircularProgressIndicator(color: Colors.white),
                      const SizedBox(height: 8),
                      Text(
                        'Solicitando permisos de ubicación...',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  )
                : Text(
                    _locationPermissionGranted
                        ? 'Permiso de ubicación concedido'
                        : 'Permiso de ubicación no concedido',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      color: _locationPermissionGranted
                          ? Colors.greenAccent
                          : Colors.redAccent,
                    ),
                  ),
            if (!_isLoading && _currentPosition != null) ...[
              const SizedBox(height: 16),
              Text(
                'Ubicación: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
