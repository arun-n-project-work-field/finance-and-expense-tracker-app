import 'dart:io';
import 'package:finance_expense_app/providers/transaction_provider.dart';
import 'package:finance_expense_app/ui/screens/add_edit_transaction_screen.dart';
import 'package:finance_expense_app/ui/widgets/balance_card.dart';
import 'package:finance_expense_app/ui/widgets/expense_chart.dart';
import 'package:finance_expense_app/ui/widgets/transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () =>
          Provider.of<TransactionProvider>(
            context,
            listen: false,
          ).fetchTransactions(),
    );
  }

  Future<void> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (status.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage permission is required to save CSV.'),
          ),
        );
        return;
      }
    }
  }

  Future<void> _downloadCsv() async {
    final provider = context.read<TransactionProvider>();
    setState(() => _isExporting = true);

    try {
      await _requestStoragePermission();
      final filePath = await provider.saveToCsvLocally();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('✅ CSV saved to: $filePath')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Failed to export: $e')));
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();
    final transactions = transactionProvider.transactions;
    final balance = transactionProvider.totalBalance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance and Expenses 💰'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => transactionProvider.fetchTransactions(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              BalanceCard(balance: transactionProvider.totalBalance),
              const SizedBox(height: 16),
              ExpenseChart(transactions: transactions),
              const SizedBox(height: 20),
              _isExporting
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text('Download CSV'),
                    onPressed: _downloadCsv,
                  ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Recent Transactions',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 10),
              if (transactions.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No transactions yet.'),
                )
              else
                Column(
                  children:
                      transactions
                          .take(10)
                          .map((t) => TransactionTile(transaction: t))
                          .toList(),
                ),
            ],
          ),
        ),
      ),

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'budget',
            onPressed: () {
              Navigator.pushNamed(context, '/budgets');
            },
            backgroundColor: Colors.amber,
            child: const Icon(Icons.account_balance_wallet_outlined),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () {
              Navigator.pushNamed(context, '/addTransaction');
            },
            backgroundColor: Colors.lightGreen,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
