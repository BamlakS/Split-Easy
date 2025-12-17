import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/firestore_service.dart';

class ExpenseProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Expense> _expenses = [];
  List<String> _roommates = ["Alex", "Jordan", "Taylor"];
  String? _touchedRoommate;

  List<Expense> get expenses => _expenses;
  Stream<List<Expense>> get expensesStream => _firestoreService.getExpenses();
  List<String> get roommates => _roommates;
  String? get touchedRoommate => _touchedRoommate;

  double get totalSpending {
    return _expenses.fold(0.0, (sum, item) => sum + item.amount);
  }

  Future<void> addExpense(Expense expense) async {
    await _firestoreService.addExpense(expense);
  }

  Future<void> updateExpense(Expense expense) async {
    await _firestoreService.updateExpense(expense);
  }

  Future<void> deleteExpense(String id) async {
    await _firestoreService.deleteExpense(id);
  }

  void addRoommate(String name) {
    if (!_roommates.contains(name)) {
      _roommates.add(name);
      notifyListeners();
    }
  }
  
  void setExpenses(List<Expense> expenses) {
    _expenses = expenses;
    notifyListeners();
  }

  void setTouchedRoommate(String roommate) {
    _touchedRoommate = roommate;
    notifyListeners();
  }

  void clearTouchedRoommate() {
    _touchedRoommate = null;
    notifyListeners();
  }
}
