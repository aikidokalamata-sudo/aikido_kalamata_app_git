// lib/screens/announcements_management_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementsManagementPage extends StatelessWidget {
  const AnnouncementsManagementPage({super.key});

  void _showAddDialog(BuildContext context) {
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Νέα Ανακοίνωση'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Κύριο κείμενο')),
            TextField(controller: subtitleController, decoration: const InputDecoration(labelText: 'Δευτερεύον κείμενο (π.χ. ημερομηνία)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Άκυρο')),
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance.collection('announcements').add({
                'title': titleController.text,
                'subtitle': subtitleController.text,
                'timestamp': FieldValue.serverTimestamp(),
              });
              Navigator.of(context).pop();
            },
            child: const Text('Προσθήκη'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Διαχείριση Ανακοινώσεων')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        backgroundColor: Colors.red.shade700,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('announcements').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['title'] ?? ''),
                subtitle: Text(data['subtitle'] ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => doc.reference.delete(),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}