
import 'package:cloud_firestore/cloud_firestore.dart';
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

  final List<String> _categories = ['Groceries', 'Utilities', 'Rent', 'Entertainment', 'Other'];

  @override
  void initState() {
    super.initState();
    final roommates = Provider.of<ExpenseProvider>(context, listen: false).roommates;
    for (var roommate in roommates) {
      _splitAmong[roommate] = false;
    }
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

  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      final totalAmount = double.tryParse(_amountController.text) ?? 0.0;
      final selectedRoommates = _splitAmong.entries.where((e) => e.value).map((e) => e.key).toList();

      if (selectedRoommates.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one roommate to split with.'),
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
        splitAmong: selectedRoommates,
        createdAt: Timestamp.now(),
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
                initialValue: _selectedCategory,
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
                        onPressed: () {
                          setState(() {
                            _splitAmong.updateAll((key, value) => true);
                          });
                        },
                        child: const Text('Select All'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _splitAmong.updateAll((key, value) => false);
                          });
                        },
                        child: const Text('Clear All'),
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
                    });
                  },
                );
              }),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Save Expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



