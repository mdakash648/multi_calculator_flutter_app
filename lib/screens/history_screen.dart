import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HistoryItem> _historyItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList('calculation_history') ?? [];

      setState(() {
        _historyItems = historyJson
            .map((item) => HistoryItem.fromJson(jsonDecode(item)))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear History'),
        content:
            Text('Are you sure you want to clear all calculation history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Clear'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('calculation_history');
        setState(() {
          _historyItems.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('History cleared successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to clear history')),
        );
      }
    }
  }

  Future<void> _deleteItem(HistoryItem item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _historyItems.remove(item);

      final historyJson =
          _historyItems.map((item) => jsonEncode(item.toJson())).toList();

      await prefs.setStringList('calculation_history', historyJson);

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item deleted from history')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete item')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('History'),
        actions: [
          if (_historyItems.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_sweep, color: Colors.red),
              onPressed: _clearHistory,
              tooltip: 'Clear All History',
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _historyItems.isEmpty
              ? _buildEmptyState()
              : _buildHistoryList(),
      floatingActionButton: _historyItems.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _clearHistory,
              backgroundColor: Colors.red,
              icon: Icon(Icons.delete_sweep, color: Colors.white),
              label: Text('Clear All', style: TextStyle(color: Colors.white)),
              tooltip: 'Clear All History',
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: theme.hintColor,
          ),
          SizedBox(height: 16),
          Text(
            'No History Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.hintColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Your calculations will appear here',
            style: TextStyle(
              fontSize: 16,
              color: theme.hintColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    final theme = Theme.of(context);

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _historyItems.length,
      itemBuilder: (context, index) {
        final item = _historyItems[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            title: Text(
              item.equation,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                Text(
                  '= ${item.result}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  item.timestamp,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _deleteItem(item),
              tooltip: 'Delete this item',
            ),
            onTap: () {
              // Copy to clipboard
              final text = '${item.equation} = ${item.result}';
              // You can add clipboard functionality here if needed
            },
          ),
        );
      },
    );
  }
}

class HistoryItem {
  final String equation;
  final String result;
  final String timestamp;
  final String type; // 'calculator', 'age', 'data', 'numeral'

  HistoryItem({
    required this.equation,
    required this.result,
    required this.timestamp,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'equation': equation,
      'result': result,
      'timestamp': timestamp,
      'type': type,
    };
  }

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      equation: json['equation'] ?? '',
      result: json['result'] ?? '',
      timestamp: json['timestamp'] ?? '',
      type: json['type'] ?? 'calculator',
    );
  }
}
