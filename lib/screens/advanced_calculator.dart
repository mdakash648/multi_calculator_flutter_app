import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'dart:convert';
import 'package:intl/intl.dart';

class AdvancedCalculator extends StatefulWidget {
  @override
  _AdvancedCalculatorState createState() => _AdvancedCalculatorState();
}

class _AdvancedCalculatorState extends State<AdvancedCalculator> {
  String _equation = "0";
  String _result = "0";
  bool _isNewNumber = true;
  bool _justCalculated = false; // Track if last button was '='

  void _buttonPressed(String buttonText) {
    setState(() {
      try {
        if (buttonText == "C") {
          _resetCalculator();
        } else if (buttonText == "⌫") {
          _handleBackspace();
        } else if (buttonText == "=") {
          _calculateResult();
        } else if (buttonText == "√") {
          _handleSquareRoot();
        } else if (buttonText == "x²") {
          _handleSquare();
        } else {
          _handleNumberOrOperatorInput(buttonText);
        }
      } catch (e) {
        _showError();
      }
    });
  }

  void _resetCalculator() {
    _equation = "0";
    _result = "0";
    _isNewNumber = true;
    _justCalculated = false;
  }

  void _handleBackspace() {
    if (_equation.length > 1) {
      _equation = _equation.substring(0, _equation.length - 1);
    } else {
      _equation = "0";
    }
    _isNewNumber = false;
    _justCalculated = false;
  }

  void _calculateResult() {
    try {
      String expression = _equation.replaceAll('×', '*').replaceAll('÷', '/');

      Parser p = Parser();
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      double evalResult = exp.evaluate(EvaluationType.REAL, cm);

      _result = _formatResult(evalResult);
      _equation = _result;
      _isNewNumber = true;
      _justCalculated = true;

      // Save to history
      _saveToHistory(expression, _result);
    } catch (e) {
      _showError();
    }
  }

  Future<void> _saveToHistory(String equation, String result) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList('calculation_history') ?? [];

      final historyItem = {
        'equation': equation,
        'result': result,
        'timestamp': DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now()),
        'type': 'calculator',
      };

      // Add new item to the beginning of the list
      historyJson.insert(0, jsonEncode(historyItem));

      // Keep only the last 100 items
      if (historyJson.length > 100) {
        historyJson.removeRange(100, historyJson.length);
      }

      await prefs.setStringList('calculation_history', historyJson);
    } catch (e) {
      // Silently fail if history saving fails
      print('Failed to save to history: $e');
    }
  }

  void _handleSquareRoot() {
    final number = double.tryParse(_equation);
    if (number != null && number >= 0) {
      double root = sqrt(number);
      _result = _formatResult(root);
      _equation = _result;
      _isNewNumber = true;
      _justCalculated = true;
    } else {
      _showError();
    }
  }

  void _handleSquare() {
    final number = double.tryParse(_equation);
    if (number != null) {
      double square = number * number;
      _result = _formatResult(square);
      _equation = _result;
      _isNewNumber = true;
      _justCalculated = true;
    } else {
      _showError();
    }
  }

  bool _isOperator(String s) {
    return s == "+" || s == "-" || s == "×" || s == "÷";
  }

  void _handleNumberOrOperatorInput(String buttonText) {
    if (_justCalculated) {
      if (_isOperator(buttonText)) {
        // If result is 0, don't use it as previous result
        if (_result == "0") {
          _equation = "0" + buttonText;
        } else {
          // Start new equation with result and operator
          _equation = _result + buttonText;
        }
        _isNewNumber = false;
      } else if (buttonText == ".") {
        _equation = "0.";
        _isNewNumber = false;
      } else {
        // Start new equation with the number
        _equation = buttonText;
        _isNewNumber = false;
      }
      _justCalculated = false;
    } else {
      if (_isNewNumber) {
        _equation = buttonText;
        _isNewNumber = false;
      } else {
        _equation += buttonText;
      }
    }
  }

  String _formatResult(double value) {
    return value % 1 == 0
        ? value.toInt().toString()
        : value
            .toStringAsFixed(4)
            .replaceAll(RegExp(r'0*$'), '')
            .replaceAll(r'.$', '');
  }

  void _showError() {
    _result = "Error";
    _equation = "Invalid Input";
    _isNewNumber = true;
    _justCalculated = false;
  }

  Widget _buildButton(String text, {Color? backgroundColor, Color? textColor}) {
    final theme = Theme.of(context);
    Color bg;
    Color fg;

    // Use provided color or theme-based color
    if (backgroundColor != null) {
      bg = backgroundColor;
      fg = textColor ?? Colors.white;
    } else {
      // Number button: use #B0B0B0 in dark mode, white in light mode
      final isDark = theme.brightness == Brightness.dark;
      bg = isDark ? const Color(0xFFB0B0B0) : Colors.white;
      fg = isDark ? Colors.black : Colors.black87;
    }

    return Container(
      margin:
          const EdgeInsets.all(2.0), // Consistent 2px margin for uniform gaps
      child: Material(
        elevation: 2,
        borderRadius:
            BorderRadius.circular(10), // Adjusted to match image (10-12px)
        color: bg,
        child: InkWell(
          borderRadius: BorderRadius.circular(10), // Adjusted to match image
          onTap: () => _buttonPressed(text),
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius:
                  BorderRadius.circular(10), // Adjusted to match image
              border: Border.all(
                color: Colors.transparent,
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.end, // Align both containers to bottom
            children: [
              // Display Section
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment:
                        MainAxisAlignment.end, // Align text to bottom
                    children: [
                      // Equation display with text wrapping
                      Flexible(
                        child: Container(
                          width: double.infinity,
                          child: Text(
                            _equation,
                            style: TextStyle(
                              fontSize: 18,
                              color: theme.hintColor,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.end,
                            maxLines: null, // Allow unlimited lines
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Result display with auto-scroll
                      Container(
                        height: 50,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          reverse: true,
                          child: Text(
                            _result,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Buttons Section
              Container(
                height: 320, // Fixed height of 320px
                padding: const EdgeInsets.all(
                    8), // Reduced padding for tighter layout
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.end, // Align buttons to bottom
                  children: [
                    // First Row
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                              child: _buildButton("C",
                                  backgroundColor: Colors.redAccent,
                                  textColor: Colors.white)),
                          Expanded(
                              child: _buildButton("⌫",
                                  backgroundColor: Colors.orange,
                                  textColor: Colors.white)),
                          Expanded(
                              child: _buildButton("x²",
                                  backgroundColor: theme.colorScheme.primary,
                                  textColor: Colors.white)),
                          Expanded(
                              child: _buildButton("÷",
                                  backgroundColor: theme.colorScheme.primary,
                                  textColor: Colors.white)),
                        ],
                      ),
                    ),
                    // Second Row
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: _buildButton("7")),
                          Expanded(child: _buildButton("8")),
                          Expanded(child: _buildButton("9")),
                          Expanded(
                              child: _buildButton("×",
                                  backgroundColor: theme.colorScheme.primary,
                                  textColor: Colors.white)),
                        ],
                      ),
                    ),
                    // Third Row
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: _buildButton("4")),
                          Expanded(child: _buildButton("5")),
                          Expanded(child: _buildButton("6")),
                          Expanded(
                              child: _buildButton("-",
                                  backgroundColor: theme.colorScheme.primary,
                                  textColor: Colors.white)),
                        ],
                      ),
                    ),
                    // Fourth Row
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: _buildButton("1")),
                          Expanded(child: _buildButton("2")),
                          Expanded(child: _buildButton("3")),
                          Expanded(
                              child: _buildButton("+",
                                  backgroundColor: theme.colorScheme.primary,
                                  textColor: Colors.white)),
                        ],
                      ),
                    ),
                    // Fifth Row
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                              child: _buildButton("√",
                                  backgroundColor: theme.colorScheme.primary,
                                  textColor: Colors.white)),
                          Expanded(child: _buildButton("0")),
                          Expanded(child: _buildButton(".")),
                          Expanded(
                              child: _buildButton("=",
                                  backgroundColor: Colors.green,
                                  textColor: Colors.white)),
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
}
