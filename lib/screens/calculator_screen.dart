import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  String _expression = '';
  double _firstOperand = 0;
  String _operator = '';
  bool _waitingForOperand = false;

  void _inputDigit(String digit) {
    setState(() {
      if (_waitingForOperand) {
        _display = digit;
        _waitingForOperand = false;
      } else {
        _display = _display == '0' ? digit : _display + digit;
      }
      _expression = _display;
    });
  }

  void _inputOperator(String nextOperator) {
    double inputValue = double.parse(_display);

    if (_firstOperand == 0) {
      _firstOperand = inputValue;
    } else if (_operator.isNotEmpty) {
      double currentValue = _firstOperand;
      double result = _calculate(currentValue, inputValue, _operator);
      
      setState(() {
        _display = result.toString();
        _firstOperand = result;
      });
    }

    setState(() {
      _waitingForOperand = true;
      _operator = nextOperator;
      _expression = '$_firstOperand $_operator';
    });
  }

  double _calculate(double firstOperand, double secondOperand, String operator) {
    switch (operator) {
      case '+':
        return firstOperand + secondOperand;
      case '-':
        return firstOperand - secondOperand;
      case '×':
        return firstOperand * secondOperand;
      case '÷':
        return firstOperand / secondOperand;
      default:
        return secondOperand;
    }
  }

  void _performCalculation() {
    double inputValue = double.parse(_display);
    
    if (_firstOperand != 0 && _operator.isNotEmpty) {
      double result = _calculate(_firstOperand, inputValue, _operator);
      
      setState(() {
        _display = result.toString();
        _expression = '$_firstOperand $_operator $inputValue = $result';
        _firstOperand = 0;
        _operator = '';
        _waitingForOperand = true;
      });
    }
  }

  void _clear() {
    setState(() {
      _display = '0';
      _expression = '';
      _firstOperand = 0;
      _operator = '';
      _waitingForOperand = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F11),
      body: SafeArea(
        child: Column(
          children: [
            // Display area
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (_expression.isNotEmpty)
                      Text(
                        _expression,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 16,
                          color: Colors.white60,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      _display,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 48,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Buttons area
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildButtonRow(['C', '±', '%', '÷']),
                    _buildButtonRow(['7', '8', '9', '×']),
                    _buildButtonRow(['4', '5', '6', '-']),
                    _buildButtonRow(['1', '2', '3', '+']),
                    _buildButtonRow(['0', '.', '=']),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonRow(List<String> buttons) {
    return Expanded(
      child: Row(
        children: buttons.map((button) {
          return Expanded(
            flex: button == '0' ? 2 : 1,
            child: Container(
              margin: const EdgeInsets.all(4),
              child: _buildButton(button),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildButton(String text) {
    Color buttonColor;
    Color textColor = Colors.white;
    
    if (text == 'C' || text == '±' || text == '%') {
      buttonColor = const Color(0xFF374151);
    } else if (['+', '-', '×', '÷', '='].contains(text)) {
      buttonColor = const Color(0xFF6366F1);
    } else {
      buttonColor = const Color(0xFF1F2937);
    }

    return ElevatedButton(
      onPressed: () => _onButtonPressed(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: textColor,
        elevation: 2,
        padding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _onButtonPressed(String buttonText) {
    switch (buttonText) {
      case 'C':
        _clear();
        break;
      case '±':
        setState(() {
          if (_display != '0') {
            if (_display.startsWith('-')) {
              _display = _display.substring(1);
            } else {
              _display = '-$_display';
            }
          }
        });
        break;
      case '%':
        setState(() {
          double value = double.parse(_display);
          _display = (value / 100).toString();
        });
        break;
      case '=':
        _performCalculation();
        break;
      case '+':
      case '-':
      case '×':
      case '÷':
        _inputOperator(buttonText);
        break;
      default:
        _inputDigit(buttonText);
        break;
    }
  }
}