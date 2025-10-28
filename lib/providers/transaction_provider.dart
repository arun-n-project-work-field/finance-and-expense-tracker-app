import 'package:flutter/foundation.dart';
import '../data/db/database_helper.dart';
import '../data/models/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  final dbHelper = DatabaseHelper.instance;
  List<TransactionModel> _transactions = [];

  List<TransactionModel> get transactions => _transactions;

  Future<void> fetchTransactions() async {
    final db = await dbHelper.database;
    final maps = await db.query('transactions', orderBy: 'date DESC');
    _transactions = maps.map((e) => TransactionModel.fromMap(e)).toList();
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    final db = await dbHelper.database;
    await db.insert('transactions', transaction.toMap());
    await fetchTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    final db = await dbHelper.database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
    await fetchTransactions();
  }

  double get totalBalance {
    double income = _transactions
        .where((t) => t.isIncome)
        .fold(0, (sum, t) => sum + t.amount);
    double expense = _transactions
        .where((t) => !t.isIncome)
        .fold(0, (sum, t) => sum + t.amount);
    return income - expense;
  }
}
