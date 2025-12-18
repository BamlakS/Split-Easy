import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/expense.dart';
import '../providers/expense_provider.dart';

class EditExpenseScreen extends StatefulWidget {
  final Expense expense;

  const EditExpenseScreen({super.key, required this.expense});

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late String _paidBy;
  late DateTime _selectedDate;
  late String _selectedCategory;
  late Map<String, bool> _splitAmong;

  final List<String> _categories = ['Groceries', 'Utilities', 'Rent', 'Entertainment', 'Other'];

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.expense.description);
    _amountController = TextEditingController(text: widget.expense.amount.toString());
    _paidBy = widget.expense.paidBy;
    _selectedDate = widget.expense.date;
    _selectedCategory = widget.expense.category;

    final roommates = Provider.of<ExpenseProvider>(context, listen: false).roommates;
    _splitAmong = {for (var r in roommates) r: widget.expense.splitAmong.contains(r)};
  }

  void _presentDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
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

      final updatedExpense = widget.expense.copyWith(
        description: _descriptionController.text,
        amount: totalAmount,
        paidBy: _paidBy,
        date: _selectedDate,
        category: _selectedCategory,
        splitAmong: selectedRoommates,
        createdAt: widget.expense.createdAt, // Preserve original creation timestamp
      );

      Provider.of<ExpenseProvider>(context, listen: false).updateExpense(updatedExpense);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expense updated!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final roommates = Provider.of<ExpenseProvider>(context, listen: false).roommates;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Expense'),
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
                  if (newValue != null) {
                    setState(() {
                      _paidBy = newValue;
                    });
                  }
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
                  value: _splitAmong[roommate] ?? false,
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
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
