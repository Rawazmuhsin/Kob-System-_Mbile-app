import 'package:flutter/foundation.dart';
import '../models/admin.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../services/admin_service.dart';

class AdminProvider with ChangeNotifier {
  Admin? _currentAdmin;
  List<Account> _userAccounts = [];
  List<Transaction> _allTransactions = [];
  List<Transaction> _pendingTransactions = [];
  Map<String, dynamic> _statistics = {};
  Map<String, int> _transactionStatusCounts = {};
  List<Map<String, dynamic>> _recentActivities = [];

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Admin? get currentAdmin => _currentAdmin;
  List<Account> get userAccounts => _userAccounts;
  List<Transaction> get allTransactions => _allTransactions;
  List<Transaction> get pendingTransactions => _pendingTransactions;
  Map<String, dynamic> get statistics => _statistics;
  Map<String, int> get transactionStatusCounts => _transactionStatusCounts;
  List<Map<String, dynamic>> get recentActivities => _recentActivities;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final AdminService _adminService = AdminService.instance;

  // Set current admin
  void setCurrentAdmin(Admin admin) {
    _currentAdmin = admin;
    notifyListeners();
  }

  // Load all admin dashboard data
  Future<void> loadAdminDashboard() async {
    _setLoading(true);
    _clearError();

    try {
      // Load all data in parallel
      await Future.wait([
        loadUserAccounts(),
        loadAllTransactions(),
        loadPendingTransactions(),
        loadStatistics(),
        loadTransactionStatusCounts(),
        loadRecentActivities(),
      ]);

      _setLoading(false);
    } catch (e) {
      _setError('Failed to load admin dashboard: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Load all user accounts
  Future<void> loadUserAccounts() async {
    try {
      _userAccounts = await _adminService.getAllUserAccounts();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load user accounts: ${e.toString()}');
    }
  }

  // Load all transactions
  Future<void> loadAllTransactions({
    String? status,
    String? type,
    int? limit,
  }) async {
    try {
      _allTransactions = await _adminService.getAllTransactions(
        status: status,
        type: type,
        limit: limit,
      );
      notifyListeners();
    } catch (e) {
      _setError('Failed to load transactions: ${e.toString()}');
    }
  }

  // Load pending transactions
  Future<void> loadPendingTransactions() async {
    try {
      _pendingTransactions = await _adminService.getPendingTransactions();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load pending transactions: ${e.toString()}');
    }
  }

  // Load statistics
  Future<void> loadStatistics() async {
    try {
      _statistics = await _adminService.getAccountStatistics();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load statistics: ${e.toString()}');
    }
  }

  // Load transaction status counts
  Future<void> loadTransactionStatusCounts() async {
    try {
      _transactionStatusCounts =
          await _adminService.getTransactionStatusCounts();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load transaction status counts: ${e.toString()}');
    }
  }

  // Load recent activities
  Future<void> loadRecentActivities() async {
    try {
      _recentActivities = await _adminService.getRecentAdminActivities();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load recent activities: ${e.toString()}');
    }
  }

  // Approve transaction
  Future<bool> approveTransaction(int transactionId) async {
    try {
      final success = await _adminService.approveTransaction(transactionId);
      if (success) {
        // Refresh pending transactions and status counts
        await loadPendingTransactions();
        await loadTransactionStatusCounts();
        await loadRecentActivities();
      }
      return success;
    } catch (e) {
      _setError('Failed to approve transaction: ${e.toString()}');
      return false;
    }
  }

  // Reject transaction
  Future<bool> rejectTransaction(int transactionId, String reason) async {
    try {
      final success = await _adminService.rejectTransaction(
        transactionId,
        reason,
      );
      if (success) {
        // Refresh pending transactions and status counts
        await loadPendingTransactions();
        await loadTransactionStatusCounts();
        await loadRecentActivities();
      }
      return success;
    } catch (e) {
      _setError('Failed to reject transaction: ${e.toString()}');
      return false;
    }
  }

  // Update user account balance
  Future<bool> updateUserAccountBalance(
    int accountId,
    double newBalance,
  ) async {
    try {
      final success = await _adminService.updateUserAccountBalance(
        accountId,
        newBalance,
      );
      if (success) {
        // Refresh user accounts
        await loadUserAccounts();
        await loadStatistics();
      }
      return success;
    } catch (e) {
      _setError('Failed to update account balance: ${e.toString()}');
      return false;
    }
  }

  // Deactivate user account
  Future<bool> deactivateUserAccount(int accountId) async {
    try {
      final success = await _adminService.deactivateUserAccount(accountId);
      if (success) {
        // Refresh user accounts
        await loadUserAccounts();
        await loadStatistics();
      }
      return success;
    } catch (e) {
      _setError('Failed to deactivate account: ${e.toString()}');
      return false;
    }
  }

  // Search accounts
  Future<List<Account>> searchAccounts(String query) async {
    try {
      return await _adminService.searchAccounts(query);
    } catch (e) {
      _setError('Failed to search accounts: ${e.toString()}');
      return [];
    }
  }

  // Get dashboard summary data
  Map<String, dynamic> getDashboardSummary() {
    return {
      'total_accounts': _statistics['total_accounts'] ?? 0,
      'total_balance': _statistics['total_balance'] ?? 0.0,
      'total_transactions': _statistics['total_transactions'] ?? 0,
      'pending_approvals': _transactionStatusCounts['PENDING'] ?? 0,
      'approved_transactions': _transactionStatusCounts['APPROVED'] ?? 0,
      'rejected_transactions': _transactionStatusCounts['REJECTED'] ?? 0,
    };
  }

  // Get formatted currency
  String formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  // Get account type distribution
  Map<String, int> getAccountTypeDistribution() {
    return {
      'Checking': _statistics['checking_accounts'] ?? 0,
      'Savings': _statistics['savings_accounts'] ?? 0,
    };
  }

  // Get recent transactions (last 10)
  List<Transaction> getRecentTransactions() {
    return _allTransactions.take(10).toList();
  }

  // Get high-value transactions (over $1000)
  List<Transaction> getHighValueTransactions() {
    return _allTransactions.where((t) => t.amount >= 1000).toList();
  }

  // Refresh all data
  Future<void> refreshDashboard() async {
    await loadAdminDashboard();
  }

  // Clear all data (for logout)
  void clearAdminData() {
    _currentAdmin = null;
    _userAccounts = [];
    _allTransactions = [];
    _pendingTransactions = [];
    _statistics = {};
    _transactionStatusCounts = {};
    _recentActivities = [];
    _clearError();
    notifyListeners();
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
}
