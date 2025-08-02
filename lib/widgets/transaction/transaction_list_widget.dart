// lib/widgets/transactions/transaction_list_widget.dart
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/transaction.dart';
import '../../widgets/admin/transaction_card_widget.dart';

class TransactionListWidget extends StatelessWidget {
  final List<Transaction> transactions;
  final String selectedPeriod;

  const TransactionListWidget({
    super.key,
    required this.transactions,
    required this.selectedPeriod,
  });

  List<Transaction> _getFilteredTransactions() {
    final now = DateTime.now();
    switch (selectedPeriod) {
      case 'Today':
        return transactions
            .where(
              (t) =>
                  t.transactionDate != null &&
                  t.transactionDate!.day == now.day &&
                  t.transactionDate!.month == now.month &&
                  t.transactionDate!.year == now.year,
            )
            .toList();
      case 'Last 7 Days':
        final weekAgo = now.subtract(const Duration(days: 7));
        return transactions
            .where(
              (t) =>
                  t.transactionDate != null &&
                  t.transactionDate!.isAfter(weekAgo),
            )
            .toList();
      case 'Last 30 Days':
        final monthAgo = now.subtract(const Duration(days: 30));
        return transactions
            .where(
              (t) =>
                  t.transactionDate != null &&
                  t.transactionDate!.isAfter(monthAgo),
            )
            .toList();
      default:
        return transactions;
    }
  }

  void _showTransactionDetails(BuildContext context, Transaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            builder: (context, scrollController) {
              final isDarkMode =
                  Theme.of(context).brightness == Brightness.dark;
              return Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.darkSurface : Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Transaction Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildDetailRow(
                        'Amount',
                        '\${transaction.amount.toStringAsFixed(2)}',
                        isDarkMode,
                      ),
                      _buildDetailRow(
                        'Type',
                        transaction.transactionType ?? 'N/A',
                        isDarkMode,
                      ),
                      _buildDetailRow(
                        'Description',
                        transaction.description ?? 'Transaction',
                        isDarkMode,
                      ),
                      _buildDetailRow(
                        'Date',
                        transaction.transactionDate?.toString().split(' ')[0] ??
                            'N/A',
                        isDarkMode,
                      ),
                      _buildDetailRow('Status', transaction.status, isDarkMode),
                      if (transaction.accountNumber != null)
                        _buildDetailRow(
                          'Account Number',
                          transaction.accountNumber!,
                          isDarkMode,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white70 : AppColors.lightText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : AppColors.darkText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final filteredTransactions = _getFilteredTransactions();

    if (filteredTransactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: isDarkMode ? Colors.white30 : AppColors.lightText,
            ),
            const SizedBox(height: 16),
            Text(
              'No transactions found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white70 : AppColors.lightText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'for $selectedPeriod',
              style: TextStyle(
                fontSize: 14,
                color:
                    isDarkMode
                        ? Colors.white.withOpacity(0.5)
                        : AppColors.lightText,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredTransactions.length,
      itemBuilder: (context, index) {
        final transaction = filteredTransactions[index];
        return TransactionCardWidget(
          transaction: transaction,
          onViewDetails: () => _showTransactionDetails(context, transaction),
        );
      },
    );
  }
}
