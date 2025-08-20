// lib/screens/member_detail_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'rank_history_page.dart';

class MemberDetailPage extends StatelessWidget {
  final DocumentSnapshot memberDoc;

  const MemberDetailPage({super.key, required this.memberDoc});

  void _showSendMessageDialog(BuildContext context) {
    // ... (no changes in this function)
  }

  void _showEditDialog(BuildContext context) {
    // ... (no changes in this function)
  }

  // --- Η ΑΝΑΒΑΘΜΙΣΗ ΤΟΥ DIALOG ΕΙΝΑΙ ΕΔΩ ---
  void _showAddSubscriptionDialog(BuildContext context) {
    final amountController = TextEditingController();
    DateTime selectedDate =
        DateTime.now(); // Προεπιλεγμένη ημερομηνία ο τρέχων μήνας

    showDialog(
      context: context,
      builder: (dialogContext) {
        // Χρησιμοποιούμε StatefulBuilder για να μπορούμε να αλλάζουμε την ημερομηνία
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Καταχώρηση Συνδρομής'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: amountController,
                      autofocus: true,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Ποσό (€)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Πεδίο για την επιλογή μήνα/έτους
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Μήνας Συνδρομής'),
                      subtitle:
                          Text(DateFormat.yMMMM('el_GR').format(selectedDate)),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2101),
                          locale: const Locale('el', 'GR'),
                        );
                        if (picked != null && picked != selectedDate) {
                          setDialogState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Άκυρο'),
                ),
                TextButton(
                  onPressed: () {
                    final double? amount =
                        double.tryParse(amountController.text.trim());
                    if (amount != null && amount > 0) {
                      final memberName = (memberDoc.data()
                              as Map<String, dynamic>)['fullName'] ??
                          'Άγνωστο μέλος';
                      final transactionDate = Timestamp.fromDate(selectedDate);

                      // Δημιουργεί την εγγραφή στα ΕΣΟΔΑ της σχολής με τη σωστή ημερομηνία
                      FirebaseFirestore.instance
                          .collection('transactions')
                          .add({
                        'amount': amount,
                        'description': 'Συνδρομή - $memberName',
                        'type': 'subscription',
                        'date': transactionDate,
                        'memberId': memberDoc.id,
                      });

                      // Δημιουργεί την εγγραφή στο ΙΣΤΟΡΙΚΟ του μέλους με τη σωστή ημερομηνία
                      memberDoc.reference.collection('subscriptions').add({
                        'paymentDate': transactionDate,
                        'amount': amount,
                      });

                      Navigator.of(dialogContext).pop();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Η συνδρομή καταχωρήθηκε!'),
                          backgroundColor: Colors.green));
                    }
                  },
                  child: const Text('Προσθήκη'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (!await launchUrl(launchUri)) print('Could not launch $launchUri');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: memberDoc.reference.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final String fullName = data['fullName'] ?? 'Χωρίς όνομα';
        final String rankType = data['rankType'] ?? '';
        final int rankLevel = data['rankLevel'] as int? ?? 0;
        final String phone = data['phone'] ?? 'Δεν υπάρχει';
        final String email = data['email'] ?? 'Δεν υπάρχει';

        return Scaffold(
          appBar: AppBar(
            title: Text(fullName),
            actions: [
              IconButton(
                  icon: const Icon(Icons.send_outlined),
                  onPressed: () => _showSendMessageDialog(context)),
              IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditDialog(context)),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Card(
                  child: ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Ονοματεπώνυμο'),
                      subtitle: Text(fullName))),
              Card(
                  child: ListTile(
                      leading: const Icon(Icons.military_tech),
                      title: const Text('Βαθμός'),
                      subtitle: Text('$rankLevelº $rankType'))),
              Card(
                  child: ListTile(
                      leading: const Icon(Icons.phone),
                      title: const Text('Τηλέφωνο'),
                      subtitle: Text(phone),
                      trailing: phone != 'Δεν υπάρχει'
                          ? IconButton(
                              icon: const Icon(Icons.call, color: Colors.green),
                              onPressed: () => _makePhoneCall(phone))
                          : null)),
              Card(
                  child: ListTile(
                      leading: const Icon(Icons.email),
                      title: const Text('Email'),
                      subtitle: Text(email))),
              const Divider(height: 30),
              const Text('Ενέργειες Διαχείρισης',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey)),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => RankHistoryPage(
                      memberId: memberDoc.id,
                      isAdmin: true,
                    ),
                  ));
                },
                icon: const Icon(Icons.add_chart),
                label: const Text('Διαχείριση Ιστορικού Βαθμών'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade800,
                    foregroundColor: Colors.white),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => _showAddSubscriptionDialog(context),
                icon: const Icon(Icons.add_card),
                label: const Text('Καταχώρηση Συνδρομής'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white),
              ),
              const Divider(height: 30),
              const Text('Ιστορικό Συνδρομών (Τελευταίες 5)',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey)),
              const SizedBox(height: 8),
              StreamBuilder<QuerySnapshot>(
                stream: memberDoc.reference
                    .collection('subscriptions')
                    .orderBy('paymentDate', descending: true)
                    .limit(5)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const Center(child: CircularProgressIndicator());
                  if (snapshot.data!.docs.isEmpty)
                    return const Center(
                        child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child:
                                Text('Δεν υπάρχουν καταχωρημένες συνδρομές.')));

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final subDoc = snapshot.data!.docs[index];
                      final paymentTimestamp =
                          subDoc['paymentDate'] as Timestamp;
                      final paymentDate = DateFormat('dd/MM/yyyy')
                          .format(paymentTimestamp.toDate());

                      return ListTile(
                        leading: const Icon(Icons.check_circle_outline,
                            color: Colors.green, size: 20),
                        title: Text('Πληρωμή στις $paymentDate'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_forever,
                              size: 20, color: Colors.grey),
                          onPressed: () => subDoc.reference.delete(),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
