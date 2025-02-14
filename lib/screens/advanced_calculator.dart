import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'dart:math';

void main() => runApp(CalculatorApp());

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.blueGrey[900],
      ),
      home: AdvancedCalculator(),
    );
  }
}

class AdvancedCalculator extends StatefulWidget {
  @override
  _AdvancedCalculatorState createState() => _AdvancedCalculatorState();
}

class _AdvancedCalculatorState extends State<AdvancedCalculator> {
  String _equation = "0";
  String _result = "0";
  bool _isNewNumber = true;

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
          _handleNumberInput(buttonText);
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
  }

  void _handleBackspace() {
    _equation = _equation.substring(0, _equation.length - 1);
    if (_equation.isEmpty) _equation = "0";
    _isNewNumber = false;
  }

  void _calculateResult() {
    try {
      String expression = _equation
          .replaceAll('×', '*')
          .replaceAll('÷', '/');

      Parser p = Parser();
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      double evalResult = exp.evaluate(EvaluationType.REAL, cm);

      _result = _formatResult(evalResult);
      _equation = _result;
      _isNewNumber = true;
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
    } else {
      _showError();
    }
  }

  // New method to handle square function
  void _handleSquare() {
    final number = double.tryParse(_equation);
    if (number != null) {
      double square = number * number;
      _result = _formatResult(square);
      _equation = _result;
      _isNewNumber = true;
    } else {
      _showError();
    }
  }

  void _handleNumberInput(String buttonText) {
    if (_isNewNumber) {
      _equation = buttonText;
      _isNewNumber = false;
    } else {
      _equation += buttonText;
    }
  }

  String _formatResult(double value) {
    return value % 1 == 0 
        ? value.toInt().toString()
        : value.toStringAsFixed(4)
            .replaceAll(RegExp(r'0*$'), '')
            .replaceAll(r'.$', '');
  }

  void _showError() {
    _result = "Error";
    _equation = "Invalid Input";
    _isNewNumber = true;
  }

  Widget _buildButton(String text, {Color? color, bool isWide = false}) {
    return Container(
      margin: EdgeInsets.all(15),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Colors.blueGrey[800],
          shape: CircleBorder(),
          padding: isWide ? EdgeInsets.all(25) : EdgeInsets.all(25),
        ),
        onPressed: () => _buttonPressed(text),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 20,
            color: color != null ? Colors.white : Colors.amber[100],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.bottomRight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            _equation,
                            style: TextStyle(
                              fontSize: 30,
                              color: const Color.fromARGB(179, 49, 49, 49),
                            ),
                          ),
                        ),
                        
                        Text(
                          _result,
                          style: TextStyle(
                            fontSize: 60,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildButton("C", color: Colors.redAccent),
                            _buildButton("⌫", color: Colors.blueGrey),
                            _buildButton("x²", color: Colors.blue),
                            _buildButton("÷", color: Colors.blue),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildButton("7"),
                            _buildButton("8"),
                            _buildButton("9"),
                            _buildButton("×", color: Colors.blue),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildButton("4"),
                            _buildButton("5"),
                            _buildButton("6"),
                            _buildButton("-", color: Colors.blue),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildButton("1"),
                            _buildButton("2"),
                            _buildButton("3"),
                            _buildButton("+", color: Colors.blue),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          
                          children: [
                            _buildButton("√", color: Colors.blue),
                            _buildButton("0"),
                            _buildButton("."),
                            _buildButton("=", color: Colors.blue),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}