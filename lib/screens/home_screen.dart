import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../widgets/roommate_spending_chart.dart';
import 'add_expense_screen.dart';
import 'manage_roommates_screen.dart';
import 'see_balances_screen.dart';
import 'view_expenses_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'SplitEasy',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.group, size: 28),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (c) => const ManageRoommatesScreen()),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Expense>>(
        stream: expenseProvider.expensesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final expenses = snapshot.data ?? [];
          WidgetsBinding.instance.addPostFrameCallback((_) {
            expenseProvider.setExpenses(expenses);
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Welcome Back!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Here\'s a summary of your shared expenses.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black54),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Roommate Spending',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                ),
                const SizedBox(height: 16),
                const Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: RoommateSpendingChart(),
                  ),
                ),
                const SizedBox(height: 30),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    Consumer<ExpenseProvider>(
                      builder: (context, provider, child) => _buildSummaryCard(
                        context,
                        title: 'Total Spending',
                        value: '\$${provider.totalSpending.toStringAsFixed(2)}',
                        icon: Icons.monetization_on,
                        color: const Color(0xFFA7DBD8),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (c) => const ViewExpensesScreen()),
                        ),
                      ),
                    ),
                    _buildSummaryCard(
                      context,
                      title: 'Your Balances',
                      value: 'View Details',
                      icon: Icons.account_balance_wallet,
                      color: const Color(0xFFE89A49),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (c) => const SeeBalancesScreen()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add, size: 28),
                  label: const Text('Add New Expense', style: TextStyle(fontSize: 18)),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (c) => const AddExpenseScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 90, 132, 224),
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
