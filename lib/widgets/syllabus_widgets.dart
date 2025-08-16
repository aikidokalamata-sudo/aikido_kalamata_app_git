// lib/widgets/syllabus_widgets.dart
import 'package:flutter/material.dart';

// Αυτό είναι το βασικό "καλούπι" για κάθε σελίδα Kyu
class SyllabusPageScaffold extends StatelessWidget {
  final String kyuLevel;
  final List<Widget> sections;

  const SyllabusPageScaffold({
    super.key,
    required this.kyuLevel,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    const pageBackgroundColor = Color(0xFF2f2a2a);

    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        backgroundColor: pageBackgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              // --- ΟΙ ΑΛΛΑΓΕΣ ΕΙΝΑΙ ΕΔΩ ---
              // Χρησιμοποιούμε το κανονικό λογότυπο
              Image.asset(
                'assets/images/etiquette_photo.png',
                // Μειώνουμε δραστικά το ύψος για πιο διακριτική εμφάνιση
                height: 90, 
                // Εξασφαλίζουμε ότι το λογότυπο φαίνεται ολόκληρο
                fit: BoxFit.contain, 
              ),
              const SizedBox(height: 24),
              Text(
                kyuLevel,
                style: const TextStyle(color: Colors.red, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...sections,
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32.0),
                child: Text(
                  '[ T = Tachiwaza, S = Suwariwaza, H = Hanmihandachi, J = Jodan, C = Chudan, G = Gedan ]',
                  style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Αυτό το widget παραμένει ακριβώς το ίδιο
class SyllabusRow extends StatelessWidget {
  final String category;
  final String techniques;

  const SyllabusRow({
    super.key,
    required this.category,
    required this.techniques,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(height: 1, color: Colors.white24),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  category,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: Text(
                  techniques,
                  style: const TextStyle(fontSize: 15, height: 1.4, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}