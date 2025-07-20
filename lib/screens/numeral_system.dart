import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class NumeralConverterScreen extends StatefulWidget {
  @override
  _NumeralConverterScreenState createState() => _NumeralConverterScreenState();
}

class _NumeralConverterScreenState extends State<NumeralConverterScreen> {
  final TextEditingController _inputController = TextEditingController();
  String _output = "";
  String _fromBase = "Decimal";
  String _toBase = "Binary";

  final Map<String, int> baseMap = {
    "Binary": 2,
    "Octal": 8,
    "Decimal": 10,
    "Hexadecimal": 16,
  };

  void _convert() {
    String input = _inputController.text.trim();
    if (input.isEmpty) {
      setState(() => _output = "");
      return;
    }
    try {
      int decimalValue = int.parse(input, radix: baseMap[_fromBase]!);
      String result =
          decimalValue.toRadixString(baseMap[_toBase]!).toUpperCase();
      setState(() => _output = result);

      // Save to history if conversion is successful
      if (result != "Invalid Input") {
        _saveToHistory(input, result);
      }
    } catch (e) {
      setState(() => _output = "Invalid Input");
    }
  }

  Future<void> _saveToHistory(String input, String result) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList('calculation_history') ?? [];

      final equation = '$_fromBase: $input';
      final resultText = '$_toBase: $result';

      final historyItem = {
        'equation': equation,
        'result': resultText,
        'timestamp': DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now()),
        'type': 'numeral',
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = theme.scaffoldBackgroundColor;
    final cardColor = theme.cardTheme.color ??
        (isDark ? const Color(0xFF23243A) : Colors.white);
    final borderColor =
        isDark ? const Color(0xFF444444) : const Color(0xFFE0E0E0);
    final labelColor = theme.textTheme.bodyLarge?.color ??
        (isDark ? Colors.white : Colors.black);
    final textColor = theme.textTheme.bodyLarge?.color ??
        (isDark ? Colors.white : Colors.black);
    final arrowColor = theme.colorScheme.primary;
    final outputLabelColor = theme.textTheme.bodyLarge?.color ??
        (isDark ? Colors.white : Colors.black);

    return Scaffold(
      backgroundColor: bgColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: bgColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Large rounded input box
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: TextField(
                  controller: _inputController,
                  keyboardType: TextInputType.text,
                  onChanged: (value) => _convert(),
                  style: TextStyle(fontSize: 20, color: textColor),
                  decoration: InputDecoration(
                    hintText: "Enter Number",
                    hintStyle: TextStyle(color: theme.hintColor),
                    filled: true,
                    fillColor: cardColor,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 22),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor, width: 2),
                    ),
                  ),
                ),
              ),
              // From/To labels and dropdowns
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // From
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "From",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: labelColor,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        Theme(
                          data: Theme.of(context).copyWith(
                            canvasColor: cardColor,
                          ),
                          child: DropdownButton<String>(
                            value: _fromBase,
                            isExpanded: true,
                            dropdownColor: cardColor,
                            style: TextStyle(color: textColor, fontSize: 18),
                            onChanged: (String? value) {
                              if (value != null) {
                                setState(() => _fromBase = value);
                                _convert();
                              }
                            },
                            items: baseMap.keys.map((String key) {
                              return DropdownMenuItem<String>(
                                value: key,
                                child: Text(key,
                                    style: TextStyle(color: textColor)),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Arrow
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child:
                        Icon(Icons.arrow_forward, color: arrowColor, size: 28),
                  ),
                  // To
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "To",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: labelColor,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        Theme(
                          data: Theme.of(context).copyWith(
                            canvasColor: cardColor,
                          ),
                          child: DropdownButton<String>(
                            value: _toBase,
                            isExpanded: true,
                            dropdownColor: cardColor,
                            style: TextStyle(color: textColor, fontSize: 18),
                            onChanged: (String? value) {
                              if (value != null) {
                                setState(() => _toBase = value);
                                _convert();
                              }
                            },
                            items: baseMap.keys.map((String key) {
                              return DropdownMenuItem<String>(
                                value: key,
                                child: Text(key,
                                    style: TextStyle(color: textColor)),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Output area
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Text(
                  "Output: ${_output.isEmpty ? '' : _output}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: outputLabelColor,
                    decoration: TextDecoration.none,
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
