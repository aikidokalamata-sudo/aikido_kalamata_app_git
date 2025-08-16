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
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Αποστολή Μηνύματος σε ${memberDoc['fullName']}'),
          content: TextField(
            controller: messageController,
            autofocus: true,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Γράψτε το μήνυμά σας εδώ...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Άκυρο'),
            ),
            TextButton(
              onPressed: () {
                final messageText = messageController.text.trim();
                if (messageText.isNotEmpty) {
                  memberDoc.reference.collection('messages').add({
                    'messageText': messageText,
                    'sender': 'Aikido Kalamata Dojo',
                    'timestamp': FieldValue.serverTimestamp(),
                    'isRead': false,
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Το μήνυμα στάλθηκε!'),
                      backgroundColor: Colors.green
                    ),
                  );
                }
              },
              child: const Text('Αποστολή'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(BuildContext context) {
    final existingData = memberDoc.data() as Map<String, dynamic>? ?? {};
    final nameController = TextEditingController(text: existingData['fullName']);
    final rankLevelController = TextEditingController(text: (existingData['rankLevel'] ?? 0).toString());
    final phoneController = TextEditingController(text: existingData['phone']);
    final emailController = TextEditingController(text: existingData['email']);
    String selectedRankType = existingData['rankType'] ?? 'Kyu';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Επεξεργασία Στοιχείων'),
            content: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: "Ονοματεπώνυμο")),
                Row(children: [
                  Expanded(
                    child: DropdownButton<String>(
                      value: selectedRankType,
                      onChanged: (val) => setDialogState(() => selectedRankType = val!),
                      items: ['Kyu', 'Dan'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: rankLevelController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Επίπεδο"))),
                ]),
                TextField(controller: phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: "Τηλέφωνο")),
                TextField(controller: emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: "Email")),
              ]),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Άκυρο')),
              TextButton(
                child: const Text('Αποθήκευση'),
                onPressed: () {
                  final dataToSave = {
                    'fullName': nameController.text.trim(),
                    'rankType': selectedRankType,
                    'rankLevel': int.tryParse(rankLevelController.text) ?? 0,
                    'phone': phoneController.text.trim(),
                    'email': emailController.text.trim().toLowerCase(),
                  };
                  memberDoc.reference.update(dataToSave);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
      },
    );
  }
  
  void _showAddSubscriptionDialog(BuildContext context) {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Καταχώρηση Συνδρομής'),
          content: TextField(
            controller: amountController,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Ποσό (€)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Άκυρο'),
            ),
            TextButton(
              onPressed: () {
                final double? amount = double.tryParse(amountController.text.trim());
                if (amount != null) {
                  final memberName = (memberDoc.data() as Map<String, dynamic>)['fullName'] ?? 'Άγνωστο μέλος';
                  
                  FirebaseFirestore.instance.collection('transactions').add({
                    'amount': amount,
                    'description': 'Συνδρομή - $memberName',
                    'type': 'subscription',
                    'date': Timestamp.now(),
                    'memberId': memberDoc.id,
                  });

                  memberDoc.reference.collection('subscriptions').add({
                    'paymentDate': Timestamp.now(),
                    'amount': amount,
                  });
                  
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Η συνδρομή καταχωρήθηκε!'), backgroundColor: Colors.green));
                }
              },
              child: const Text('Προσθήκη'),
            ),
          ],
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
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
              IconButton(icon: const Icon(Icons.send_outlined), onPressed: () => _showSendMessageDialog(context)),
              IconButton(icon: const Icon(Icons.edit), onPressed: () => _showEditDialog(context)),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Card(child: ListTile(leading: const Icon(Icons.person), title: const Text('Ονοματεπώνυμο'), subtitle: Text(fullName))),
              Card(child: ListTile(leading: const Icon(Icons.military_tech), title: const Text('Βαθμός'), subtitle: Text('$rankLevelº $rankType'))),
              Card(child: ListTile(leading: const Icon(Icons.phone), title: const Text('Τηλέφωνο'), subtitle: Text(phone), trailing: phone != 'Δεν υπάρχει' ? IconButton(icon: const Icon(Icons.call, color: Colors.green), onPressed: () => _makePhoneCall(phone)) : null)),
              Card(child: ListTile(leading: const Icon(Icons.email), title: const Text('Email'), subtitle: Text(email))),
              
              const Divider(height: 30),

              const Text('Ενέργειες Διαχείρισης', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
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
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade800, foregroundColor: Colors.white),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => _showAddSubscriptionDialog(context),
                icon: const Icon(Icons.add_card),
                label: const Text('Καταχώρηση Συνδρομής'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
              ),

              const Divider(height: 30),

              const Text('Ιστορικό Συνδρομών (Τελευταίες 5)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              
              StreamBuilder<QuerySnapshot>(
                stream: memberDoc.reference.collection('subscriptions').orderBy('paymentDate', descending: true).limit(5).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  if (snapshot.data!.docs.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text('Δεν υπάρχουν καταχωρημένες συνδρομές.')));
                  
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final subDoc = snapshot.data!.docs[index];
                      final paymentTimestamp = subDoc['paymentDate'] as Timestamp;
                      final paymentDate = DateFormat('dd/MM/yyyy').format(paymentTimestamp.toDate());
                      
                      return ListTile(
                        leading: const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                        title: Text('Πληρωμή στις $paymentDate'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_forever, size: 20, color: Colors.grey),
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