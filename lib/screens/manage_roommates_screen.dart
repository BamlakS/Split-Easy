import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';

class ManageRoommatesScreen extends StatefulWidget {
  const ManageRoommatesScreen({super.key});

  @override
  State<ManageRoommatesScreen> createState() => _ManageRoommatesScreenState();
}

class _ManageRoommatesScreenState extends State<ManageRoommatesScreen> {
  final _nameController = TextEditingController();

  void _addRoommate() {
    if (_nameController.text.isNotEmpty) {
      Provider.of<ExpenseProvider>(context, listen: false).addRoommate(_nameController.text);
      _nameController.clear();
    }
  }

  void _removeRoommate(String name) {
    Provider.of<ExpenseProvider>(context, listen: false).removeRoommate(name);
  }

  @override
  Widget build(BuildContext context) {
    final roommates = Provider.of<ExpenseProvider>(context).roommates;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Roommates'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'New Roommate Name'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addRoommate,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: roommates.length,
              itemBuilder: (context, index) {
                final roommate = roommates[index];
                return ListTile(
                  title: Text(roommate),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeRoommate(roommate),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
