import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


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
      home: const AgeCalculator(),
    );
  }
}

class AgeCalculator extends StatefulWidget {
  const AgeCalculator({super.key});

  @override
  _AgeCalculatorState createState() => _AgeCalculatorState();
}

class _AgeCalculatorState extends State<AgeCalculator> {
  DateTime? _selectedDate;
  int? years, months, days;
  int? nextBirthdayDays;
  String? nextBirthdayMonth;

  // Function to open date picker
  Future<void> _selectDate(BuildContext context) async {
    DateTime currentDate = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(1900),
      lastDate: currentDate,
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _calculateAge();
      });
    }
  }

  // Function to calculate age and next birthday
  void _calculateAge() {
    if (_selectedDate == null) return;

    DateTime today = DateTime.now();
    Duration difference = today.difference(_selectedDate!);
    years = difference.inDays ~/ 365;

    DateTime lastBirthday = DateTime(today.year, _selectedDate!.month, _selectedDate!.day);
    if (lastBirthday.isAfter(today)) {
      years = years! - 1;
    }

    DateTime previousBirthday = DateTime(today.year, _selectedDate!.month, _selectedDate!.day);
    if (previousBirthday.isAfter(today)) {
      previousBirthday = DateTime(today.year - 1, _selectedDate!.month, _selectedDate!.day);
    }

    Duration ageDuration = today.difference(previousBirthday);
    months = (ageDuration.inDays ~/ 30) % 12;
    days = ageDuration.inDays % 30;

    // Calculate next birthday
    DateTime nextBirthday = DateTime(today.year, _selectedDate!.month, _selectedDate!.day);
    if (nextBirthday.isBefore(today) || nextBirthday.isAtSameMomentAs(today)) {
      nextBirthday = DateTime(today.year + 1, _selectedDate!.month, _selectedDate!.day);
    }

    Duration nextBdayDuration = nextBirthday.difference(today);
    nextBirthdayDays = nextBdayDuration.inDays;
    nextBirthdayMonth = DateFormat('MMMM').format(nextBirthday);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Center( // ✅ Center everything on the screen
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center, // ✅ Center-align content
            children: [
              Text(
                _selectedDate == null
                    ? "Select your birthdate"
                    : "Selected Date: ${DateFormat('dd MMMM yyyy').format(_selectedDate!)}",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center, // ✅ Center-align text
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _selectDate(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text("Pick a Date"),
              ),
              const SizedBox(height: 30),
              _selectedDate == null
                  ? const SizedBox()
                  : Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(15),
                          constraints: const BoxConstraints(
                            minWidth: 100, // ✅ Minimum width to avoid too small boxes
                            maxWidth: 300, // ✅ Maximum width to fit content
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.blueAccent),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min, // ✅ Box adjusts to content size
                            children: [
                              const Text(
                                "Your Age",
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "$years Years, $months Months, $days Days",
                                style: const TextStyle(fontSize: 18),
                                textAlign: TextAlign.center, // ✅ Center-align text
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(15),
                          constraints: const BoxConstraints(
                            minWidth: 100, // ✅ Minimum width to avoid too small boxes
                            maxWidth: 300, // ✅ Maximum width to fit content
                          ),
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.green),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min, // ✅ Box adjusts to content size
                            children: [
                              const Text(
                                "Next Birthday",
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "In $nextBirthdayDays days (${nextBirthdayMonth!})",
                                style: const TextStyle(fontSize: 18),
                                textAlign: TextAlign.center, // ✅ Center-align text
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
