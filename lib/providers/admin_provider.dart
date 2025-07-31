// lib/providers/admin_provider.dart
import 'package:flutter/foundation.dart';
import '../models/admin.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../models/admin/pending_transaction.dart'; // Add this import
import '../services/admin_service.dart';

class AdminProvider with ChangeNotifier {
  Admin? _currentAdmin;
  List<Account> _userAccounts = [];
  List<Transaction> _allTransactions = [];
  List<Transaction> _pendingTransactions = [];
  List<PendingTransaction> _pendingTransactionsWithDetails = []; // Add this
  Map<String, dynamic> _statistics = {};
  Map<String, int> _transactionStatusCounts = {};
  List<Map<String, dynamic>> _recentActivities = [];

  bool _isLoading = false;
  bool _isProcessingApproval = false;
  String? _errorMessage;

  // Getters
  Admin? get currentAdmin => _currentAdmin;
  List<Account> get userAccounts => _userAccounts;
  List<Transaction> get allTransactions => _allTransactions;
  List<Transaction> get pendingTransactions => _pendingTransactions;
  List<PendingTransaction> get pendingTransactionsWithDetails =>
      _pendingTransactionsWithDetails; // Add this
  Map<String, dynamic> get statistics => _statistics;
  Map<String, int> get transactionStatusCounts => _transactionStatusCounts;
  List<Map<String, dynamic>> get recentActivities => _recentActivities;
  bool get isLoading => _isLoading;
  bool get isProcessingApproval => _isProcessingApproval;
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
        loadPendingTransactionsWithDetails(), // Add this
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
      _pendingTransactions = await _adminService.getAllTransactions(
        status: 'PENDING',
      );
      notifyListeners();
    } catch (e) {
      _setError('Failed to load pending transactions: ${e.toString()}');
    }
  }

  // Load pending transactions with user details
  Future<void> loadPendingTransactionsWithDetails() async {
    try {
      _pendingTransactionsWithDetails =
          await _adminService.getPendingTransactions();
      notifyListeners();
    } catch (e) {
      _setError(
        'Failed to load detailed pending transactions: ${e.toString()}',
      );
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
    _setProcessingApproval(true);
    _clearError();

    try {
      print(
        '🔄 AdminProvider: Starting transaction approval for ID: $transactionId',
      );
      final success = await _adminService.approveTransaction(transactionId);

      if (success) {
        print('✅ AdminProvider: Transaction approved, refreshing data...');
        // Refresh data
        await loadPendingTransactions();
        await loadPendingTransactionsWithDetails();
        await loadTransactionStatusCounts();
        await loadRecentActivities();
        await loadAllTransactions();
        await loadStatistics();
        print('🔄 AdminProvider: Data refresh completed');
      } else {
        print('❌ AdminProvider: Transaction approval failed');
        _setError(
          'Transaction approval failed. This could be due to:\n• Transaction not found\n• Already approved\n• Insufficient funds (for withdrawals)\n• Database error',
        );
      }

      _setProcessingApproval(false);
      return success;
    } catch (e) {
      print('❌ AdminProvider: Exception during transaction approval: $e');
      _setError('Failed to approve transaction: ${e.toString()}');
      _setProcessingApproval(false);
      return false;
    }
  }

  // Reject transaction
  Future<bool> rejectTransaction(int transactionId, String reason) async {
    _setProcessingApproval(true);
    _clearError();

    try {
      final success = await _adminService.rejectTransaction(
        transactionId,
        reason,
      );

      if (success) {
        // Refresh data
        await loadPendingTransactions();
        await loadPendingTransactionsWithDetails();
        await loadTransactionStatusCounts();
        await loadRecentActivities();
        await loadAllTransactions();
      }

      _setProcessingApproval(false);
      return success;
    } catch (e) {
      _setError('Failed to reject transaction: ${e.toString()}');
      _setProcessingApproval(false);
      return false;
    }
  }

  // Update user account balance
  Future<bool> updateUserAccountBalance(
    int accountId,
    double newBalance,
  ) async {
    _setLoading(true);
    _clearError();

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

      _setLoading(false);
      return success;
    } catch (e) {
      _setError('Failed to update account balance: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Deactivate user account
  Future<bool> deactivateUserAccount(int accountId) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _adminService.deactivateUserAccount(accountId);

      if (success) {
        // Refresh user accounts
        await loadUserAccounts();
        await loadStatistics();
      }

      _setLoading(false);
      return success;
    } catch (e) {
      _setError('Failed to deactivate account: ${e.toString()}');
      _setLoading(false);
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

  // Get user account by ID
  Account? getUserById(int accountId) {
    return _userAccounts.firstWhere(
      (account) => account.accountId == accountId,
      orElse:
          () => Account(
            accountId: accountId,
            username: 'Unknown',
            email: '',
            password: '',
            accountType: 'Unknown',
            balance: 0,
            phone: '',
          ),
    );
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
    _pendingTransactionsWithDetails = []; // Clear this too
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

  void _setProcessingApproval(bool processing) {
    _isProcessingApproval = processing;
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
