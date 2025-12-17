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
      Provider.of<ExpenseProvider>(context, listen: false)
          .addRoommate(_nameController.text.trim());
      _nameController.clear();
      FocusScope.of(context).unfocus(); // Dismiss keyboard
    }
  }

  void _confirmRemoveRoommate(String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to remove $name? This action cannot be undone.'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
            onPressed: () {
              Provider.of<ExpenseProvider>(context, listen: false).removeRoommate(name);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final roommates = expenseProvider.roommates;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F7),
      appBar: AppBar(
        title: const Text('Manage Roommates', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'New Roommate Name',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Color.fromARGB(255, 90, 132, 224), size: 30),
                      onPressed: _addRoommate,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: roommates.length,
              itemBuilder: (context, index) {
                final roommate = roommates[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getColorForRoommate(roommate, roommates),
                    child: Text(roommate[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(roommate, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    tooltip: 'Delete Roommate',
                    onPressed: () => _confirmRemoveRoommate(roommate),
                  ),
                );
              },
            ),
          ),
        ],
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
