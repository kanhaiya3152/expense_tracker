import 'package:expense_tracker/api_service.dart';
import 'package:flutter/material.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  Map<String, double> _summaryData = {};

  @override
  void initState() {
    super.initState();
    _fetchSummary(); // Fetch summary from MongoDB
  }

  Future<void> _fetchSummary() async {
    try {
      List<Map<String, dynamic>> summaryList = await ApiService().getExpenseSummary();
      Map<String, double> summary = {};

      for (var item in summaryList) {
        String key = item['subcategory'] != null
            ? '${item['category']} - ${item['subcategory']}'
            : item['category'] ?? 'Unknown'; // Default to 'Unknown' if category is null
        summary[key] = item['total'];
      }

      print("Fetched Summary: $summary"); // Log the summary data
      setState(() {
        _summaryData = summary;
      });
    } catch (e) {
      print("Error fetching summary: $e");
    }
  }

  double _calculateTotalExpenditure() {
    return _summaryData.values.fold(0.0, (sum, value) => sum + value);
  }

  final Map<String, IconData> _categoryIcons = {
    'Food': Icons.fastfood,
    'Transport': Icons.directions_bus,
    'Entertainment': Icons.movie,
    'Other': Icons.category,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Center(
            child: Text(
              'Expense Summary',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),
          Divider(),
          _summaryData.isEmpty
              ? Text('No summary data available')
              : Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: _summaryData.entries.map((entry) {
                        return ListTile(
                          leading: Icon(
                            _categoryIcons[entry.key] ?? Icons.fastfood,
                            color: Colors.black45,
                          ),
                          title: Text(
                            '${entry.key}: ₹${entry.value.toStringAsFixed(2)}',
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total Expenditure: ₹${_calculateTotalExpenditure().toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}