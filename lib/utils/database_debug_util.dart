// lib/utils/database_debug_util.dart
import '../core/db_helper.dart';

class DatabaseDebugUtil {
  static Future<void> printAccountInfo(int accountId) async {
    try {
      print('=== ACCOUNT DEBUG INFO ===');
      final dbHelper = DatabaseHelper();
      final db = await dbHelper.database;
      
      // Get account info
      final accountResult = await db.query(
        'accounts',
        where: 'account_id = ?',
        whereArgs: [accountId],
      );
      
      if (accountResult.isNotEmpty) {
        final account = accountResult.first;
        print('Account ID: ${account['account_id']}');
        print('Username: ${account['username']}');
        print('Email: ${account['email']}');
        print('Balance: ${account['balance']}');
        print('Account Type: ${account['account_type']}');
        print('Created At: ${account['created_at']}');
      } else {
        print('❌ Account not found with ID: $accountId');
      }
      
      // Get recent transactions
      final transactionResult = await db.query(
        'transactions',
        where: 'account_id = ?',
        whereArgs: [accountId],
        orderBy: 'transaction_date DESC',
        limit: 5,
      );
      
      print('\n=== RECENT TRANSACTIONS ===');
      if (transactionResult.isNotEmpty) {
        for (var i = 0; i < transactionResult.length; i++) {
          final txn = transactionResult[i];
          print('${i + 1}. ID: ${txn['transaction_id']}, Type: ${txn['transaction_type']}, Amount: ${txn['amount']}, Status: ${txn['status']}, Date: ${txn['transaction_date']}');
        }
      } else {
        print('No transactions found');
      }
      
      print('========================\n');
    } catch (e) {
      print('❌ Database debug error: $e');
    }
  }
  
  static Future<void> printAllAccounts() async {
    try {
      print('=== ALL ACCOUNTS DEBUG ===');
      final dbHelper = DatabaseHelper();
      final db = await dbHelper.database;
      
      final result = await db.query('accounts');
      
      if (result.isNotEmpty) {
        for (var account in result) {
          print('ID: ${account['account_id']}, Username: ${account['username']}, Balance: ${account['balance']}');
        }
      } else {
        print('No accounts found');
      }
      
      print('========================\n');
    } catch (e) {
      print('❌ Database debug error: $e');
    }
  }
  
  static Future<void> printTransactionCount() async {
    try {
      final dbHelper = DatabaseHelper();
      final db = await dbHelper.database;
      
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM transactions');
      final count = result.first['count'];
      
      print('=== TRANSACTION COUNT ===');
      print('Total transactions: $count');
      print('========================\n');
    } catch (e) {
      print('❌ Database debug error: $e');
    }
  }
}
