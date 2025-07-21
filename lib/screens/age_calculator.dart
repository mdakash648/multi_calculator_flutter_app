import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AgeCalculator extends StatefulWidget {
  const AgeCalculator({super.key});

  @override
  AgeCalculatorState createState() => AgeCalculatorState();
}

class AgeCalculatorState extends State<AgeCalculator> {
  DateTime? _selectedDate;
  int? years, months, days;
  int? nextBirthdayDays;
  String? nextBirthdayMonth;

  Future<void> _selectDate(BuildContext context) async {
    DateTime currentDate = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(1900),
      lastDate: currentDate,
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: Color(0xFF4C8BF5),
                    onPrimary: Colors.white,
                    surface: Color(0xFF2A2A2A),
                    onSurface: Color(0xFFE0E0E0),
                  )
                : const ColorScheme.light(
                    primary: Color(0xFF3F51B5),
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Color(0xFF333333),
                  ),
            dialogBackgroundColor:
                isDark ? const Color(0xFF2A2A2A) : Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _calculateAge();
      });
    }
  }

  void _calculateAge() {
    if (_selectedDate == null) return;

    DateTime today = DateTime.now();
    Duration difference = today.difference(_selectedDate!);
    years = difference.inDays ~/ 365;

    DateTime lastBirthday =
        DateTime(today.year, _selectedDate!.month, _selectedDate!.day);
    if (lastBirthday.isAfter(today)) {
      years = years! - 1;
    }

    DateTime previousBirthday =
        DateTime(today.year, _selectedDate!.month, _selectedDate!.day);
    if (previousBirthday.isAfter(today)) {
      previousBirthday =
          DateTime(today.year - 1, _selectedDate!.month, _selectedDate!.day);
    }

    Duration ageDuration = today.difference(previousBirthday);
    months = (ageDuration.inDays ~/ 30) % 12;
    days = ageDuration.inDays % 30;

    DateTime nextBirthday =
        DateTime(today.year, _selectedDate!.month, _selectedDate!.day);
    if (nextBirthday.isBefore(today) || nextBirthday.isAtSameMomentAs(today)) {
      nextBirthday =
          DateTime(today.year + 1, _selectedDate!.month, _selectedDate!.day);
    }

    Duration nextBdayDuration = nextBirthday.difference(today);
    nextBirthdayDays = nextBdayDuration.inDays;
    nextBirthdayMonth = DateFormat('MMMM').format(nextBirthday);

    // Save to history
    _saveToHistory();
  }

  Future<void> _saveToHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList('calculation_history') ?? [];

      final birthDate = DateFormat('dd MMMM yyyy').format(_selectedDate!);
      final ageResult = '$years years, $months months, $days days';

      final historyItem = {
        'equation': 'Birth Date: $birthDate',
        'result': ageResult,
        'timestamp': DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now()),
        'type': 'age',
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

  void setBirthDateFromHistory(String equation) {
    // equation is like 'Birth Date: 01 January 2000'
    final regex = RegExp(r'Birth Date: (.+)');
    final match = regex.firstMatch(equation);
    if (match != null) {
      final dateStr = match.group(1);
      try {
        final date = DateFormat('dd MMMM yyyy').parse(dateStr!);
        setState(() {
          _selectedDate = date;
          _calculateAge();
        });
      } catch (e) {
        // ignore parse error
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final primaryBtnColor =
        isDark ? const Color(0xFF4C8BF5) : const Color(0xFF3F51B5);
    final textColor = isDark ? Colors.white : const Color(0xFF333333);
    final subtitleColor =
        isDark ? const Color(0xFFBBBBBB) : const Color(0xFF666666);
    final iconColor =
        isDark ? const Color(0xFF4C8BF5) : const Color(0xFF3F51B5);

    return Container(
      color: bgColor,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: cardColor,
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
                Icon(
                  Icons.cake,
                  size: 48,
                  color: iconColor,
                ),
                const SizedBox(height: 16),
                Text(
                  _selectedDate == null
                      ? "Select your birthdate"
                      : "Selected Date: ${DateFormat('dd MMMM yyyy').format(_selectedDate!)}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _selectDate(context),
                  icon: const Icon(Icons.calendar_today),
                  label: const Text("Pick a Date"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBtnColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Results Section
          if (_selectedDate != null) ...[
            // Age Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: cardColor,
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.person,
                          color: iconColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        "Your Age",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: iconColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "$years Years, $months Months, $days Days",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "(Calculated based on your selected date)",
                    style: TextStyle(
                      fontSize: 14,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),

            // Next Birthday Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardColor,
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.celebration,
                          color: Color(0xFF4CAF50),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        "Next Birthday",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "In $nextBirthdayDays days (${nextBirthdayMonth!})",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "(Days left until your next birthday)",
                    style: TextStyle(
                      fontSize: 14,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
