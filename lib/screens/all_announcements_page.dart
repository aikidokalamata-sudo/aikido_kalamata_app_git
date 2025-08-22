// lib/screens/all_announcements_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AllAnnouncementsPage extends StatelessWidget {
  const AllAnnouncementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Όλες οι Ανακοινώσεις'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Παίρνουμε ΟΛΕΣ τις ανακοινώσεις, ταξινομημένες από την πιο πρόσφατη
        stream: FirebaseFirestore.instance
            .collection('announcements')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Παρουσιάστηκε σφάλμα.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Δεν υπάρχουν ανακοινώσεις.'));
          }

          final announcements = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(8.0),
            itemCount: announcements.length,
            separatorBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(height: 1, color: Colors.grey.shade300),
            ),
            itemBuilder: (context, index) {
              final announcementDoc = announcements[index];
              final data = announcementDoc.data() as Map<String, dynamic>;

              final title = data['title'] ?? 'Χωρίς τίτλο';
              final subtitle = data['subtitle'] ?? '';
              final timestamp = data['timestamp'] as Timestamp?;

              String formattedDate = '';
              if (timestamp != null) {
                formattedDate =
                    DateFormat('dd/MM/yyyy').format(timestamp.toDate());
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: null,
                  child: ListTile(
                    title: Text(title,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('$subtitle\n$formattedDate'),
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
