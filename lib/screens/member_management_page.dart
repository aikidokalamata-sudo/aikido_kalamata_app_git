// lib/screens/member_management_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aikido_kalamata_app/screens/member_detail_page.dart';

class MemberManagementPage extends StatefulWidget {
  const MemberManagementPage({super.key});

  @override
  State<MemberManagementPage> createState() => _MemberManagementPageState();
}

class _MemberManagementPageState extends State<MemberManagementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showMemberDialog({DocumentSnapshot? existingMember}) {
    final bool isEditing = existingMember != null;
    final docId = existingMember?.id;
    final existingData = existingMember?.data() as Map<String, dynamic>?;

    final nameController = TextEditingController(text: existingData?['fullName'] ?? '');
    final rankLevelController = TextEditingController(text: (existingData?['rankLevel'] ?? 0).toString());
    final phoneController = TextEditingController(text: existingData?['phone'] ?? '');
    final emailController = TextEditingController(text: existingData?['email'] ?? '');
    String selectedRankType = existingData?['rankType'] ?? 'Kyu';
    String selectedMemberType = existingData?['memberType'] ?? 'Ενήλικες';

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Επεξεργασία Μέλους' : 'Προσθήκη Νέου Μέλους'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: nameController, decoration: const InputDecoration(labelText: "Ονοματεπώνυμο"), autofocus: true),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedMemberType,
                      decoration: const InputDecoration(labelText: 'Κατηγορία Μέλους'),
                      items: ['Ενήλικες', 'Παιδικό'].map((String category) {
                        return DropdownMenuItem<String>(value: category, child: Text(category));
                      }).toList(),
                      onChanged: (String? newValue) {
                        setDialogState(() => selectedMemberType = newValue!);
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(flex: 2, child: DropdownButton<String>(value: selectedRankType, isExpanded: true, onChanged: (String? newValue) => setDialogState(() => selectedRankType = newValue!), items: <String>['Kyu', 'Dan'].map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList())),
                        const SizedBox(width: 8),
                        Expanded(flex: 1, child: TextField(controller: rankLevelController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Επίπεδο"))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(controller: phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: "Τηλέφωνο")),
                    const SizedBox(height: 8),
                    TextField(controller: emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: "Email")),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(child: const Text('Άκυρο'), onPressed: () => Navigator.of(dialogContext).pop()),
                TextButton(
                  child: Text(isEditing ? 'Αποθήκευση' : 'Προσθήκη'),
                  onPressed: () {
                    final emailToSave = emailController.text.trim().toLowerCase();
                    
                    final dataToSave = {
                      'fullName': nameController.text.trim(),
                      'rankType': selectedRankType,
                      'rankLevel': int.tryParse(rankLevelController.text) ?? 0,
                      'phone': phoneController.text.trim(),
                      'email': emailToSave,
                      'memberType': selectedMemberType,
                      if (!isEditing) 'createdAt': FieldValue.serverTimestamp(),
                    };

                    if (isEditing) {
                      _firestore.collection('members').doc(docId).update(dataToSave);
                    } else {
                      _firestore.collection('members').add(dataToSave);
                    }
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  Future<void> _deleteMember(String docId, String memberName) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Επιβεβαίωση Διαγραφής'),
        content: Text('Είστε σίγουρος ότι θέλετε να διαγράψετε οριστικά το μέλος "$memberName";'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Άκυρο')),
          TextButton(
            onPressed: () {
              _firestore.collection('members').doc(docId).delete();
              Navigator.of(context).pop();
            },
            child: const Text('Διαγραφή', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Διαχείριση Μελών'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'ΕΝΗΛΙΚΕΣ'),
              Tab(text: 'ΠΑΙΔΙΚΟ'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showMemberDialog(),
          tooltip: 'Προσθήκη Μέλους',
          backgroundColor: Colors.red.shade700,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: TabBarView(
          children: [
            _MemberList(
              memberType: 'Ενήλικες',
              onEdit: (memberDoc) => _showMemberDialog(existingMember: memberDoc),
              onDelete: (memberDoc) => _deleteMember(memberDoc.id, memberDoc['fullName']),
            ),
            _MemberList(
              memberType: 'Παιδικό',
              onEdit: (memberDoc) => _showMemberDialog(existingMember: memberDoc),
              onDelete: (memberDoc) => _deleteMember(memberDoc.id, memberDoc['fullName']),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberList extends StatelessWidget {
  final String memberType;
  final Function(DocumentSnapshot) onEdit;
  final Function(DocumentSnapshot) onDelete;

  const _MemberList({
    required this.memberType,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // Παίρνουμε τα μέλη ταξινομημένα απλά αλφαβητικά από το Firestore.
      // Η τελική ταξινόμηση θα γίνει μέσα στην εφαρμογή.
      stream: FirebaseFirestore.instance
          .collection('members')
          .where('memberType', isEqualTo: memberType)
          .orderBy('fullName')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Παρουσιάστηκε σφάλμα.'));
        }
        if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Δεν υπάρχουν μέλη σε αυτή την κατηγορία.\nΠατήστε "+" για προσθήκη.', textAlign: TextAlign.center));
        }
        
        final members = snapshot.data!.docs;

        // --- Η ΛΟΓΙΚΗ ΤΗΣ ΑΥΤΟΜΑΤΗΣ ΤΑΞΙΝΟΜΗΣΗΣ ΕΙΝΑΙ ΕΔΩ ---
        members.sort((a, b) {
          final dataA = a.data() as Map<String, dynamic>;
          final dataB = b.data() as Map<String, dynamic>;

          final rankTypeA = dataA['rankType'] as String? ?? 'Kyu';
          final rankTypeB = dataB['rankType'] as String? ?? 'Kyu';
          final rankLevelA = dataA['rankLevel'] as int? ?? 0;
          final rankLevelB = dataB['rankLevel'] as int? ?? 0;

          // 1. Προτεραιότητα στα Dan
          if (rankTypeA == 'Dan' && rankTypeB == 'Kyu') {
            return -1; // Ο Α προηγείται
          }
          if (rankTypeA == 'Kyu' && rankTypeB == 'Dan') {
            return 1; // Ο Β προηγείται
          }

          // 2. Αν είναι και οι δύο Dan, ταξινόμηση φθίνουσα
          if (rankTypeA == 'Dan') {
            return rankLevelB.compareTo(rankLevelA);
          }

          // 3. Αν είναι και οι δύο Kyu, ταξινόμηση αύξουσα
          if (rankTypeA == 'Kyu') {
            return rankLevelA.compareTo(rankLevelB);
          }
          
          return 0; // Αν είναι ίδιοι
        });
        // --- ΤΕΛΟΣ ΛΟΓΙΚΗΣ ΤΑΞΙΝΟΜΗΣΗΣ ---

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: members.length,
          itemBuilder: (context, index) {
            final memberDoc = members[index];
            final memberData = memberDoc.data() as Map<String, dynamic>;
            final memberFullName = memberData['fullName'] ?? 'Άγνωστο Όνομα';

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(memberFullName),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => MemberDetailPage(memberDoc: memberDoc),
                  ));
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit_note, color: Colors.grey.shade700),
                      tooltip: 'Επεξεργασία',
                      onPressed: () => onEdit(memberDoc),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: 'Διαγραφή',
                      onPressed: () => onDelete(memberDoc),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}