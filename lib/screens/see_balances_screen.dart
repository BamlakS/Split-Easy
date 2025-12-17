
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';

class SeeBalancesScreen extends StatelessWidget {
  const SeeBalancesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final expenses = expenseProvider.expenses;
    final roommates = expenseProvider.roommates;

    Map<String, double> balances = {};
    for (var roommate in roommates) {
      balances[roommate] = 0.0;
    }

    for (var expense in expenses) {
      // Add to the balance of the person who paid
      balances[expense.paidBy] = (balances[expense.paidBy] ?? 0) + expense.amount;

      // Subtract from the balance of those who owe
      for (var split in expense.splitAmong) {
        balances[split['name']] = (balances[split['name']] ?? 0) - (split['owes'] as double);
      }
    }

    final sortedBalances = balances.entries.toList()
      ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));

    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F7),
      appBar: AppBar(
        title: const Text('Balances'),
      ),
      body: expenses.isEmpty
          ? const Center(
              child: Text(
                'No expenses yet. Add expenses to see balances!',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: sortedBalances.length,
              itemBuilder: (context, index) {
                final entry = sortedBalances[index];
                final roommate = entry.key;
                final balance = entry.value;

                IconData icon;
                Color color;
                String text;

                if (balance > 0.01) {
                  icon = Icons.arrow_downward;
                  color = Colors.green;
                  text = 'Is owed S${balance.toStringAsFixed(2)}';
                } else if (balance < -0.01) {
                  icon = Icons.arrow_upward;
                  color = const Color(0xFFE89A49);
                  text = 'Owes S${(-balance).toStringAsFixed(2)}';
                } else {
                  icon = Icons.check_circle_outline;
                  color = Colors.grey;
                  text = 'All settled up!';
                }

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(icon, color: color, size: 40),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              roommate,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              text,
                              style: TextStyle(
                                fontSize: 18,
                                color: color,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
