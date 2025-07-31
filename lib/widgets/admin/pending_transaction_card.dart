// lib/widgets/admin/pending_transaction_card.dart
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/transaction.dart';

class PendingTransactionCard extends StatelessWidget {
  final Transaction transaction;
  final String? username;
  final String? accountNumber;
  final Function(int) onApprove;
  final Function(int, String) onReject;
  final bool isProcessing;

  const PendingTransactionCard({
    super.key,
    required this.transaction,
    this.username,
    this.accountNumber,
    required this.onApprove,
    required this.onReject,
    this.isProcessing = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isDeposit = transaction.transactionType == 'deposit';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
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
          // Header with transaction type and amount
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color:
                  isDeposit
                      ? AppColors.primaryGreen.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(
                bottom: BorderSide(
                  color:
                      isDarkMode
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.05),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isDeposit
                          ? Icons.add_circle_outline
                          : Icons.remove_circle_outline,
                      color: isDeposit ? AppColors.primaryGreen : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      transaction.transactionType?.toUpperCase() ??
                          'TRANSACTION',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : AppColors.darkText,
                      ),
                    ),
                  ],
                ),
                Text(
                  '\$${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDeposit ? AppColors.primaryGreen : Colors.red,
                  ),
                ),
              ],
            ),
          ),

          // Transaction details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  'User',
                  username ?? 'User ID: ${transaction.accountId}',
                  isDarkMode,
                ),
                _buildInfoRow(
                  'Account',
                  accountNumber ?? 'Account ID: ${transaction.accountId}',
                  isDarkMode,
                ),
                _buildInfoRow(
                  'Date',
                  _formatDate(transaction.transactionDate ?? DateTime.now()),
                  isDarkMode,
                ),
                _buildInfoRow(
                  'Description',
                  transaction.description ?? 'No description',
                  isDarkMode,
                ),

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            isProcessing || transaction.transactionId == null
                                ? null
                                : () {
                                  print(
                                    '🔄 Card: Approving transaction ID: ${transaction.transactionId}',
                                  );
                                  onApprove(transaction.transactionId!);
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child:
                            isProcessing
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Text('APPROVE'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            isProcessing
                                ? null
                                : () => _showRejectDialog(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('REJECT'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color:
                    isDarkMode
                        ? Colors.white.withOpacity(0.7)
                        : AppColors.lightText,
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showRejectDialog(BuildContext context) {
    final reasonController = TextEditingController();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reject Transaction'),
            backgroundColor: isDarkMode ? AppColors.darkSurface : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Please provide a reason for rejection:'),
                const SizedBox(height: 12),
                TextField(
                  controller: reasonController,
                  decoration: InputDecoration(
                    hintText: 'Enter reason',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor:
                        isDarkMode
                            ? Colors.white.withOpacity(0.05)
                            : Colors.white,
                  ),
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : AppColors.darkText,
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                onPressed: () {
                  final reason = reasonController.text.trim();
                  if (reason.isEmpty) {
                    // Show error
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please provide a reason for rejection'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  Navigator.pop(context);
                  onReject(transaction.transactionId ?? 0, reason);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('REJECT'),
              ),
            ],
          ),
    );
  }
}
