// lib/screens/nafudakake_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Βοηθητικό widget για τον τίτλο κάθε βαθμού (π.χ., "3 Dan")
Widget _buildRankHeader(String title, Color backgroundColor, Color textColor) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(top: 24, bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
      ],
    ),
    child: Text(
      title,
      style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
      textAlign: TextAlign.center,
    ),
  );
}

// Βοηθητικό widget για την "πλακέτα" ονόματος κάθε μέλους
Widget _buildMemberTile(String name) {
  return Card(
    elevation: 1,
    color: const Color(0xFFd2b48c), // Χρώμα ξύλου
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        name,
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        textAlign: TextAlign.center,
      ),
    ),
  );
}

class NafudakakePage extends StatefulWidget {
  const NafudakakePage({super.key});

  @override
  State<NafudakakePage> createState() => _NafudakakePageState();
}

class _NafudakakePageState extends State<NafudakakePage> {
  Future<Map<String, List<DocumentSnapshot>>> _fetchAndGroupMembers() async {
    // --- Η ΑΛΛΑΓΗ ΕΙΝΑΙ ΕΔΩ: Προσθέτουμε το .where() για να φιλτράρουμε τα μέλη ---
    final querySnapshot = await FirebaseFirestore.instance
        .collection('members')
        .where('memberType', isEqualTo: 'Ενήλικες') // Παίρνουμε ΜΟΝΟ τους ενήλικες
        .get();
    
    final allMembers = querySnapshot.docs;

    // Η υπόλοιπη λογική ταξινόμησης και ομαδοποίησης παραμένει η ίδια
    allMembers.sort((a, b) {
      final dataA = a.data();
      final dataB = b.data();
      final rankTypeA = dataA['rankType'] as String? ?? 'Kyu';
      final rankTypeB = dataB['rankType'] as String? ?? 'Kyu';
      final rankLevelA = dataA['rankLevel'] as int? ?? 0;
      final rankLevelB = dataB['rankLevel'] as int? ?? 0;

      if (rankTypeA == 'Dan' && rankTypeB == 'Kyu') return -1;
      if (rankTypeA == 'Kyu' && rankTypeB == 'Dan') return 1;
      if (rankTypeA == 'Dan') return rankLevelB.compareTo(rankLevelA);
      return rankLevelA.compareTo(rankLevelB);
    });

    final Map<String, List<DocumentSnapshot>> groupedMembers = {};
    for (var member in allMembers) {
      final data = member.data();
      final rankType = data['rankType'] as String? ?? 'Kyu';
      final rankLevel = data['rankLevel'] as int? ?? 0;
      final key = '$rankLevel $rankType';

      groupedMembers.putIfAbsent(key, () => []).add(member);
    }
    
    groupedMembers.forEach((key, value) {
      value.sort((a, b) => (a['fullName'] as String).compareTo(b['fullName'] as String));
    });

    final sortedKeys = groupedMembers.keys.toList();
    sortedKeys.sort((a, b){
      final typeA = a.contains('Dan') ? 'Dan' : 'Kyu';
      final typeB = b.contains('Dan') ? 'Dan' : 'Kyu';
      final levelA = int.parse(a.split(' ')[0]);
      final levelB = int.parse(b.split(' ')[0]);

      if (typeA == 'Dan' && typeB == 'Kyu') return -1;
      if (typeA == 'Kyu' && typeB == 'Dan') return 1;
      if (typeA == 'Dan') return levelB.compareTo(levelA);
      return levelA.compareTo(levelB);
    });

    final Map<String, List<DocumentSnapshot>> sortedGroupedMembers = {
      for (var key in sortedKeys) key: groupedMembers[key]!
    };
    
    return sortedGroupedMembers;
  }

  @override
  Widget build(BuildContext context) {
    const danColor = Color(0xFF1a1a1a);
    const kyuColor = Color(0xFFf0e9e0);
    const pageBackgroundColor = Color(0xFF2f2a2a);

    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        title: const Text('Nafudakake'),
        backgroundColor: pageBackgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'ZonaPro', fontWeight: FontWeight.bold),
      ),
      body: FutureBuilder<Map<String, List<DocumentSnapshot>>>(
        future: _fetchAndGroupMembers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Σφάλμα: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Δεν βρέθηκαν μέλη.', style: TextStyle(color: Colors.white)));
          }

          final groupedMembers = snapshot.data!;
          final rankKeys = groupedMembers.keys.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: rankKeys.length,
            itemBuilder: (context, index) {
              final rankKey = rankKeys[index];
              final membersInRank = groupedMembers[rankKey]!;
              final isDan = rankKey.contains('Dan');

              return Column(
                children: [
                  _buildRankHeader(
                    rankKey,
                    isDan ? danColor : kyuColor,
                    isDan ? Colors.white : Colors.black,
                  ),
                  ...membersInRank.map((member) => _buildMemberTile(member['fullName'])),
                ],
              );
            },
          );
        },
      ),
    );
  }
}