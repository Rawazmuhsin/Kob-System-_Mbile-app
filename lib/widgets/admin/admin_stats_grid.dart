import 'package:flutter/material.dart';
import '../../core/constants.dart';

class AdminStatsGrid extends StatelessWidget {
  final Map<String, dynamic> statistics;
  final Function(String) onStatTap;

  const AdminStatsGrid({
    super.key,
    required this.statistics,
    required this.onStatTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'System Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? Colors.white : AppColors.darkText,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                context,
                'Total Accounts',
                '${statistics['total_accounts'] ?? 0}',
                Icons.people,
                Colors.blue,
                'accounts',
                isDarkMode,
              ),
              _buildStatCard(
                context,
                'Total Balance',
                _formatCurrency(
                  (statistics['total_balance'] ?? 0.0).toDouble(),
                ),
                Icons.account_balance_wallet,
                Colors.green,
                'balance',
                isDarkMode,
              ),
              _buildStatCard(
                context,
                'Total Transactions',
                '${statistics['total_transactions'] ?? 0}',
                Icons.receipt_long,
                Colors.orange,
                'transactions',
                isDarkMode,
              ),
              _buildStatCard(
                context,
                'Pending Approvals',
                '${statistics['pending_approvals'] ?? 0}',
                Icons.pending_actions,
                Colors.red,
                'approvals',
                isDarkMode,
                urgent: (statistics['pending_approvals'] ?? 0) > 0,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Additional stats row
          Row(
            children: [
              Expanded(
                child: _buildMiniStatCard(
                  context,
                  'Approved',
                  '${statistics['approved_transactions'] ?? 0}',
                  Icons.check_circle,
                  Colors.green,
                  isDarkMode,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMiniStatCard(
                  context,
                  'Rejected',
                  '${statistics['rejected_transactions'] ?? 0}',
                  Icons.cancel,
                  Colors.red,
                  isDarkMode,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    String statType,
    bool isDarkMode, {
    bool urgent = false,
  }) {
    return GestureDetector(
      onTap: () => onStatTap(statType),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isDarkMode
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                urgent
                    ? Colors.red.withValues(alpha: 0.3)
                    : (isDarkMode
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.05)),
            width: urgent ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  urgent
                      ? Colors.red.withValues(alpha: 0.2)
                      : (isDarkMode ? Colors.black : Colors.grey).withValues(
                        alpha: 0.1,
                      ),
              blurRadius: urgent ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icon and urgent indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                if (urgent)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'URGENT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Value
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color:
                    urgent
                        ? Colors.red
                        : (isDarkMode ? Colors.white : AppColors.darkText),
              ),
              overflow: TextOverflow.ellipsis,
            ),
            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.white70 : AppColors.lightText,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : AppColors.darkText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDarkMode ? Colors.white70 : AppColors.lightText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }
}
