import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/model/expense_model.dart';

class FirestoreService {
  final CollectionReference _expensesCollection =
      FirebaseFirestore.instance.collection('expenses');

  Future<void> addExpense(Expense expense) async {
    await _expensesCollection.add(expense.toMap());
  }

  Stream<List<Expense>> getExpenses() {
    return _expensesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Expense.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
}
