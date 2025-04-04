import 'dart:convert';
import 'package:http/http.dart' as http;
import 'model/expense_model.dart';

class ApiService {
  final String baseUrl = 'http://192.168.29.222:5000';

  Future<String> addExpense(Map<String, dynamic> expense) async {
  try {
    print("Sending Expense Data: ${jsonEncode(expense)}");
    final response = await http.post(
      Uri.parse('$baseUrl/addExpense'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(expense),
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      print("Expense Added Successfully: $responseData");
      return responseData['_id']; // Return the MongoDB ID
    } else {
      print("Failed to Add Expense: ${response.body}");
      throw Exception("Failed to add expense: ${response.statusCode}");
    }
  } catch (e) {
    print("Error Adding Expense: $e");
    throw Exception("Error Adding Expense: $e");
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

  Future<List<Map<String, dynamic>>> getExpenseSummary() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/summary'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data.map((item) => {
              'category':
                  item['category'] ?? 'Unknown', // Default to 'Unknown' if null
              'subcategory': item['subcategory'], // Allow null values
              'total': item['total'].toDouble(),
            }));
      } else {
        throw Exception("Failed to fetch summary: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching summary: $e");
      throw Exception("Connection error: $e");
    }
  }

  Future<void> deleteExpense(String mongoId) async {
  if (mongoId.isEmpty) {
    print("Error: MongoDB ID is empty");
    throw Exception("MongoDB ID is missing");
  }

  try {
    print("Deleting Expense with MongoDB ID: $mongoId");
    final response =
        await http.delete(Uri.parse('$baseUrl/deleteExpense/$mongoId'));

    if (response.statusCode != 200) {
      print("Failed to delete expense: ${response.body}");
      throw Exception("Failed to delete expense from MongoDB");
    } else {
      print("Expense deleted successfully from MongoDB");
    }
  } catch (e) {
    print("Error deleting expense from MongoDB: $e");
    throw Exception("Connection error: $e");
  }
}
}
