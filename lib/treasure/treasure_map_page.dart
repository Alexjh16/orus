import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/treasure_model.dart';
import 'treasure_service.dart';
import 'create_treasure_dialog.dart';
import 'treasure_details_dialog.dart';

class TreasureMapPage extends StatefulWidget {
  final String name;
  final String lastName;
  final String estado;
  final String mongoId;

  const TreasureMapPage({
    super.key,
    required this.name,
    required this.lastName,
    required this.estado,
    required this.mongoId,
  });

  @override
  State<TreasureMapPage> createState() => _TreasureMapPageState();
}

class _TreasureMapPageState extends State<TreasureMapPage> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLoading = true;
  bool _locationPermissionGranted = false;
  final TreasureService _treasureService = TreasureService();

  // Marcadores para tesoros
  final Set<Marker> _treasureMarkers = {};
  final List<Treasure> _nearbyTreasures = [];

  // Estadísticas del usuario
  Map<String, dynamic> _userStats = {};

  // Posición por defecto (ej: Bogotá, Colombia)
  static const LatLng _defaultPosition = LatLng(4.7110, -74.0721);

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    await _requestLocationPermission();

    // Intentar obtener ubicación actual
    if (_locationPermissionGranted) {
      await _getCurrentLocation();
    }

    // Cargar tesoros (usando ubicación actual o por defecto)
    await _loadNearbyTreasures();
    await _loadUserStats();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Los servicios de ubicación están deshabilitados.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Permiso de ubicación denegado permanentemente. Habilítelo en configuración.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Si llegamos aquí, los permisos están concedidos (whileInUse o always)
    setState(() {
      _locationPermissionGranted = true;
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Centrar mapa en ubicación actual si el controlador ya existe
      if (_mapController != null) {
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            16,
          ),
        );
      }
    } catch (e) {
      print('Error obteniendo ubicación: $e');
      // Mostrar mensaje pero no bloquear la app
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'No se pudo obtener la ubicación actual. Usando ubicación por defecto.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _loadNearbyTreasures() async {
    // Usar ubicación actual o por defecto
    final lat = _currentPosition?.latitude ?? _defaultPosition.latitude;
    final lng = _currentPosition?.longitude ?? _defaultPosition.longitude;

    try {
      final treasures = await _treasureService.getNearbyTreasures(
        lat,
        lng,
        1000.0, // 5km de radio
      );

      setState(() {
        _nearbyTreasures.clear();
        _nearbyTreasures.addAll(treasures);
        _updateTreasureMarkers();
      });
    } catch (e) {
      print('Error cargando tesoros: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar tesoros cercanos: $e'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _loadUserStats() async {
    try {
      // Usar el mongoId del usuario como ID único
      print(
          'TreasureMapPage: Cargando estadísticas para usuario ${widget.mongoId}');
      final stats = await _treasureService.getUserStats(widget.mongoId);
      print('TreasureMapPage: Estadísticas cargadas: $stats');
      setState(() {
        _userStats = stats;
      });
    } catch (e) {
      print('Error cargando estadísticas: $e');
    }
  }

  void _updateTreasureMarkers() {
    _treasureMarkers.clear();

    for (final treasure in _nearbyTreasures) {
      final marker = Marker(
        markerId: MarkerId(treasure.id),
        position: LatLng(treasure.latitude, treasure.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          treasure.isFound
              ? BitmapDescriptor.hueGreen
              : BitmapDescriptor.hueOrange,
        ),
        infoWindow: InfoWindow(
          title: treasure.title,
          snippet: treasure.hint,
          onTap: () => _showTreasureDetails(treasure),
        ),
      );
      _treasureMarkers.add(marker);
    }

    // Agregar marcador de ubicación actual
    if (_currentPosition != null) {
      _treasureMarkers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position:
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(
            title: 'Tu ubicación',
            snippet: '¡Encuentra tesoros cerca!',
          ),
        ),
      );
    }
  }

  void _showTreasureDetails(Treasure treasure) {
    showDialog(
      context: context,
      builder: (context) => TreasureDetailsDialog(
        treasure: treasure,
        currentPosition: _currentPosition,
        onTreasureClaimed: _onTreasureClaimed,
        currentUserId: widget.mongoId, // Pasar ID real del usuario
      ),
    );
  }

  void _onTreasureClaimed(Treasure treasure) {
    setState(() {
      treasure.isFound = true;
      _updateTreasureMarkers();
    });
    _loadUserStats(); // Recargar estadísticas
  }

  void _showCreateTreasureDialog() {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primero obtén tu ubicación actual'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => CreateTreasureDialog(
        currentPosition: _currentPosition!,
        creatorId: widget.name, // Temporal
        creatorName: '${widget.name} ${widget.lastName}',
        onTreasureCreated: _onTreasureCreated,
      ),
    );
  }

  void _onTreasureCreated(Treasure treasure) {
    setState(() {
      _nearbyTreasures.add(treasure);
      _updateTreasureMarkers();
    });
    _loadUserStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mapa de Tesoros',
          style: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF4052B6),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateTreasureDialog,
            tooltip: 'Crear Tesoro',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNearbyTreasures,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Estadísticas del usuario
                Container(
                  padding: const EdgeInsets.all(16),
                  color: const Color(0xFF4052B6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(
                        'Creados',
                        _userStats['treasures_created']?.toString() ?? '0',
                        Icons.create,
                      ),
                      _buildStatItem(
                        'Encontrados',
                        _userStats['treasures_found']?.toString() ?? '0',
                        Icons.search,
                      ),
                      _buildStatItem(
                        'Puntos',
                        _userStats['total_points']?.toString() ?? '0',
                        Icons.star,
                      ),
                    ],
                  ),
                ),

                // Mapa
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: _currentPosition != null
                                ? LatLng(_currentPosition!.latitude,
                                    _currentPosition!.longitude)
                                : _defaultPosition,
                            zoom: 16,
                          ),
                          onMapCreated: (controller) {
                            _mapController = controller;
                            // Si tenemos ubicación, centrar el mapa
                            if (_currentPosition != null) {
                              _mapController?.animateCamera(
                                CameraUpdate.newLatLngZoom(
                                  LatLng(_currentPosition!.latitude,
                                      _currentPosition!.longitude),
                                  16,
                                ),
                              );
                            }
                          },
                          markers: _treasureMarkers,
                          myLocationEnabled: _locationPermissionGranted,
                          myLocationButtonEnabled: _locationPermissionGranted,
                          zoomControlsEnabled: true,
                        ),
                ),

                // Información del usuario
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xFF4052B6),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.name} ${widget.lastName}',
                              style: GoogleFonts.lato(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Estado: ${widget.estado}',
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              'ID: ${widget.mongoId}',
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _userStats['rank']?.toString() ?? 'Novato',
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4052B6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.lato(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
