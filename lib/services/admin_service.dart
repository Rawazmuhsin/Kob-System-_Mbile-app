// lib/services/admin_service.dart
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../core/db_helper.dart';
import '../models/admin.dart';
import '../models/account.dart';
import '../models/transaction.dart';

class AdminService {
  static final AdminService _instance = AdminService._internal();
  static AdminService get instance => _instance;

  AdminService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Generate salt for password hashing
  String _generateSalt() {
    final bytes = utf8.encode(DateTime.now().millisecondsSinceEpoch.toString());
    return sha256.convert(bytes).toString().substring(0, 16);
  }

  // Hash password with salt
  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    return sha256.convert(bytes).toString();
  }

  // Check if admin email exists
  Future<bool> adminEmailExists(String email) async {
    try {
      final admins = await _dbHelper.query(
        'admin',
        where: 'email = ?',
        whereArgs: [email.toLowerCase().trim()],
      );
      return admins.isNotEmpty;
    } catch (e) {
      print('❌ Error checking admin email existence: $e');
      return false;
    }
  }

  // Authenticate admin credentials
  Future<Admin?> authenticateAdmin(String email, String password) async {
    try {
      print('=== ADMIN LOGIN DEBUG ===');
      print('Trying to login admin with email: $email');

      final admins = await _dbHelper.query(
        'admin',
        where: 'email = ? AND is_active = ?',
        whereArgs: [email.toLowerCase().trim(), 1],
      );

      print('Found ${admins.length} active admins with this email');

      if (admins.isEmpty) {
        print('❌ No active admin found with email: $email');
        return null;
      }

      final adminData = admins.first;
      final salt = adminData['salt'] as String? ?? '';
      final storedHashedPassword = adminData['password'] as String;
      final hashedPassword = _hashPassword(password, salt);

      print('Admin stored salt: $salt');
      print('Passwords match: ${hashedPassword == storedHashedPassword}');

      if (hashedPassword == storedHashedPassword) {
        print('✅ Admin login successful!');

        // Update last login time
        await _updateLastLogin(adminData['admin_id']);

        return Admin.fromMap(adminData);
      }

      print('❌ Admin password mismatch!');
      return null;
    } catch (e) {
      print('❌ Admin authentication error: $e');
      throw Exception('Admin authentication error: $e');
    }
  }

  // Update last login time
  Future<void> _updateLastLogin(int adminId) async {
    try {
      await _dbHelper.update(
        'admin',
        {'last_login': DateTime.now().toIso8601String()},
        where: 'admin_id = ?',
        whereArgs: [adminId],
      );
    } catch (e) {
      print('Error updating admin last login: $e');
    }
  }

  // Create default admin if none exists
  Future<void> createDefaultAdmin() async {
    try {
      final existingAdmins = await _dbHelper.query('admin');

      if (existingAdmins.isEmpty) {
        print('Creating default admin...');

        final salt = _generateSalt();
        final hashedPassword = _hashPassword('Rawaz111', salt);

        final adminData = {
          'username': 'Rawaz Muhsinn',
          'email': 'rawazm@gmail.com',
          'password': hashedPassword,
          'first_name': 'Rawaz',
          'last_name': 'Muhsinn',
          'role': 'super_admin',
          'created_at': DateTime.now().toIso8601String(),
          'is_active': 1,
          'salt': salt,
        };

        final adminId = await _dbHelper.insert('admin', adminData);

        if (adminId > 0) {
          print('✅ Default admin created successfully');
          print('Email: rawazm@gmail.com');
          print('Password: Rawaz111');
          print('Name: Rawaz Muhsinn');
          print('Role: super_admin');
        }
      } else {
        print('Admin account already exists, skipping creation');
      }
    } catch (e) {
      print('❌ Error creating default admin: $e');
    }
  }

  // Get all user accounts (for admin management)
  Future<List<Account>> getAllUserAccounts() async {
    try {
      final accountsData = await _dbHelper.query(
        'accounts',
        orderBy: 'created_at DESC',
      );
      return accountsData.map((data) => Account.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Error retrieving user accounts: $e');
    }
  }

  // Get account statistics
  Future<Map<String, dynamic>> getAccountStatistics() async {
    try {
      final accounts = await getAllUserAccounts();
      final transactions = await _dbHelper.query('transactions');

      double totalBalance = 0.0;
      int checkingAccounts = 0;
      int savingsAccounts = 0;

      for (final account in accounts) {
        totalBalance += account.balance;
        if (account.accountType == 'Checking') {
          checkingAccounts++;
        } else if (account.accountType == 'Savings') {
          savingsAccounts++;
        }
      }

      return {
        'total_accounts': accounts.length,
        'checking_accounts': checkingAccounts,
        'savings_accounts': savingsAccounts,
        'total_balance': totalBalance,
        'total_transactions': transactions.length,
        'average_balance':
            accounts.isNotEmpty ? totalBalance / accounts.length : 0.0,
      };
    } catch (e) {
      throw Exception('Error getting account statistics: $e');
    }
  }

  // Get all transactions (for admin review)
  Future<List<Transaction>> getAllTransactions({
    String? status,
    String? type,
    int? limit,
  }) async {
    try {
      String? whereClause;
      List<dynamic>? whereArgs;

      if (status != null && type != null) {
        whereClause = 'status = ? AND transaction_type = ?';
        whereArgs = [status, type];
      } else if (status != null) {
        whereClause = 'status = ?';
        whereArgs = [status];
      } else if (type != null) {
        whereClause = 'transaction_type = ?';
        whereArgs = [type];
      }

      final transactionsData = await _dbHelper.query(
        'transactions',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'transaction_date DESC',
        limit: limit,
      );

      return transactionsData.map((data) => Transaction.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Error retrieving transactions: $e');
    }
  }

  // Get pending transactions for approval
  Future<List<Transaction>> getPendingTransactions() async {
    return await getAllTransactions(status: 'PENDING');
  }

  // Approve transaction
  Future<bool> approveTransaction(int transactionId) async {
    try {
      final result = await _dbHelper.update(
        'transactions',
        {
          'status': 'APPROVED',
          'approval_date': DateTime.now().toIso8601String(),
        },
        where: 'transaction_id = ?',
        whereArgs: [transactionId],
      );
      return result > 0;
    } catch (e) {
      throw Exception('Error approving transaction: $e');
    }
  }

  // Reject transaction
  Future<bool> rejectTransaction(int transactionId, String reason) async {
    try {
      final result = await _dbHelper.update(
        'transactions',
        {
          'status': 'REJECTED',
          'description':
              '${await _getTransactionDescription(transactionId)} - REJECTED: $reason',
          'approval_date': DateTime.now().toIso8601String(),
        },
        where: 'transaction_id = ?',
        whereArgs: [transactionId],
      );
      return result > 0;
    } catch (e) {
      throw Exception('Error rejecting transaction: $e');
    }
  }

  // Get transaction description
  Future<String> _getTransactionDescription(int transactionId) async {
    try {
      final transactions = await _dbHelper.query(
        'transactions',
        where: 'transaction_id = ?',
        whereArgs: [transactionId],
      );
      if (transactions.isNotEmpty) {
        return transactions.first['description'] ?? 'Transaction';
      }
      return 'Transaction';
    } catch (e) {
      return 'Transaction';
    }
  }

  // Update account balance (admin action)
  Future<bool> updateUserAccountBalance(
    int accountId,
    double newBalance,
  ) async {
    try {
      final result = await _dbHelper.update(
        'accounts',
        {'balance': newBalance},
        where: 'account_id = ?',
        whereArgs: [accountId],
      );
      return result > 0;
    } catch (e) {
      throw Exception('Error updating account balance: $e');
    }
  }

  // Deactivate user account
  Future<bool> deactivateUserAccount(int accountId) async {
    try {
      // For now, we'll mark balance as 0 and add a note
      // In a real system, you'd have an 'active' field
      final result = await _dbHelper.update(
        'accounts',
        {'balance': 0.0},
        where: 'account_id = ?',
        whereArgs: [accountId],
      );
      return result > 0;
    } catch (e) {
      throw Exception('Error deactivating account: $e');
    }
  }

  // Get transaction counts by status
  Future<Map<String, int>> getTransactionStatusCounts() async {
    try {
      final transactions = await _dbHelper.query('transactions');

      Map<String, int> statusCounts = {
        'PENDING': 0,
        'APPROVED': 0,
        'REJECTED': 0,
      };

      for (final transaction in transactions) {
        final status = transaction['status'] as String;
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
      }

      return statusCounts;
    } catch (e) {
      throw Exception('Error getting transaction status counts: $e');
    }
  }

  // Search accounts by email or username
  Future<List<Account>> searchAccounts(String query) async {
    try {
      final accountsData = await _dbHelper.query(
        'accounts',
        where: 'username LIKE ? OR email LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'created_at DESC',
      );
      return accountsData.map((data) => Account.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Error searching accounts: $e');
    }
  }

  // Get recent admin activities (simplified)
  Future<List<Map<String, dynamic>>> getRecentAdminActivities() async {
    try {
      // For now, return recent transactions with approval dates
      final recentTransactions = await _dbHelper.query(
        'transactions',
        where: 'approval_date IS NOT NULL',
        orderBy: 'approval_date DESC',
        limit: 10,
      );

      return recentTransactions.map((transaction) {
        return {
          'activity': 'Transaction ${transaction['status']}',
          'description': transaction['description'] ?? 'Transaction',
          'amount': transaction['amount'],
          'date': transaction['approval_date'],
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
