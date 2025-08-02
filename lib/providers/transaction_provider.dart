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

  // ✅ NEW: INSTANT TRANSFER - No pending, immediate balance update
  Future<bool> makeTransfer({
    required int fromAccountId,
    required int toAccountId,
    required double amount,
    required String description,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Validate transfer first
      final validation = await validateTransfer(
        fromAccountId: fromAccountId,
        toAccountId: toAccountId,
        amount: amount,
      );

      if (!validation['isValid']) {
        _setError(validation['error']);
        _setLoading(false);
        return false;
      }

      // Execute instant transfer (this method handles both accounts and transactions)
      final success = await _dashboardService.executeInstantTransfer(
        fromAccountId: fromAccountId,
        toAccountId: toAccountId,
        amount: amount,
        description: description,
      );

      _setLoading(false);
      return success;
    } catch (e) {
      _setError('Transfer failed: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // ✅ NEW: Validate transfer (including balance check)
  Future<Map<String, dynamic>> validateTransfer({
    required int fromAccountId,
    required int toAccountId,
    required double amount,
  }) async {
    try {
      // Check if sender and recipient are different
      if (fromAccountId == toAccountId) {
        return {'isValid': false, 'error': 'Cannot transfer to same account'};
      }

      // Check minimum transfer amount
      if (amount < 1.0) {
        return {'isValid': false, 'error': 'Minimum transfer amount is \$1.00'};
      }

      // Check maximum transfer amount
      if (amount > 10000.0) {
        return {
          'isValid': false,
          'error': 'Maximum transfer amount is \$10,000.00',
        };
      }

      // Get sender account to check balance
      final senderAccount = await _dashboardService.getAccountById(
        fromAccountId,
      );
      if (senderAccount == null) {
        return {'isValid': false, 'error': 'Sender account not found'};
      }

      // Check sufficient balance
      if (senderAccount.balance < amount) {
        return {
          'isValid': false,
          'error':
              'Insufficient balance. Available: \$${senderAccount.balance.toStringAsFixed(2)}',
        };
      }

      // Get recipient account to verify it exists
      final recipientAccount = await _dashboardService.getAccountById(
        toAccountId,
      );
      if (recipientAccount == null) {
        return {'isValid': false, 'error': 'Recipient account not found'};
      }

      return {
        'isValid': true,
        'senderAccount': senderAccount,
        'recipientAccount': recipientAccount,
      };
    } catch (e) {
      return {
        'isValid': false,
        'error': 'Transfer validation failed: ${e.toString()}',
      };
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
