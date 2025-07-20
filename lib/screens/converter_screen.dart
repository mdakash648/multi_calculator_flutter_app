import 'package:flutter/material.dart';
import 'conversion_logic.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class ConverterScreen extends StatefulWidget {
  @override
  _ConverterScreenState createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  String _fromUnit = "Megabyte";
  String _toUnit = "Gigabyte";

  final List<String> units = [
    "Byte",
    "Kilobyte",
    "Megabyte",
    "Gigabyte",
    "Terabyte",
    "Petabyte"
  ];

  void _updateConversion() {
    double value = double.tryParse(_controller1.text) ?? 0.0;
    setState(() {
      _controller2.text = convertData(value, _fromUnit, _toUnit).toString();
    });

    // Save to history if there's a valid conversion
    if (value > 0 && _controller1.text.isNotEmpty) {
      _saveToHistory(value);
    }
  }

  Future<void> _saveToHistory(double value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList('calculation_history') ?? [];

      final result = convertData(value, _fromUnit, _toUnit);
      final equation = '$value $_fromUnit';
      final resultText = '${result.toStringAsFixed(4)} $_toUnit';

      final historyItem = {
        'equation': equation,
        'result': resultText,
        'timestamp': DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now()),
        'type': 'data',
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

  void _clearFields() {
    setState(() {
      _controller1.clear();
      _controller2.clear();
    });
  }

  void _swapUnits() {
    setState(() {
      String temp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = temp;
      _updateConversion();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Palette
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
    final textFieldBg = isDark ? const Color(0xFF1F1F1F) : Colors.white;
    final textFieldBorder =
        isDark ? const Color(0xFF444444) : const Color(0xFFCCCCCC);
    final textFieldText = isDark ? Colors.white : Colors.black;
    final labelText = isDark ? const Color(0xFFE0E0E0) : Colors.black;
    final dropdownText = isDark ? Colors.white : Colors.black;
    final swapIconColor =
        isDark ? const Color(0xFF58D68D) : const Color(0xFF2ECC71);
    final clearBtnBg =
        isDark ? const Color(0xFF2E7D32) : const Color(0xFF28A745);
    final clearBtnText = Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // From Section
            Row(
              children: [
                Text(
                  "From:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: labelText,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _controller1,
                    keyboardType: TextInputType.number,
                    onChanged: (value) => _updateConversion(),
                    style: TextStyle(color: textFieldText),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: textFieldBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: textFieldBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: textFieldBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: textFieldBorder, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Theme(
                  data: Theme.of(context).copyWith(
                    canvasColor: textFieldBg,
                  ),
                  child: DropdownButton<String>(
                    value: _fromUnit,
                    dropdownColor: textFieldBg,
                    style: TextStyle(
                        color: dropdownText, fontWeight: FontWeight.w600),
                    onChanged: (String? newValue) {
                      setState(() => _fromUnit = newValue!);
                      _updateConversion();
                    },
                    items: units.map((String unit) {
                      return DropdownMenuItem<String>(
                        value: unit,
                        child:
                            Text(unit, style: TextStyle(color: dropdownText)),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Swap Button
            IconButton(
              icon: Icon(
                Icons.swap_vert,
                color: swapIconColor,
                size: 24,
              ),
              onPressed: _swapUnits,
            ),
            const SizedBox(height: 10),
            // To Section
            Row(
              children: [
                Text(
                  "To:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: labelText,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(width: 28),
                Expanded(
                  child: TextField(
                    controller: _controller2,
                    readOnly: true,
                    style: TextStyle(color: textFieldText),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: textFieldBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: textFieldBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: textFieldBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: textFieldBorder, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Theme(
                  data: Theme.of(context).copyWith(
                    canvasColor: textFieldBg,
                  ),
                  child: DropdownButton<String>(
                    value: _toUnit,
                    dropdownColor: textFieldBg,
                    style: TextStyle(
                        color: dropdownText, fontWeight: FontWeight.w600),
                    onChanged: (String? newValue) {
                      setState(() => _toUnit = newValue!);
                      _updateConversion();
                    },
                    items: units.map((String unit) {
                      return DropdownMenuItem<String>(
                        value: unit,
                        child:
                            Text(unit, style: TextStyle(color: dropdownText)),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Clear Button
            ElevatedButton(
              onPressed: _clearFields,
              style: ElevatedButton.styleFrom(
                backgroundColor: clearBtnBg,
                foregroundColor: clearBtnText,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Clear"),
            ),
          ],
        ),
      ),
    );
  }
}
