import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/models/transaction_model.dart';
import '../../../providers/transaction_provider.dart';

class AddEditTransactionScreen extends StatefulWidget {
  final TransactionModel? existingTransaction;

  const AddEditTransactionScreen({super.key, this.existingTransaction});

  @override
  State<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  String _selectedCategory = 'Food';
  bool _isIncome = false;
  DateTime _selectedDate = DateTime.now();

  final _categories = [
    'Food',
    'Travel',
    'Bills',
    'Shopping',
    'Salary',
    'Entertainment',
  ];

  @override
  void initState() {
    super.initState();
    final tx = widget.existingTransaction;
    _titleController = TextEditingController(text: tx?.title ?? '');
    _amountController = TextEditingController(
      text: tx?.amount.toString() ?? '',
    );
    _selectedCategory = tx?.category ?? 'Food';
    _isIncome = tx?.isIncome ?? false;
    _selectedDate = tx?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final transaction = TransactionModel(
      id: widget.existingTransaction?.id,
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      category: _selectedCategory,
      date: _selectedDate,
      isIncome: _isIncome,
    );

    final provider = context.read<TransactionProvider>();

    if (widget.existingTransaction == null) {
      await provider.addTransaction(transaction);
    } else {
      await provider.updateTransaction(transaction);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingTransaction == null
              ? 'Add Transaction'
              : 'Edit Transaction',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  prefixIcon: Icon(Icons.title),
                ),
                validator:
                    (value) => value!.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
                validator: (value) {
                  if (value!.isEmpty) return 'Enter an amount';
                  if (double.tryParse(value) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items:
                    _categories
                        .map(
                          (cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)),
                        )
                        .toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Income?'),
                value: _isIncome,
                onChanged: (val) => setState(() => _isIncome = val),
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(
                  'Date: ${DateFormat.yMMMd().format(_selectedDate)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    initialDate: _selectedDate,
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Save Transaction'),
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
