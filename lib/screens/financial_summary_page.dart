// lib/screens/financial_summary_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FinancialSummaryPage extends StatefulWidget {
  const FinancialSummaryPage({super.key});

  @override
  State<FinancialSummaryPage> createState() => _FinancialSummaryPageState();
}

class _FinancialSummaryPageState extends State<FinancialSummaryPage> {
  DateTime _selectedDate = DateTime.now();

  // --- ΟΛΟΚΛΗΡΩΜΕΝΗ ΣΥΝΑΡΤΗΣΗ ΓΙΑ ΤΟ DIALOG ---
  void _showTransactionDialog({DocumentSnapshot? existingTransaction}) {
    final bool isEditing = existingTransaction != null;
    final data = isEditing ? existingTransaction.data() as Map<String, dynamic> : null;

    final descriptionController = TextEditingController(text: data?['description'] ?? '');
    final amountController = TextEditingController(text: (data?['amount'] as num?)?.abs().toString() ?? '');
    bool isIncome = data?['amount'] == null || (data?['amount'] as num) > 0;
    DateTime transactionDate = (data?['date'] as Timestamp?)?.toDate() ?? DateTime.now();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Επεξεργασία Κίνησης' : 'Νέα Κίνηση'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: 'Περιγραφή'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Ποσό (€)'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text('Τύπος:'),
                        ChoiceChip(
                          label: const Text('Έσοδο'),
                          selected: isIncome,
                          onSelected: (selected) {
                            setDialogState(() => isIncome = true);
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Έξοδο'),
                          selected: !isIncome,
                          onSelected: (selected) {
                            setDialogState(() => isIncome = false);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Άκυρο'),
                ),
                TextButton(
                  onPressed: () {
                    final double? amount = double.tryParse(amountController.text.trim());
                    if (amount != null && descriptionController.text.isNotEmpty) {
                      final finalAmount = isIncome ? amount : -amount;
                      
                      FirebaseFirestore.instance.collection('transactions').add({
                        'amount': finalAmount,
                        'description': descriptionController.text.trim(),
                        'date': Timestamp.fromDate(transactionDate),
                      });
                      
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  child: Text(isEditing ? 'Αποθήκευση' : 'Προσθήκη'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final startOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final endOfMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0, 23, 59, 59);

    return Scaffold(
      appBar: AppBar(
        title: Text('Σύνοψη ${DateFormat.yMMMM('el_GR').format(_selectedDate)}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                locale: const Locale('el', 'GR'),
              );
              if (picked != null && picked != _selectedDate) {
                setState(() {
                  _selectedDate = picked;
                });
              }
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('transactions')
            .where('date', isGreaterThanOrEqualTo: startOfMonth)
            .where('date', isLessThanOrEqualTo: endOfMonth)
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Δεν υπάρχουν κινήσεις για αυτόν τον μήνα.'),
                ],
              ),
            );
          }

          double totalIncome = 0;
          double totalExpenses = 0;
          List<DocumentSnapshot> incomeTransactions = [];
          List<DocumentSnapshot> expenseTransactions = [];

          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final amount = data['amount'] as num;

            if (amount > 0) {
              totalIncome += amount;
              incomeTransactions.add(doc);
            } else {
              totalExpenses += amount;
              expenseTransactions.add(doc);
            }
          }

          final netBalance = totalIncome + totalExpenses;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    _buildSummaryCard('Έσοδα', totalIncome, Colors.green),
                    _buildSummaryCard('Έξοδα', totalExpenses, Colors.red),
                    _buildSummaryCard('Ισοζύγιο', netBalance, netBalance >= 0 ? Colors.blue : Colors.orange),
                  ],
                ),
              ),
              Expanded(
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      const TabBar(
                        labelColor: Colors.black,
                        tabs: [Tab(text: 'ΕΣΟΔΑ'), Tab(text: 'ΕΞΟΔΑ')],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildTransactionList(incomeTransactions, true),
                            _buildTransactionList(expenseTransactions, false),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTransactionDialog(),
        tooltip: 'Προσθήκη Κίνησης',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Text(title, style: const TextStyle(fontSize: 14, color: Colors.black54)),
              const SizedBox(height: 4),
              Text(
                '${amount.toStringAsFixed(2)} €',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionList(List<DocumentSnapshot> transactions, bool isIncome) {
    if (transactions.isEmpty) {
      return Center(child: Text('Δεν υπάρχουν ${isIncome ? "έσοδα" : "έξοδα"}.'));
    }
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final doc = transactions[index];
        final data = doc.data() as Map<String, dynamic>;
        final amount = data['amount'] as num;
        final description = data['description'] as String? ?? 'Χωρίς περιγραφή';
        final date = (data['date'] as Timestamp).toDate();

        return ListTile(
          leading: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: isIncome ? Colors.green : Colors.red),
          title: Text(description),
          subtitle: Text(DateFormat('dd/MM/yyyy').format(date)),
          trailing: Text(
            '${amount.abs().toStringAsFixed(2)} €',
            style: TextStyle(fontWeight: FontWeight.bold, color: isIncome ? Colors.green : Colors.red),
          ),
          onLongPress: () {
            showDialog(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Διαγραφή Κίνησης'),
                content: const Text('Είστε σίγουρος ότι θέλετε να διαγράψετε αυτή την κίνηση;'),
                actions: [
                  TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Άκυρο')),
                  TextButton(
                    onPressed: () {
                      doc.reference.delete();
                      Navigator.of(dialogContext).pop();
                    },
                    child: const Text('Διαγραφή', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}