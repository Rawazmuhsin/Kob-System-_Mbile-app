// lib/widgets/admin/analytics_quick_stats_widget.dart

import 'package:flutter/material.dart';
import '../../core/constants.dart';

class AnalyticsQuickStatsWidget extends StatelessWidget {
  final Map<String, dynamic> summary;
  final Function(String) onStatTap;

  const AnalyticsQuickStatsWidget({
    super.key,
    required this.summary,
    required this.onStatTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildQuickStatCard(
          'Pending Approvals',
          '${summary['pending_approvals']}',
          Icons.pending_actions,
          Colors.orange,
          isDarkMode,
          'pending',
          urgent: (summary['pending_approvals'] ?? 0) > 0,
        ),
        _buildQuickStatCard(
          'Approved Today',
          '${summary['approved_transactions']}',
          Icons.check_circle,
          Colors.green,
          isDarkMode,
          'approved',
        ),
        _buildQuickStatCard(
          'Rejected',
          '${summary['rejected_transactions']}',
          Icons.cancel,
          Colors.red,
          isDarkMode,
          'rejected',
        ),
        _buildQuickStatCard(
          'Processing Rate',
          '${_calculateProcessingRate(summary)}%',
          Icons.speed,
          Colors.blue,
          isDarkMode,
          'processing',
        ),
      ],
    );
  }

  Widget _buildQuickStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDarkMode,
    String statType, {
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
                    ? Colors.red.withOpacity(0.3)
                    : (isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05)),
            width: urgent ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  urgent
                      ? Colors.red.withOpacity(0.2)
                      : (isDarkMode ? Colors.black : Colors.grey).withOpacity(
                        0.1,
                      ),
              blurRadius: urgent ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? Colors.white : AppColors.darkText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.white70 : AppColors.lightText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  int _calculateProcessingRate(Map<String, dynamic> summary) {
    final total =
        (summary['approved_transactions'] ?? 0) +
        (summary['rejected_transactions'] ?? 0) +
        (summary['pending_approvals'] ?? 0);

    if (total == 0) return 100;

    final processed =
        (summary['approved_transactions'] ?? 0) +
        (summary['rejected_transactions'] ?? 0);

    return ((processed / total) * 100).round();
  }
}
