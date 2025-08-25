
import 'package:multi_user_expense_app/model/transaction.dart';
import 'package:multi_user_expense_app/model/user.dart';
import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'expense_manager.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onOpen: (db) async {
        // ✅ foreign keys enable
        await db.execute("PRAGMA foreign_keys = ON");
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        mobile TEXT NOT NULL,
        joinDate INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        date INTEGER NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  // ---------------- USER OPERATIONS ----------------
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<List<User>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');

    List<User> users = [];
    for (var map in maps) {
      final user = User.fromMap(map);
      final balance = await getUserBalance(user.id!);
      final transactionCount = await getUserTransactionCount(user.id!);

      users.add(
        user.copyWith(balance: balance, transactions: transactionCount),
      );
    }
    return users;
  }

  Future<User?> getUser(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      final user = User.fromMap(maps.first);
      final balance = await getUserBalance(id);
      final transactionCount = await getUserTransactionCount(id);

      return user.copyWith(balance: balance, transactions: transactionCount);
    }
    return null;
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // ❌ Old method: sirf user delete karta tha
  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // ✅ New safer method: user + uske transactions delete
  Future<void> deleteUserWithTransactions(int id) async {
    final db = await database;
    await db.delete('transactions', where: 'userId = ?', whereArgs: [id]);
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------- TRANSACTION OPERATIONS ----------------
  Future<int> insertTransaction(Transaction transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<Transaction>> getTransactionsByUser(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  Future<List<Transaction>> getAllTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  Future<int> updateTransaction(Transaction transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------- STATISTICS ----------------
  Future<double> getUserBalance(int userId) async {
    final income = await getUserIncome(userId);
    final expense = await getUserExpense(userId);
    return income - expense;
  }

  Future<double> getUserIncome(int userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE userId = ? AND type = ?',
      [userId, 'income'],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getUserExpense(int userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE userId = ? AND type = ?',
      [userId, 'expense'],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<int> getUserTransactionCount(int userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM transactions WHERE userId = ?',
      [userId],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  Future<double> getTotalIncome() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE type = ?',
      ['income'],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getTotalExpense() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE type = ?',
      ['expense'],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<int> getTotalUsers() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM users');
    return (result.first['count'] as int?) ?? 0;
  }
}
