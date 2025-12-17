
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';

class SeeBalancesScreen extends StatelessWidget {
  const SeeBalancesScreen({super.key});

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Groceries':
        return Icons.shopping_cart;
      case 'Utilities':
        return Icons.lightbulb_outline;
      case 'Rent':
        return Icons.home;
      case 'Entertainment':
        return Icons.movie;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final expenses = expenseProvider.expenses;
    final roommates = expenseProvider.roommates;

    // Calculate balances
    Map<String, double> balances = {};
    for (var roommate in roommates) {
      balances[roommate] = 0.0;
    }
    for (var expense in expenses) {
      balances[expense.paidBy] = (balances[expense.paidBy] ?? 0) + expense.amount;
      for (var split in expense.splitAmong) {
        balances[split['name']] = (balances[split['name']] ?? 0) - (split['owes'] as double);
      }
    }
    final sortedBalances = balances.entries.toList()
      ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));

    // Calculate spending by category
    Map<String, double> spendingByCategory = {};
    for (var expense in expenses) {
      spendingByCategory.update(expense.category, (value) => value + expense.amount, ifAbsent: () => expense.amount);
    }
    final sortedCategories = spendingByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F7),
      appBar: AppBar(
        title: const Text('Balances & Spending'),
      ),
      body: expenses.isEmpty
          ? const Center(
              child: Text(
                'No expenses yet. Add expenses to see balances!',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(8.0),
              children: [
                // Balances Section
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                  child: Text(
                    'Current Balances',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
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
                      text = 'Is owed \$${balance.toStringAsFixed(2)}';
                    } else if (balance < -0.01) {
                      icon = Icons.arrow_upward;
                      color = const Color(0xFFE89A49);
                      text = 'Owes \$${(-balance).toStringAsFixed(2)}';
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

                const SizedBox(height: 24),
                const Divider(thickness: 1),
                const SizedBox(height: 16),

                // Spending by Category Section
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                  child: Text(
                    'Spending by Category',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                ...sortedCategories.map((entry) {
                  final category = entry.key;
                  final total = entry.value;
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ListTile(
                      leading: Icon(_getCategoryIcon(category), color: Theme.of(context).primaryColor, size: 30),
                      title: Text(category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      trailing: Text(
                        '\$${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFFA7DBD8),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
    );
  }
}
