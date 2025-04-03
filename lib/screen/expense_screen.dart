import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/api_service.dart';
import 'package:expense_tracker/model/expense_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ExpenseScreen extends StatefulWidget {
  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final TextEditingController _amountController = TextEditingController();
  String _selectedCategory = 'Food';
  String? _selectedSubcategory;
  final List<String> _categories = [
    'Food',
    'Transport',
    'Entertainment',
    'Other'
  ];
  final List<String> _foodSubcategories = [
    'Groceries',
    'Dining Out',
    'Snacks',
    'Beverages'
  ];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Map<String, IconData> _categoryIcons = {
    'Food': Icons.fastfood,
    'Transport': Icons.directions_bus,
    'Entertainment': Icons.movie,
    'Other': Icons.category,
  };

  Map<String, double> _summaryData = {};
  final userId = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    _fetchSummary(); // Fetch summary from MongoDB
  }

  // Fetch summary data from MongoDB
  Future<void> _fetchSummary() async {
    try {
      Map<String, double> summary = await ApiService().getExpenseSummary();
      print("Fetched Summary: $summary"); // Log the summary data
      setState(() {
        _summaryData = summary;
      });
    } catch (e) {
      print("Error fetching summary: $e");
    }
  }

  // Add expense to Firestore
  void _addExpense() async {
    if (_amountController.text.isEmpty) return;

    try {
      double amount = double.tryParse(_amountController.text) ?? 0;
      if (amount <= 0) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Enter a valid amount")));
        return;
      }

      // Include subcategory only if the category is "Food"
      String? subcategory = _selectedCategory == 'Food' ? _selectedSubcategory : null;

      Expense expense = Expense(
        amount: amount,
        category: _selectedCategory,
        subcategory: subcategory, // Add subcategory to the expense
        date: DateTime.now(),
      );

      print("Adding Expense: ${expense.toJson()}"); // Log the expense data

      // Call the ApiService to add the expense to MongoDB
      await ApiService().addExpense(expense.toJson());

      await _firestore
          .collection('users')
          .doc(userId.uid)
          .collection('expenses')
          .add(expense.toJson());

      _amountController.clear();
      setState(() {
        _selectedSubcategory = null; // Reset subcategory after adding
      }); // Refresh UI after adding
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Expense added successfully")));
    } catch (e) {
      print("Error adding expense: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Tracker'),
        backgroundColor: Color.fromARGB(255, 141, 127, 127),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter Amount',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedCategory = newValue!;
                      _selectedSubcategory = null; // Reset subcategory when category changes
                    });
                  },
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Row(
                        children: [
                          Icon(_categoryIcons[category], color: Colors.black54),
                          SizedBox(width: 10),
                          Text(category, style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    );
                  }).toList(),
                  icon: Icon(Icons.arrow_drop_down, color: Colors.black54),
                ),
              ),
            ),
            if (_selectedCategory == 'Food') ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedSubcategory,
                    isExpanded: true,
                    hint: Text("Select Subcategory"),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedSubcategory = newValue!;
                      });
                    },
                    items: _foodSubcategories.map((subcategory) {
                      return DropdownMenuItem(
                        value: subcategory,
                        child: Text(subcategory, style: TextStyle(fontSize: 16)),
                      );
                    }).toList(),
                    icon: Icon(Icons.arrow_drop_down, color: Colors.black54),
                  ),
                ),
              ),
            ],
            SizedBox(height: 18),
            ElevatedButton(
              onPressed: _addExpense,
              child: Text('Add Expense', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 20),
            Divider(),

            // Display Expense Summary from MongoDB
            Text(
              'Expense Summary ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            _summaryData.isEmpty
                ? Text('No summary data available')
                : Column(
                    children: _summaryData.entries.map((entry) {
                      return ListTile(
                        leading: Icon(
                            _categoryIcons[entry.key] ?? Icons.category,
                            color: Colors.black45),
                        title: Text(
                            '${entry.key}: \$${entry.value.toStringAsFixed(2)}'),
                      );
                    }).toList(),
                  ),
            Divider(),

            // Display Expenses from Firestore
            Text(
              'Expense List',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
                child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .doc(userId.uid)
                  .collection('expenses')
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  print("Error loading expenses: ${snapshot.error}");
                  return Center(child: Text("Error loading expenses"));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No expenses recorded"));
                }
                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    Map<String, dynamic> data =
                        doc.data() as Map<String, dynamic>;
                    Expense expense = Expense.fromJson(data);
                    return Card(
                      color: Color.fromARGB(189, 211, 190, 190),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: Icon(
                          _categoryIcons[expense.category] ?? Icons.category,
                          color: Colors.black45,
                        ),
                        title: Text(
                          '${expense.category}: \$${expense.amount.toStringAsFixed(2)}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(expense.date.toString(),
                            style: TextStyle(color: Colors.grey[800])),
                      ),
                    );
                  }).toList(),
                );
              },
            )),
          ],
        ),
      ),
    );
  }
}