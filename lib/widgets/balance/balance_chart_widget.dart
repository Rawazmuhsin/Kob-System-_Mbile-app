import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../services/balance_service.dart';

class BalanceChartWidget extends StatelessWidget {
  final List<BalancePoint> balanceHistory;
  final String period;
  final bool isDarkMode;

  const BalanceChartWidget({
    super.key,
    required this.balanceHistory,
    required this.period,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
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
            'Balance Trend ($period)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : AppColors.darkText,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child:
                balanceHistory.isEmpty
                    ? _buildEmptyChart()
                    : CustomPaint(
                      painter: BalanceChartPainter(balanceHistory, isDarkMode),
                      size: const Size(double.infinity, double.infinity),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.trending_up,
            size: 48,
            color:
                isDarkMode
                    ? Colors.white.withOpacity(0.3)
                    : AppColors.lightText.withOpacity(0.5),
          ),
          const SizedBox(height: 8),
          Text(
            'No balance history available',
            style: TextStyle(
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
}

// Custom painter for balance chart
class BalanceChartPainter extends CustomPainter {
  final List<BalancePoint> balanceHistory;
  final bool isDarkMode;

  BalanceChartPainter(this.balanceHistory, this.isDarkMode);

  @override
  void paint(Canvas canvas, Size size) {
    if (balanceHistory.isEmpty) return;

    final paint =
        Paint()
          ..color = AppColors.primaryGreen
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final fillPaint =
        Paint()
          ..color = AppColors.primaryGreen.withOpacity(0.1)
          ..style = PaintingStyle.fill;

    final gridPaint =
        Paint()
          ..color = (isDarkMode ? Colors.white : Colors.black).withOpacity(0.1)
          ..strokeWidth = 1;

    // Draw grid lines
    for (int i = 0; i <= 4; i++) {
      final y = (size.height / 4) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Calculate min and max values
    final amounts = balanceHistory.map((point) => point.amount).toList();
    final minAmount = amounts.reduce((a, b) => a < b ? a : b);
    final maxAmount = amounts.reduce((a, b) => a > b ? a : b);
    final range = maxAmount - minAmount;

    if (range == 0) return;

    // Create path for line chart
    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < balanceHistory.length; i++) {
      final x = (size.width / (balanceHistory.length - 1)) * i;
      final y =
          size.height -
          ((balanceHistory[i].amount - minAmount) / range) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // Complete fill path
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Draw fill and line
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw points
    for (int i = 0; i < balanceHistory.length; i++) {
      final x = (size.width / (balanceHistory.length - 1)) * i;
      final y =
          size.height -
          ((balanceHistory[i].amount - minAmount) / range) * size.height;

      canvas.drawCircle(
        Offset(x, y),
        4,
        Paint()..color = AppColors.primaryGreen,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
