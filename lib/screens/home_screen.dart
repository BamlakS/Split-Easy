import 'package:flutter/material.dart';
import 'package:myapp/screens/add_expense_screen.dart';
import 'package:myapp/screens/view_expenses_screen.dart';
import 'package:myapp/screens/see_balances_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SplitEasy'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddExpenseScreen(),
                  ),
                );
              },
              child: const Text('Add Expense'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ViewExpensesScreen(),
                  ),
                );
              },
              child: const Text('View Expenses'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SeeBalancesScreen(),
                  ),
                );
              },
              child: const Text('See Balances'),
            ),
          ],
        ),
      ),
    );
  }
}
