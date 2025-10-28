import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../data/models/transaction_model.dart';

class ExpenseChart extends StatelessWidget {
  final List<TransactionModel> transactions;
  const ExpenseChart({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final expenseData = <String, double>{};

    // Sum up expenses by category
    for (var tx in transactions.where((t) => !t.isIncome)) {
      expenseData[tx.category] = (expenseData[tx.category] ?? 0) + tx.amount;
    }

    // Assign distinct colors per category
    final Map<String, Color> categoryColors = {
      'Food': Colors.orange,
      'Travel': Colors.blue,
      'Bills': Colors.red,
      'Shopping': Colors.purple,
      'Entertainment': Colors.green,
      'Misc': Colors.grey,
    };

    final pieSections = expenseData.entries.map((e) {
      final color = categoryColors[e.key] ?? Colors.teal;
      return PieChartSectionData(
        color: color,
        title: '${e.key}\n₹${e.value.toStringAsFixed(0)}',
        value: e.value,
        radius: 70,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      );
    }).toList();

    if (pieSections.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('No expense data available')),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Expenses by Category',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: pieSections,
                  centerSpaceRadius: 35,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Legend below chart
            Wrap(
              spacing: 12,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: expenseData.keys.map((category) {
                final color = categoryColors[category] ?? Colors.teal;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      category,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
