import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class AdvancedCalculator extends StatefulWidget {
  final String? initialEquation;
  final void Function(AdvancedCalculatorState)? onCalculatorCreated;
  AdvancedCalculator({this.initialEquation, this.onCalculatorCreated});
  @override
  AdvancedCalculatorState createState() => AdvancedCalculatorState();
}

class AdvancedCalculatorState extends State<AdvancedCalculator> {
  final GlobalKey _firstButtonKey = GlobalKey();
  String _equation = "0";
  String _result = "0";
  bool _isNewNumber = true;
  bool _justCalculated = false; // Track if last button was '='

  @override
  void initState() {
    super.initState();
    if (widget.onCalculatorCreated != null) {
      widget.onCalculatorCreated!(this);
    }
    if (widget.initialEquation != null && widget.initialEquation!.isNotEmpty) {
      _equation = widget.initialEquation!;
      _isNewNumber = false;
      _updateResultRealtime();
    }
  }

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
    // Real-time calculation after input
    _updateResultRealtime();
  }

  void _updateResultRealtime() {
    try {
      String expression = _equation.replaceAll('×', '*').replaceAll('÷', '/');
      Parser p = Parser();
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      double evalResult = exp.evaluate(EvaluationType.REAL, cm);
      _result = _formatResult(evalResult);
    } catch (e) {
      _result = ""; // Or set to 'Error' if you prefer
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

  Widget _buildButton(String text,
      {Key? key,
      Color? backgroundColor,
      Color? textColor,
      double? windowWidth,
      bool? isWindows}) {
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
      bg = isDark ? const Color.fromARGB(255, 245, 239, 239) : Colors.white;
      fg = isDark ? Colors.black : Colors.black87;
    }

    Widget button = Container(
      key: key,
      margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      child: Material(
        elevation: 2,
        borderRadius:
            BorderRadius.circular(20), // Adjusted to match image (10-12px)
        color: bg,
        child: InkWell(
          borderRadius: BorderRadius.circular(20), // Adjusted to match image
          onTap: () => _buttonPressed(text),
          child: Container(
            width: double.infinity,
            height: 62,
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
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // Apply 67:35 aspect ratio if on Windows and width >= 723px
    if ((isWindows ?? false) && (windowWidth ?? 0) >= 723) {
      button = AspectRatio(
        aspectRatio: 67 / 35,
        child: button,
      );
    }
    return button;
  }

  void setEquationFromHistory(String equation) {
    setState(() {
      _equation = equation;
      _isNewNumber = false;
      _justCalculated = false;
      _updateResultRealtime();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWindows = Platform.isWindows;
    final windowWidth = MediaQuery.of(context).size.width;
    final displayFlex = isWindows ? 3 : 1;
    final buttonFlex = isWindows ? 7 : 1;
    final windowHeight = MediaQuery.of(context).size.height;
    final useWideMargin = isWindows && windowWidth >= 723;
    final horizontalMargin = useWideMargin ? windowWidth * 0.1 : 0.0;
    // Responsive text sizes
    double equationFontSize = 25;
    double resultFontSize = 35;
    if (windowWidth >= 1194) {
      equationFontSize = 32;
      resultFontSize = 44;
    } else if (windowWidth >= 723) {
      equationFontSize = 28;
      resultFontSize = 38;
    }
    // Get button size for debug
    Size? buttonSize;
    final contextButton = _firstButtonKey.currentContext;
    if (contextButton != null) {
      final renderBox = contextButton.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize) {
        buttonSize = renderBox.size;
      }
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.end, // Align both containers to bottom
            children: [
              Expanded(
                flex: displayFlex,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  margin: EdgeInsets.only(
                    left: horizontalMargin,
                    right: horizontalMargin,
                    bottom: 16.0,
                  ),
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
                              fontSize: equationFontSize,
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
                              fontSize: resultFontSize,
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
              Expanded(
                flex: buttonFlex,
                child: Container(
                  padding: const EdgeInsets.all(
                      8), // Reduced padding for tighter layout
                  margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 0,
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
                                    key: _firstButtonKey,
                                    backgroundColor: Colors.redAccent,
                                    textColor: Colors.white,
                                    windowWidth: windowWidth,
                                    isWindows: isWindows)),
                            Expanded(
                                child: _buildButton("⌫",
                                    backgroundColor: Colors.orange,
                                    textColor: Colors.white,
                                    windowWidth: windowWidth,
                                    isWindows: isWindows)),
                            Expanded(
                                child: _buildButton("x²",
                                    backgroundColor: theme.colorScheme.primary,
                                    textColor: Colors.white,
                                    windowWidth: windowWidth,
                                    isWindows: isWindows)),
                            Expanded(
                                child: _buildButton("÷",
                                    backgroundColor: theme.colorScheme.primary,
                                    textColor: Colors.white,
                                    windowWidth: windowWidth,
                                    isWindows: isWindows)),
                          ],
                        ),
                      ),
                      // Second Row
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                                child: _buildButton("7",
                                    windowWidth: windowWidth,
                                    isWindows: isWindows)),
                            Expanded(
                                child: _buildButton("8",
                                    windowWidth: windowWidth,
                                    isWindows: isWindows)),
                            Expanded(
                                child: _buildButton("9",
                                    windowWidth: windowWidth,
                                    isWindows: isWindows)),
                            Expanded(
                                child: _buildButton("×",
                                    backgroundColor: theme.colorScheme.primary,
                                    textColor: Colors.white,
                                    windowWidth: windowWidth,
                                    isWindows: isWindows)),
                          ],
                        ),
                      ),
                      // Third Row
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                                child: _buildButton("4",
                                    windowWidth: windowWidth,
                                    isWindows: isWindows)),
                            Expanded(
                                child: _buildButton("5",
                                    windowWidth: windowWidth,
                                    isWindows: isWindows)),
                            Expanded(
                                child: _buildButton("6",
                                    windowWidth: windowWidth,
                                    isWindows: isWindows)),
                            Expanded(
                                child: _buildButton("-",
                                    backgroundColor: theme.colorScheme.primary,
                                    textColor: Colors.white,
                                    windowWidth: windowWidth,
                                    isWindows: isWindows)),
                          ],
                        ),
                      ),
                      // Fourth Row
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                                child: _buildButton("1",
                                    windowWidth: windowWidth,
                                    isWindows: isWindows)),
                            Expanded(
                                child: _buildButton("2",
                                    windowWidth: windowWidth,
                                    isWindows: isWindows)),
                            Expanded(
                                child: _buildButton("3",
                                    windowWidth: windowWidth,
                                    isWindows: isWindows)),
                            Expanded(
                                child: _buildButton("+",
                                    backgroundColor: theme.colorScheme.primary,
                                    textColor: Colors.white,
                                    windowWidth: windowWidth,
                                    isWindows: isWindows)),
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
                                    textColor: Colors.white,
                                    windowWidth: windowWidth,
                                    isWindows: isWindows)),
                            Expanded(
                                child: _buildButton("0",
                                    windowWidth: windowWidth,
                                    isWindows: isWindows)),
                            Expanded(
                                child: _buildButton(".",
                                    windowWidth: windowWidth,
                                    isWindows: isWindows)),
                            Expanded(
                                child: _buildButton("=",
                                    backgroundColor: Colors.green,
                                    textColor: Colors.white,
                                    windowWidth: windowWidth,
                                    isWindows: isWindows)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
