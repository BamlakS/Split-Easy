
class Expense {
  String id;
  double amount;
  String description;
  String paidBy;
  List<Map<String, dynamic>> splitAmong; // [{name: String, owes: double}]
  DateTime date;

  Expense({
    required this.id,
    required this.amount,
    required this.description,
    required this.paidBy,
    required this.splitAmong,
    required this.date,
  });

  Expense copyWith({
    String? id,
    double? amount,
    String? description,
    String? paidBy,
    List<Map<String, dynamic>>? splitAmong,
    DateTime? date,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      paidBy: paidBy ?? this.paidBy,
      splitAmong: splitAmong ?? this.splitAmong,
      date: date ?? this.date,
    );
  }
}
