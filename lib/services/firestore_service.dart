import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _userId = "demoUser";

  // Get a stream of expenses
  Stream<List<Expense>> getExpenses() {
    return _db
        .collection('users')
        .doc(_userId)
        .collection('expenses')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      developer.log('Received expense snapshot with ${snapshot.docs.length} documents', name: 'FirestoreService');
      return snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList();
    });
  }

  // Add a new expense
  Future<void> addExpense(Expense expense) {
    return _db
        .collection('users')
        .doc(_userId)
        .collection('expenses')
        .add(expense.toFirestore());
  }

  // Update an existing expense
  Future<void> updateExpense(Expense expense) {
    return _db
        .collection('users')
        .doc(_userId)
        .collection('expenses')
        .doc(expense.id)
        .update(expense.toFirestore());
  }

  // Delete an expense
  Future<void> deleteExpense(String expenseId) {
    return _db
        .collection('users')
        .doc(_userId)
        .collection('expenses')
        .doc(expenseId)
        .delete();
  }

  // Roommate Methods
  Future<List<String>> getRoommates() async {
    try {
      final snapshot = await _db.collection('users').doc(_userId).collection('roommates').get();
      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      developer.log("Error fetching roommates: $e", name: 'FirestoreService');
      return [];
    }
  }

  Future<void> addRoommate(String name) {
    return _db
        .collection('users')
        .doc(_userId)
        .collection('roommates')
        .doc(name)
        .set({});
  }

  Future<void> deleteRoommate(String name) {
    return _db
        .collection('users')
        .doc(_userId)
        .collection('roommates')
        .doc(name)
        .delete();
  }
}
