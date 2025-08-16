// lib/screens/member_messages_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MemberMessagesPage extends StatelessWidget {
  final String memberId;

  const MemberMessagesPage({super.key, required this.memberId});

  // Όταν το μέλος πατήσει το μήνυμα, το μαρκάρουμε ως διαβασμένο
  void _markAsRead(DocumentSnapshot messageDoc) {
    if (messageDoc['isRead'] == false) {
      messageDoc.reference.update({'isRead': true});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Μηνύματα από το Dojo'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Παρακολουθούμε την υπο-συλλογή "messages" ΜΟΝΟ του συγκεκριμένου μέλους
        stream: FirebaseFirestore.instance
            .collection('members')
            .doc(memberId)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Δεν έχετε μηνύματα.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final messageDoc = snapshot.data!.docs[index];
              final data = messageDoc.data() as Map<String, dynamic>;

              final String messageText = data['messageText'] ?? '';
              final String sender = data['sender'] ?? 'Dojo';
              final bool isRead = data['isRead'] ?? false;
              final Timestamp? timestamp = data['timestamp'];

              final String formattedDate = timestamp != null
                  ? DateFormat('dd/MM/yyyy, HH:mm').format(timestamp.toDate())
                  : '';

              return Card(
                color: isRead ? Colors.white : Colors.blue.shade50,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: Icon(
                    isRead ? Icons.mark_email_read_outlined : Icons.email,
                    color: isRead ? Colors.grey : Colors.blue,
                  ),
                  title: Text(
                    messageText,
                    style: TextStyle(
                        fontWeight: isRead ? FontWeight.normal : FontWeight.bold),
                  ),
                  subtitle: Text('Από: $sender - $formattedDate'),
                  onTap: () => _markAsRead(messageDoc),
                ),
              );
            },
          );
        },
      ),
    );
  }
}