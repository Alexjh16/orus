import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  final int _numPages = 3;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF4052B6), // Color azul similar al de la imagen
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Stack(
            children: [
              PageView(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: _buildPages(),
              ),
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _buildPageIndicator(),
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Botón Previous
                          TextButton(
                            onPressed: _currentPage != 0
                                ? () {
                                    // Ir a la página anterior
                                    _pageController.previousPage(
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.ease,
                                    );
                                  }
                                : null, // Deshabilitar el botón en la primera página
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _currentPage != 0
                                    ? const Icon(Icons.arrow_back,
                                        color: Colors.white)
                                    : Container(),
                                const SizedBox(width: 4),
                                Text(
                                  'Anterior',
                                  style: GoogleFonts.inter(
                                    color: _currentPage != 0
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.3),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Botón Next
                          _currentPage != _numPages - 1
                              ? ElevatedButton(
                                  onPressed: () {
                                    _pageController.nextPage(
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.ease,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF4052B6),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Siguiente',
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.arrow_forward),
                                    ],
                                  ),
                                )
                              : Builder(builder: (BuildContext innerContext) {
                                  return ElevatedButton(
                                    onPressed: () {
                                      // Abrir el drawer usando un contexto válido
                                      Scaffold.of(innerContext).openDrawer();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFF4052B6),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: Text(
                                      'Comenzar',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPages() {
    return [
      _buildPage(
        title: 'Rápido Y Fluido',
        description:
            '💀⚠️ Una aplicación para el climita y algunas operaciones complejamente difíciles de matemáticas.⚠️💀',
        icon: Icons.speed_outlined,
      ),
      _buildPage(
        title: 'Calculadora Inteligente',
        description:
            'Realiza cálculos matemáticos con nuestra herramienta precisa!!!',
        icon: Icons.calculate_outlined,
      ),
      _buildPage(
        title: 'Clima en Tiempo Real',
        description: 'Mantente informado sobre el clima de tu ciudad.',
        icon: Icons.cloud_outlined,
      ),
    ];
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> indicators = [];
    for (int i = 0; i < _numPages; i++) {
      indicators.add(
        Container(
          width: 10.0,
          height: 10.0,
          margin: const EdgeInsets.symmetric(horizontal: 5.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i == _currentPage
                ? Colors.white
                : Colors.white.withOpacity(0.5),
          ),
        ),
      );
    }
    return indicators;
  }

  Widget _buildPage({
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icono principal
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                icon,
                size: 100,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 40),

          // Título
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Descripción
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 18,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Este método ya no se usa en el nuevo diseño, pero lo mantenemos por compatibilidad
  // con otras partes de la aplicación si fuera necesario
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(); // Devolvemos un widget vacío
  }
}
