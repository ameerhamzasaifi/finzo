class BudgetModel {
  final String id;
  final String categoryId;
  final double amount;
  final double spent;
  final int month;
  final int year;

  const BudgetModel({
    required this.id,
    required this.categoryId,
    required this.amount,
    this.spent = 0.0,
    required this.month,
    required this.year,
  });

  double get remaining => amount - spent;
  double get percentage => amount > 0 ? (spent / amount).clamp(0.0, 1.0) : 0.0;
  bool get isOverBudget => spent > amount;

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'] as String,
      categoryId: map['category_id'] as String,
      amount: (map['amount'] as num).toDouble(),
      spent: (map['spent'] as num?)?.toDouble() ?? 0.0,
      month: map['month'] as int,
      year: map['year'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'amount': amount,
      'spent': spent,
      'month': month,
      'year': year,
    };
  }
}
