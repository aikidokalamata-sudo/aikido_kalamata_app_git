// lib/screens/kyu_3_page.dart
import 'package:flutter/material.dart';
import 'package:aikido_kalamata_app/widgets/syllabus_widgets.dart';

class Kyu3Page extends StatelessWidget {
  const Kyu3Page({super.key});

  @override
  Widget build(BuildContext context) {
    return const SyllabusPageScaffold(
      kyuLevel: '3 KYU',
      sections: [
        SyllabusRow(category: 'Προϋπόθεση', techniques: '80 ώρες προπόνηση μετά από το 4 kyu'),
        SyllabusRow(category: 'Εξασκήσεις', techniques: 'Taisabaki, Ukemi. Επιθέσεις, Torifune'),
        SyllabusRow(category: 'Gyaku Hanmi\nKatatedori', techniques: 'T\nKokyuho, Shihonage, Uchikaiten-kokyunage, Sotokaiten-kokyunage, Kotegaeshi, Uchikaiten-nage, Udekimenage, Kokyunage, Sumiotoshi, Uchikaiten-Katagatame\n\nT&S\nIkkyo, Nikkyo, Sankyo, Kotegaeshi, Iriminage & Kokyuho (J,C,G)\n\nH\nShihonage, Uchikaiten-nage, Kotegaeshi, Iriminage'),
        SyllabusRow(category: 'Ai Hanmi\nKatatedori', techniques: 'T\nKokyuho, Ikkyo, Iriminage, Shihonage, Uchikaiten-sankyo, Sotokaitennage, Udekimenage, Kokyunage\n\nT&S\nIkkyo, Nikkyo, Sankyo, Iriminage, Kokyuho, Kotegaeshi'),
        SyllabusRow(category: 'Kata-, Mune-\n& Sode-dori', techniques: 'T\nKokyuho\n\nT&S\nIkkyo, Nikkyo, Sankyo'),
        SyllabusRow(category: 'Shomen Uchi', techniques: 'T\nShihonage, Udekimenage, Uchikaiten-sankyo, Uchi-irimitenkan + Shihonage, + Kotegaeshi, + Iriminage\n\nT&S\nIkkyo, Nikkyo, Sankyo, Yonkyo, Kokyuho, Iriminage, Kotegaeshi, Sotokaitennage, Katagatame'),
        SyllabusRow(category: 'Yokomen Uchi', techniques: 'T\nShihonage, Iriminage, Udekimenage, Kotegaeshi (J,C,G), Gokyu\n\nT&S\nIkkyo, Nikkyo, Sankyo\n\nH\nShihonage'),
        SyllabusRow(category: 'Ryotedori\nRyotemochi', techniques: 'T\nShihonage, Tenchinage, Kokyuho, Kotegaeshi, Iriminage (J,C,G)\n\nT&S\nIkkyo, Nikkyo, Sankyo, Kokyuho\n\nH\nShihonage'),
        SyllabusRow(category: 'Morotedori', techniques: 'T\nKokyuho, Ikkyo, Kokyunage'),
        SyllabusRow(category: 'Tsuki', techniques: 'Chudan (C)\nIkkyo, Nikkyo, Sankyo, Sotokaitennage, Katagatame, Kotegaeshi, Uchikaiten-sankyo'),
        SyllabusRow(category: 'Ushiro', techniques: 'Ryokatatedori\nIkkyo, Kokyunage'),
      ],
    );
  }
}