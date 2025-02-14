import 'package:flutter/material.dart';

void main() {
  runApp(NumeralConverterApp());
}

class NumeralConverterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: NumeralConverterScreen(),
    );
  }
}

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
      String result = decimalValue.toRadixString(baseMap[_toBase]!).toUpperCase();
      setState(() => _output = result);
    } catch (e) {
      setState(() => _output = "Invalid Input");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _inputController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: "Enter Number",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              style: TextStyle(color: Colors.black),
              onChanged: (value) => _convert(),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDropdown("From", _fromBase, (String? value) {
                  if (value != null) {
                    setState(() => _fromBase = value);
                    _convert();
                  }
                }),
                Icon(Icons.arrow_right_alt, size: 32, color: Colors.blueAccent),
                _buildDropdown("To", _toBase, (String? value) {
                  if (value != null) {
                    setState(() => _toBase = value);
                    _convert();
                  }
                }),
              ],
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Output: $_output",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String currentValue, ValueChanged<String?> onChanged) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
        DropdownButton<String>(
          value: currentValue,
          dropdownColor: Colors.white,
          items: baseMap.keys.map((String key) {
            return DropdownMenuItem<String>(
              value: key,
              child: Text(key, style: TextStyle(color: Colors.black)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
