import 'package:flutter/foundation.dart';
import '../data/db/database_helper.dart';
import '../data/models/budget_model.dart';

class BudgetProvider with ChangeNotifier {
  final DatabaseHelper db = DatabaseHelper.instance;
  List<CategoryBudget> _budgets = [];
  String _currentMonthKey = _generateMonthKey(DateTime.now());

  List<CategoryBudget> get budgets => _budgets;
  String get currentMonthKey => _currentMonthKey;

  static String _generateMonthKey(DateTime d) =>
      '${d.year.toString().padLeft(4,'0')}-${d.month.toString().padLeft(2,'0')}';

  Future<void> loadBudgetsForMonth([String? monthKey]) async {
    _currentMonthKey = monthKey ?? _currentMonthKey;
    final dbClient = await db.database;
    final maps = await dbClient.query(
      'budgets',
      where: 'month = ?',
      whereArgs: [_currentMonthKey],
      orderBy: 'category ASC',
    );
    _budgets =
        maps.map((e) => CategoryBudget.fromMap(e)).toList();
    notifyListeners();
  }

  Future<void> upsertBudget(CategoryBudget b) async {
    final dbClient = await db.database;
    if (b.id == null) {
      await dbClient.insert('budgets', b.toMap());
    } else {
      await dbClient.update('budgets', b.toMap(),
          where: 'id = ?', whereArgs: [b.id]);
    }
    await loadBudgetsForMonth(_currentMonthKey);
  }

  Future<void> deleteBudget(int id) async {
    final dbClient = await db.database;
    await dbClient.delete('budgets', where: 'id = ?', whereArgs: [id]);
    await loadBudgetsForMonth(_currentMonthKey);
  }
}
