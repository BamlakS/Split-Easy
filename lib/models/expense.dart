import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final double amount;
  final String description;
  final String paidBy;
  final List<String> splitAmong;
  final DateTime date;
  final String category;
  final Timestamp createdAt;

  Expense({
    required this.id,
    required this.amount,
    required this.description,
    required this.paidBy,
    required this.splitAmong,
    required this.date,
    required this.category,
    required this.createdAt,
  });

  factory Expense.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Expense(
      id: doc.id,
      amount: (data['amount'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      paidBy: data['paidBy'] ?? '',
      splitAmong: List<String>.from(data['splitAmong'] ?? []),
      date: (data['date'] as Timestamp).toDate(),
      category: data['category'] ?? '',
      createdAt: data['createdAt'] as Timestamp,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'amount': amount,
      'description': description,
      'paidBy': paidBy,
      'splitAmong': splitAmong,
      'date': Timestamp.fromDate(date),
      'category': category,
      'createdAt': createdAt,
    };
  }

  Expense copyWith({
    String? id,
    double? amount,
    String? description,
    String? paidBy,
    List<String>? splitAmong,
    DateTime? date,
    String? category,
    Timestamp? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      paidBy: paidBy ?? this.paidBy,
      splitAmong: splitAmong ?? this.splitAmong,
      date: date ?? this.date,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
