import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/expense_chart.dart';
import '../../widgets/transaction_tile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final transactions = provider.transactions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Finance 💰'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.fetchTransactions(),
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            BalanceCard(balance: provider.totalBalance),
            const SizedBox(height: 16),
            ExpenseChart(transactions: transactions),
            const SizedBox(height: 16),
            Text(
              'Recent Transactions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (transactions.isEmpty)
              const Center(
                  child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No transactions yet. Add one to get started!'),
              ))
            else
              ...transactions.take(5).map((tx) => TransactionTile(transaction: tx)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/addTransaction'),
        label: const Text('Add'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
