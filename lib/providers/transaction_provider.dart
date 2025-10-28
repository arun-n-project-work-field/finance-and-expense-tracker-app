import 'package:flutter/foundation.dart';
import 'package:csv/csv.dart';
import '../data/db/database_helper.dart';
import '../data/models/transaction_model.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class TransactionProvider extends ChangeNotifier {
  final dbHelper = DatabaseHelper.instance;
  List<TransactionModel> _transactions = [];

  List<TransactionModel> get transactions => _transactions;

  Future<void> exportToCsv() async {
    final dbClient = await db.database;
    final transactions = await dbClient.query('transactions');

    List<List<dynamic>> rows = [
      ['ID', 'Title', 'Amount', 'Category', 'Date', 'Type'],
    ];

    for (var t in transactions) {
      rows.add([
        t['id'],
        t['title'],
        t['amount'],
        t['category'],
        t['date'],
        t['type'],
      ]);
    }

    String csvData = const ListToCsvConverter().convert(rows);

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/transactions.csv';
    final file = File(path);
    await file.writeAsString(csvData);

    await Share.shareXFiles([
      XFile(path),
    ], text: 'My Finance Tracker CSV Export');
  }

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
