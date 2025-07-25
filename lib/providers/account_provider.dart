// Account state management
import 'package:flutter/foundation.dart';
import '../models/account.dart';
import '../core/db_helper.dart';

class AccountProvider with ChangeNotifier {
  List<Account> _accounts = [];
  bool _isLoading = false;

  List<Account> get accounts => _accounts;
  bool get isLoading => _isLoading;

  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Get all accounts
  Future<void> loadAccounts() async {
    _setLoading(true);

    try {
      final accountsData = await _dbHelper.query('accounts');
      _accounts = accountsData.map((data) => Account.fromMap(data)).toList();

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setLoading(false);
      debugPrint('Load accounts error: $e');
    }
  }

  // Get account by ID
  Future<Account?> getAccountById(int accountId) async {
    try {
      final accountsData = await _dbHelper.query(
        'accounts',
        where: 'account_id = ?',
        whereArgs: [accountId],
      );

      if (accountsData.isNotEmpty) {
        return Account.fromMap(accountsData.first);
      }
      return null;
    } catch (e) {
      debugPrint('Get account by ID error: $e');
      return null;
    }
  }

  // Update account
  Future<bool> updateAccount(Account account) async {
    try {
      final result = await _dbHelper.update(
        'accounts',
        account.toMap(),
        where: 'account_id = ?',
        whereArgs: [account.accountId],
      );

      if (result > 0) {
        await loadAccounts();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Update account error: $e');
      return false;
    }
  }

  // Delete account
  Future<bool> deleteAccount(int accountId) async {
    try {
      final result = await _dbHelper.delete(
        'accounts',
        where: 'account_id = ?',
        whereArgs: [accountId],
      );

      if (result > 0) {
        await loadAccounts();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Delete account error: $e');
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
