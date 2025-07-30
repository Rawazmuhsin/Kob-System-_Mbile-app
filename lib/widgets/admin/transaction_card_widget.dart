// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/transaction.dart';

class TransactionCardWidget extends StatelessWidget {
  final Transaction transaction;
  final String? userName;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback onViewDetails;

  const TransactionCardWidget({
    super.key,
    required this.transaction,
    this.userName,
    this.onApprove,
    this.onReject,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isDebit =
        transaction.transactionType == 'withdrawal' ||
        transaction.transactionType == 'transfer';
    final isPending = transaction.status.toLowerCase() == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isPending
                  ? Colors.orange.withOpacity(0.3)
                  : (isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05)),
          width: isPending ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Transaction Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getTransactionColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getTransactionIcon(),
                  color: _getTransactionColor(),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Transaction Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            transaction.description ?? 'Transaction',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color:
                                  isDarkMode
                                      ? Colors.white
                                      : AppColors.darkText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isPending)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'URGENT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userName ?? 'Unknown User',
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            isDarkMode ? Colors.white70 : AppColors.lightText,
                      ),
                    ),
                    Text(
                      '${transaction.transactionType?.toUpperCase() ?? 'UNKNOWN'} • ${_formatDate(transaction.transactionDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            isDarkMode ? Colors.white60 : AppColors.lightText,
                      ),
                    ),
                  ],
                ),
              ),

              // Amount and Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isDebit ? '-' : '+'}${r'$'}${transaction.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _getTransactionColor(),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      transaction.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Action Buttons (only for pending transactions)
          if (isPending && (onApprove != null || onReject != null)) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                if (onReject != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onReject,
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.1),
                        foregroundColor: Colors.red,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.red.withOpacity(0.3)),
                        ),
                      ),
                    ),
                  ),
                if (onApprove != null && onReject != null)
                  const SizedBox(width: 12),
                if (onApprove != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onApprove,
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: onViewDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    foregroundColor: Colors.blue,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.blue.withOpacity(0.3)),
                    ),
                  ),
                  child: const Icon(Icons.visibility, size: 16),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onViewDetails,
                icon: const Icon(Icons.visibility, size: 16),
                label: const Text('View Details'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
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

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown date';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
