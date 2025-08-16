// lib/screens/inbox_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Αυτή η συνάρτηση "μαρκάρει" ένα μήνυμα ως διαβασμένο
  void _markAsRead(DocumentSnapshot messageDoc) {
    final bool isAlreadyRead = messageDoc['isRead'] as bool? ?? false;
    // Κάνουμε update μόνο αν δεν είναι ήδη διαβασμένο για να αποφύγουμε άσκοπες εγγραφές
    if (!isAlreadyRead) {
      messageDoc.reference.update({'isRead': true});
    }
  }

  // Αυτή η συνάρτηση διαγράφει ένα μήνυμα
  void _deleteMessage(String docId) {
    _firestore.collection('inbox').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Εισερχόμενα Μηνύματα'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Παίρνουμε τα μηνύματα με το πιο πρόσφατο στην κορυφή
        stream: _firestore.collection('inbox').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Δεν υπάρχουν μηνύματα.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final messageDoc = snapshot.data!.docs[index];
              final data = messageDoc.data() as Map<String, dynamic>;
              
              final String messageText = data['messageText'] ?? 'Κενό μήνυμα';
              final String senderEmail = data['senderEmail'] ?? 'Άγνωστος αποστολέας';
              final bool isRead = data['isRead'] ?? false;
              final Timestamp? timestamp = data['timestamp'];
              
              // Μορφοποίηση ημερομηνίας
              final String formattedDate = timestamp != null
                  ? DateFormat('dd/MM/yyyy, HH:mm').format(timestamp.toDate())
                  : 'Χωρίς ημερομηνία';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                elevation: 2,
                child: ListTile(
                  // Το εικονίδιο αλλάζει ανάλογα με το αν το μήνυμα είναι διαβασμένο
                  leading: Icon(
                    isRead ? Icons.mark_email_read_outlined : Icons.mark_email_unread,
                    color: isRead ? Colors.grey : Colors.blue,
                  ),
                  // Ο τίτλος είναι έντονος (bold) αν το μήνυμα είναι αδιάβαστο
                  title: Text(
                    messageText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.bold),
                  ),
                  subtitle: Text('Από: $senderEmail\n$formattedDate'),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: 'Διαγραφή',
                    onPressed: () => _deleteMessage(messageDoc.id),
                  ),
                  onTap: () {
                    // Όταν πατάμε το μήνυμα, το μαρκάρει ως διαβασμένο
                    _markAsRead(messageDoc);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}