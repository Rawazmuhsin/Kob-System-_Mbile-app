// lib/services/balance_service.dart
import '../core/db_helper.dart';
import '../models/account.dart';
import '../models/transaction.dart';

class BalancePoint {
  final DateTime date;
  final double amount;

  BalancePoint(this.date, this.amount);
}

class BalanceInsight {
  final String title;
  final String description;
  final double value;
  final String type; // 'positive', 'negative', 'neutral'
  final String period;

  BalanceInsight({
    required this.title,
    required this.description,
    required this.value,
    required this.type,
    required this.period,
  });
}

class BalanceService {
  static final BalanceService _instance = BalanceService._internal();
  static BalanceService get instance => _instance;

  BalanceService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Get balance history for a specific period
  Future<List<BalancePoint>> getBalanceHistory({
    required int accountId,
    required String period, // '7D', '1M', '3M', '6M', '1Y'
  }) async {
    try {
      // Calculate date range based on period
      final endDate = DateTime.now();
      late DateTime startDate;

      switch (period) {
        case '7D':
          startDate = endDate.subtract(const Duration(days: 7));
          break;
        case '1M':
          startDate = endDate.subtract(const Duration(days: 30));
          break;
        case '3M':
          startDate = endDate.subtract(const Duration(days: 90));
          break;
        case '6M':
          startDate = endDate.subtract(const Duration(days: 180));
          break;
        case '1Y':
          startDate = endDate.subtract(const Duration(days: 365));
          break;
        default:
          startDate = endDate.subtract(const Duration(days: 30));
      }

      // Get transactions within date range
      final transactions = await _dbHelper.query(
        'transactions',
        where: 'account_id = ? AND transaction_date BETWEEN ? AND ?',
        whereArgs: [
          accountId,
          startDate.toIso8601String(),
          endDate.toIso8601String(),
        ],
        orderBy: 'transaction_date ASC',
      );

      // Get account current balance
      final accounts = await _dbHelper.query(
        'accounts',
        where: 'account_id = ?',
        whereArgs: [accountId],
      );

      if (accounts.isEmpty) {
        throw Exception('Account not found');
      }

      final currentBalance = (accounts.first['balance'] as num).toDouble();
      final balanceHistory = <BalancePoint>[];

      // Calculate balance at each transaction point
      double runningBalance = currentBalance;

      // Work backwards from current balance
      for (int i = transactions.length - 1; i >= 0; i--) {
        final transaction = Transaction.fromMap(transactions[i]);

        // Subtract this transaction to get previous balance
        switch (transaction.transactionType) {
          case 'deposit':
            runningBalance -= transaction.amount;
            break;
          case 'withdrawal':
          case 'transfer':
            runningBalance += transaction.amount;
            break;
        }

        balanceHistory.insert(
          0,
          BalancePoint(
            transaction.transactionDate ?? DateTime.now(),
            runningBalance,
          ),
        );
      }

      // Add current balance as the latest point
      balanceHistory.add(BalancePoint(endDate, currentBalance));

      return balanceHistory;
    } catch (e) {
      throw Exception('Error getting balance history: $e');
    }
  }

  // Get balance insights and analytics
  Future<List<BalanceInsight>> getBalanceInsights(int accountId) async {
    try {
      final insights = <BalanceInsight>[];

      // Get account data
      final accounts = await _dbHelper.query(
        'accounts',
        where: 'account_id = ?',
        whereArgs: [accountId],
      );

      if (accounts.isEmpty) {
        throw Exception('Account not found');
      }

      final currentBalance = (accounts.first['balance'] as num).toDouble();

      // Get transactions for last 30 days
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final transactions = await _dbHelper.query(
        'transactions',
        where: 'account_id = ? AND transaction_date >= ?',
        whereArgs: [accountId, thirtyDaysAgo.toIso8601String()],
        orderBy: 'transaction_date DESC',
      );

      // Calculate insights
      double totalDeposits = 0;
      double totalWithdrawals = 0;
      int transactionCount = transactions.length;

      for (final transactionData in transactions) {
        final transaction = Transaction.fromMap(transactionData);
        switch (transaction.transactionType) {
          case 'deposit':
            totalDeposits += transaction.amount;
            break;
          case 'withdrawal':
          case 'transfer':
            totalWithdrawals += transaction.amount;
            break;
        }
      }

      // Average daily balance (simplified calculation)
      final averageDailyBalance = currentBalance;

      // Net change in last 30 days
      final netChange = totalDeposits - totalWithdrawals;

      // Create insights
      insights.add(
        BalanceInsight(
          title: 'Monthly Net Change',
          description:
              netChange >= 0
                  ? 'Your balance increased this month'
                  : 'Your balance decreased this month',
          value: netChange,
          type: netChange >= 0 ? 'positive' : 'negative',
          period: 'Last 30 days',
        ),
      );

      insights.add(
        BalanceInsight(
          title: 'Average Daily Balance',
          description: 'Your estimated average daily balance',
          value: averageDailyBalance,
          type: 'neutral',
          period: 'Last 30 days',
        ),
      );

      insights.add(
        BalanceInsight(
          title: 'Transaction Activity',
          description: '$transactionCount transactions in the last month',
          value: transactionCount.toDouble(),
          type: transactionCount > 10 ? 'positive' : 'neutral',
          period: 'Last 30 days',
        ),
      );

      insights.add(
        BalanceInsight(
          title: 'Spending vs Income',
          description:
              totalDeposits > totalWithdrawals
                  ? 'You saved money this month'
                  : 'You spent more than you earned',
          value:
              (totalDeposits / (totalWithdrawals + 1)) *
              100, // Avoid division by zero
          type: totalDeposits > totalWithdrawals ? 'positive' : 'negative',
          period: 'Last 30 days',
        ),
      );

      return insights;
    } catch (e) {
      throw Exception('Error getting balance insights: $e');
    }
  }

  // Export balance report data
  Future<Map<String, dynamic>> getBalanceReportData({
    required int accountId,
    required String period,
  }) async {
    try {
      final account = await getAccountById(accountId);
      final balanceHistory = await getBalanceHistory(
        accountId: accountId,
        period: period,
      );
      final insights = await getBalanceInsights(accountId);

      return {
        'account': account?.toMap(),
        'balance_history':
            balanceHistory
                .map(
                  (point) => {
                    'date': point.date.toIso8601String(),
                    'amount': point.amount,
                  },
                )
                .toList(),
        'insights':
            insights
                .map(
                  (insight) => {
                    'title': insight.title,
                    'description': insight.description,
                    'value': insight.value,
                    'type': insight.type,
                    'period': insight.period,
                  },
                )
                .toList(),
        'generated_at': DateTime.now().toIso8601String(),
        'period': period,
      };
    } catch (e) {
      throw Exception('Error generating balance report: $e');
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

  // Get balance statistics
  Future<Map<String, dynamic>> getBalanceStatistics(int accountId) async {
    try {
      final balanceHistory = await getBalanceHistory(
        accountId: accountId,
        period: '1Y',
      );

      if (balanceHistory.isEmpty) {
        return {
          'highest_balance': 0.0,
          'lowest_balance': 0.0,
          'average_balance': 0.0,
          'current_balance': 0.0,
        };
      }

      final balances = balanceHistory.map((point) => point.amount).toList();
      final highestBalance = balances.reduce((a, b) => a > b ? a : b);
      final lowestBalance = balances.reduce((a, b) => a < b ? a : b);
      final averageBalance = balances.reduce((a, b) => a + b) / balances.length;
      final currentBalance = balances.last;

      return {
        'highest_balance': highestBalance,
        'lowest_balance': lowestBalance,
        'average_balance': averageBalance,
        'current_balance': currentBalance,
      };
    } catch (e) {
      throw Exception('Error getting balance statistics: $e');
    }
  }

  // Format currency
  String formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  // Get balance trend (positive, negative, stable)
  String getBalanceTrend(List<BalancePoint> history) {
    if (history.length < 2) return 'stable';

    final firstBalance = history.first.amount;
    final lastBalance = history.last.amount;
    final difference = lastBalance - firstBalance;

    if (difference > 50) return 'positive';
    if (difference < -50) return 'negative';
    return 'stable';
  }

  // Calculate percentage change
  double calculatePercentageChange(double oldValue, double newValue) {
    if (oldValue == 0) return 0;
    return ((newValue - oldValue) / oldValue) * 100;
  }
}
