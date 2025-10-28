import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
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
  final _budgetController = TextEditingController();
  String _selectedCategory = 'Food';
  String _selectedMonth = '';

  final _categories = const [
    'Food',
    'Travel',
    'Bills',
    'Shopping',
    'Entertainment',
    'Misc',
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
      lastDate: DateTime(now.year + 1, 12),
    );

    if (picked != null) {
      setState(() {
        _selectedMonth =
            '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}';
      });

      await Provider.of<BudgetProvider>(
        context,
        listen: false,
      ).loadBudgetsForMonth(_selectedMonth);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bProv = Provider.of<BudgetProvider>(context);
    final txProv = Provider.of<TransactionProvider>(context);
    final budgets = bProv.budgets;

    final Map<String, double> spentByCategory =
        txProv.expensesByCategory != null
            ? txProv.expensesByCategory(
              year: DateTime.now().year,
              month: DateTime.now().month,
            )
            : {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Month selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Month: ${bProv.currentMonthKey}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_month_rounded),
                    onPressed: () => _selectMonth(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // New polished input area
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        items:
                            _categories
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (v) => setState(() => _selectedCategory = v!),
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _budgetController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Budget Amount',
                          prefixIcon: Icon(Icons.currency_rupee),
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (v) =>
                                v == null || v.isEmpty ? 'Enter amount' : null,
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;
                          final val = double.tryParse(_budgetController.text)!;
                          await bProv.upsertBudget(
                            CategoryBudget(
                              category: _selectedCategory,
                              budgetAmount: val,
                              monthKey: bProv.currentMonthKey,
                            ),
                          );
                          _budgetController.clear();
                        },
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text(
                          'Set Budget',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Budget list
            Expanded(
              child:
                  budgets.isEmpty
                      ? const Center(
                        child: Text(
                          'No budgets yet',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                      : ListView.separated(
                        itemCount: budgets.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (_, idx) {
                          final b = budgets[idx];
                          final spent = spentByCategory[b.category] ?? 0.0;
                          final percent =
                              b.budgetAmount == 0
                                  ? 0
                                  : (spent / b.budgetAmount);

                          Color color = Colors.green;
                          if (percent >= 1.0) {
                            color = Colors.red;
                          } else if (percent >= 0.8) {
                            color = Colors.orange;
                          }

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceVariant.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    b.category,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium!.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '₹${spent.toStringAsFixed(2)} / ₹${b.budgetAmount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: percent.clamp(0.0, 1.0).toDouble(),
                                      color: color,
                                      backgroundColor: color.withOpacity(0.3),
                                      minHeight: 8,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${(percent * 100).toStringAsFixed(0)}% used',
                                        style: TextStyle(
                                          color: color,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        color: Colors.redAccent,
                                        onPressed:
                                            () => bProv.deleteBudget(b.id!),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
