// lib/screens/home_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'login_page.dart';
import 'aikido_terms_page.dart';
import 'etiquette_page.dart';
import 'all_announcements_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Stream<DocumentSnapshot?> getNextLessonStream() {
    final now = DateTime.now();
    final int currentDay = now.weekday;
    final String currentTime = DateFormat('HH:mm').format(now);

    return FirebaseFirestore.instance.collection('schedule').snapshots().map((snapshot) {
      var potentialLessonsToday = snapshot.docs
          .where((doc) => doc['day'] == currentDay && (doc['startTime'] as String).compareTo(currentTime) >= 0)
          .toList()..sort((a, b) => (a['startTime'] as String).compareTo(b['startTime'] as String));

      if (potentialLessonsToday.isNotEmpty) {
        return potentialLessonsToday.first;
      }

      for (int i = 1; i <= 7; i++) {
        int nextDay = (currentDay + i - 1) % 7 + 1;
        var potentialLessonsNextDays = snapshot.docs
            .where((doc) => doc['day'] == nextDay)
            .toList()..sort((a, b) => (a['startTime'] as String).compareTo(b['startTime'] as String));

        if (potentialLessonsNextDays.isNotEmpty) {
          return potentialLessonsNextDays.first;
        }
      }
      return null;
    });
  }

  String getDayName(int dayNumber) {
    final now = DateTime.now();
    if (dayNumber == now.weekday) {
      return 'Σήμερα';
    }
    switch (dayNumber) {
      case 1: return 'Δευτέρα';
      case 2: return 'Τρίτη';
      case 3: return 'Τετάρτη';
      case 4: return 'Πέμπτη';
      case 5: return 'Παρασκευή';
      case 6: return 'Σάββατο';
      case 7: return 'Κυριακή';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    const lightCardBackgroundColor = Color(0xFFf7f2fa);
    const darkCardBackgroundColor = Color(0xFF2f2a2a);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            pinned: false,
            expandedHeight: 200.0,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Image.asset(
                  'assets/images/aikido_logo.png',
                  height: 150,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            actions: [
              StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginPage()));
                      },
                      child: const Text('Login', style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   StreamBuilder<User?>(
                    stream: FirebaseAuth.instance.authStateChanges(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: Text(
                            'Καλώς ήρθες, ${snapshot.data!.email!}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const Text('ΕΠΟΜΕΝΟ ΜΑΘΗΜΑ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 8),
                  Card(
                    color: darkCardBackgroundColor,
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: StreamBuilder<DocumentSnapshot?>(
                      stream: getNextLessonStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const ListTile(title: Text('Αναζήτηση...', style: TextStyle(color: Colors.white)));
                        }
                        if (!snapshot.hasData || snapshot.data == null) {
                          return const ListTile(title: Text('Δεν έχει οριστεί πρόγραμμα.', style: TextStyle(color: Colors.white)));
                        }
                        final lessonData = snapshot.data!.data() as Map<String, dynamic>;
                        final dayName = getDayName(lessonData['day']);
                        final time = lessonData['startTime'];
                        final category = lessonData['category'];
                        return ListTile(
                          leading: const Icon(Icons.access_time_filled, color: Colors.white, size: 30),
                          title: Text(category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                          subtitle: Text('$dayName στις $time μ.μ.', style: const TextStyle(fontSize: 14, color: Colors.white70)),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text('ΤΕΛΕΥΤΑΙΕΣ ΑΝΑΚΟΙΝΩΣΕΙΣ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AllAnnouncementsPage()));
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Card(
                      color: darkCardBackgroundColor,
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: FirebaseFirestore.instance.collection('announcements').orderBy('timestamp', descending: true).limit(2).snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                              return const ListTile(title: Text('Δεν υπάρχουν πρόσφατες ανακοινώσεις.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white)));
                            }
                            final announcements = snapshot.data!.docs;
                            return Column(
                              children: List.generate(announcements.length, (index) {
                                final announcement = announcements[index].data();
                                final isFirstItem = index == 0;
                                return Column(
                                  children: [
                                    if (!isFirstItem) Divider(indent: 20, endIndent: 20, height: 1, color: Colors.grey.shade700),
                                    ListTile(
                                      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                                      title: Text(
                                        announcement['title'] ?? '',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text('ΧΡΗΣΙΜΑ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 8),
                  Card(
                    color: lightCardBackgroundColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: const Icon(Icons.translate, color: Colors.black54, size: 30),
                      title: const Text('Λεξικό Ορολογίας Aikido', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      subtitle: const Text('Βρείτε τους όρους που χρησιμοποιούμε στο Dojo.', style: TextStyle(color: Colors.black87)),
                      trailing: const Icon(Icons.arrow_forward, color: Colors.black54),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AikidoTermsPage()));
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    color: lightCardBackgroundColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: const Icon(Icons.rule_folder_outlined, color: Colors.black54, size: 30),
                      title: const Text('Κανόνες Dojo / Etiquette', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      subtitle: const Text('Διαβάστε τον κώδικα συμπεριφοράς του Dojo.', style: TextStyle(color: Colors.black87)),
                      trailing: const Icon(Icons.arrow_forward, color: Colors.black54),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const EtiquettePage()));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}