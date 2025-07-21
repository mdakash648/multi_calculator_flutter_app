import 'package:flutter/material.dart';
import 'screens/advanced_calculator.dart';
import 'screens/age_calculator.dart';
import 'screens/data_converter.dart';
import 'screens/numeral_system.dart';
import 'screens/history_screen.dart'; // Added import for HistoryScreen
import 'screens/converter_screen.dart';
import 'dart:io';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system; // Default to system theme

  void _toggleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.system) {
        // If currently system, switch to light
        _themeMode = ThemeMode.light;
      } else if (_themeMode == ThemeMode.light) {
        // If currently light, switch to dark
        _themeMode = ThemeMode.dark;
      } else {
        // If currently dark, switch back to system
        _themeMode = ThemeMode.system;
      }
    });
  }

  String _getThemeModeText() {
    switch (_themeMode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  IconData _getThemeModeIcon() {
    switch (_themeMode) {
      case ThemeMode.system:
        return Icons.brightness_auto;
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.indigo,
        primaryColor: const Color(0xFF3F51B5),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF3F51B5),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3F51B5),
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3F51B5), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.indigo,
        primaryColor: const Color(0xFF3F51B5),
        scaffoldBackgroundColor: const Color(0xFF181A20),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF23243A),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3F51B5),
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: const Color(0xFF23243A),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF23243A)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF23243A)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3F51B5), width: 2),
          ),
          filled: true,
          fillColor: const Color(0xFF23243A),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      home: MainScreen(onToggleTheme: _toggleTheme, themeMode: _themeMode),
    );
  }
}

class AlwaysOnTopController {
  static const MethodChannel _channel =
      MethodChannel('multi_calculator/always_on_top');
  static Future<void> setAlwaysOnTop(bool value) async {
    try {
      await _channel.invokeMethod('setAlwaysOnTop', {'value': value});
    } catch (e) {
      // ignore
    }
  }
}

class MainScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;
  const MainScreen(
      {super.key, required this.onToggleTheme, required this.themeMode});

  String getThemeModeText() {
    switch (themeMode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  IconData getThemeModeIcon() {
    switch (themeMode) {
      case ThemeMode.system:
        return Icons.brightness_auto;
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
    }
  }

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _alwaysOnTop = false;
  int _currentIndex = 0;

  AdvancedCalculatorState? _calculatorState;
  final GlobalKey<AgeCalculatorState> _ageKey = GlobalKey<AgeCalculatorState>();
  final GlobalKey<ConverterScreenState> _converterKey =
      GlobalKey<ConverterScreenState>();
  final GlobalKey<NumeralConverterScreenState> _numeralKey =
      GlobalKey<NumeralConverterScreenState>();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      AdvancedCalculator(
        onCalculatorCreated: (state) {
          _calculatorState = state;
        },
      ),
      AgeCalculator(key: _ageKey),
      ConverterScreen(key: _converterKey),
      NumeralConverterScreen(key: _numeralKey),
    ];
  }

  final List<String> _titles = [
    'Advanced Calculator',
    'Age Calculator',
    'Data Converter',
    'Numeral Converter',
  ];

  void _navigateToHistory() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HistoryScreen(
          onSelectHistory: (type, equation, result) {
            if (type == 'calculator') {
              setState(() {
                _currentIndex = 0;
              });
              _calculatorState?.setEquationFromHistory(equation);
            } else if (type == 'age') {
              setState(() {
                _currentIndex = 1;
              });
              _ageKey.currentState?.setBirthDateFromHistory(equation);
            } else if (type == 'data') {
              setState(() {
                _currentIndex = 2;
              });
              _converterKey.currentState?.setDataFromHistory(equation, result);
            } else if (type == 'numeral') {
              setState(() {
                _currentIndex = 3;
              });
              _numeralKey.currentState?.setNumeralFromHistory(equation, result);
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.history),
          onPressed: _navigateToHistory,
          tooltip: 'View History',
        ),
        title: Text(_titles[_currentIndex]),
        actions: [
          IconButton(
            icon: Icon(widget.getThemeModeIcon()),
            tooltip: 'Theme: ${widget.getThemeModeText()}',
            onPressed: widget.onToggleTheme,
          ),
          if (Platform.isWindows)
            IconButton(
              icon:
                  Icon(_alwaysOnTop ? Icons.push_pin : Icons.push_pin_outlined),
              tooltip: _alwaysOnTop
                  ? 'Disable Always on Top'
                  : 'Enable Always on Top',
              onPressed: () async {
                setState(() {
                  _alwaysOnTop = !_alwaysOnTop;
                });
                await AlwaysOnTopController.setAlwaysOnTop(_alwaysOnTop);
              },
            ),
        ],
      ),
      body: Container(
        color: theme.scaffoldBackgroundColor,
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: theme.colorScheme.surface,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.unselectedWidgetColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate_outlined),
            activeIcon: Icon(Icons.calculate),
            label: 'Calculator',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cake_outlined),
            activeIcon: Icon(Icons.cake),
            label: 'Age',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storage_outlined),
            activeIcon: Icon(Icons.storage),
            label: 'Data',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.format_list_numbered_outlined),
            activeIcon: Icon(Icons.format_list_numbered),
            label: 'Numeral',
          ),
        ],
      ),
    );
  }
}
