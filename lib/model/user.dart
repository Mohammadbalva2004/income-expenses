class User {
  final int? id;
  final String name;
  final String mobile;
  final DateTime joinDate;
  final double balance;
  final int transactions;

  User({
    this.id,
    required this.name,
    required this.mobile,
    required this.joinDate,
    required this.balance,
    required this.transactions,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'joinDate': joinDate.millisecondsSinceEpoch,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      mobile: map['mobile'] ?? '',
      joinDate: DateTime.fromMillisecondsSinceEpoch(map['joinDate']),
      balance: 0.0,
      transactions: 0,
    );
  }

  User copyWith({
    int? id,
    String? name,
    String? mobile,
    DateTime? joinDate,
    double? balance,
    int? transactions,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      joinDate: joinDate ?? this.joinDate,
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
    );
  }
}
