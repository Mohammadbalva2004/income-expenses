import 'dart:convert';
import 'dart:io';

import 'package:multi_user_expense_app/model/transaction.dart';
import 'package:multi_user_expense_app/model/user.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../database/database_helper.dart';


class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Create backup data structure
  Future<Map<String, dynamic>> _createBackupData() async {
    final users = await _dbHelper.getAllUsers();
    final transactions = await _dbHelper.getAllTransactions();
    
    return {
      'backup_version': '1.0',
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'app_name': 'Multi User Income-Expense Manager',
      'users': users.map((user) => user.toMap()).toList(),
      'transactions': transactions.map((transaction) => transaction.toMap()).toList(),
    };
  }

  // Export backup to JSON file
  Future<String> createBackup() async {
    try {
      // Request storage permission
      var status = await Permission.manageExternalStorage.status;
      if (!status.isGranted) {
        status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) {
          throw Exception('Storage permission denied');
        }
      }

      // Create backup data
      final backupData = await _createBackupData();
      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);

      // Get Downloads directory
      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
        if (!await downloadsDir.exists()) {
          downloadsDir = await getExternalStorageDirectory();
        }
      } else {
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      if (downloadsDir == null) {
        throw Exception('Could not access storage directory');
      }

      // Create backup file
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'expense_backup_$timestamp.json';
      final file = File('${downloadsDir.path}/$fileName');
      
      await file.writeAsString(jsonString);
      return file.path;
    } catch (e) {
      throw Exception('Failed to create backup: $e');
    }
  }

  // Restore from backup file
  Future<bool> restoreFromBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Backup file not found');
      }

      final jsonString = await file.readAsString();
      final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validate backup structure
      if (!backupData.containsKey('users') || !backupData.containsKey('transactions')) {
        throw Exception('Invalid backup file format');
      }

      // Clear existing data
      await _clearAllData();

      // Restore users
      final usersData = backupData['users'] as List<dynamic>;
      final userIdMapping = <int, int>{}; // old_id -> new_id
      
      for (var userData in usersData) {
        final userMap = userData as Map<String, dynamic>;
        final oldId = userMap['id'] as int;
        userMap.remove('id'); // Remove old ID to get new auto-generated ID
        
        final user = User.fromMap(userMap);
        final newId = await _dbHelper.insertUser(user);
        userIdMapping[oldId] = newId;
      }

      // Restore transactions with updated user IDs
      final transactionsData = backupData['transactions'] as List<dynamic>;
      for (var transactionData in transactionsData) {
        final transactionMap = transactionData as Map<String, dynamic>;
        final oldUserId = transactionMap['userId'] as int;
        final newUserId = userIdMapping[oldUserId];
        
        if (newUserId != null) {
          transactionMap['userId'] = newUserId;
          transactionMap.remove('id'); // Remove old ID to get new auto-generated ID
          
          final transaction = Transaction.fromMap(transactionMap);
          await _dbHelper.insertTransaction(transaction);
        }
      }

      return true;
    } catch (e) {
      throw Exception('Failed to restore backup: $e');
    }
  }

  // Clear all data from database
  Future<void> _clearAllData() async {
    final db = await _dbHelper.database;
    await db.delete('transactions');
    await db.delete('users');
  }

  // Auto backup (can be called periodically)
  Future<String?> createAutoBackup() async {
    try {
      final backupPath = await createBackup();
      return backupPath;
    } catch (e) {
      print('Auto backup failed: $e');
      return null;
    }
  }

  // Get backup info from file
  Future<Map<String, dynamic>?> getBackupInfo(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;

      final jsonString = await file.readAsString();
      final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

      final usersCount = (backupData['users'] as List).length;
      final transactionsCount = (backupData['transactions'] as List).length;
      final createdAt = backupData['created_at'] as int;

      return {
        'users_count': usersCount,
        'transactions_count': transactionsCount,
        'created_at': DateTime.fromMillisecondsSinceEpoch(createdAt),
        'version': backupData['backup_version'] ?? '1.0',
      };
    } catch (e) {
      return null;
    }
  }

  Future<String> exportData() async {
    try {
      // Request storage permission
      var status = await Permission.manageExternalStorage.status;
      if (!status.isGranted) {
        status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) {
          throw Exception('Storage permission denied');
        }
      }

      // Create export data
      final exportData = await _createBackupData();
      exportData['export_type'] = 'manual_export';
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      // Get Downloads directory
      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
        if (!await downloadsDir.exists()) {
          downloadsDir = await getExternalStorageDirectory();
        }
      } else {
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      if (downloadsDir == null) {
        throw Exception('Could not access storage directory');
      }

      // Create export file
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'expense_export_$timestamp.json';
      final file = File('${downloadsDir.path}/$fileName');
      
      await file.writeAsString(jsonString);
      return file.path;
    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }

  Future<Map<String, int>> importData(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Import file not found');
      }

      final jsonString = await file.readAsString();
      final importData = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validate import structure
      if (!importData.containsKey('users') || !importData.containsKey('transactions')) {
        throw Exception('Invalid import file format');
      }

      int importedUsers = 0;
      int importedTransactions = 0;

      // Import users (add to existing, don't replace)
      final usersData = importData['users'] as List<dynamic>;
      final userIdMapping = <int, int>{}; // old_id -> new_id
      final existingUsers = await _dbHelper.getAllUsers();
      final existingMobiles = existingUsers.map((u) => u.mobile).toSet();
      
      for (var userData in usersData) {
        final userMap = userData as Map<String, dynamic>;
        final oldId = userMap['id'] as int;
        final mobile = userMap['mobile'] as String;
        
        // Check if user with same mobile already exists
        if (!existingMobiles.contains(mobile)) {
          userMap.remove('id'); // Remove old ID to get new auto-generated ID
          
          final user = User.fromMap(userMap);
          final newId = await _dbHelper.insertUser(user);
          userIdMapping[oldId] = newId;
          importedUsers++;
        } else {
          // Find existing user with same mobile for transaction mapping
          final existingUser = existingUsers.firstWhere((u) => u.mobile == mobile);
          userIdMapping[oldId] = existingUser.id!;
        }
      }

      // Import transactions (add to existing, don't replace)
      final transactionsData = importData['transactions'] as List<dynamic>;
      for (var transactionData in transactionsData) {
        final transactionMap = transactionData as Map<String, dynamic>;
        final oldUserId = transactionMap['userId'] as int;
        final newUserId = userIdMapping[oldUserId];
        
        if (newUserId != null) {
          transactionMap['userId'] = newUserId;
          transactionMap.remove('id'); // Remove old ID to get new auto-generated ID
          
          final transaction = Transaction.fromMap(transactionMap);
          await _dbHelper.insertTransaction(transaction);
          importedTransactions++;
        }
      }

      return {
        'users': importedUsers,
        'transactions': importedTransactions,
      };
    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }
}
