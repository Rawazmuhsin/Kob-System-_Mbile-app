// lib/providers/dashboard_provider.dart
import 'package:flutter/foundation.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../services/dashboard_service.dart';

class DashboardProvider with ChangeNotifier {
  Account? _currentAccount;
  List<Transaction> _recentTransactions = [];
  Map<String, dynamic> _accountStatistics = {};
  bool _isLoading = false;
  bool _balanceVisible = true;
  String? _errorMessage;

  // Getters
  Account? get currentAccount => _currentAccount;
  List<Transaction> get recentTransactions => _recentTransactions;
  Map<String, dynamic> get accountStatistics => _accountStatistics;
  bool get isLoading => _isLoading;
  bool get balanceVisible => _balanceVisible;
  String? get errorMessage => _errorMessage;

  final DashboardService _dashboardService = DashboardService.instance;

  // Load dashboard data
  Future<void> loadDashboardData(int accountId) async {
    _setLoading(true);
    _clearError();

    try {
      // Load account summary
      final summary = await _dashboardService.getAccountSummary(accountId);
      _currentAccount = summary['account'] as Account;

      // Load recent transactions
      _recentTransactions = await _dashboardService.getRecentTransactions(
        accountId,
      );

      // Load account statistics
      _accountStatistics = await _dashboardService.getAccountStatistics(
        accountId,
      );

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load dashboard data: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Refresh dashboard data
  Future<void> refreshDashboard() async {
    if (_currentAccount?.accountId != null) {
      await loadDashboardData(_currentAccount!.accountId!);
    }
  }

  // Toggle balance visibility
  void toggleBalanceVisibility() {
    _balanceVisible = !_balanceVisible;
    notifyListeners();
  }

  // Get formatted balance
  String getFormattedBalance() {
    if (_currentAccount == null) return '\$0.00';
    if (!_balanceVisible) return '****';
    return _dashboardService.formatCurrency(_currentAccount!.balance);
  }

  // Get masked account number
  String getMaskedAccountNumber() {
    if (_currentAccount?.accountNumber == null) return '****';
    return _dashboardService.getMaskedAccountNumber(
      _currentAccount!.accountNumber,
    );
  }

  // Update account balance
  Future<bool> updateBalance(double newBalance) async {
    if (_currentAccount?.accountId == null) return false;

    try {
      final success = await _dashboardService.updateAccountBalance(
        _currentAccount!.accountId!,
        newBalance,
      );

      if (success) {
        _currentAccount = _currentAccount!.copyWith(balance: newBalance);
        notifyListeners();
      }

      return success;
    } catch (e) {
      _setError('Failed to update balance: ${e.toString()}');
      return false;
    }
  }

  // Create transaction and update balance
  Future<bool> performTransaction({
    required String transactionType,
    required double amount,
    required String description,
    String? recipientAccountNumber,
  }) async {
    if (_currentAccount?.accountId == null) return false;

    _setLoading(true);
    _clearError();

    try {
      // Create transaction record
      final transactionCreated = await _dashboardService.createTransaction(
        accountId: _currentAccount!.accountId!,
        transactionType: transactionType,
        amount: amount,
        description: description,
        recipientAccountNumber: recipientAccountNumber,
      );

      if (transactionCreated) {
        // Update account balance based on transaction type
        double newBalance = _currentAccount!.balance;

        switch (transactionType) {
          case 'deposit':
            newBalance += amount;
            break;
          case 'withdrawal':
          case 'transfer':
            newBalance -= amount;
            break;
        }

        // Update balance in database and local state
        final balanceUpdated = await updateBalance(newBalance);

        if (balanceUpdated) {
          // Refresh recent transactions
          await refreshDashboard();
          _setLoading(false);
          return true;
        }
      }

      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Transaction failed: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Quick deposit
  Future<bool> quickDeposit(double amount) async {
    return await performTransaction(
      transactionType: 'deposit',
      amount: amount,
      description: 'Quick deposit',
    );
  }

  // Quick withdrawal
  Future<bool> quickWithdrawal(double amount) async {
    return await performTransaction(
      transactionType: 'withdrawal',
      amount: amount,
      description: 'Quick withdrawal',
    );
  }

  // Get transaction count
  int get transactionCount => _recentTransactions.length;

  // Get last transaction description
  String getLastTransactionDescription() {
    if (_recentTransactions.isEmpty) return 'No transactions';
    final lastTransaction = _recentTransactions.first;
    return '${lastTransaction.transactionType?.toUpperCase()}: ${lastTransaction.description ?? 'Transaction'}';
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear dashboard data (for logout)
  void clearDashboardData() {
    _currentAccount = null;
    _recentTransactions = [];
    _accountStatistics = {};
    _balanceVisible = true;
    _clearError();
    notifyListeners();
  }
}
