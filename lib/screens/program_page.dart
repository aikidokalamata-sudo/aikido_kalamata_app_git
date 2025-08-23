// lib/screens/program_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'schedule_management_page.dart';

class ProgramPage extends StatefulWidget {
  const ProgramPage({super.key});

  @override
  State<ProgramPage> createState() => _ProgramPageState();
}

class _ProgramPageState extends State<ProgramPage> {
  final List<String> daysOfWeek = [
    'Δευτέρα',
    'Τρίτη',
    'Τετάρτη',
    'Πέμπτη',
    'Παρασκευή',
    'Σάββατο',
    'Κυριακή'
  ];
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final idTokenResult = await user.getIdTokenResult(true);
      if (mounted) {
        setState(() {
          _isAdmin = idTokenResult.claims?['admin'] as bool? ?? false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isAdmin = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- Ορίζουμε το νέο χρώμα εδώ ---
    const cardBackgroundColor = Color(0xFF2f2a2a);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Εβδομαδιαίο Πρόγραμμα'),
        elevation: 1,
        actions: [
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.edit_calendar, color: Colors.black54),
              tooltip: 'Επεξεργασία Προγράμματος',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const ScheduleManagementPage()),
                );
              },
            ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('schedule')
            .orderBy('day')
            .orderBy('startTime')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Παρουσιάστηκε σφάλμα!'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('Το πρόγραμμα δεν έχει οριστεί ακόμα.'));
          }

          Map<int, List<DocumentSnapshot>> lessonsByDay = {};
          for (var doc in snapshot.data!.docs) {
            final day = doc['day'] as int;
            lessonsByDay.putIfAbsent(day, () => []).add(doc);
          }

          return ListView.builder(
            itemCount: daysOfWeek.length,
            itemBuilder: (context, index) {
              final dayIndex = index + 1;
              final dayName = daysOfWeek[index];
              final lessonsForDay = lessonsByDay[dayIndex] ?? [];

              if (lessonsForDay.isEmpty) return const SizedBox.shrink();

              return Card(
                // --- ΕΦΑΡΜΟΓΗ ΝΕΩΝ ΧΡΩΜΑΤΩΝ ---
                color: cardBackgroundColor,
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dayName,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red)),
                      const Divider(color: Colors.white24),
                      ...lessonsForDay.map((lessonDoc) {
                        final lessonData =
                            lessonDoc.data() as Map<String, dynamic>;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time,
                                  size: 16, color: Colors.white70),
                              const SizedBox(width: 8),
                              Text(
                                '${lessonData['startTime']} - ${lessonData['endTime']}',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              const Spacer(),
                              Chip(
                                label: Text(lessonData['category'] ?? ''),
                                backgroundColor:
                                    Colors.white, // Λευκό chip για να ξεχωρίζει
                                labelStyle:
                                    const TextStyle(color: Colors.black),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
