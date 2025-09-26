import 'package:flutter/material.dart';
import 'package:orus/theme/app_theme.dart';
import 'package:orus/screens/home_screen.dart';
import 'package:orus/screens/calculator_screen.dart';
import 'package:orus/screens/weather_screen.dart';
import 'package:orus/widgets/custom_drawer.dart';

void main() {
  runApp(const OrusApp());
}

class OrusApp extends StatelessWidget {
  const OrusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orus',
      theme: AppTheme.darkTheme,
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
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CalculatorScreen(),
    const WeatherScreen(),
  ];

  final List<String> _titles = [
    'Inicio',
    'Calculadora',
    'Clima',
  ];

  void _onDrawerItemTap(String page) {
    setState(() {
      switch (page) {
        case 'home':
          _currentIndex = 0;
          break;
        case 'calculator':
          _currentIndex = 1;
          break;
        case 'weather':
          _currentIndex = 2;
          break;
        default:
          _currentIndex = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1F1F23),
                Color(0xFF0F0F11),
              ],
            ),
          ),
        ),
      ),
      drawer: CustomDrawer(onItemTap: _onDrawerItemTap),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
    );
  }
}
