// lib/confirmation/auth_service.dart
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../core/db_helper.dart';
import '../models/account.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  static AuthService get instance => _instance;

  AuthService._internal();

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

  // Generate unique account number
  String _generateAccountNumber() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'KOB${timestamp.toString().substring(5)}';
  }

  // Validate email format
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate phone format
  bool isValidPhone(String phone) {
    return RegExp(r'^\+?[\d\s\-\(\)]{10,}$').hasMatch(phone);
  }

  // Validate strong password
  bool isStrongPassword(String password) {
    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password);
  }

  // Check if email already exists - WITH BETTER ERROR HANDLING
  Future<bool> emailExists(String email) async {
    try {
      print('=== CHECKING EMAIL IN DATABASE ===');
      print('Email to check: $email');

      final accounts = await _dbHelper.query(
        'accounts',
        where: 'email = ?',
        whereArgs: [email.toLowerCase().trim()],
      );

      print('Query executed successfully');
      print('Found ${accounts.length} accounts with this email');
      print('=================================');

      return accounts.isNotEmpty;
    } catch (e) {
      print('❌ Error checking email existence: $e');
      print('Database might not be initialized properly');

      // Return false to allow registration to continue
      return false;
    }
  }

  // Authenticate user credentials - WITH DEBUG PRINTS
  Future<Account?> authenticate(String email, String password) async {
    try {
      print('=== LOGIN DEBUG ===');
      print('Trying to login with email: $email');
      print('Trying to login with password: $password');

      final accounts = await _dbHelper.query(
        'accounts',
        where: 'email = ?',
        whereArgs: [email.toLowerCase().trim()],
      );

      print('Found ${accounts.length} accounts with this email');

      if (accounts.isEmpty) {
        print('❌ No account found with email: $email');
        return null; // Email not found
      }

      final accountData = accounts.first;
      final salt = accountData['salt'] as String? ?? '';
      final storedHashedPassword = accountData['password'] as String;
      final hashedPassword = _hashPassword(password, salt);

      print('Stored salt: $salt');
      print('Stored hashed password: $storedHashedPassword');
      print('New hashed password: $hashedPassword');
      print('Passwords match: ${hashedPassword == storedHashedPassword}');
      print('==================');

      if (hashedPassword == storedHashedPassword) {
        print('✅ Login successful!');
        return Account.fromMap(accountData);
      }

      print('❌ Password mismatch!');
      return null; // Password doesn't match
    } catch (e) {
      print('❌ Authentication error: $e');
      throw Exception('Authentication error: $e');
    }
  }

  // Create new account - WITH IMPROVED ERROR HANDLING
  Future<Account?> createAccount({
    required String username,
    required String email,
    required String password,
    required String phone,
    required String accountType,
  }) async {
    try {
      print('=== ACCOUNT CREATION DEBUG ===');
      print('Creating account for: $email');

      // Validate inputs
      if (!isValidEmail(email)) {
        throw Exception('Invalid email format');
      }

      if (!isValidPhone(phone)) {
        throw Exception('Invalid phone number format');
      }

      if (!isStrongPassword(password)) {
        throw Exception(
          'Password must be at least 8 characters with uppercase, lowercase, and number',
        );
      }

      // Check if email already exists - but don't fail if check fails
      try {
        if (await emailExists(email)) {
          throw Exception('Email already exists');
        }
      } catch (e) {
        print(
          'Warning: Could not check email existence, continuing with registration',
        );
      }

      // Generate salt and hash password
      final salt = _generateSalt();
      final hashedPassword = _hashPassword(password, salt);
      final accountNumber = _generateAccountNumber();

      print('Salt: $salt');
      print('Hashed Password: $hashedPassword');
      print('Account Number: $accountNumber');

      // Create account data
      final accountData = {
        'username': username.trim(),
        'email': email.toLowerCase().trim(),
        'password': hashedPassword,
        'balance': 0.0,
        'account_type': accountType,
        'phone': phone.trim(),
        'account_number': accountNumber,
        'salt': salt,
        'created_at': DateTime.now().toIso8601String(),
      };

      print('Inserting account data into database...');

      // Insert into database
      final accountId = await _dbHelper.insert('accounts', accountData);

      if (accountId > 0) {
        print('✅ Account created with ID: $accountId');

        // Return the created account
        return Account.fromMap({'account_id': accountId, ...accountData});
      }

      throw Exception('Failed to create account - database insert returned 0');
    } catch (e) {
      print('❌ Account creation error: $e');
      throw Exception('Account creation error: $e');
    }
  }

  // Reset password method
  Future<bool> resetPassword(String email, String newPassword) async {
    try {
      // Validate new password
      if (!isStrongPassword(newPassword)) {
        throw Exception(
          'Password must be at least 8 characters with uppercase, lowercase, and number',
        );
      }

      // Check if email exists
      final accounts = await _dbHelper.query(
        'accounts',
        where: 'email = ?',
        whereArgs: [email.toLowerCase().trim()],
      );

      if (accounts.isEmpty) {
        throw Exception('Account not found');
      }

      // Generate new salt and hash new password
      final salt = _generateSalt();
      final hashedPassword = _hashPassword(newPassword, salt);

      print('=== PASSWORD RESET DEBUG ===');
      print('Email: $email');
      print('New Password: $newPassword');
      print('New Salt: $salt');
      print('New Hashed Password: $hashedPassword');
      print('============================');

      // Update password in database
      final result = await _dbHelper.update(
        'accounts',
        {'password': hashedPassword, 'salt': salt},
        where: 'email = ?',
        whereArgs: [email.toLowerCase().trim()],
      );

      if (result > 0) {
        print('✅ Password reset successful');
        return true;
      } else {
        print('❌ Password reset failed');
        return false;
      }
    } catch (e) {
      print('❌ Password reset error: $e');
      throw Exception('Password reset error: $e');
    }
  }

  // Update account password (for change password functionality)
  Future<bool> updatePassword(
    int accountId,
    String currentPassword,
    String newPassword,
  ) async {
    try {
      // Get account data
      final accounts = await _dbHelper.query(
        'accounts',
        where: 'account_id = ?',
        whereArgs: [accountId],
      );

      if (accounts.isEmpty) {
        throw Exception('Account not found');
      }

      final accountData = accounts.first;
      final salt = accountData['salt'] as String? ?? '';
      final storedHashedPassword = accountData['password'] as String;
      final currentHashedPassword = _hashPassword(currentPassword, salt);

      // Verify current password
      if (currentHashedPassword != storedHashedPassword) {
        throw Exception('Current password is incorrect');
      }

      // Validate new password
      if (!isStrongPassword(newPassword)) {
        throw Exception(
          'New password must be at least 8 characters with uppercase, lowercase, and number',
        );
      }

      // Generate new salt and hash new password
      final newSalt = _generateSalt();
      final newHashedPassword = _hashPassword(newPassword, newSalt);

      // Update password in database
      final result = await _dbHelper.update(
        'accounts',
        {'password': newHashedPassword, 'salt': newSalt},
        where: 'account_id = ?',
        whereArgs: [accountId],
      );

      return result > 0;
    } catch (e) {
      throw Exception('Password update error: $e');
    }
  }

  // Update account balance
  Future<bool> updateAccountBalance(int accountId, double newBalance) async {
    try {
      final result = await _dbHelper.update(
        'accounts',
        {'balance': newBalance},
        where: 'account_id = ?',
        whereArgs: [accountId],
      );
      return result > 0;
    } catch (e) {
      throw Exception('Error updating balance: $e');
    }
  }

  // Get account by ID
  Future<Account?> getAccountById(int accountId) async {
    try {
      final accounts = await _dbHelper.query(
        'accounts',
        where: 'account_id = ?',
        whereArgs: [accountId],
      );

      if (accounts.isNotEmpty) {
        return Account.fromMap(accounts.first);
      }
      return null;
    } catch (e) {
      throw Exception('Error retrieving account: $e');
    }
  }

  // Get account by email
  Future<Account?> getAccountByEmail(String email) async {
    try {
      final accounts = await _dbHelper.query(
        'accounts',
        where: 'email = ?',
        whereArgs: [email.toLowerCase().trim()],
      );

      if (accounts.isNotEmpty) {
        return Account.fromMap(accounts.first);
      }
      return null;
    } catch (e) {
      throw Exception('Error retrieving account: $e');
    }
  }

  // Get account by account number
  Future<Account?> getAccountByAccountNumber(String accountNumber) async {
    try {
      final accounts = await _dbHelper.query(
        'accounts',
        where: 'account_number = ?',
        whereArgs: [accountNumber],
      );

      if (accounts.isNotEmpty) {
        return Account.fromMap(accounts.first);
      }
      return null;
    } catch (e) {
      throw Exception('Error retrieving account: $e');
    }
  }

  // Get all accounts (admin function)
  Future<List<Account>> getAllAccounts() async {
    try {
      final accountsData = await _dbHelper.query('accounts');
      return accountsData.map((data) => Account.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Error retrieving accounts: $e');
    }
  }

  // Update account profile
  Future<bool> updateAccountProfile({
    required int accountId,
    String? username,
    String? email,
    String? phone,
    String? profileImage,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (username != null) updateData['username'] = username.trim();
      if (email != null) {
        if (!isValidEmail(email)) {
          throw Exception('Invalid email format');
        }
        // Check if email is already taken by another account
        final existingAccounts = await _dbHelper.query(
          'accounts',
          where: 'email = ? AND account_id != ?',
          whereArgs: [email.toLowerCase().trim(), accountId],
        );
        if (existingAccounts.isNotEmpty) {
          throw Exception('Email already exists');
        }
        updateData['email'] = email.toLowerCase().trim();
      }
      if (phone != null) {
        if (!isValidPhone(phone)) {
          throw Exception('Invalid phone format');
        }
        updateData['phone'] = phone.trim();
      }
      if (profileImage != null) updateData['profile_image'] = profileImage;

      if (updateData.isEmpty) {
        return true; // Nothing to update
      }

      final result = await _dbHelper.update(
        'accounts',
        updateData,
        where: 'account_id = ?',
        whereArgs: [accountId],
      );

      return result > 0;
    } catch (e) {
      throw Exception('Profile update error: $e');
    }
  }

  // Delete account (admin function)
  Future<bool> deleteAccount(int accountId) async {
    try {
      final result = await _dbHelper.delete(
        'accounts',
        where: 'account_id = ?',
        whereArgs: [accountId],
      );
      return result > 0;
    } catch (e) {
      throw Exception('Error deleting account: $e');
    }
  }

  // Get account statistics (admin function)
  Future<Map<String, dynamic>> getAccountStatistics() async {
    try {
      final allAccounts = await _dbHelper.query('accounts');

      final totalAccounts = allAccounts.length;
      final checkingAccounts =
          allAccounts.where((acc) => acc['account_type'] == 'Checking').length;
      final savingsAccounts =
          allAccounts.where((acc) => acc['account_type'] == 'Savings').length;

      double totalBalance = 0.0;
      for (final acc in allAccounts) {
        totalBalance += (acc['balance'] as num).toDouble();
      }

      return {
        'total_accounts': totalAccounts,
        'checking_accounts': checkingAccounts,
        'savings_accounts': savingsAccounts,
        'total_balance': totalBalance,
        'average_balance':
            totalAccounts > 0 ? totalBalance / totalAccounts : 0.0,
      };
    } catch (e) {
      throw Exception('Error getting statistics: $e');
    }
  }

  // Verify account credentials (for sensitive operations)
  Future<bool> verifyAccountCredentials(int accountId, String password) async {
    try {
      final accounts = await _dbHelper.query(
        'accounts',
        where: 'account_id = ?',
        whereArgs: [accountId],
      );

      if (accounts.isEmpty) {
        return false;
      }

      final accountData = accounts.first;
      final salt = accountData['salt'] as String? ?? '';
      final storedHashedPassword = accountData['password'] as String;
      final hashedPassword = _hashPassword(password, salt);

      return hashedPassword == storedHashedPassword;
    } catch (e) {
      return false;
    }
  }

  // Close database connection
  Future<void> closeDatabase() async {
    try {
      await _dbHelper.close();
    } catch (e) {
      print('Error closing database: $e');
    }
  }
}
