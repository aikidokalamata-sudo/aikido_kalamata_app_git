// lib/screens/kyu_1_page.dart
import 'package:flutter/material.dart';
import 'package:aikido_kalamata_app/widgets/syllabus_widgets.dart';

class Kyu1Page extends StatelessWidget {
  const Kyu1Page({super.key});

  @override
  Widget build(BuildContext context) {
    return const SyllabusPageScaffold(
      kyuLevel: '1 KYU',
      sections: [
        SyllabusRow(category: 'ΤΕΧΝΙΚΕΣ', techniques: 'Όλες οι τεχνικές του 2 KYU, ΣΥΝ:'),
        SyllabusRow(category: 'Προϋπόθεση', techniques: '100 ώρες προπόνηση'),
        SyllabusRow(category: 'Gyaku Hanmi\nKatatedori', techniques: 'Sannindori (Randori με 3 uke)'),
        SyllabusRow(category: 'Ai Hanmi\nKatatedori', techniques: 'Sannindori (Randori με 3 uke)'),
        SyllabusRow(category: 'Kata-, Mune-\n& Sode-dori', techniques: 'T Katadori Shomenuchi\nRokyu, Kokyunage, Shihonage, Kotegaeshi, Koshinage, Iriminage'),
        SyllabusRow(category: 'Shomen Uchi', techniques: 'T\nRokyo, Udegaraminage, Koshinage,\n\nH\nRokyo, Iriminage, Kotegaeshi, Sumiotoshi\n\nSannindori (Randori με 3 uke)\n\nTantodori (1 uke)'),
        SyllabusRow(category: 'Yokomen Uchi', techniques: 'T\nKoshinage, Iriminage\n\nSannindori (Randori με 3 uke)\n\nTantodori (1 uke)'),
        SyllabusRow(category: 'Ryotedori\nRyotemochi', techniques: 'T\nKoshinage, Jujigaraminage, Udehishige\n\nSannindori (Randori με 3 uke)'),
        SyllabusRow(category: 'Morotedori', techniques: 'T\nJujigaraminage, Koshinage\n\nFutaridori (2 uke πιάνουν ταυτόχρονα)'),
        SyllabusRow(category: 'Tsuki', techniques: 'T (C)\nKoshinage, Kokyunage, Udehishige\n\n(J)\nIkkyo - Rokyo, Kokyunage\n\nSannindori (Randori με 3 uke)\n\nTantodori (1 uke)'),
        SyllabusRow(category: 'Ushiro', techniques: 'T Ryokatatedori\nRokyo, Udekimenage, Jujigaraminage, Sotokaitenage, Kokyunage, Shihonage, Kotegaeshi\n\nΤεχνικές από Ryokatadori & Ryohijidori'),
      ],
    );
  }
}