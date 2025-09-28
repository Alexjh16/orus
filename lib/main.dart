import 'package:flutter/material.dart';
import 'package:orus/home/home_page.dart';
import 'package:orus/calculator/calculator_page.dart';
import 'package:orus/weather/weather_page.dart';

void main() {
  runApp(const OrusApp());
}

class OrusApp extends StatelessWidget {
  const OrusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orus',
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1),
          secondary: Color(0xFF8B5CF6),
          tertiary: Color(0xFF06B6D4),
          surface: Color(0xFF1F1F23),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onTertiary: Colors.white,
          onSurface: Color(0xFFE5E5E7),
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Widget _currentPage = const HomePage();
  String _currentTitle = 'Inicio';

  void _navigateToPage(Widget page, String title) {
    setState(() {
      _currentPage = page;
      _currentTitle = title;
    });
    Navigator.of(context).pop(); // Cierra el drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentTitle),
        backgroundColor: const Color(0xFF1F1F23),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF1F1F23),
        child: Column(
          children: [
            // Header del drawer
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF6366F1),
                    const Color(0xFF8B5CF6),
                  ],
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.apps,
                      size: 40,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Orus',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Tu App Multifuncional',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            // Menu items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    icon: Icons.home,
                    title: 'Inicio',
                    onTap: () => _navigateToPage(const HomePage(), 'Inicio'),
                    isSelected: _currentTitle == 'Inicio',
                  ),
                  _buildDrawerItem(
                    icon: Icons.calculate,
                    title: 'Calculadora',
                    onTap: () => _navigateToPage(const CalculatorPage(), 'Calculadora'),
                    isSelected: _currentTitle == 'Calculadora',
                  ),
                  _buildDrawerItem(
                    icon: Icons.cloud,
                    title: 'Clima',
                    onTap: () => _navigateToPage(const WeatherPage(), 'Clima'),
                    isSelected: _currentTitle == 'Clima',
                  ),
                ],
              ),
            ),
            
            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Versión 1.0.0',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
      body: _currentPage,
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSelected ? const Color(0xFF6366F1).withOpacity(0.2) : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? const Color(0xFF6366F1) : Colors.white70,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color(0xFF6366F1) : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
