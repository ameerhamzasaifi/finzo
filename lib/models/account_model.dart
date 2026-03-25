class AccountModel {
  final String id;
  final String name;
  final double balance;
  final int color;
  final String icon;
  final DateTime createdAt;

  const AccountModel({
    required this.id,
    required this.name,
    required this.balance,
    required this.color,
    required this.icon,
    required this.createdAt,
  });

  factory AccountModel.fromMap(Map<String, dynamic> map) {
    return AccountModel(
      id: map['id'] as String,
      name: map['name'] as String,
      balance: (map['balance'] as num).toDouble(),
      color: map['color'] as int,
      icon: map['icon'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'color': color,
      'icon': icon,
      'created_at': createdAt.toIso8601String(),
    };
  }

  AccountModel copyWith({
    String? name,
    double? balance,
    int? color,
    String? icon,
  }) {
    return AccountModel(
      id: id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt,
    );
  }
}
