import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class CalculatorView extends StatefulWidget {
  const CalculatorView({super.key});

  @override
  State<CalculatorView> createState() => _CalculatorViewState();
}

class _CalculatorViewState extends State<CalculatorView> {
  final TextEditingController _firstNumberController = TextEditingController();
  final TextEditingController _secondNumberController = TextEditingController();
  double _result = 0;
  String _operation = '';

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
          _result = math.pow(firstNum, secondNum).toDouble();
          break;
        case 'raiz':
          if (firstNum < 0) {
            _showError('No se puede calcular raíz de número negativo');
            return;
          }
          // Raíz n-ésima: firstNum^(1/secondNum)
          _result = math.pow(firstNum, 1 / secondNum).toDouble();
          break;
      }
    });
  }

  void _clearAll() {
    setState(() {
      _firstNumberController.clear();
      _secondNumberController.clear();
      _result = 0;
      _operation = '';
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _firstNumberController.dispose();
    _secondNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F11),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
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
              const SizedBox(height: 40),

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
                    color: Colors.blue,
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
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.refresh),
                    const SizedBox(width: 8),
                    Text(
                      'Limpiar Todo',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Área de resultado
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.lightBlue.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    Text(
                      'Σ',
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Resultado (+)',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _result == _result.toInt() 
                          ? _result.toInt().toString()
                          : _result.toStringAsFixed(2),
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
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

  Widget _buildNumberInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.indigo.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.shade200,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: GoogleFonts.jetBrainsMono(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.indigo.shade800,
        ),
        decoration: InputDecoration(
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon, 
              color: Colors.blue.shade700,
              size: 24,
            ),
          ),
          labelText: label,
          labelStyle: GoogleFonts.inter(
            color: Colors.indigo.shade600,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          floatingLabelStyle: GoogleFonts.inter(
            color: Colors.blue.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.blue.shade400,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          hintText: '0.0',
          hintStyle: GoogleFonts.jetBrainsMono(
            color: Colors.indigo.shade300,
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
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
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
