// lib/screens/kyu_2_page.dart
import 'package:flutter/material.dart';
import 'package:aikido_kalamata_app/widgets/syllabus_widgets.dart';

class Kyu2Page extends StatelessWidget {
  const Kyu2Page({super.key});

  @override
  Widget build(BuildContext context) {
    return const SyllabusPageScaffold(
      kyuLevel: '2 KYU',
      sections: [
        SyllabusRow(category: 'Προϋπόθεση', techniques: '100 ώρες προπόνηση μετά από το 3 kyu'),
        SyllabusRow(category: 'Εξασκήσεις', techniques: 'Taisabaki, Ukemi. Επιθέσεις, Torifune'),
        SyllabusRow(category: 'Gyaku Hanmi\nKatatedori', techniques: 'T\nKokyuho, Shihonage, Uchikaiten-kokyunage, Sotokaiten-kokyunage, Kotegaeshi, Tenchinage, Uchikaiten-nage, Udekimenage, Kokyunage, Udehishige, Uchikaiten-Katagatame, Sumiotoshi, Koshinage'),
        SyllabusRow(category: 'Futaridori\n(Randori με 2 uke)', techniques: 'T&S\nIkkyo, Nikkyo, Sankyo, Yonkyo, Kotegaeshi, Iriminage & Kokyuho\n\nH\nShihonage, Sumiotoshi, Uchikaiten-nage, Kotegaeshi, Iriminage, Tenchinage, Kokyunage'),
        SyllabusRow(category: 'Ai Hanmi\nKatatedori', techniques: 'T\nKokyuho, Ikkyo, Iriminage, Shihonage, Uchikaiten-sankyo, Sotokaitennage, Udekimenage, Kokyunage, Koshinage, Udegaraminage, Sumiotoshi\n\nT&S\nIkkyo, Nikkyo, Sankyo, Yonkyo, Iriminage, Kokyuho, Kotegaeshi\n\nH\nIkkyo, Nikkyo, Sankyo, Yonkyo, Iriminage'),
        SyllabusRow(category: 'Katadori Shomenuchi', techniques: 'T\nKokyuho, Udehishige\n\nT&S\nIkkyo, Nikkyo, Sankyo, Yonkyo'),
        SyllabusRow(category: 'Shomen Uchi', techniques: 'T\nShihonage, Udekimenage, Uchikaiten-sankyo, Tenchinage, Sumiotoshi, Uchi-irimitenkan +Shihonage, +Kotegaeshi, +Iriminage\n\nT&S\nIkkyo, Nikkyo, Sankyo, Yonkyo, Gokyo, Kokyuho, Iriminage, Kotegaeshi, Sotokaitennage, Katagatame'),
        SyllabusRow(category: 'Futaridori\n(Randori με 2 uke)\nTantodori (1 uke)', techniques: 'T\nShihonage, Iriminage, Udekimenage, Kotegaeshi (J,C,G), Gokyo\n\nT&S\nIkkyo, Nikkyo, Sankyo, Yonkyo, Gokyo\n\nH\nShihonage, Kotegaeshi'),
        SyllabusRow(category: 'Futaridori\n(Randori με 2 uke),\nTantodori (1 uke)', techniques: 'T\nShihonage, Tenchinage, Kokyuho, Iriminage (J,C,G), Sumiotoshi\n\nT&S\nIkkyo, Nikkyo, Sankyo, Yonkyo, Kokyuho, Katagatame, Kotegaeshi, Iriminage, Kokyunage\n\nH\nShihonage, Kotegaeshi'),
        SyllabusRow(category: 'Tsuki', techniques: 'T\nKokyuho, Ikkyo, Nikkyo, Sankyo, Yonkyo (J, C, G i.e. Jodan, Chudan & Gedan παραλλαγές), Iriminage, Kotegaeshi, Kokyunage\n\nChudan (C)\nIkkyo, Nikyo, Sankyo, Yonkyo, Gokyo, Sotokaitennage, Katagatame, Kotegaeshi, Tenchinage, Iriminage, Shihonage, Uchikaiten-sankyo'),
        SyllabusRow(category: 'Ushiro', techniques: 'Ryokatatedori\nIkkyo-Yonkyo\n\nKatatekubishime\nIkkyo-Yonkyo\n\nH Ryokatadori\nKokyunage, Ikkyo-Yonkyo'),
      ],
    );
  }
}