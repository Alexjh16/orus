import 'package:flutter/material.dart';
import '../treasure/treasure_map_page.dart';

class MapPage extends StatelessWidget {
  final String name;
  final String lastName;
  final String estado;
  final String mongoId;

  const MapPage({
    super.key,
    required this.name,
    required this.lastName,
    required this.estado,
    required this.mongoId,
  });

  @override
  Widget build(BuildContext context) {
    // Redirigir automáticamente a la página de tesoros
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => TreasureMapPage(
            name: name,
            lastName: lastName,
            estado: estado,
            mongoId: mongoId,
          ),
        ),
      );
    });

    // Mostrar pantalla de carga mientras redirige
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
