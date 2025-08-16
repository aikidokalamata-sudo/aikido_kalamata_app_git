// lib/screens/subscriptions_history_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SubscriptionsHistoryPage extends StatelessWidget {
  final String memberId;

  const SubscriptionsHistoryPage({super.key, required this.memberId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ιστορικό Συνδρομών'),
      ),
      // --- ΑΛΛΑΓΗ #1: Τυλίγουμε το StreamBuilder σε ένα Column ---
      body: Column(
        children: [
          // --- ΑΛΛΑΓΗ #2: Προσθέτουμε το μήνυμα στην κορυφή ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
            child: Text(
              'Παρακαλώ οι συνδρομές να εξοφλούνται το πρώτο δεκαήμερο του μήνα.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const Divider(indent: 16, endIndent: 16),

          // --- ΑΛΛΑΓΗ #3: Τυλίγουμε το StreamBuilder σε ένα Expanded ---
          // για να πάρει τον υπόλοιπο διαθέσιμο χώρο.
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('members')
                  .doc(memberId)
                  .collection('subscriptions')
                  .orderBy('paymentDate', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Παρουσιάστηκε σφάλμα.'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Δεν υπάρχουν καταχωρημένες συνδρομές.', textAlign: TextAlign.center),
                    ),
                  );
                }

                final subscriptions = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: subscriptions.length,
                  itemBuilder: (context, index) {
                    final subDoc = subscriptions[index];
                    final subData = subDoc.data() as Map<String, dynamic>;
                    
                    final paymentTimestamp = subData['paymentDate'] as Timestamp;
                    final paymentDate = DateFormat('MMMM yyyy', 'el_GR').format(paymentTimestamp.toDate());
                    final amount = subData['amount'] as num?;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.check_circle, color: Colors.green),
                        title: Text('Συνδρομή για $paymentDate'),
                        subtitle: Text('Καταχωρήθηκε στις ${DateFormat('dd/MM/yyyy').format(paymentTimestamp.toDate())}'),
                        trailing: amount != null 
                          ? Text('${amount.toStringAsFixed(2)} €', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)) 
                          : null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}