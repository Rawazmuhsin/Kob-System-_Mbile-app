import '../core/db_helper.dart';
import '../models/account.dart';
import '../models/transaction.dart';

class DashboardService {
  static final DashboardService _instance = DashboardService._internal();
  static DashboardService get instance => _instance;

  DashboardService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Get account summary data
  Future<Map<String, dynamic>> getAccountSummary(int accountId) async {
    try {
      final accounts = await _dbHelper.query(
        'accounts',
        where: 'account_id = ?',
        whereArgs: [accountId],
      );

      if (accounts.isEmpty) {
        throw Exception('Account not found');
      }

      final account = Account.fromMap(accounts.first);

      // Get transaction count
      final transactions = await _dbHelper.query(
        'transactions',
        where: 'account_id = ?',
        whereArgs: [accountId],
      );

      return {
        'account': account,
        'transaction_count': transactions.length,
        'last_transaction':
            transactions.isNotEmpty
                ? Transaction.fromMap(transactions.first)
                : null,
      };
    } catch (e) {
      throw Exception('Error getting account summary: $e');
    }
  }

  // Get recent transactions (last 5)
  Future<List<Transaction>> getRecentTransactions(int accountId) async {
    try {
      final transactionsData = await _dbHelper.query(
        'transactions',
        where: 'account_id = ?',
        whereArgs: [accountId],
        orderBy: 'transaction_date DESC',
        limit: 5,
      );

      return transactionsData.map((data) => Transaction.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Error getting recent transactions: $e');
    }
  }

  // Get all transactions for account
  Future<List<Transaction>> getAllTransactions(int accountId) async {
    try {
      final transactionsData = await _dbHelper.query(
        'transactions',
        where: 'account_id = ?',
        whereArgs: [accountId],
        orderBy: 'transaction_date DESC',
      );

      return transactionsData.map((data) => Transaction.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Error getting all transactions: $e');
    }
  }

  // Get account statistics
  Future<Map<String, dynamic>> getAccountStatistics(int accountId) async {
    try {
      final transactions = await getAllTransactions(accountId);

      double totalDeposits = 0;
      double totalWithdrawals = 0;
      double totalTransfers = 0;

      for (final transaction in transactions) {
        switch (transaction.transactionType) {
          case 'deposit':
            totalDeposits += transaction.amount;
            break;
          case 'withdrawal':
            totalWithdrawals += transaction.amount;
            break;
          case 'transfer':
            totalTransfers += transaction.amount;
            break;
        }
      }

      return {
        'total_transactions': transactions.length,
        'total_deposits': totalDeposits,
        'total_withdrawals': totalWithdrawals,
        'total_transfers': totalTransfers,
        'last_transaction_date':
            transactions.isNotEmpty ? transactions.first.transactionDate : null,
      };
    } catch (e) {
      throw Exception('Error getting account statistics: $e');
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
      throw Exception('Error updating account balance: $e');
    }
  }

  // Create a new transaction
  Future<bool> createTransaction({
    required int accountId,
    required String transactionType,
    required double amount,
    required String description,
    String status = 'PENDING',
    String? recipientAccountNumber,
  }) async {
    try {
      final transactionData = {
        'account_id': accountId,
        'transaction_type': transactionType,
        'amount': amount,
        'description': description,
        'status': status,
        'recipient_account_number': recipientAccountNumber,
        'reference_number': _generateReferenceNumber(),
        'transaction_date': DateTime.now().toIso8601String(),
      };

      final result = await _dbHelper.insert('transactions', transactionData);
      return result > 0;
    } catch (e) {
      throw Exception('Error creating transaction: $e');
    }
  }

  // Generate unique reference number
  String _generateReferenceNumber() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'TXN${timestamp.toString().substring(5)}';
  }

  // Get masked account number for display
  String getMaskedAccountNumber(String? accountNumber) {
    if (accountNumber == null || accountNumber.length < 4) {
      return '****';
    }
    return '****${accountNumber.substring(accountNumber.length - 4)}';
  }

  // Format currency
  String formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  // Get transaction icon
  String getTransactionIcon(String? transactionType) {
    switch (transactionType) {
      case 'deposit':
        return '💰';
      case 'withdrawal':
        return '💸';
      case 'transfer':
        return '↔️';
      case 'purchase':
        return '🛒';
      case 'card_payment':
        return '💳';
      default:
        return '📄';
    }
  }

  // Get transaction status color
  String getTransactionStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'completed':
        return 'green';
      case 'pending':
        return 'orange';
      case 'rejected':
      case 'failed':
        return 'red';
      default:
        return 'grey';
    }
  }
}
