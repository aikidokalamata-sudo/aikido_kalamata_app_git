// lib/screens/kyu_5_page.dart
import 'package:flutter/material.dart';
import 'package:aikido_kalamata_app/widgets/syllabus_widgets.dart';

class Kyu5Page extends StatelessWidget {
  const Kyu5Page({super.key});

  @override
  Widget build(BuildContext context) {
    // Η ΔΙΟΡΘΩΣΗ ΕΙΝΑΙ ΕΔΩ: Αφαιρούμε το 'const'
    return const SyllabusPageScaffold(
      kyuLevel: '5 KYU',
      sections: [
        SyllabusRow(category: 'Προϋπόθεση', techniques: '40 ώρες προπόνηση μετά από το 6 kyu'),
        SyllabusRow(category: 'Εξασκήσεις', techniques: 'Taisabaki, Ukemi.\n5 Taisabaki ενάντια σε Gyakuhanmi katatedori\ni.e. Irimi, Tenkan, Uchi-kaiten, Soto-Kaiten, Sokomen Yokomen+Tsugiashi'),
        SyllabusRow(category: 'Gyaku Hanmi\nKatatedori', techniques: 'T\nKokyuho, Shihonage\nUchikaiten-kokyunage\nSotokaiten-kokyunage\n\nT&S\nIkkyo, Iriminage'),
        SyllabusRow(category: 'Ai Hanmi\nKatatedori', techniques: 'T\nIkkyo, Iriminage,\nShihonage, Kokyuho\n\nS\nIkkyo, Iriminage'),
        SyllabusRow(category: 'Katadori', techniques: 'T&S\nIkkyo'),
        SyllabusRow(category: 'Shomen Uchi', techniques: 'T&S\nIkkyo, Kokyuho, Iriminage'),
        SyllabusRow(category: 'Yokomen Uchi', techniques: 'T&S\nIkkyo, Shihonage'),
        SyllabusRow(category: 'Ryotedori\nRyotemochi', techniques: 'T\nShihonage, Ikkyo\n\nS\nKokyuho, Ikkyo'),
        SyllabusRow(category: 'Morotedori', techniques: 'Kokyuho'),
      ],
    );
  }
}