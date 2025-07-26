// lib/widgets/dashboard/recent_transactions_section.dart
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/transaction.dart';

class RecentTransactionsSection extends StatelessWidget {
  final List<Transaction> transactions;
  final int transactionCount;
  final String lastTransactionDescription;
  final VoidCallback onViewAll;

  const RecentTransactionsSection({
    super.key,
    required this.transactions,
    required this.transactionCount,
    required this.lastTransactionDescription,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with transaction stats
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Transactions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode ? Colors.white : AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$transactionCount',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: isDarkMode ? Colors.white : AppColors.darkText,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Last Transaction',
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          isDarkMode
                              ? Colors.white.withOpacity(0.7)
                              : AppColors.lightText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 150),
                    child: Text(
                      lastTransactionDescription,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : AppColors.darkText,
                      ),
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Recent transactions list
          if (transactions.isEmpty)
            _buildEmptyState(isDarkMode)
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length > 3 ? 3 : transactions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return TransactionListItem(transaction: transactions[index]);
              },
            ),

          const SizedBox(height: 20),

          // View all button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onViewAll,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'View All Transactions',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color:
                isDarkMode
                    ? Colors.white.withOpacity(0.3)
                    : AppColors.lightText.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color:
                  isDarkMode
                      ? Colors.white.withOpacity(0.7)
                      : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your transaction history will appear here',
            style: TextStyle(
              fontSize: 14,
              color:
                  isDarkMode
                      ? Colors.white.withOpacity(0.5)
                      : AppColors.lightText.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;

  const TransactionListItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isDebit =
        transaction.transactionType == 'withdrawal' ||
        transaction.transactionType == 'transfer';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? Colors.white.withOpacity(0.03)
                : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isDarkMode
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.03),
        ),
      ),
      child: Row(
        children: [
          // Transaction icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
                  isDebit
                      ? Colors.red.withOpacity(0.1)
                      : AppColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getTransactionIcon(transaction.transactionType),
              color: isDebit ? Colors.red : AppColors.primaryGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Transaction details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description ?? 'Transaction',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : AppColors.darkText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(transaction.transactionDate),
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        isDarkMode
                            ? Colors.white.withOpacity(0.7)
                            : AppColors.lightText,
                  ),
                ),
              ],
            ),
          ),

          // Amount and status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isDebit ? '-' : '+'}${r'$'}${transaction.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDebit ? Colors.red : AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStatusColor(transaction.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  transaction.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: _getStatusColor(transaction.status),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getTransactionIcon(String? type) {
    switch (type) {
      case 'deposit':
        return Icons.add_circle_outline;
      case 'withdrawal':
        return Icons.remove_circle_outline;
      case 'transfer':
        return Icons.swap_horiz;
      case 'purchase':
        return Icons.shopping_cart_outlined;
      case 'card_payment':
        return Icons.credit_card;
      default:
        return Icons.receipt;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'completed':
        return AppColors.primaryGreen;
      case 'pending':
        return AppColors.primaryAmber;
      case 'rejected':
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
