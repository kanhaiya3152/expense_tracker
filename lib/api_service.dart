import 'dart:convert';
import 'package:http/http.dart' as http;
import 'model/expense_model.dart';

class ApiService {
  final String baseUrl = 'http://192.168.29.222:5000';

  Future<void> addExpense(Map<String, dynamic> expense) async {
  try {
    print("Sending Expense Data: ${jsonEncode(expense)}");
    final response = await http.post(
      Uri.parse('$baseUrl/addExpense'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(expense),
    );

    if (response.statusCode == 201) {
      print("Expense Added Successfully: ${response.body}");
    } else {
      print("Failed to Add Expense: ${response.body}");
    }
  } catch (e) {
    print("Error Adding Expense: $e");
  }
}

  Future<List<Expense>> getExpenses() async {
    final response = await http.get(Uri.parse('$baseUrl/expenses'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return List<Expense>.from(data.map((e) => Expense.fromJson(e)));
    } else {
      throw Exception("Failed to load expenses");
    }
  }

  Future<Map<String, double>> getExpenseSummary() async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/summary'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return {for (var item in data) item['_id']: item['total'].toDouble()};
    } else {
      throw Exception("Failed to fetch summary: ${response.statusCode}");
    }
  } catch (e) {
    print("Error fetching summary: $e");
    throw Exception("Connection error: $e");
  }
}
}
