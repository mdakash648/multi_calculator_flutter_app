import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'dart:math';

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
    _equation = _equation.substring(0, _equation.length - 1);
    if (_equation.isEmpty) _equation = "0";
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
    } catch (e) {
      _showError();
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

  Color _buttonColor(BuildContext context, {Color? light, Color? dark}) {
    final brightness = Theme.of(context).brightness;
    if (brightness == Brightness.dark) {
      return dark ??
          const Color(0xFF2D2D2D); // Dark gray background for dark mode
    } else {
      return light ?? Colors.white;
    }
  }

  Color _buttonTextColor(BuildContext context, {Color? light, Color? dark}) {
    final brightness = Theme.of(context).brightness;
    if (brightness == Brightness.dark) {
      return dark ?? Colors.white; // White text for dark mode
    } else {
      return light ?? Colors.black87;
    }
  }

  Widget _buildButton(String text,
      {Color? backgroundColor, Color? textColor, bool isWide = false}) {
    final theme = Theme.of(context);
    Color? bg;
    Color? fg;
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

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive button size based on available width
        final availableWidth = constraints.maxWidth;
        final buttonSize =
            (availableWidth - 32) / 4; // 4 buttons per row, 32px total margins
        final minButtonSize = 60.0; // Minimum button size
        final maxButtonSize = 100.0; // Maximum button size
        final responsiveButtonSize =
            buttonSize.clamp(minButtonSize, maxButtonSize);

        // Calculate responsive margin
        final totalMargin = availableWidth - (responsiveButtonSize * 4);
        final responsiveMargin =
            (totalMargin / 5).clamp(4.0, 16.0); // 5 gaps between 4 buttons

        // Calculate responsive font size
        final responsiveFontSize =
            (responsiveButtonSize * 0.3).clamp(16.0, 28.0);

        return Container(
          margin: EdgeInsets.all(responsiveMargin),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(16),
            color: bg,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _buttonPressed(text),
              child: Container(
                width: responsiveButtonSize,
                height: responsiveButtonSize,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: responsiveFontSize,
                      fontWeight: FontWeight.w600,
                      color: fg,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Display Section
          LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              final responsivePadding =
                  (availableWidth * 0.05).clamp(16.0, 32.0);
              final responsiveMargin =
                  (availableWidth * 0.02).clamp(12.0, 24.0);
              final responsiveFontSize =
                  (availableWidth * 0.06).clamp(20.0, 32.0);
              final responsiveResultFontSize =
                  (availableWidth * 0.12).clamp(36.0, 56.0);

              return Container(
                width: double.infinity,
                padding: EdgeInsets.all(responsivePadding),
                margin: EdgeInsets.only(bottom: responsiveMargin),
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
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        _equation,
                        style: TextStyle(
                          fontSize: responsiveFontSize,
                          color: theme.hintColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: responsivePadding * 0.3),
                    Text(
                      _result,
                      style: TextStyle(
                        fontSize: responsiveResultFontSize,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // Buttons Section
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Calculate responsive spacing based on available height
                final availableHeight = constraints.maxHeight;
                final responsiveRowSpacing =
                    (availableHeight * 0.02).clamp(8.0, 20.0);

                return Container(
                  padding: EdgeInsets.all(16),
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
                    children: [
                      // First Row
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildButton("C",
                                backgroundColor: Colors.redAccent,
                                textColor: Colors.white),
                            _buildButton("⌫",
                                backgroundColor: Colors.orange,
                                textColor: Colors.white),
                            _buildButton("x²",
                                backgroundColor: theme.colorScheme.primary,
                                textColor: Colors.white),
                            _buildButton("÷",
                                backgroundColor: theme.colorScheme.primary,
                                textColor: Colors.white),
                          ],
                        ),
                      ),
                      SizedBox(height: responsiveRowSpacing),
                      // Second Row
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildButton("7"),
                            _buildButton("8"),
                            _buildButton("9"),
                            _buildButton("×",
                                backgroundColor: theme.colorScheme.primary,
                                textColor: Colors.white),
                          ],
                        ),
                      ),
                      SizedBox(height: responsiveRowSpacing),
                      // Third Row
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildButton("4"),
                            _buildButton("5"),
                            _buildButton("6"),
                            _buildButton("-",
                                backgroundColor: theme.colorScheme.primary,
                                textColor: Colors.white),
                          ],
                        ),
                      ),
                      SizedBox(height: responsiveRowSpacing),
                      // Fourth Row
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildButton("1"),
                            _buildButton("2"),
                            _buildButton("3"),
                            _buildButton("+",
                                backgroundColor: theme.colorScheme.primary,
                                textColor: Colors.white),
                          ],
                        ),
                      ),
                      SizedBox(height: responsiveRowSpacing),
                      // Fifth Row
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildButton("√",
                                backgroundColor: theme.colorScheme.primary,
                                textColor: Colors.white),
                            _buildButton("0"),
                            _buildButton("."),
                            _buildButton("=",
                                backgroundColor: Colors.green,
                                textColor: Colors.white),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
