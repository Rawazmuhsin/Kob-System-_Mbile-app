// lib/widgets/admin/transaction_details_widget.dart
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/transaction.dart';

class TransactionDetailsWidget extends StatelessWidget {
  final Transaction transaction;
  final String? userName;
  final String? userEmail;

  const TransactionDetailsWidget({
    super.key,
    required this.transaction,
    this.userName,
    this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isDebit =
        transaction.transactionType == 'withdrawal' ||
        transaction.transactionType == 'transfer';

    return Container(
      width: double.infinity,
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
          // Header
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getTransactionColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _getTransactionIcon(),
                  color: _getTransactionColor(),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description ?? 'Transaction Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? Colors.white : AppColors.darkText,
                      ),
                    ),
                    Text(
                      transaction.transactionType?.toUpperCase() ??
                          'UNKNOWN TYPE',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _getTransactionColor(),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _getStatusColor().withOpacity(0.3)),
                ),
                child: Text(
                  transaction.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Amount Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getTransactionColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getTransactionColor().withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Transaction Amount',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white70 : AppColors.lightText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${isDebit ? '-' : '+'}${r'$'}${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: _getTransactionColor(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Transaction Details
          Text(
            'Transaction Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? Colors.white : AppColors.darkText,
            ),
          ),
          const SizedBox(height: 16),

          _buildDetailRow(
            'Transaction ID',
            '#${transaction.transactionId ?? 'N/A'}',
            isDarkMode,
          ),
          _buildDetailRow(
            'Account ID',
            '#${transaction.accountId}',
            isDarkMode,
          ),
          _buildDetailRow('User Name', userName ?? 'Unknown User', isDarkMode),
          _buildDetailRow('User Email', userEmail ?? 'N/A', isDarkMode),
          _buildDetailRow(
            'Transaction Type',
            transaction.transactionType ?? 'Unknown',
            isDarkMode,
          ),
          _buildDetailRow(
            'Amount',
            '\$${transaction.amount.toStringAsFixed(2)}',
            isDarkMode,
          ),
          _buildDetailRow('Status', transaction.status, isDarkMode),
          _buildDetailRow(
            'Description',
            transaction.description ?? 'No description',
            isDarkMode,
          ),
          _buildDetailRow(
            'Transaction Date',
            _formatDateTime(transaction.transactionDate),
            isDarkMode,
          ),

          if (transaction.approvalDate != null)
            _buildDetailRow(
              'Approval Date',
              _formatDateTime(transaction.approvalDate),
              isDarkMode,
            ),

          if (transaction.accountNumber != null)
            _buildDetailRow(
              'Recipient Account',
              transaction.accountNumber!,
              isDarkMode,
            ),

          const SizedBox(height: 20),

          // Additional Information
          if (transaction.transactionType == 'transfer' ||
              transaction.accountNumber != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    isDarkMode
                        ? Colors.blue.withOpacity(0.1)
                        : Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Transfer Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (transaction.accountNumber != null)
                    Text(
                      'Recipient Account: ${transaction.accountNumber}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.white : AppColors.darkText,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white70 : AppColors.lightText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isDarkMode ? Colors.white : AppColors.darkText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTransactionIcon() {
    switch (transaction.transactionType) {
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

  Color _getTransactionColor() {
    switch (transaction.transactionType) {
      case 'deposit':
        return AppColors.primaryGreen;
      case 'withdrawal':
        return Colors.red;
      case 'transfer':
        return Colors.blue;
      case 'purchase':
        return Colors.purple;
      case 'card_payment':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor() {
    switch (transaction.status.toLowerCase()) {
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

  String _formatDateTime(DateTime? date) {
    if (date == null) return 'N/A';

    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
