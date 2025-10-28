// import 'package:flutter/material.dart';
// import '../../../data/models/transaction_model.dart';

// class TransactionTile extends StatelessWidget {
//   final TransactionModel transaction;

//   const TransactionTile({super.key, required this.transaction});

//   @override
//   Widget build(BuildContext context) {
//     final isIncome = transaction.isIncome;
//     final color = isIncome ? Colors.green : Colors.red;
//     final sign = isIncome ? '+' : '-';

//     return Card(
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundColor: color.withOpacity(0.15),
//           child: Icon(
//             isIncome ? Icons.arrow_downward : Icons.arrow_upward,
//             color: color,
//           ),
//         ),
//         title: Text(transaction.title),
//         subtitle: Text(transaction.category),
//         trailing: Text(
//           '$sign ₹${transaction.amount.toStringAsFixed(2)}',
//           style: TextStyle(color: color, fontWeight: FontWeight.bold),
//         ),
//       ),
//     );
//   }
// }
import 'package:finance_expense_app/ui/screens/add_edit_transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/models/transaction_model.dart';
import '../../../providers/transaction_provider.dart';


class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.isIncome;
    final color = isIncome ? Colors.green : Colors.red;
    final sign = isIncome ? '+' : '-';
    final dateString = DateFormat.yMMMd().format(transaction.date);

    return Dismissible(
      key: ValueKey(transaction.id),
      background: Container(
        color: Colors.red.withOpacity(0.8),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red.withOpacity(0.8),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        final confirm = await showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text('Delete Transaction'),
                content: const Text('Are you sure you want to delete this?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
        );
        return confirm ?? false;
      },
      onDismissed: (_) {
        Provider.of<TransactionProvider>(
          context,
          listen: false,
        ).deleteTransaction(transaction.id!);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Transaction deleted')));
      },
      child: Card(
        child: ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => AddEditTransactionScreen(
                      existingTransaction: transaction,
                    ),
              ),
            );
          },
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: color,
            ),
          ),
          title: Text(transaction.title),
          subtitle: Text('${transaction.category} • $dateString'),
          trailing: Text(
            '$sign ₹${transaction.amount.toStringAsFixed(2)}',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
