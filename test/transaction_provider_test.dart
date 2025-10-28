import 'package:finance_expense_app/providers/transaction_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Adding transaction updates list', () async {
    final provider = TransactionProvider();
    await provider.addTransaction(
      title: 'Test',
      amount: 100,
      category: 'Food',
      type: 'expense',
      date: DateTime.now(),
    );
    expect(provider.transactions.isNotEmpty, true);
  });
}
