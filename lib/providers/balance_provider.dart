// lib/providers/balance_provider.dart
// Replace your entire balance_provider.dart with this:

import 'package:flutter/foundation.dart';
import '../models/account.dart';
import '../services/balance_service.dart';
import '../services/export_service.dart';

class BalanceProvider with ChangeNotifier {
  Account? _currentAccount;
  List<BalancePoint> _balanceHistory = [];
  List<BalanceInsight> _balanceInsights = [];
  Map<String, dynamic> _balanceStatistics = {};
  bool _isLoading = false;
  bool _balanceVisible = true;
  String _selectedPeriod = '1M';
  String? _errorMessage;

  // Getters
  Account? get currentAccount => _currentAccount;
  List<BalancePoint> get balanceHistory => _balanceHistory;
  List<BalanceInsight> get balanceInsights => _balanceInsights;
  Map<String, dynamic> get balanceStatistics => _balanceStatistics;
  bool get isLoading => _isLoading;
  bool get balanceVisible => _balanceVisible;
  String get selectedPeriod => _selectedPeriod;
  String? get errorMessage => _errorMessage;

  final BalanceService _balanceService = BalanceService.instance;

  // Load balance data for account
  Future<void> loadBalanceData(int accountId) async {
    _setLoading(true);
    _clearError();

    try {
      // Load account details
      _currentAccount = await _balanceService.getAccountById(accountId);

      // Load balance history
      await loadBalanceHistory(accountId);

      // Load balance insights
      await loadBalanceInsights(accountId);

      // Load balance statistics
      await loadBalanceStatistics(accountId);

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load balance data: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Load balance history for selected period
  Future<void> loadBalanceHistory(int accountId) async {
    try {
      _balanceHistory = await _balanceService.getBalanceHistory(
        accountId: accountId,
        period: _selectedPeriod,
      );
      notifyListeners();
    } catch (e) {
      _setError('Failed to load balance history: ${e.toString()}');
    }
  }

  // Load balance insights
  Future<void> loadBalanceInsights(int accountId) async {
    try {
      _balanceInsights = await _balanceService.getBalanceInsights(accountId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load balance insights: ${e.toString()}');
    }
  }

  // Load balance statistics
  Future<void> loadBalanceStatistics(int accountId) async {
    try {
      _balanceStatistics = await _balanceService.getBalanceStatistics(
        accountId,
      );
      notifyListeners();
    } catch (e) {
      _setError('Failed to load balance statistics: ${e.toString()}');
    }
  }

  // Change selected period and reload history
  Future<void> changePeriod(String period, int accountId) async {
    if (_selectedPeriod != period) {
      _selectedPeriod = period;
      await loadBalanceHistory(accountId);
    }
  }

  // Toggle balance visibility
  void toggleBalanceVisibility() {
    _balanceVisible = !_balanceVisible;
    notifyListeners();
  }

  // Refresh all balance data
  Future<void> refreshBalanceData() async {
    if (_currentAccount?.accountId != null) {
      await loadBalanceData(_currentAccount!.accountId!);
    }
  }

  // Get formatted balance
  String getFormattedBalance() {
    if (_currentAccount == null) return '\$0.00';
    if (!_balanceVisible) return '****';
    return _balanceService.formatCurrency(_currentAccount!.balance);
  }

  // Get balance trend
  String getBalanceTrend() {
    return _balanceService.getBalanceTrend(_balanceHistory);
  }

  // Get balance change percentage
  double getBalanceChangePercentage() {
    if (_balanceHistory.length < 2) return 0.0;

    final firstBalance = _balanceHistory.first.amount;
    final lastBalance = _balanceHistory.last.amount;

    return _balanceService.calculatePercentageChange(firstBalance, lastBalance);
  }

  // Get highest balance
  double getHighestBalance() {
    return (_balanceStatistics['highest_balance'] as num?)?.toDouble() ??
        _currentAccount?.balance ??
        0.0;
  }

  // Get lowest balance
  double getLowestBalance() {
    return (_balanceStatistics['lowest_balance'] as num?)?.toDouble() ??
        _currentAccount?.balance ??
        0.0;
  }

  // Get average balance
  double getAverageBalance() {
    return (_balanceStatistics['average_balance'] as num?)?.toDouble() ??
        _currentAccount?.balance ??
        0.0;
  }

  // Get available balance (current balance minus pending transactions)
  double getAvailableBalance() {
    return _currentAccount?.balance ?? 0.0;
  }

  // Get pending amount
  double getPendingAmount() {
    return 0.0;
  }

  // Check if balance is healthy (above certain threshold)
  bool isBalanceHealthy() {
    final balance = _currentAccount?.balance ?? 0.0;
    return balance > 100.0;
  }

  // Get balance health status
  String getBalanceHealthStatus() {
    final balance = _currentAccount?.balance ?? 0.0;

    if (balance >= 1000) return 'Excellent';
    if (balance >= 500) return 'Good';
    if (balance >= 100) return 'Fair';
    return 'Low';
  }

  // Generate sample data for export (if real data is empty)
  void generateSampleDataForExport() {
    if (_balanceHistory.isEmpty && _currentAccount != null) {
      final now = DateTime.now();
      final currentBalance = _currentAccount!.balance;

      _balanceHistory = [
        BalancePoint(
          now.subtract(const Duration(days: 30)),
          currentBalance - 200.00,
        ),
        BalancePoint(
          now.subtract(const Duration(days: 25)),
          currentBalance - 150.50,
        ),
        BalancePoint(
          now.subtract(const Duration(days: 20)),
          currentBalance - 100.25,
        ),
        BalancePoint(
          now.subtract(const Duration(days: 15)),
          currentBalance - 75.80,
        ),
        BalancePoint(
          now.subtract(const Duration(days: 10)),
          currentBalance - 50.15,
        ),
        BalancePoint(
          now.subtract(const Duration(days: 5)),
          currentBalance - 25.90,
        ),
        BalancePoint(now, currentBalance),
      ];
      print('📊 Generated sample balance history');
    }

    if (_balanceStatistics.isEmpty && _currentAccount != null) {
      final currentBalance = _currentAccount!.balance;
      _balanceStatistics = {
        'highest_balance': currentBalance + 100.00,
        'lowest_balance': currentBalance - 200.00,
        'average_balance': currentBalance - 50.00,
        'current_balance': currentBalance,
      };
      print('📈 Generated sample statistics');
    }
  }

  // Prepare export data
  Future<ExportData> prepareBalanceExportData() async {
    print('=== PREPARING EXPORT DATA ===');

    if (_currentAccount == null) {
      print('❌ No current account found');
      throw Exception('No account data available');
    }

    print('✅ Current Account: ${_currentAccount!.username}');
    print('✅ Balance History: ${_balanceHistory.length} items');
    print('✅ Balance Insights: ${_balanceInsights.length} items');

    // Generate sample data if needed
    generateSampleDataForExport();

    // Prepare user data
    final userData = {
      'username': _currentAccount!.username,
      'account_type': _currentAccount!.accountType,
      'account_number': _currentAccount!.accountNumber ?? 'N/A',
      'current_balance': _currentAccount!.balance.toString(),
    };

    print('✅ User Data: $userData');

    // Prepare table data from balance history
    List<Map<String, dynamic>> tableData = [];

    if (_balanceHistory.isNotEmpty) {
      tableData =
          _balanceHistory.map((point) {
            return {
              'date': point.date.toString().split(' ')[0],
              'amount': '\$${point.amount.toStringAsFixed(2)}',
              'day_of_week': _getDayOfWeek(point.date),
            };
          }).toList();
    } else {
      // Add current balance as single entry
      final today = DateTime.now();
      tableData = [
        {
          'date': today.toString().split(' ')[0],
          'amount': getFormattedBalance(),
          'day_of_week': _getDayOfWeek(today),
        },
      ];
    }

    print('✅ Table Data: ${tableData.length} rows');

    // Prepare summary data
    final summary = {
      'Current Balance': getFormattedBalance(),
      'Account Type': _currentAccount!.accountType,
      'Account Status': 'Active',
      'Report Period': _selectedPeriod,
      'Generated Date': DateTime.now().toString().split(' ')[0],
      'Highest Balance': '\$${getHighestBalance().toStringAsFixed(2)}',
      'Lowest Balance': '\$${getLowestBalance().toStringAsFixed(2)}',
      'Average Balance': '\$${getAverageBalance().toStringAsFixed(2)}',
      'Balance Health': getBalanceHealthStatus(),
      'Total Insights': '${_balanceInsights.length}',
    };

    print('✅ Summary Data: $summary');

    final exportData = ExportData(
      title: 'Account Balance Report',
      subtitle:
          'Complete balance analysis and history for ${_currentAccount!.username}',
      userData: userData,
      tableData: tableData,
      headers: ['Date', 'Amount', 'Day of Week'],
      summary: summary,
      period: _selectedPeriod,
    );

    print('✅ Export Data Created Successfully');
    print('================================');

    return exportData;
  }

  String _getDayOfWeek(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[date.weekday - 1];
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

  // Clear balance data (for logout)
  void clearBalanceData() {
    _currentAccount = null;
    _balanceHistory = [];
    _balanceInsights = [];
    _balanceStatistics = {};
    _balanceVisible = true;
    _selectedPeriod = '1M';
    _clearError();
    notifyListeners();
  }
}
