// Debug utility to test transaction approval
// This file can be used to debug transaction approval issues

import '../core/db_helper.dart';

class TransactionDebugUtil {
  static Future<void> debugTransactionApproval(int transactionId) async {
    print('🔍 === DEBUG TRANSACTION APPROVAL ===');

    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;

    try {
      // 1. Check if transaction exists
      print('🔍 Step 1: Checking if transaction exists...');
      final transactionQuery = await db.query(
        'transactions',
        where: 'transaction_id = ?',
        whereArgs: [transactionId],
      );

      if (transactionQuery.isEmpty) {
        print('❌ Transaction not found with ID: $transactionId');
        return;
      }

      final transaction = transactionQuery.first;
      print('✅ Transaction found: $transaction');

      // 2. Check account exists
      print('🔍 Step 2: Checking if account exists...');
      final accountId = transaction['account_id'];
      final accountQuery = await db.query(
        'accounts',
        where: 'account_id = ?',
        whereArgs: [accountId],
      );

      if (accountQuery.isEmpty) {
        print('❌ Account not found with ID: $accountId');
        return;
      }

      final account = accountQuery.first;
      print(
        '✅ Account found: ${account['username']} - Balance: ${account['balance']}',
      );

      // 3. Check transaction status
      print('🔍 Step 3: Checking transaction status...');
      final status = transaction['status'];
      print('📋 Current status: $status');

      if (status == 'APPROVED') {
        print('⚠️ Transaction is already approved');
        return;
      }

      // 4. Calculate new balance
      print('🔍 Step 4: Calculating new balance...');
      final currentBalance = account['balance'] as double;
      final amount = transaction['amount'] as double;
      final transactionType = transaction['transaction_type'];

      double newBalance = currentBalance;
      if (transactionType == 'deposit') {
        newBalance += amount;
        print('📈 Deposit: $currentBalance + $amount = $newBalance');
      } else if (transactionType == 'withdrawal') {
        if (currentBalance < amount) {
          print('❌ Insufficient funds: $currentBalance < $amount');
          return;
        }
        newBalance -= amount;
        print('📉 Withdrawal: $currentBalance - $amount = $newBalance');
      }

      print('✅ All checks passed. Ready for approval.');
    } catch (e) {
      print('❌ Debug error: $e');
    }

    print('🔍 === END DEBUG ===');
  }

  static Future<List<Map<String, dynamic>>> getAllPendingTransactions() async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;

    try {
      final result = await db.query(
        'transactions',
        where: 'status = ?',
        whereArgs: ['PENDING'],
        orderBy: 'transaction_date DESC',
      );

      print('📋 Found ${result.length} pending transactions');
      for (var transaction in result) {
        print(
          '  - ID: ${transaction['transaction_id']}, Type: ${transaction['transaction_type']}, Amount: ${transaction['amount']}',
        );
      }

      return result;
    } catch (e) {
      print('❌ Error getting pending transactions: $e');
      return [];
    }
  }
}
