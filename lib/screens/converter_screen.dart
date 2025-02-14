import 'package:flutter/material.dart';
import 'conversion_logic.dart';

class ConverterScreen extends StatefulWidget {
  @override
  _ConverterScreenState createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  String _fromUnit = "Megabyte";
  String _toUnit = "Gigabyte";

  final List<String> units = ["Byte", "Kilobyte", "Megabyte", "Gigabyte", "Terabyte", "Petabyte"];

  void _updateConversion() {
    double value = double.tryParse(_controller1.text) ?? 0.0;
    setState(() {
      _controller2.text = convertData(value, _fromUnit, _toUnit).toString();
    });
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
    return Scaffold(
      
      body: Container(
        padding: EdgeInsets.all(16.0),
        color: Color(0xFFFAFAFA), // Solid off-white background
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Text("From:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _controller1,
                    keyboardType: TextInputType.number,
                    onChanged: (value) => _updateConversion(),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: _fromUnit,
                  onChanged: (String? newValue) {
                    setState(() => _fromUnit = newValue!);
                    _updateConversion();
                  },
                  items: units.map((String unit) {
                    return DropdownMenuItem<String>(value: unit, child: Text(unit));
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: 10),
            IconButton(
              icon: Icon(Icons.swap_vert, color: Colors.green, size: 24),
              onPressed: _swapUnits,
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text("To:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(width: 28),
                Expanded(
                  child: TextField(
                    controller: _controller2,
                    readOnly: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: _toUnit,
                  onChanged: (String? newValue) {
                    setState(() => _toUnit = newValue!);
                    _updateConversion();
                  },
                  items: units.map((String unit) {
                    return DropdownMenuItem<String>(value: unit, child: Text(unit));
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _clearFields,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text("Clear", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
