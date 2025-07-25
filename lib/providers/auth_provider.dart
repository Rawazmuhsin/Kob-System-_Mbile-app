// Authentication state management
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/account.dart';
import '../core/db_helper.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  Account? _currentAccount;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  Account? get currentAccount => _currentAccount;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

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

  // Login method
  Future<bool> login(String email, String password) async {
    _setLoading(true);

    try {
      // Query account by email
      final accounts = await _dbHelper.query(
        'accounts',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (accounts.isEmpty) {
        _setLoading(false);
        return false;
      }

      final accountData = accounts.first;
      final salt = accountData['salt'] as String? ?? '';
      final hashedPassword = _hashPassword(password, salt);

      if (hashedPassword == accountData['password']) {
        _currentAccount = Account.fromMap(accountData);
        _currentUser = User(
          userId: accountData['account_id'],
          username: accountData['username'],
          email: accountData['email'],
        );
        _isAuthenticated = true;

        _setLoading(false);
        notifyListeners();
        return true;
      }

      _setLoading(false);
      return false;
    } catch (e) {
      _setLoading(false);
      debugPrint('Login error: $e');
      return false;
    }
  }

  // Register method
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String phone,
    required String accountType,
  }) async {
    _setLoading(true);

    try {
      // Check if email already exists
      final existingAccounts = await _dbHelper.query(
        'accounts',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (existingAccounts.isNotEmpty) {
        _setLoading(false);
        return false;
      }

      // Generate salt and hash password
      final salt = _generateSalt();
      final hashedPassword = _hashPassword(password, salt);

      // Generate account number
      final accountNumber = 'KOB${DateTime.now().millisecondsSinceEpoch}';

      // Create account
      final accountData = {
        'username': username,
        'email': email,
        'password': hashedPassword,
        'balance': 0.0,
        'account_type': accountType,
        'phone': phone,
        'account_number': accountNumber,
        'salt': salt,
      };

      final accountId = await _dbHelper.insert('accounts', accountData);

      if (accountId > 0) {
        _currentAccount = Account.fromMap({
          'account_id': accountId,
          ...accountData,
        });
        _currentUser = User(
          userId: accountId,
          username: username,
          email: email,
        );
        _isAuthenticated = true;

        _setLoading(false);
        notifyListeners();
        return true;
      }

      _setLoading(false);
      return false;
    } catch (e) {
      _setLoading(false);
      debugPrint('Registration error: $e');
      return false;
    }
  }

  // Logout method
  void logout() {
    _currentUser = null;
    _currentAccount = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  // Update account balance
  Future<void> updateBalance(double newBalance) async {
    if (_currentAccount != null) {
      try {
        await _dbHelper.update(
          'accounts',
          {'balance': newBalance},
          where: 'account_id = ?',
          whereArgs: [_currentAccount!.accountId],
        );

        _currentAccount = _currentAccount!.copyWith(balance: newBalance);
        notifyListeners();
      } catch (e) {
        debugPrint('Update balance error: $e');
      }
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
