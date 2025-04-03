import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final double amount;
  final String category;
  final String? subcategory; // Add subcategory as an optional field
  final DateTime date;

  Expense({
    required this.amount,
    required this.category,
    this.subcategory, // Optional subcategory
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'category': category,
      'subcategory': subcategory, // Include subcategory in the map
      'date': date.toIso8601String(), // Use ISO 8601 format for consistency
    };
  }

  factory Expense.fromMap(Map<String, dynamic> json) {
    return Expense(
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] as String? ?? 'Unknown',
      subcategory: json['subcategory'] as String?, // Parse subcategory
      date: _parseDate(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'category': category,
      'subcategory': subcategory, // Include subcategory in JSON
      'date': date.toIso8601String(), // Use ISO 8601 format for consistency
    };
  }

  static Expense fromJson(Map<String, dynamic> json) {
    return Expense.fromMap(json);
  }

  // Helper method to parse the date field
  static DateTime _parseDate(dynamic date) {
    if (date is Timestamp) {
      return date.toDate(); // Convert Firestore Timestamp to DateTime
    } else if (date is String) {
      return DateTime.parse(date); // Parse ISO 8601 string to DateTime
    } else {
      return DateTime.now(); // Default to current time if the format is unknown
    }
  }
}