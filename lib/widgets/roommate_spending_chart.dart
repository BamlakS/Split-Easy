import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';

class RoommateSpendingChart extends StatelessWidget {
  const RoommateSpendingChart({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final expenses = expenseProvider.expenses;
    final roommates = expenseProvider.roommates;

    Map<String, double> spendingByRoommate = {};
    for (var roommate in roommates) {
      spendingByRoommate[roommate] = 0.0;
    }
    for (var expense in expenses) {
      spendingByRoommate[expense.paidBy] =
          (spendingByRoommate[expense.paidBy] ?? 0) + expense.amount;
    }

    // Filter out roommates with no spending
    final activeSpendings = Map.fromEntries(
      spendingByRoommate.entries.where((entry) => entry.value > 0),
    );

    if (activeSpendings.isEmpty) {
      return const Center(
        child: Text(
          'No spending data available.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 1.7,
      child: PieChart(
        PieChartData(
          sections: activeSpendings.entries.map((entry) {
            const double fontSize = 14;
            const double radius = 100;
            final Color color =
                _getColorForRoommate(entry.key, roommates);

            return PieChartSectionData(
              color: color,
              value: entry.value,
              title: '\$${entry.value.toStringAsFixed(0)}', // Display spending amount
              radius: radius,
              titleStyle: const TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Color(0xffffffff),
                shadows: [Shadow(color: Colors.black, blurRadius: 2)],
              ),
            );
          }).toList(),
          sectionsSpace: 4,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Color _getColorForRoommate(String roommate, List<String> roommates) {
    int index = roommates.indexOf(roommate);
    List<Color> colors = [
      Colors.teal.shade300,
      Colors.orange.shade300,
      Colors.purple.shade300,
      Colors.lightBlue.shade300,
      Colors.red.shade300,
      Colors.green.shade300,
    ];
    return colors[index % colors.length];
  }
}
