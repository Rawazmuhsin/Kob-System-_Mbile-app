// lib/widgets/admin/transactions_stats_widget.dart
import 'package:flutter/material.dart';
import '../../core/constants.dart';

class TransactionsStatsWidget extends StatelessWidget {
  final Map<String, dynamic> stats;
  final Function(String) onStatTap;

  const TransactionsStatsWidget({
    super.key,
    required this.stats,
    required this.onStatTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaction Overview',
            style: TextStyle(
              fontSize: 18,
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
                'Total Transactions',
                '${stats['total'] ?? 0}',
                Icons.receipt_long,
                Colors.blue,
                'all',
                isDarkMode,
              ),
              _buildStatCard(
                context,
                'Pending Approvals',
                '${stats['pending'] ?? 0}',
                Icons.pending_actions,
                Colors.orange,
                'pending',
                isDarkMode,
                urgent: (stats['pending'] ?? 0) > 0,
              ),
              _buildStatCard(
                context,
                'Approved',
                '${stats['approved'] ?? 0}',
                Icons.check_circle,
                AppColors.primaryGreen,
                'approved',
                isDarkMode,
              ),
              _buildStatCard(
                context,
                'Rejected',
                '${stats['rejected'] ?? 0}',
                Icons.cancel,
                Colors.red,
                'rejected',
                isDarkMode,
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
                  'Total Volume',
                  _formatCurrency((stats['total_volume'] ?? 0.0).toDouble()),
                  Icons.trending_up,
                  Colors.purple,
                  isDarkMode,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMiniStatCard(
                  context,
                  'Avg Amount',
                  _formatCurrency((stats['average_amount'] ?? 0.0).toDouble()),
                  Icons.show_chart,
                  Colors.teal,
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
                  ? Colors.white.withOpacity(0.05)
                  : Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                urgent
                    ? Colors.orange.withOpacity(0.3)
                    : (isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05)),
            width: urgent ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  urgent
                      ? Colors.orange.withOpacity(0.2)
                      : (isDarkMode ? Colors.black : Colors.grey).withOpacity(
                        0.1,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
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
                      color: Colors.orange,
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
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color:
                    urgent
                        ? Colors.orange
                        : (isDarkMode ? Colors.white : AppColors.darkText),
              ),
              overflow: TextOverflow.ellipsis,
            ),
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
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
                    fontSize: 14,
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
