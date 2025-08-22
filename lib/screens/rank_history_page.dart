// lib/screens/rank_history_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'evaluation_detail_page.dart';
import 'failure_letter_page.dart';

// --- ΑΛΛΑΓΗ: Μετατροπή σε StatefulWidget ---
class RankHistoryPage extends StatefulWidget {
  final String memberId;
  final bool isAdmin;

  const RankHistoryPage({
    super.key,
    required this.memberId,
    this.isAdmin = false,
  });

  @override
  State<RankHistoryPage> createState() => _RankHistoryPageState();
}

class _RankHistoryPageState extends State<RankHistoryPage> {
  void _showAddRankDialog() {
    final rankController = TextEditingController();
    final examinerController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context, // Χρησιμοποιούμε το context του State
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Καταχώρηση Εξέτασης'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: rankController,
                      autofocus: true,
                      decoration: const InputDecoration(
                          labelText: 'Βαθμός (π.χ. 4ο Kyu)'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: examinerController,
                      decoration: const InputDecoration(labelText: 'Εξεταστής'),
                    ),
                    const SizedBox(height: 24),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Ημερομηνία Απονομής'),
                      subtitle:
                          Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
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
                    final rankName = rankController.text.trim();
                    if (rankName.isNotEmpty) {
                      FirebaseFirestore.instance
                          .collection('members')
                          .doc(
                              widget.memberId) // Χρησιμοποιούμε widget.memberId
                          .collection('rank_history')
                          .add({
                        'rankName': rankName,
                        'examiner': examinerController.text.trim(),
                        'examDate': Timestamp.fromDate(selectedDate),
                      });
                      Navigator.of(dialogContext).pop();
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

  Future<void> _deleteRank(DocumentReference rankRef) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Επιβεβαίωση Διαγραφής'),
          content: const SingleChildScrollView(
            child: Text(
                'Είστε σίγουρος ότι θέλετε να διαγράψετε αυτόν τον βαθμό;'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Άκυρο'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child:
                  const Text('Διαγραφή', style: TextStyle(color: Colors.red)),
              onPressed: () {
                rankRef.delete();
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ιστορικό Βαθμών'),
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
              onPressed: _showAddRankDialog, // Καλούμε τη μέθοδο απευθείας
              tooltip: 'Προσθήκη Εξέτασης',
              child: const Icon(Icons.add),
            )
          : null,
      persistentFooterButtons: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => const FailureLetterPage()),
              );
            },
            icon: Icon(Icons.lightbulb_outline, color: Colors.red.shade700),
            label: Text(
              'Επιστολή για την αντιμετώπιση της αποτυχίας',
              style: TextStyle(
                  color: Colors.grey.shade800,
                  decoration: TextDecoration.underline),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8.0),
            ),
          ),
        )
      ],
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('members')
            .doc(widget.memberId)
            .collection('rank_history')
            .orderBy('examDate', descending: true)
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
                child: Text('Δεν έχουν καταχωρηθεί βαθμοί ακόμα.',
                    textAlign: TextAlign.center),
              ),
            );
          }

          final ranks = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: ranks.length,
            itemBuilder: (context, index) {
              final rankDoc = ranks[index];
              final rankData = rankDoc.data() as Map<String, dynamic>;

              final String rankName = rankData['rankName'] ?? 'Άγνωστος Βαθμός';
              final Timestamp awardedTimestamp =
                  rankData['examDate'] as Timestamp;
              final String awardedDate = DateFormat('dd MMMM yyyy', 'el_GR')
                  .format(awardedTimestamp.toDate());

              final bool isDanRank = rankName.toLowerCase().contains('dan');
              final String beltImage = isDanRank
                  ? 'assets/images/black_belt.png'
                  : 'assets/images/white_belt.png';

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFf7f2fa),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => EvaluationDetailPage(
                        rankDocRef: rankDoc.reference,
                        isEditing: widget.isAdmin,
                      ),
                    ));
                  },
                  child: ListTile(
                    leading: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Image.asset(beltImage, width: 40),
                    ),
                    title: Text(rankName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Text('Απονομή στις $awardedDate'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.arrow_forward_ios,
                            size: 16, color: Colors.grey),
                        if (widget.isAdmin)
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red, size: 20),
                            onPressed: () => _deleteRank(rankDoc.reference),
                          ),
                      ],
                    ),
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
