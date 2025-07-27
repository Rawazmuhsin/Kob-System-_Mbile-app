// lib/widgets/admin/user_details_widget.dart
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/account.dart';

class UserDetailsWidget extends StatelessWidget {
  final Account user;

  const UserDetailsWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                child: Text(
                  user.username.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.username,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? Colors.white : AppColors.darkText,
                      ),
                    ),
                    Text(
                      '${user.accountType} Account',
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            isDarkMode ? Colors.white70 : AppColors.lightText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _buildDetailRow('Email', user.email ?? 'Not provided', isDarkMode),
          _buildDetailRow('Phone', user.phone, isDarkMode),
          _buildDetailRow(
            'Account Number',
            user.accountNumber ?? 'Not assigned',
            isDarkMode,
          ),
          _buildDetailRow(
            'Balance',
            '\$${user.balance.toStringAsFixed(2)}',
            isDarkMode,
          ),
          _buildDetailRow('Account Type', user.accountType, isDarkMode),
          _buildDetailRow(
            'Created At',
            user.createdAt?.toString().split(' ')[0] ?? 'Unknown',
            isDarkMode,
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
            width: 120,
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
}
