
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/expense.dart';
import '../providers/expense_provider.dart';
import './edit_expense_screen.dart';

enum DateFilter {
  allTime,
  thisWeek,
  thisMonth,
  custom,
}

class ViewExpensesScreen extends StatefulWidget {
  const ViewExpensesScreen({super.key});

  @override
  State<ViewExpensesScreen> createState() => _ViewExpensesScreenState();
}

class _ViewExpensesScreenState extends State<ViewExpensesScreen> {
  String _selectedCategory = 'All Categories';
  final List<String> _categories = [
    'All Categories',
    'Groceries',
    'Utilities',
    'Rent',
    'Entertainment',
    'Other'
  ];

  DateFilter _selectedDateFilter = DateFilter.allTime;
  DateTimeRange? _customDateRange;

  void _confirmDelete(BuildContext context, String expenseId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this expense?'),
        content: const Text('This action cannot be undone.'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          TextButton(
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Provider.of<ExpenseProvider>(context, listen: false).deleteExpense(expenseId);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Expense deleted'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

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

  void _selectDateFilter(DateFilter filter) async {
    if (filter == DateFilter.custom) {
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2022),
        lastDate: DateTime.now(),
        initialDateRange: _customDateRange,
      );
      if (picked != null) {
        setState(() {
          _customDateRange = picked;
          _selectedDateFilter = DateFilter.custom;
        });
      }
    } else {
      setState(() {
        _selectedDateFilter = filter;
        _customDateRange = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final allExpenses = expenseProvider.expenses;
    allExpenses.sort((a, b) => b.date.compareTo(a.date));

    List<Expense> filteredExpenses = allExpenses;

    // Category Filter
    if (_selectedCategory != 'All Categories') {
      filteredExpenses = filteredExpenses.where((exp) => exp.category == _selectedCategory).toList();
    }

    // Date Filter
    final now = DateTime.now();
    switch (_selectedDateFilter) {
      case DateFilter.thisWeek:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        filteredExpenses = filteredExpenses.where((exp) => exp.date.isAfter(startOfWeek)).toList();
        break;
      case DateFilter.thisMonth:
        filteredExpenses =
            filteredExpenses.where((exp) => exp.date.month == now.month && exp.date.year == now.year).toList();
        break;
      case DateFilter.custom:
        if (_customDateRange != null) {
          filteredExpenses = filteredExpenses
              .where((exp) =>
                  exp.date.isAfter(_customDateRange!.start.subtract(const Duration(days: 1))) &&
                  exp.date.isBefore(_customDateRange!.end.add(const Duration(days: 1))))
              .toList();
        }
        break;
      case DateFilter.allTime:
        break;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F7),
      appBar: AppBar(
        title: const Text('All Expenses'),
      ),
      body: Column(
        children: [
          // Date Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(DateFilter.allTime, 'All Time'),
                  _buildFilterChip(DateFilter.thisWeek, 'This Week'),
                  _buildFilterChip(DateFilter.thisMonth, 'This Month'),
                  _buildFilterChip(DateFilter.custom, _getCustomDateLabel()),
                ],
              ),
            ),
          ),

          // Category Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Filter by Category',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedCategory = newValue!;
                });
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Showing ${filteredExpenses.length} expenses',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: filteredExpenses.isEmpty
                ? const Center(
                    child: Text(
                      'No expenses found for this period',
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: filteredExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = filteredExpenses[index];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(_getCategoryIcon(expense.category),
                                          size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 8),
                                      Text(
                                        expense.category,
                                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Color(0xFFA7DBD8)),
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => EditExpenseScreen(expense: expense),
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete, color: Colors.red.shade300),
                                        onPressed: () => _confirmDelete(context, expense.id),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                expense.description,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '\$${expense.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFA7DBD8),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text('Paid by: ${expense.paidBy}'),
                              const SizedBox(height: 8),
                              Text(DateFormat('MMM d, yyyy').format(expense.date)),
                              const SizedBox(height: 12),
                              const Divider(),
                              const SizedBox(height: 12),
                              _buildSplitBetween(expense),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _getCustomDateLabel() {
    if (_customDateRange != null) {
      return '${DateFormat('MMM d').format(_customDateRange!.start)} - ${DateFormat('MMM d').format(_customDateRange!.end)}';
    }
    return 'Custom Range';
  }

  Widget _buildFilterChip(DateFilter filter, String label) {
    final isSelected = _selectedDateFilter == filter;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            _selectDateFilter(filter);
          }
        },
        selectedColor: const Color(0xFFE89A49),
        backgroundColor: const Color.fromARGB(255, 90, 132, 224),
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
      ),
    );
  }

  Widget _buildSplitBetween(Expense expense) {
    final splitDetails = expense.splitAmong.map((split) {
      return '${split['name']} owes \$${(split['owes'] as double).toStringAsFixed(2)}';
    }).join('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Split between:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(splitDetails),
      ],
    );
  }
}
