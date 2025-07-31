// Transaction state management
// lib/providers/transaction_provider.dart
import 'package:flutter/foundation.dart';
import '../services/dashboard_service.dart';

class TransactionProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final DashboardService _dashboardService = DashboardService.instance;

  // Make deposit transaction
  Future<bool> makeDeposit(
    int accountId,
    double amount,
    String description,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _dashboardService.createTransaction(
        accountId: accountId,
        transactionType: 'deposit',
        amount: amount,
        description: description,
      );

      _setLoading(false);
      return success;
    } catch (e) {
      _setError('Deposit failed: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Make withdrawal transaction
  Future<bool> makeWithdrawal(
    int accountId,
    double amount,
    String description,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _dashboardService.createTransaction(
        accountId: accountId,
        transactionType: 'withdrawal',
        amount: amount,
        description: description,
      );

      _setLoading(false);
      return success;
    } catch (e) {
      _setError('Withdrawal failed: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Helper methods
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
