// lib/screens/kyu_6_page.dart
import 'package:flutter/material.dart';
import 'package:aikido_kalamata_app/widgets/syllabus_widgets.dart';

class Kyu6Page extends StatelessWidget {
  const Kyu6Page({super.key});

  @override
  Widget build(BuildContext context) {
    // Η ΔΙΟΡΘΩΣΗ ΕΙΝΑΙ ΕΔΩ: Αφαιρούμε το 'const'
    return const SyllabusPageScaffold(
      kyuLevel: '6 KYU',
      sections: [
        SyllabusRow(category: 'Προϋπόθεση', techniques: '40 ώρες προπόνηση'),
        SyllabusRow(category: 'Εξασκήσεις', techniques: 'Taisabaki: Irimi, Tenkan, Kaiten, Tsugiashi\nUkemi: Mae (μπροστά), Ushiro (όπισθεν)'),
        SyllabusRow(category: 'Επιθέσεις/\nΆλλες Τεχνικές', techniques: 'Shomen Uchi\nYokomen Uchi'),
        SyllabusRow(category: 'Gyaku Hanmi\nKatatedori', techniques: 'T (Tachiwaza - Όρθιοι)\nKokyuho, Shihonage'),
        SyllabusRow(category: 'Ai Hanmi\nKatatedori', techniques: 'T (Tachiwaza)\nIkkyo, Iriminage, Shihonage\n\nS (Suwariwaza - Καθιστά)\nIkkyo'),
        SyllabusRow(category: 'Shomen Uchi', techniques: 'T (Tachiwaza) & S (Suwariwaza - Καθιστά)\nIkkyo'),
        SyllabusRow(category: 'Yokomen Uchi', techniques: 'T&S\nIkkyo, Shihonage'),
        SyllabusRow(category: 'Ryotedori\nRyotemochi', techniques: 'S (Suwariwaza)\nKokyuho'),
        
      ],
    );
  }
}