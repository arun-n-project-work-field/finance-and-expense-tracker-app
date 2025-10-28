import 'package:finance_expense_app/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProv = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle between light and dark themes'),
            value: themeProv.isDark,
            onChanged: (v) => themeProv.toggleTheme(),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('App Version'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.file_download),
            title: const Text('Export Transactions to CSV'),
            onTap: () async {
              await Provider.of<TransactionProvider>(
                context,
                listen: false,
              ).exportToCsv();
            },
          ),
        ],
      ),
    );
  }
}
