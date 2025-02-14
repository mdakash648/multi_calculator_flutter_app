import 'package:flutter/material.dart';
import 'screens/advanced_calculator.dart';
import 'screens/age_calculator.dart';
import 'screens/data_converter.dart';
import 'screens/numeral_system.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    AdvancedCalculator(),  // Removed 'const' here
    AgeCalculator(),       // Removed 'const' here
    DataConverterApp(),    // Removed 'const' here
    NumeralConverterApp(), // Removed 'const' here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multi Calculator'),
        backgroundColor: Colors.blue,
      ),
      body: _screens[_currentIndex], // Display current screen based on _currentIndex
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Switch screens
          });
        },
        backgroundColor: Colors.blue, // Set the background color to blue
        selectedItemColor: Colors.red, // Set the selected item color to white
        unselectedItemColor: Colors.blue,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Advanced Calculator',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cake),
            label: 'Age Calculator',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storage),
            label: 'Data Converter',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.transform),
            label: 'Numeral Converter',
          ),
        ],
      ),
    );
  }
}
