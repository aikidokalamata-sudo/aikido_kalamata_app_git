// lib/screens/techniques_page.dart

import 'package:flutter/material.dart';

import 'kyu_6_page.dart';
import 'kyu_5_page.dart';
import 'kyu_4_page.dart';
import 'kyu_3_page.dart';
import 'kyu_2_page.dart';
import 'kyu_1_page.dart';

class TechniquesPage extends StatelessWidget {
  const TechniquesPage({super.key});

  final List<Map<String, dynamic>> kyuRanks = const [
    {'title': '6ο Kyu', 'page': Kyu6Page()},
    {'title': '5ο Kyu', 'page': Kyu5Page()},
    {'title': '4ο Kyu', 'page': Kyu4Page()},
    {'title': '3ο Kyu', 'page': Kyu3Page()},
    {'title': '2ο Kyu', 'page': Kyu2Page()},
    {'title': '1ο Kyu', 'page': Kyu1Page()},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ύλη Εξετάσεων'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final rank = kyuRanks[index];
                  final String rankTitle = rank['title'];
                  final Widget rankPage = rank['page'];

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ListTile(
                      // --- ΑΛΛΑΓΗ ΕΔΩ ---
                      // Αντικαθιστούμε το Icon widget με το Image.asset widget
                      leading: Padding(
                        padding: const EdgeInsets.all(5.0), // Λίγο padding για να μην "κολλάει"
                        child: Image.asset(
                          // Σημείωση: Αν η εικόνα είναι στο assets/images, άλλαξε το path αναλόγως.
                          'assets/icon/icon.png',
                          height: 35.0,
                          width: 35.0,
                        ),
                      ),
                      title: Text(
                        rankTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16.0,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => rankPage,
                          ),
                        );
                      },
                    ),
                  );
                },
                childCount: kyuRanks.length,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Image.asset(
                'assets/images/techniques_background.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}