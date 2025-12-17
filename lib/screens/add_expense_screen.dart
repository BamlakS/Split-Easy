
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/expense.dart';
import '../providers/expense_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  String? _paidBy;
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Other';
  final Map<String, bool> _splitAmong = {};
  final Map<String, TextEditingController> _splitAmountControllers = {};
  double _splitTotal = 0.0;

  final List<String> _categories = ['Groceries', 'Utilities', 'Rent', 'Entertainment', 'Other'];

  @override
  void initState() {
    super.initState();
    final roommates = Provider.of<ExpenseProvider>(context, listen: false).roommates;
    for (var roommate in roommates) {
      _splitAmong[roommate] = false;
      _splitAmountControllers[roommate] = TextEditingController();
      _splitAmountControllers[roommate]!.addListener(() {
        _updateSplitTotal();
      });
    }
  }

  void _updateSplitTotal() {
    double total = 0.0;
    _splitAmountControllers.forEach((key, controller) {
      if (_splitAmong[key]!) {
        total += double.tryParse(controller.text) ?? 0.0;
      }
    });
    setState(() {
      _splitTotal = total;
    });
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  void _splitEqually() {
    final totalAmount = double.tryParse(_amountController.text);

    if (totalAmount == null || totalAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid total amount before splitting.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final selectedRoommates =
        _splitAmong.entries.where((entry) => entry.value).map((entry) => entry.key).toList();

    if (selectedRoommates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one roommate to split with.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Clear previous values for all controllers before setting new ones
    for (var controller in _splitAmountControllers.values) {
      controller.clear();
    }

    final int splitCount = selectedRoommates.length;
    final int totalInCents = (totalAmount * 100).round();
    final int baseShareInCents = totalInCents ~/ splitCount;
    int remainderInCents = totalInCents % splitCount;

    for (final roommate in selectedRoommates) {
      int shareInCents = baseShareInCents;
      if (remainderInCents > 0) {
        shareInCents++;
        remainderInCents--;
      }
      _splitAmountControllers[roommate]!.text = (shareInCents / 100).toStringAsFixed(2);
    }
    _updateSplitTotal(); // Manually trigger update
  }

  void _selectAll() {
    setState(() {
      _splitAmong.keys.forEach((roommate) {
        _splitAmong[roommate] = true;
      });
    });
  }

  void _clearAll() {
    setState(() {
      _splitAmong.keys.forEach((roommate) {
        _splitAmong[roommate] = false;
        _splitAmountControllers[roommate]!.clear();
      });
      _updateSplitTotal();
    });
  }

  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      final totalAmount = double.tryParse(_amountController.text) ?? 0.0;
      if ((_splitTotal - totalAmount).abs() > 0.01) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Split amounts must equal the total expense amount.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final newExpense = Expense(
        id: const Uuid().v4(),
        description: _descriptionController.text,
        amount: totalAmount,
        paidBy: _paidBy!,
        date: _selectedDate,
        category: _selectedCategory,
        splitAmong: _splitAmong.entries
            .where((entry) => entry.value)
            .map((entry) {
          return {
            'name': entry.key,
            'owes': double.tryParse(_splitAmountControllers[entry.key]!.text) ?? 0.0,
          };
        }).toList(),
      );

      Provider.of<ExpenseProvider>(context, listen: false).addExpense(newExpense);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expense added!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final roommates = Provider.of<ExpenseProvider>(context).roommates;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
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
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount', prefixText: '\$'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'Please enter a valid amount.';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                initialValue: _paidBy,
                decoration: const InputDecoration(labelText: 'Who Paid?'),
                items: roommates.map((String roommate) {
                  return DropdownMenuItem<String>(
                    value: roommate,
                    child: Text(roommate),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _paidBy = newValue;
                  });
                },
                validator: (value) => value == null ? 'Please select who paid.' : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text('Date: ${DateFormat.yMd().format(_selectedDate)}'),
                  ),
                  TextButton(
                    onPressed: _presentDatePicker,
                    child: const Text(
                      'Choose Date',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Split Between:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      TextButton(
                        onPressed: _selectAll,
                        child: const Text('Select All', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      TextButton(
                        onPressed: _clearAll,
                        child: const Text('Clear All', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                      ),
                    ],
                  ),
                ],
              ),
              ...roommates.map((roommate) {
                return CheckboxListTile(
                  title: Text(roommate),
                  value: _splitAmong[roommate],
                  onChanged: (bool? value) {
                    setState(() {
                      _splitAmong[roommate] = value!;
                      if (!value) {
                        _splitAmountControllers[roommate]!.clear();
                      }
                      _updateSplitTotal();
                    });
                  },
                );
              }),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  onPressed: _splitEqually,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE89A49),
                  ),
                  child: const Text('Split Equally'),
                ),
              ),
              ...roommates.where((r) => _splitAmong[r]!).map((roommate) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: TextFormField(
                    controller: _splitAmountControllers[roommate],
                    decoration: InputDecoration(labelText: '\$${roommate} owes'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                );
              }),
              const SizedBox(height: 20),
              Text('Running Total: \$${_splitTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
              if ((_splitTotal - (double.tryParse(_amountController.text) ?? 0.0)).abs() > 0.01 && _splitTotal > 0.0)
                const Text(
                  'Warning: Split amounts do not equal total amount.',
                  style: TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveExpense,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 90, 132, 224), padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Save Expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
