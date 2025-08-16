// lib/screens/kyu_4_page.dart
import 'package:flutter/material.dart';
import 'package:aikido_kalamata_app/widgets/syllabus_widgets.dart';

class Kyu4Page extends StatelessWidget {
  const Kyu4Page({super.key});

  @override
  Widget build(BuildContext context) {
    // Η ΔΙΟΡΘΩΣΗ ΕΙΝΑΙ ΕΔΩ: Αφαιρούμε το 'const'
    return const SyllabusPageScaffold(
      kyuLevel: '4 KYU',
      sections: [
        SyllabusRow(category: 'Προϋπόθεση', techniques: '60 ώρες προπόνηση μετά από το 5 kyu'),
        SyllabusRow(category: 'Εξασκήσεις', techniques: 'Taisabaki, Ukemi.\nΕπιθέσεις Shomen, Yokomen και Chudan Tsuki.\nTorifune'),
        SyllabusRow(category: 'Gyaku Hanmi\nKatatedori', techniques: 'T\nIkkyo, Nikkyo, Sankyo, Iriminage, Kokyuho, Shihonage, Uchikaiten-kokyunage, Sotokaiten-kokyunage, Uchikaiten-nage, Udekimenage, Kokyunage\n\nS\nIkkyo, Nikkyo, Sankyo, Iriminage\n\nH\nShihonage, Uchikaiten-nage'),
        SyllabusRow(category: 'Ai Hanmi\nKatatedori', techniques: 'T\nIkkyo, Nikkyo, Sankyo, Kokyuho, Iriminage, Shihonage, Uchikaiten-sankyo, Sotokaitennage, Udekimenage, Kotegaeshi\n\nS\nIkkyo, Nikkyo, Sankyo, Iriminage'),
        SyllabusRow(category: 'Katadori', techniques: 'T\nIkkyo, Nikkyo, Sankyo, Kokyuho\n\nS\nIkkyo, Nikkyo, Sankyo'),
        SyllabusRow(category: 'Shomen Uchi', techniques: 'T\nIkkyo, Nikkyo, Sankyo, Kokyuho, Iriminage, Shihonage, Udekimenage, Uchikaiten-sankyo\n\nS\nIkkyo, Nikkyo, Sankyo, Kokyuho, Iriminage'),
        SyllabusRow(category: 'Yokomen Uchi', techniques: 'T\nIkkyo, Nikkyo, Sankyo, Shihonage, Iriminage, Udekimenage\n\nS\nIkkyo, Nikkyo, Sankyo, Iriminage'),
        SyllabusRow(category: 'Ryotedori\nRyotemochi', techniques: 'T\nIkkyo, Nikkyo, Sankyo, Shihonage, Kokyuho\n\nS\nIkkyo, Nikkyo, Sankyo, Kokyuho\n\nH\nShihonage'),
        SyllabusRow(category: 'Morotedori', techniques: 'T\nKokyuho, Kokyunage'),
        SyllabusRow(category: 'Tsuki', techniques: 'Chudan (C)\nIkkyo'),
      ],
    );
  }
}