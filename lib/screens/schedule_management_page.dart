// lib/screens/schedule_management_page.dart
    
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleManagementPage extends StatefulWidget {
  const ScheduleManagementPage({super.key});

  @override
  State<ScheduleManagementPage> createState() => _ScheduleManagementPageState();
}

class _ScheduleManagementPageState extends State<ScheduleManagementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showAddLessonDialog({DocumentSnapshot? existingLesson}) {
    // Αν επεξεργαζόμαστε υπάρχον μάθημα, συμπληρώνουμε τα πεδία
    final isEditing = existingLesson != null;
    final docId = existingLesson?.id;
    final existingData = existingLesson?.data() as Map<String, dynamic>?;

    final startTimeController = TextEditingController(text: existingData?['startTime'] ?? '');
    final endTimeController = TextEditingController(text: existingData?['endTime'] ?? '');
    int selectedDay = existingData?['day'] ?? 1;
    String selectedCategory = existingData?['category'] ?? 'Όλα τα επίπεδα';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Επεξεργασία Μαθήματος' : 'Προσθήκη Μαθήματος'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      value: selectedDay,
                      decoration: const InputDecoration(labelText: 'Ημέρα'),
                      items: List.generate(7, (index) {
                        final days = ['Δευτέρα', 'Τρίτη', 'Τετάρτη', 'Πέμπτη', 'Παρασκευή', 'Σάββατο', 'Κυριακή'];
                        return DropdownMenuItem(value: index + 1, child: Text(days[index]));
                      }),
                      onChanged: (value) => setDialogState(() => selectedDay = value!),
                    ),
                    TextField(controller: startTimeController, decoration: const InputDecoration(labelText: 'Ώρα Έναρξης (π.χ. 19:00)')),
                    TextField(controller: endTimeController, decoration: const InputDecoration(labelText: 'Ώρα Λήξης (π.χ. 20:30)')),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(labelText: 'Κατηγορία'),
                      items: ['Αρχάριοι', 'Όλα τα επίπεδα', 'Παιδικό'].map((String category) {
                        return DropdownMenuItem<String>(value: category, child: Text(category));
                      }).toList(),
                      onChanged: (value) => setDialogState(() => selectedCategory = value!),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Άκυρο')),
                TextButton(
                  onPressed: () {
                    final dataToSave = {
                      'day': selectedDay,
                      'startTime': startTimeController.text.trim(),
                      'endTime': endTimeController.text.trim(),
                      'category': selectedCategory,
                    };
                    
                    if (isEditing) {
                      _firestore.collection('schedule').doc(docId).update(dataToSave);
                    } else {
                      _firestore.collection('schedule').add(dataToSave);
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text(isEditing ? 'Αποθήκευση' : 'Προσθήκη'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Επεξεργασία Προγράμματος'),
        // Το AppBar είναι ήδη λευκό από το θέμα, οπότε δεν χρειάζεται αλλαγή
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddLessonDialog(),
        backgroundColor: Colors.red.shade700,
        tooltip: 'Προσθήκη Μαθήματος', // ΑΛΛΑΓΗ ΧΡΩΜΑΤΟΣ
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('schedule').orderBy('day').orderBy('startTime').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Δεν υπάρχουν μαθήματα. Πατήστε "+" για προσθήκη.'));
          }

          return ListView(
            padding: const EdgeInsets.all(8.0),
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final days = ['Δευτέρα', 'Τρίτη', 'Τετάρτη', 'Πέμπτη', 'Παρασκευή', 'Σάββατο', 'Κυριακή'];
              final dayName = days[(data['day'] as int) - 1];
              
              return Card(
                child: ListTile(
                  title: Text('$dayName, ${data['startTime']} - ${data['endTime']}'),
                  subtitle: Text(data['category']),
                  // Κουμπί Επεξεργασίας
                  leading: IconButton(
                    icon: Icon(Icons.edit, color: Colors.grey.shade600),
                    onPressed: () => _showAddLessonDialog(existingLesson: doc),
                  ),
                  // Κουμπί Διαγραφής
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => doc.reference.delete(),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}