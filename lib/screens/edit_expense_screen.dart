
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
  late Map<String, bool> _splitAmong;
  late Map<String, TextEditingController> _splitAmountControllers;
  double _splitTotal = 0.0;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.expense.description);
    _amountController = TextEditingController(text: widget.expense.amount.toString());
    _paidBy = widget.expense.paidBy;
    _selectedDate = widget.expense.date;

    final roommates = Provider.of<ExpenseProvider>(context, listen: false).roommates;
    _splitAmong = {for (var r in roommates) r: false};
    _splitAmountControllers = {for (var r in roommates) r: TextEditingController()};

    for (var split in widget.expense.splitAmong) {
      final String name = split['name'];
      final double owes = split['owes'];
      _splitAmong[name] = true;
      _splitAmountControllers[name] = TextEditingController(text: owes.toString());
    }

    for (var controller in _splitAmountControllers.values) {
      controller.addListener(_updateSplitTotal);
    }

    _updateSplitTotal();
  }

  void _updateSplitTotal() {
    double total = 0.0;
    _splitAmountControllers.forEach((key, controller) {
      if (_splitAmong[key] ?? false) {
        total += double.tryParse(controller.text) ?? 0.0;
      }
    });
    if (mounted) {
      setState(() {
        _splitTotal = total;
      });
    }
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

    final selectedRoommates = _splitAmong.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (selectedRoommates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one roommate to split with.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final int splitCount = selectedRoommates.length;
    final double amountPerPerson = totalAmount / splitCount;
    final double roundedAmount = (amountPerPerson * 100).floorToDouble() / 100;
    double remainder = totalAmount - (roundedAmount * splitCount);

    for (final roommate in selectedRoommates) {
      double share = roundedAmount;
      if (remainder > 0.001) {
        share += 0.01;
        remainder -= 0.01;
      }
      _splitAmountControllers[roommate]!.text = share.toStringAsFixed(2);
    }
    _updateSplitTotal();
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

      final updatedExpense = widget.expense.copyWith(
        description: _descriptionController.text,
        amount: totalAmount,
        paidBy: _paidBy,
        date: _selectedDate,
        splitAmong: _splitAmong.entries
            .where((entry) => entry.value)
            .map((entry) {
          return {
            'name': entry.key,
            'owes': double.tryParse(_splitAmountControllers[entry.key]!.text) ?? 0.0,
          };
        }).toList(),
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
                validator: (value) =>
                    value == null ? 'Please select who paid.' : null,
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
              const Text('Split Between:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ...roommates.map((roommate) {
                return CheckboxListTile(
                  title: Text(roommate),
                  value: _splitAmong[roommate] ?? false,
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
              ..._splitAmountControllers.entries
                  .where((entry) => _splitAmong[entry.key] ?? false)
                  .map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: TextFormField(
                    controller: entry.value,
                    decoration: InputDecoration(labelText: '\$${entry.key} owes'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                );
              }),
              const SizedBox(height: 20),
              Text('Running Total: \$${_splitTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
              if ((_splitTotal - (double.tryParse(_amountController.text) ?? 0.0)).abs() > 0.01 &&
                  _splitTotal > 0.0)
                const Text(
                  'Warning: Split amounts do not equal total amount.',
                  style: TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA7DBD8),
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
    for (var controller in _splitAmountControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
