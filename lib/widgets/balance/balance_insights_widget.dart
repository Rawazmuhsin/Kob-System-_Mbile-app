// lib/widgets/balance/balance_insights_widget.dart
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../services/balance_service.dart';

class BalanceInsightsWidget extends StatelessWidget {
  final List<BalanceInsight> insights;
  final bool isDarkMode;

  const BalanceInsightsWidget({
    super.key,
    required this.insights,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Text(
            'Balance Insights',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? Colors.white : AppColors.darkText,
            ),
          ),
          const SizedBox(height: 16),
          if (insights.isEmpty)
            _buildEmptyInsights()
          else
            ...insights.map((insight) => _buildInsightItem(insight)),
        ],
      ),
    );
  }

  Widget _buildEmptyInsights() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.insights,
              size: 48,
              color:
                  isDarkMode
                      ? Colors.white.withOpacity(0.3)
                      : AppColors.lightText.withOpacity(0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'No insights available yet',
              style: TextStyle(
                color:
                    isDarkMode
                        ? Colors.white.withOpacity(0.5)
                        : AppColors.lightText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(BalanceInsight insight) {
    Color insightColor;
    IconData insightIcon;

    switch (insight.type) {
      case 'positive':
        insightColor = AppColors.primaryGreen;
        insightIcon = Icons.trending_up;
        break;
      case 'negative':
        insightColor = Colors.red;
        insightIcon = Icons.trending_down;
        break;
      default:
        insightColor = Colors.blue;
        insightIcon = Icons.info_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: insightColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: insightColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: insightColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(insightIcon, color: insightColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white70 : AppColors.lightText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight.period,
                  style: TextStyle(
                    fontSize: 11,
                    color: insightColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (insight.value != 0)
            Text(
              insight.type == 'positive' || insight.type == 'negative'
                  ? '${insight.value > 0 ? '+' : ''}\$${insight.value.abs().toStringAsFixed(2)}'
                  : insight.value.toStringAsFixed(0),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: insightColor,
              ),
            ),
        ],
      ),
    );
  }
}
