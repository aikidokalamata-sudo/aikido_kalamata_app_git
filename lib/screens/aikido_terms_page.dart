// lib/screens/aikido_terms_page.dart

import 'package:flutter/material.dart';
import 'attack_forms_page.dart'; // Import της νέας σελίδας με τις εικόνες

class AikidoTerm {
  final String term;
  final String explanation;
  const AikidoTerm(this.term, this.explanation);
}

class TermSection {
  final String title;
  final List<AikidoTerm> terms;
  final bool isTwoColumn;
  const TermSection(this.title, this.terms, {this.isTwoColumn = true});
}

class AikidoTermsPage extends StatelessWidget {
  const AikidoTermsPage({super.key});

  final List<TermSection> allSections = const [
    TermSection('Γενική Ορολογία', [
      AikidoTerm('ONEGAI-SHIMASU', 'Αρχή μαθήματος (Ας μάθουμε ο ένας από τον άλλο)'),
      AikidoTerm('DOMO ARIGATO GOSAIMASHITA', 'Τέλος μαθήματος (Ευχαριστώ πολύ)'),
      AikidoTerm('DOJO', 'Ο χώρος προπόνησης'),
      AikidoTerm('SENSEI', 'Δάσκαλος'),
      AikidoTerm('REI', 'Υπόκλιση'),
      AikidoTerm('SEIZA', 'Κάθισμα στα γόνατα'),
      AikidoTerm('WAZA', 'Τεχνική'),
      AikidoTerm('MAAI', 'Απόσταση'),
      AikidoTerm('TORI or NAGE', 'Αυτός που εκτελεί την τεχνική'),
      AikidoTerm('UKE', 'Αυτός που δέχεται την τεχνική'),
      AikidoTerm('TATAMI', 'Στρώματα'),
      AikidoTerm('KEIKOGI or GI', 'Στολή προπόνησης'),
      AikidoTerm('ZORI', 'Σαγιονάρες'),
      AikidoTerm('OBI', 'Ζώνη'),
      AikidoTerm('UKEMI', 'Τεχνική υποδοχής'),
      AikidoTerm('KOKYU', 'Δύναμη'),
    ]),
    TermSection('Αριθμοί', [
      AikidoTerm('ICHI: 1, NI: 2, SAN: 3, SHI ή YON: 4, GO: 5, ROKU: 6', ''),
      AikidoTerm('SHICHI: 7, HACHI: 8, KU: 9, JU: 10', ''),
    ], isTwoColumn: false),
    TermSection('Βασικές Στάσεις', [
      AikidoTerm('SAN-KAKU', 'Τριγωνική στάση'),
      AikidoTerm('HANMI', 'Η βασική στάση σώματος'),
      AikidoTerm('MIGI-HANMI', 'Δεξιά στάση'),
      AikidoTerm('HIDARI-HANMI', 'Αριστερή στάση'),
      AikidoTerm('AI-HANMI', 'Ίδια στάση (και οι δύο MIGI-HANMI ή HIDARI-HANMI)'),
      AikidoTerm('GYAKU-HANMI', 'Αντίθετη στάση (ένας MIGI-HANMI και ο άλλος HIDARI-HANMI)'),
    ]),
    TermSection('Κινήσεις Σώματος', [
      AikidoTerm('TAI-SABAKI', 'Κινήσεις σώματος'),
      AikidoTerm('IRIMI', 'Εισέρχομαι'),
      AikidoTerm('ASHI', 'Βήμα'),
      AikidoTerm('KAITEN', 'Στροφή'),
      AikidoTerm('TENKAN', 'Περιστροφή'),
      AikidoTerm('SHIKKO', 'Βάδισμα στα γόνατα'),
      AikidoTerm('TSUGI', 'Γλίστρημα'),
      AikidoTerm('URA', 'Από πίσω'),
      AikidoTerm('OMOTE', 'Από εμπρός'),
    ]),
    TermSection('UKEMI', [
      AikidoTerm('MAE', 'Εμπρός'),
      AikidoTerm('USHIRO', 'Πίσω'),
      AikidoTerm('YOKO', 'Πλάγια'),
    ]),
    TermSection('Βασικές Τεχνικές Ακινητοποίησης', [
      AikidoTerm('IKKYO', 'Πρώτη'),
      AikidoTerm('NIKKYO', 'Δεύτερη'),
      AikidoTerm('SANKYO', 'Τρίτη'),
      AikidoTerm('YONKYO', 'Τέταρτη'),
      AikidoTerm('GOKYO', 'Πέμπτη'),
      AikidoTerm('ROKYO', 'Έκτη'),
    ]),
     TermSection('Μέλη του Σώματος', [
      AikidoTerm('TE', 'Χέρι'),
      AikidoTerm('HIJI or UDE', 'Αγκώνας'),
      AikidoTerm('KATA', 'Ώμος'),
      AikidoTerm('SODE', 'Μανίκι'),
      AikidoTerm('ERI', 'Γιακάς'),
      AikidoTerm('YOKOMEN', 'Πλάι του κεφαλιού'),
      AikidoTerm('TEGATANA', 'Άκρη χεριού'),
      AikidoTerm('RYOTE', 'Τα δύο χέρια'),
      AikidoTerm('MUNE', 'Στήθος'),
      AikidoTerm('KUBI', 'Αυχένας'),
      AikidoTerm('HARA', 'Κοιλιά'),
      AikidoTerm('SHOMEN', 'Μέση του κεφαλιού'),
    ]),
    TermSection('Μορφές Επίθεσης', [
      AikidoTerm('TACHI-WAZA', 'Uke και Nage όρθιοι'),
      AikidoTerm('SUWARI-WAZA', 'Uke και Nage στα γόνατα'),
      AikidoTerm('HANMI HANDACHI-WAZA', 'Uke όρθιος και Nage στα γόνατα'),
    ], isTwoColumn: false),
    TermSection('Μορφές Επίθεσης και Άμυνας (Λαβές)', [
      AikidoTerm('KATATE DORI', 'Πιάσιμο του καρπού με το χέρι'),
      AikidoTerm('MOROTE DORI', 'Πιάσιμο του καρπού με τα δύο χέρια'),
      AikidoTerm('KATA DORI', 'Πιάσιμο από τον ώμο με το χέρι'),
      AikidoTerm('MUNE DORI', 'Πιάσιμο στο στήθος ή τα πέτα με το χέρι'),
      AikidoTerm('SODE DORI', 'Πιάσιμο από το μανίκι με το χέρι'),
      AikidoTerm('HIJI DORI', 'Πιάσιμο του αγκώνα με το χέρι'),
      AikidoTerm('ERI DORI', 'Πιάσιμο στο γιακά με το χέρι από πίσω'),
      AikidoTerm('RYOTEMOCHI-RYOTEDORI', 'Πιάσιμο των καρπών με τα δύο χέρια'),
      AikidoTerm('RYOTEMOCHI-MUNEDORI', 'Πιάσιμο στο στήθος ή τα πέτα με τα δύο χέρια'),
      AikidoTerm('RYOTEMOCHI-HIJIDORI', 'Πιάσιμο των δύο αγκώνων με τα χέρια'),
      AikidoTerm('RYOTEMOCHI-KATADORI', 'Πιάσιμο των δύο ώμων με τα χέρια'),
      AikidoTerm('USHIRO-RYOTEDORI', 'Πιάσιμο των δύο καρπών με τα χέρια από πίσω'),
      AikidoTerm('USHIRO-RYOKATADORI', 'Πιάσιμο των δύο ώμων με τα χέρια από πίσω'),
      AikidoTerm('USHIRO-RYOHIJIDORI', 'Πιάσιμο των δύο αγκώνων με τα χέρια από πίσω'),
      AikidoTerm('USHIRO-KATATE-KUBIJIME', 'Πιάσιμο του καρπού και του σβέρκου από πίσω'),
      AikidoTerm('USHIRO-MUNEDAKISHIME', 'Πιάσιμο στο στήθος με τα χέρια από πίσω'),
    ]),
    TermSection('Χτυπήματα', [
      AikidoTerm('UCHI', 'Χτύπημα'),
      AikidoTerm('TSUKI (SKI)', 'Γροθιά'),
      AikidoTerm('GERI', 'Κλωτσιά'),
      AikidoTerm('SHOMEN-UCHI', 'Χτύπημα στο κέντρο του κεφαλιού με το χέρι'),
      AikidoTerm('YOKOMEN-UCHI', 'Χτύπημα στο πλάι του κεφαλιού με το χέρι'),
      AikidoTerm('CHUDAN-TSUKI ή MUNE TSUKI', 'Γροθιά στο στήθος ή στο στομάχι'),
      AikidoTerm('JODAN-TSUKI ή MEN-TSUKI', 'Γροθιά στο κεφάλι'),
      AikidoTerm('GEDAN-TSUKI', 'Χαμηλή γροθιά'),
      AikidoTerm('MAE-GERI', 'Κλωτσιά από μπροστά'),
      AikidoTerm('MAWASHI-GERI', 'Κλωτσιά από το πλάι'),
      AikidoTerm('ATEMI', 'Χτύπημα στη πορεία της τεχνικής που βοηθάει την τεχνική'),
    ]),
    TermSection('Βασικές Τεχνικές Ρίψης', [
      AikidoTerm('IRIMI NAGE', 'Ρίψη με είσοδο του σώματος (IRI: Είσοδος, ΜΙ: Σώμα, NAGE: Ρίψη)'),
      AikidoTerm('SHIHO NAGE', 'Ρίψη σε τέσσερις διευθύνσεις (SHI: Τέσσερα, HO: Διεύθυνση)'),
      AikidoTerm('KOTE GAESHI', 'Ρίψη με στροφή του καρπού προς τα έξω (KOTE: Καρπός, GAESHI: Στροφή)'),
      AikidoTerm('KAITEN NAGE', 'Περιστροφική ρίψη (KAITEN: Περιστροφή)'),
      AikidoTerm('KOSHI NAGE', 'Ρίψη με τους γοφούς (KOSHI: Γοφοί)'),
      AikidoTerm('SUMI OTOSHI', 'Γωνιακή ρίψη (SUMI: Γωνία, OTOSHI: Πτώση)'),
      AikidoTerm('KOKYU NAGE', 'Ρίψη με συγκέντρωση δύναμης και αναπνοή (KOKYU: Δύναμη)'),
      AikidoTerm('KOKYU HO', 'Εξάσκηση συγκέντρωσης δύναμης (HO: Τεχνική ή μέθοδος)'),
    ]),
    TermSection('Όπλα', [
      AikidoTerm('TANTO', 'Μαχαίρι'),
      AikidoTerm('KEN', 'Σπαθί'),
      AikidoTerm('BOKKEN ή BOKUTO', 'Ξύλινο σπαθί'),
      AikidoTerm('SHINAI', 'Σπαθί από μπαμπού'),
      AikidoTerm('JYO ή JO', 'Ραβδί / Κοντάρι'),
      AikidoTerm('TANTODORI', 'Τεχνική έναντι μαχαιριού'),
      AikidoTerm('TACHIDORI', 'Τεχνική έναντι σπαθιού'),
      AikidoTerm('JOTORI', 'Τεχνική έναντι ραβδιού'),
    ]),
    TermSection('Τρεις Μορφές Προπόνησης', [
      AikidoTerm('GO-NO-KEIKO', 'Σκληρά με πλήρη δύναμη. Κυρίως βασική τεχνική (GO: Σκληρά)'),
      AikidoTerm('JYU-NO-KEIKO', 'Χαλαρά (JYU: Μαλακά)'),
      AikidoTerm('RYU-NO-KEIKO', 'Χαλαρά με ροή (RYU: Ροή)'),
    ], isTwoColumn: false),
  ];

  @override
  Widget build(BuildContext context) {
    const pageBackgroundColor = Color(0xFF2f2a2a);

    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        title: const Text('Ορολογία Aikido', style: TextStyle(color: Colors.white)),
        backgroundColor: pageBackgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // --- ΑΛΛΑΓΗ #1: Τυλίγουμε το ListView.builder σε ένα Column ---
      body: Column(
        children: [
          // --- ΑΛΛΑΓΗ #2: Προσθέτουμε το νέο κουμπί στην κορυφή ---
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Card(
              elevation: 2,
              color: const Color(0xFF4a4a4a), // Λίγο πιο σκούρο χρώμα για να ταιριάζει
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(Icons.image_search, color: Colors.red.shade400),
                title: const Text(
                  'Οπτικός Οδηγός Επιθέσεων',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AttackFormsPage()),
                  );
                },
              ),
            ),
          ),
          
          // --- ΑΛΛΑΓΗ #3: Τυλίγουμε το ListView.builder σε ένα Expanded για να πάρει τον υπόλοιπο χώρο ---
          Expanded(
            child: ListView.builder(
              itemCount: allSections.length,
              itemBuilder: (context, index) {
                final section = allSections[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 24, 4, 12),
                        child: Text(
                          section.title.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
                        ),
                      ),
                      _buildSectionContent(section),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContent(TermSection section) {
    if (section.isTwoColumn) {
      final int middle = (section.terms.length / 2).ceil();
      final List<AikidoTerm> firstColumnTerms = section.terms.sublist(0, middle);
      final List<AikidoTerm> secondColumnTerms = section.terms.sublist(middle);

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: firstColumnTerms.map((term) => _buildTermItem(term)).toList(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: secondColumnTerms.map((term) => _buildTermItem(term)).toList(),
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: section.terms.map((term) => _buildTermItem(term)).toList(),
      );
    }
  }

  Widget _buildTermItem(AikidoTerm term) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(term.term, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          if (term.explanation.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(term.explanation, style: const TextStyle(color: Colors.white70)),
            ),
        ],
      ),
    );
  }
}