
import 'package:flutter/material.dart';
import '../models/expense.dart';

class ExpenseProvider with ChangeNotifier {
  final List<Expense> _expenses = [];
  final List<String> _roommates = ["Alex", "Jordan", "Taylor"];

  List<Expense> get expenses => _expenses;
  List<String> get roommates => _roommates;

  void addExpense(Expense expense) {
    _expenses.add(expense);
    notifyListeners();
  }

  void updateExpense(Expense updatedExpense) {
    final index = _expenses.indexWhere((expense) => expense.id == updatedExpense.id);
    if (index != -1) {
      _expenses[index] = updatedExpense;
      notifyListeners();
    }
  }

  void deleteExpense(String id) {
    _expenses.removeWhere((expense) => expense.id == id);
    notifyListeners();
  }
}
