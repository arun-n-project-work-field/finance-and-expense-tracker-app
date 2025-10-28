import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../data/models/transaction_model.dart';

class ExpenseChart extends StatelessWidget {
  final List<TransactionModel> transactions;
  const ExpenseChart({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final expenseData = <String, double>{};

    for (var tx in transactions.where((t) => !t.isIncome)) {
      expenseData[tx.category] = (expenseData[tx.category] ?? 0) + tx.amount;
    }

    final pieSections = expenseData.entries
        .map((e) => PieChartSectionData(
              title: e.key,
              value: e.value,
              radius: 70,
              titleStyle: const TextStyle(fontSize: 12),
            ))
        .toList();

    if (pieSections.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('No expense data available')),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Expenses by Category',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sections: pieSections,
                  centerSpaceRadius: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
