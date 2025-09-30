import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'dart:ui';

class CalculatorView extends StatefulWidget {
  const CalculatorView({super.key});

  @override
  State<CalculatorView> createState() => _CalculatorViewState();
}

class _CalculatorViewState extends State<CalculatorView>
    with SingleTickerProviderStateMixin {
  final TextEditingController _firstNumberController = TextEditingController();
  final TextEditingController _secondNumberController = TextEditingController();
  double _result = 0;
  String _operation = '';
  bool _showResultModal = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _firstNumberController.dispose();
    _secondNumberController.dispose();
    super.dispose();
  }

  void _performOperation(String operation) {
    final double? firstNum = double.tryParse(_firstNumberController.text);
    final double? secondNum = double.tryParse(_secondNumberController.text);

    if (firstNum == null || secondNum == null) {
      _showError('Por favor ingresa números válidos');
      return;
    }

    setState(() {
      _operation = operation;
      switch (operation) {
        case 'sumar':
          _result = firstNum + secondNum;
          break;
        case 'restar':
          _result = firstNum - secondNum;
          break;
        case 'multiplicar':
          _result = firstNum * secondNum;
          break;
        case 'dividir':
          if (secondNum == 0) {
            _showError('No se puede dividir por cero');
            return;
          }
          _result = firstNum / secondNum;
          break;
        case 'potencia':
          try {
            double potenciaResult = math.pow(firstNum, secondNum).toDouble();
            if (potenciaResult.isInfinite || potenciaResult.isNaN) {
              _showError(
                  'La operación resulta en un valor demasiado grande (infinito)');
              return;
            }
            _result = potenciaResult;
          } catch (e) {
            _showError('Error en la operación de potencia: ${e.toString()}');
            return;
          }
          break;
        case 'raiz':
          if (firstNum < 0) {
            _showError('No se puede calcular raíz de número negativo');
            return;
          }
          if (secondNum == 0) {
            _showError('No se puede usar 0 como índice de una raíz');
            return;
          }
          try {
            // Raíz n-ésima: firstNum^(1/secondNum)
            double raizResult = math.pow(firstNum, 1 / secondNum).toDouble();
            if (raizResult.isInfinite || raizResult.isNaN) {
              _showError('La operación resulta en un valor no válido');
              return;
            }
            _result = raizResult;
          } catch (e) {
            _showError('Error en la operación de raíz: ${e.toString()}');
            return;
          }
          break;
      }
      _showResultModal = true;
      _animationController.reset();
      _animationController.forward();
    });
  }

  void _clearAll() {
    setState(() {
      _firstNumberController.clear();
      _secondNumberController.clear();
      _result = 0;
      _operation = '';
      _showResultModal = false;
      _animationController.reverse();
    });
  }

  void _showError(String message) {
    if (!mounted) return;

    // Usar Future.microtask para asegurarnos que se ejecute en un momento seguro
    Future.microtask(() {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: <Widget>[
          // Base UI
          Scaffold(
            backgroundColor: const Color(0xFF4052B6),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Text(
                        'Calculadora',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Realiza operaciones matemáticas básicas y avanzadas',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),

                      // Primer número
                      _buildNumberInput(
                        controller: _firstNumberController,
                        label: 'Primer número',
                        icon: Icons.looks_one,
                      ),
                      const SizedBox(height: 16),

                      // Ícono de suma
                      Center(
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Segundo número
                      _buildNumberInput(
                        controller: _secondNumberController,
                        label: 'Segundo número',
                        icon: Icons.looks_two,
                      ),
                      const SizedBox(height: 32),

                      // Botones de operaciones
                      Row(
                        children: [
                          Expanded(
                            child: _buildOperationButton(
                              'Sumar',
                              Colors.green,
                              Icons.add,
                              'sumar',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildOperationButton(
                              'Restar',
                              Colors.orange,
                              Icons.remove,
                              'restar',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _buildOperationButton(
                              'Multiplicar',
                              Colors.purple,
                              Icons.close,
                              'multiplicar',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildOperationButton(
                              'Dividir',
                              Colors.teal,
                              Icons.more_horiz,
                              'dividir',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _buildOperationButton(
                              'Potencia',
                              Colors.indigo,
                              Icons.trending_up,
                              'potencia',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildOperationButton(
                              'Raíz',
                              Colors.brown,
                              Icons.square_foot,
                              'raiz',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Botón limpiar todo
                      ElevatedButton(
                        onPressed: _clearAll,
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
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.refresh, color: const Color(0xFF4052B6)),
                            const SizedBox(width: 8),
                            Text(
                              'Limpiar Todo',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF4052B6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Modal con blur para mostrar el resultado
          if (_showResultModal)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 5 * _animation.value,
                      sigmaY: 5 * _animation.value,
                    ),
                    child: GestureDetector(
                      onTap: _clearAll,
                      child: Container(
                        color: Colors.black.withOpacity(0.3 * _animation.value),
                        child: Center(
                          child: TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0.8, end: 1.0),
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutBack,
                            builder: (context, scale, child) {
                              return Transform.scale(
                                scale: scale,
                                child: FractionallySizedBox(
                                  widthFactor:
                                      0.95, // Esto hace que el modal sea el 95% del ancho de la pantalla
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16, horizontal: 24),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4052B6),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Σ',
                                          style: GoogleFonts.inter(
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Resultado',
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            color:
                                                Colors.white.withOpacity(0.8),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 30,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.15),
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                          child: Text(
                                            _result == _result.toInt()
                                                ? _result.toInt().toString()
                                                : _result.toStringAsFixed(2),
                                            style: GoogleFonts.inter(
                                              fontSize: 48,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 14),
                                        ElevatedButton(
                                          onPressed: _clearAll,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor:
                                                const Color(0xFF4052B6),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 8,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                          ),
                                          child: Text(
                                            'Cerrar',
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNumberInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          labelText: label,
          labelStyle: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          floatingLabelStyle: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          hintText: '0.0',
          hintStyle: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.5),
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildOperationButton(
    String text,
    Color color,
    IconData icon,
    String operation,
  ) {
    return ElevatedButton(
      onPressed: () => _performOperation(operation),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.15),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 4),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
