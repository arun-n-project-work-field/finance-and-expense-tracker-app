import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../data/models/budget_model.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});
  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedCategory = 'Food';
  final _budgetController = TextEditingController();
  String _selectedMonth = '';

  final _categories = [
    'Food',
    'Travel',
    'Bills',
    'Shopping',
    'Entertainment',
    'Misc'
  ];

  @override
  void initState() {
    super.initState();
    final bProv = Provider.of<BudgetProvider>(context, listen: false);
    _selectedMonth = bProv.currentMonthKey;
    bProv.loadBudgetsForMonth();
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _selectMonth(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showMonthPicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 2, 1),
      lastDate: now,
    );
    if (picked != null) {
      _selectedMonth =
          '${picked.year.toString().padLeft(4,'0')}-${picked.month.toString().padLeft(2,'0')}';
      await Provider.of<BudgetProvider>(context, listen: false)
          .loadBudgetsForMonth(_selectedMonth);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bProv = Provider.of<BudgetProvider>(context);
    final txProv = Provider.of<TransactionProvider>(context);
    final budgets = bProv.budgets;

    final spentByCategory =
        txProv.expensesByCategory(year: DateTime.now().year, month: DateTime.now().month);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Row(
            children: [
              Expanded(child: Text('Month: ${bProv.currentMonthKey}')),
              IconButton(
                icon: const Icon(Icons.calendar_month),
                onPressed: () => _selectMonth(context),
              ),
            ],
          ),
          Form(
            key: _formKey,
            child: Row(children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: _categories
                      .map((c) => DropdownMenuItem(
                          value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v!),
                  decoration:
                      const InputDecoration(labelText: 'Category'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _budgetController,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Budget Amount'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter amount' : null,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final val = double.tryParse(_budgetController.text)!;
                  await bProv.upsertBudget(CategoryBudget(
                      category: _selectedCategory,
                      budgetAmount: val,
                      monthKey: bProv.currentMonthKey));
                  _budgetController.clear();
                },
                child: const Text('Set'),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: budgets.isEmpty
                ? const Center(child: Text('No budgets yet'))
                : ListView.separated(
                    itemCount: budgets.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (_, idx) {
                      final b = budgets[idx];
                      final spent =
                          spentByCategory[b.category] ?? 0.0;
                      final percent = (b.budgetAmount == 0)
                          ? 0
                          : (spent / b.budgetAmount);
                      Color color = Colors.green;
                      if (percent >= 1.0) color = Colors.red;
                      else if (percent >= 0.8) color = Colors.orange;
                      return Card(
                        child: Padding(
                          padding:
                              const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(b.category,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value:
                                    percent.clamp(0.0, 1.0),
                                color: color,
                                backgroundColor:
                                    color.withOpacity(0.3),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                  'Used: ₹${spent.toStringAsFixed(2)} of ₹${b.budgetAmount.toStringAsFixed(2)}'),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                children: [
                                  Text(
                                      '${(percent * 100).toStringAsFixed(0)}%'),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () =>
                                        bProv.deleteBudget(b.id!),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          )
        ]),
      ),
    );
  }
}
