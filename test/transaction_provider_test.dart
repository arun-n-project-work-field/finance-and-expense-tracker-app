import 'package:flutter_test/flutter_test.dart';
import 'package:finance_expense_app/providers/transaction_provider.dart';
import 'package:finance_expense_app/data/models/transaction_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Adding transaction updates list', () async {
    final provider = TransactionProvider();

    final transaction = TransactionModel(
      title: 'Test Expense',
      amount: 100.0,
      category: 'Food',
      date: DateTime.now(),
      isIncome: false, // 👈 replace 'type' with 'isIncome'
    );

    await provider.addTransaction(transaction);
    await provider.fetchTransactions();

    expect(provider.transactions.isNotEmpty, true);
    expect(provider.transactions.first.title, 'Test Expense');
  });
}
