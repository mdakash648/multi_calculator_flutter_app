import 'package:flutter/material.dart';
import 'converter_screen.dart';

void main() {
  runApp(DataConverterApp());
}

class DataConverterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ConverterScreen(),
    );
  }
}
