// lib/screens/evaluation_detail_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EvaluationDetailPage extends StatefulWidget {
  final DocumentReference rankDocRef;
  final bool isEditing;

  const EvaluationDetailPage({
    super.key,
    required this.rankDocRef,
    required this.isEditing,
  });

  @override
  State<EvaluationDetailPage> createState() => _EvaluationDetailPageState();
}

class _EvaluationDetailPageState extends State<EvaluationDetailPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  String _pageTitle = 'Αξιολόγηση';

  late TextEditingController _examinerController;
  late TextEditingController _commentsController;
  late Map<String, TextEditingController> _ratingControllers;

  // --- ΝΕΟ STATE: Για την ημερομηνία ---
  DateTime? _examDate;

  final List<Map<String, String>> _criteria = [
    {'key': 'ukemi', 'label': 'UKEMI'},
    {'key': 'kokyu', 'label': 'KOKYU (Δύναμη)'},
    {'key': 'zanshin', 'label': 'ZANSHIN (Συνείδηση)'},
    {'key': 'synchronization', 'label': 'Συγχρονισμός'},
    {'key': 'correctness', 'label': 'Ορθότητα'},
    {'key': 'stance', 'label': 'Στάση'},
    {'key': 'spirit', 'label': 'Διάθεση'},
    {'key': 'flexibility', 'label': 'Ευελιξία'},
  ];

  @override
  void initState() {
    super.initState();
    _examinerController = TextEditingController();
    _commentsController = TextEditingController();
    _ratingControllers = {
      for (var item in _criteria) item['key']!: TextEditingController()
    };
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final doc = await widget.rankDocRef.get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        final ratings = data['ratings'] as Map<String, dynamic>? ?? {};
        
        setState(() {
          _pageTitle = data['rankName'] ?? 'Αξιολόγηση';
          _examinerController.text = data['examiner'] ?? '';
          _commentsController.text = data['comments'] ?? '';
          
          // --- ΑΛΛΑΓΗ: Φορτώνουμε την ημερομηνία ---
          _examDate = (data['examDate'] as Timestamp?)?.toDate();

          for (var item in _criteria) {
            _ratingControllers[item['key']!]?.text = (ratings[item['key']!] ?? '').toString();
          }
        });
      }
    } catch (e) {
      print('Error loading evaluation data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveData() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final Map<String, int> ratingsMap = {};
      for (var item in _criteria) {
        ratingsMap[item['key']!] = int.tryParse(_ratingControllers[item['key']!]!.text) ?? 0;
      }

      try {
        await widget.rankDocRef.set({
          // --- ΑΛΛΑΓΗ: Αποθηκεύουμε την ημερομηνία ---
          'examDate': _examDate != null ? Timestamp.fromDate(_examDate!) : FieldValue.serverTimestamp(),
          'examiner': _examinerController.text.trim(),
          'comments': _commentsController.text.trim(),
          'ratings': ratingsMap,
        }, SetOptions(merge: true));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Οι αλλαγές αποθηκεύτηκαν!'), backgroundColor: Colors.green),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        print('Error saving evaluation: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Σφάλμα: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
  
  // --- ΝΕΑ ΜΕΘΟΔΟΣ: Για την επιλογή ημερομηνίας ---
  Future<void> _selectDate() async {
    if (!widget.isEditing) return; // Μόνο ο admin μπορεί να αλλάξει την ημερομηνία

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _examDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)), // Μέχρι ένα χρόνο στο μέλλον
    );
    if (picked != null && picked != _examDate) {
      setState(() {
        _examDate = picked;
      });
    }
  }

  @override
  void dispose() {
    _examinerController.dispose();
    _commentsController.dispose();
    _ratingControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitle),
        actions: [
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _isLoading ? null : _saveData,
            )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  ..._criteria.map((criterion) => _buildRatingRow(criterion['label']!, _ratingControllers[criterion['key']!]!)),
                  const Divider(height: 32),

                  // --- ΝΕΟ WIDGET: Πεδίο για την ημερομηνία ---
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Ημερομηνία Απονομής'),
                    subtitle: Text(
                      _examDate != null 
                        ? DateFormat('dd MMMM yyyy', 'el_GR').format(_examDate!) 
                        : 'Δεν έχει οριστεί',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: widget.isEditing ? const Icon(Icons.edit) : null,
                    onTap: _selectDate,
                  ),
                  const Divider(height: 32),
                  
                  TextFormField(
                    controller: _commentsController,
                    enabled: widget.isEditing,
                    maxLines: 5,
                    style: !widget.isEditing 
                      ? const TextStyle(fontSize: 16.0, color: Colors.black87) 
                      : null,
                    decoration: const InputDecoration(
                      labelText: 'Σχόλια',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _examinerController,
                    enabled: widget.isEditing,
                    style: !widget.isEditing 
                      ? const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold) 
                      : null,
                    decoration: const InputDecoration(
                      labelText: 'Εξεταστής',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildRatingRow(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(label, style: const TextStyle(fontSize: 16))),
          Expanded(
            flex: 1,
            child: TextFormField(
              controller: controller,
              enabled: widget.isEditing,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: !widget.isEditing
                  ? const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      color: Colors.black,
                    )
                  : null,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}