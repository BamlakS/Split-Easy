import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/firestore_service.dart';

class ExpenseProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Expense> _expenses = [];
  List<String> _roommates = [];

  List<Expense> get expenses => _expenses;
  Stream<List<Expense>> get expensesStream => _firestoreService.getExpenses();
  List<String> get roommates => _roommates;

  ExpenseProvider() {
    _fetchRoommates();
    _firestoreService.getExpenses().listen((expenses) {
      _expenses = expenses;
      developer.log('Expenses updated from stream', name: 'ExpenseProvider');
      notifyListeners();
    });
  }

  double get totalSpending {
    return _expenses.fold(0.0, (sum, item) => sum + item.amount);
  }

  Future<void> _fetchRoommates() async {
    _roommates = await _firestoreService.getRoommates();
    notifyListeners();
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

  Future<void> addRoommate(String name) async {
    if (!_roommates.contains(name)) {
      await _firestoreService.addRoommate(name);
      _roommates.add(name);
      notifyListeners();
    }
  }

  Future<void> removeRoommate(String name) async {
    await _firestoreService.deleteRoommate(name);
    _roommates.remove(name);
    notifyListeners();
  }

  void setExpenses(List<Expense> expenses) {
    _expenses = expenses;
    notifyListeners();
  }
}
