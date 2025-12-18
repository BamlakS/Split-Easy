import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/expense.dart';
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

  List<Map<String, dynamic>> _calculateDirectSettlements(List<Expense> expenses, List<String> roommates) {
    Map<String, double> directDebts = {};

    for (var expense in expenses) {
      String payer = expense.paidBy;
      final splitCount = expense.splitAmong.length;
      if (splitCount == 0) continue;
      final amountPerPerson = expense.amount / splitCount;

      for (var borrower in expense.splitAmong) {
        if (payer != borrower) {
          String key = '$borrower -> $payer';
          directDebts.update(key, (value) => value + amountPerPerson, ifAbsent: () => amountPerPerson);
        }
      }
    }

    Map<String, double> simplifiedDebts = {};
    Map<String, double> debtsCopy = Map.from(directDebts);

    debtsCopy.forEach((key, amount) {
      if (!simplifiedDebts.containsKey(key)) {
        List<String> parts = key.split(' -> ');
        String borrower = parts[0];
        String lender = parts[1];

        String reverseKey = '$lender -> $borrower';

        if (debtsCopy.containsKey(reverseKey)) {
          double reverseAmount = debtsCopy[reverseKey]!;
          if (amount > reverseAmount) {
            simplifiedDebts[key] = amount - reverseAmount;
            simplifiedDebts[reverseKey] = 0; 
          } else {
            simplifiedDebts[reverseKey] = reverseAmount - amount;
            simplifiedDebts[key] = 0; 
          }
        } else {
          simplifiedDebts[key] = amount;
        }
      }
    });

    List<Map<String, dynamic>> settlements = [];
    simplifiedDebts.forEach((key, amount) {
      if (amount > 0.01) {
        List<String> parts = key.split(' -> ');
        settlements.add({
          'from': parts[0],
          'to': parts[1],
          'amount': amount,
        });
      }
    });

    return settlements;
  }

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
      balances[expense.paidBy] = (balances[expense.paidBy] ?? 0) + expense.amount;
      final splitCount = expense.splitAmong.length;
      if (splitCount > 0) {
        final amountPerPerson = expense.amount / splitCount;
        for (var roommateName in expense.splitAmong) {
          balances[roommateName] = (balances[roommateName] ?? 0) - amountPerPerson;
        }
      }
    }
    final sortedBalances = balances.entries.toList()
      ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));

    final settlements = _calculateDirectSettlements(expenses, roommates);

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

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                  child: Text(
                    'Settlement Plan',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),

                if (settlements.isEmpty)
                  const Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(vertical: 4.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.check_circle, color: Colors.green, size: 30),
                      title: Text(
                        'Everyone is settled up!',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                  )
                else
                  ...settlements.map((settlement) {
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(settlement['from'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, color: Colors.grey, size: 20),
                            const SizedBox(width: 8),
                            Text(settlement['to'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          ],
                        ),
                        trailing: Text(
                          '\$${(settlement['amount'] as double).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFFE89A49),
                          ),
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 24),
                const Divider(thickness: 1),
                const SizedBox(height: 16),

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
                }),
              ],
            ),
    );
  }
}
