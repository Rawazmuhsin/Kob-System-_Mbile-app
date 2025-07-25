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

  // Check if email already exists
  Future<bool> emailExists(String email) async {
    try {
      final accounts = await _dbHelper.query(
        'accounts',
        where: 'email = ?',
        whereArgs: [email.toLowerCase().trim()],
      );
      return accounts.isNotEmpty;
    } catch (e) {
      throw Exception('Error checking email existence: $e');
    }
  }

  // Authenticate user credentials
  Future<Account?> authenticate(String email, String password) async {
    try {
      final accounts = await _dbHelper.query(
        'accounts',
        where: 'email = ?',
        whereArgs: [email.toLowerCase().trim()],
      );

      if (accounts.isEmpty) {
        return null; // Email not found
      }

      final accountData = accounts.first;
      final salt = accountData['salt'] as String? ?? '';
      final storedHashedPassword = accountData['password'] as String;
      final hashedPassword = _hashPassword(password, salt);

      if (hashedPassword == storedHashedPassword) {
        return Account.fromMap(accountData);
      }

      return null; // Password doesn't match
    } catch (e) {
      throw Exception('Authentication error: $e');
    }
  }

  // Create new account
  Future<Account?> createAccount({
    required String username,
    required String email,
    required String password,
    required String phone,
    required String accountType,
  }) async {
    try {
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

      // Check if email already exists
      if (await emailExists(email)) {
        throw Exception('Email already exists');
      }

      // Generate salt and hash password
      final salt = _generateSalt();
      final hashedPassword = _hashPassword(password, salt);
      final accountNumber = _generateAccountNumber();

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

      // Insert into database
      final accountId = await _dbHelper.insert('accounts', accountData);

      if (accountId > 0) {
        // Return the created account
        return Account.fromMap({'account_id': accountId, ...accountData});
      }

      throw Exception('Failed to create account');
    } catch (e) {
      throw Exception('Account creation error: $e');
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

  // Get all accounts (admin function)
  Future<List<Account>> getAllAccounts() async {
    try {
      final accountsData = await _dbHelper.query('accounts');
      return accountsData.map((data) => Account.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Error retrieving accounts: $e');
    }
  }
}
