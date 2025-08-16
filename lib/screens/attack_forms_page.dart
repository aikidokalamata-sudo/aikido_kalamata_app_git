import 'package:flutter/material.dart';

class AttackFormsPage extends StatelessWidget {
  const AttackFormsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Μορφές & Επιθέσεις'),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 1.0,
          maxScale: 5.0,
          child: Image.asset(
            'assets/images/attack_page.png',
            fit: BoxFit.fitWidth,             // Γεμίζει το πλάτος
            alignment: Alignment.topCenter,   // Κρατάει την εικόνα στο κέντρο
          ),
        ),
      ),
    );
  }
}

