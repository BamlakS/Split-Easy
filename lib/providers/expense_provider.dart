
import 'package:flutter/material.dart';
import '../models/expense.dart';

class ExpenseProvider with ChangeNotifier {
  final List<Expense> _expenses = [];
  List<String> _roommates = ["Alex", "Jordan", "Taylor"];
  String? _touchedRoommate;

  List<Expense> get expenses => _expenses;
  List<String> get roommates => _roommates;
  String? get touchedRoommate => _touchedRoommate;

  double get totalSpending {
    return _expenses.fold(0.0, (sum, item) => sum + item.amount);
  }

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

  void addRoommate(String name) {
    if (!_roommates.contains(name)) {
      _roommates.add(name);
      notifyListeners();
    }
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
