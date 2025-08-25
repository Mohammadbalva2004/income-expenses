enum TransactionType { income, expense }

class Transaction {
  final int? id;
  final int userId;
  final double amount;
  final String description;
  final TransactionType type;
  final DateTime date;

  Transaction({
    this.id,
    required this.userId,
    required this.amount,
    required this.description,
    required this.type,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'description': description,
      'type': type.name,
      'date': date.millisecondsSinceEpoch,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id']?.toInt(),
      userId: map['userId']?.toInt() ?? 0,
      amount: map['amount']?.toDouble() ?? 0.0,
      description: map['description'] ?? '',
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TransactionType.expense,
      ),
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
    );
  }

  Transaction copyWith({
    int? id,
    int? userId,
    double? amount,
    String? description,
    TransactionType? type,
    DateTime? date,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      type: type ?? this.type,
      date: date ?? this.date,
    );
  }
}
