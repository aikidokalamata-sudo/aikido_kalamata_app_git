// lib/screens/progress_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  final _trainingGoalsController = TextEditingController();
  final _nextTechniquesController = TextEditingController();
  final _seminarsController = TextEditingController();
  bool _isLoading = true;
  
  late DocumentReference _progressDocRef;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _progressDocRef = FirebaseFirestore.instance
          .collection('members')
          .doc(user.uid)
          .collection('progress')
          .doc('user_notes');
      _loadData();
    }
  }

  @override
  void dispose() {
    _trainingGoalsController.dispose();
    _nextTechniquesController.dispose();
    _seminarsController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final doc = await _progressDocRef.get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _trainingGoalsController.text = data['trainingGoals'] ?? '';
        _nextTechniquesController.text = data['nextTechniques'] ?? '';
        _seminarsController.text = data['seminars'] ?? '';
      }
    } catch (e) {
      print("Error loading progress data: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveData() async {
    setState(() => _isLoading = true);
    try {
      await _progressDocRef.set({
        'trainingGoals': _trainingGoalsController.text,
        'nextTechniques': _nextTechniquesController.text,
        'seminars': _seminarsController.text,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Η πρόοδός σου αποθηκεύτηκε!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      print("Error saving progress data: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- ΟΡΙΖΟΥΜΕ ΤΟ ΣΚΟΥΡΟ ΧΡΩΜΑ ---
    const pageBackgroundColor = Color(0xFF2f2a2a);

    return Scaffold(
      // --- ΕΦΑΡΜΟΖΟΥΜΕ ΤΟ ΣΚΟΥΡΟ ΧΡΩΜΑ ---
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        title: const Text('Η Πρόοδός μου'),
        // --- ΠΡΟΣΑΡΜΟΓΗ ΤΟΥ APPBAR ΓΙΑ DARK MODE ---
        backgroundColor: pageBackgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'ZonaPro', fontWeight: FontWeight.bold),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveData,
            tooltip: 'Αποθήκευση',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildTextField(
                  controller: _trainingGoalsController,
                  label: 'Στόχοι Προπόνησης',
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _nextTechniquesController,
                  label: 'Επόμενες Τεχνικές προς Εκμάθηση',
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _seminarsController,
                  label: 'Συμμετοχή σε Σεμινάρια',
                ),
              ],
            ),
    );
  }

  // --- ΠΡΟΣΑΡΜΟΓΗ ΤΟΥ TEXTFIELD ΓΙΑ DARK MODE ---
  Widget _buildTextField({required TextEditingController controller, required String label}) {
    return TextFormField(
      controller: controller,
      maxLines: 8,
      style: const TextStyle(color: Colors.white), // Χρώμα κειμένου που γράφει ο χρήστης
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70), // Χρώμα ετικέτας
        alignLabelWithHint: true,
        // Στυλ για το περίγραμμα
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white54),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}