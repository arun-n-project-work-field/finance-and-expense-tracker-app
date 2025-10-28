class CategoryBudget {
  final int? id;
  final String category;
  final double budgetAmount;
  final String monthKey; // format YYYY-MM

  CategoryBudget({
    this.id,
    required this.category,
    required this.budgetAmount,
    required this.monthKey,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'category': category,
      'budgetAmount': budgetAmount,
      'month': monthKey,
    };
  }

  factory CategoryBudget.fromMap(Map<String, dynamic> m) {
    return CategoryBudget(
      id: m['id'] as int?,
      category: m['category'] as String,
      budgetAmount: (m['budgetAmount'] as num).toDouble(),
      monthKey: m['month'] as String,
    );
  }
}
