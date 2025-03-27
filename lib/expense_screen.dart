import 'package:expense_tracker/expense_model.dart';
import 'package:expense_tracker/service.dart';
import 'package:flutter/material.dart';

class ExpenseScreen extends StatefulWidget {
  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final TextEditingController _amountController = TextEditingController();
  String _selectedCategory = 'Food';
  final List<String> _categories = ['Food', 'Transport', 'Entertainment', 'Other'];
  final FirestoreService _firestoreService = FirestoreService();

  final Map<String, IconData> _categoryIcons = {
    'Food': Icons.fastfood,
    'Transport': Icons.directions_bus,
    'Entertainment': Icons.movie,
    'Other': Icons.category,
  };

  void _addExpense() async {
    if (_amountController.text.isEmpty) return;
    Expense expense = Expense(
      amount: double.parse(_amountController.text),
      category: _selectedCategory,
      date: DateTime.now(),
    );
    await _firestoreService.addExpense(expense);
    _amountController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Tracker'),
        backgroundColor: const Color.fromARGB(255, 141, 127, 127),
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
                  borderRadius: BorderRadius.circular(12.0),
                ),
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
            SizedBox(height: 18),
            ElevatedButton(
              onPressed: _addExpense,
              child: Text('Add Expense', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 20),
            Divider(),
            Expanded(
              child: StreamBuilder(
                stream: _firestoreService.getExpenses(),
                builder: (context, AsyncSnapshot<List<Expense>> snapshot) {
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                  return ListView(
                    children: snapshot.data!.map((expense) {
                      return Card(
                        color:  const Color.fromARGB(189, 211, 190, 190),
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: Icon(
                            _categoryIcons[expense.category] ?? Icons.category,
                            color: Colors.black45,
                          ),
                          title: Text(
                            '${expense.category}: \$${expense.amount}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            expense.date.toString(),
                            style: TextStyle(color: Colors.grey[800]),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
