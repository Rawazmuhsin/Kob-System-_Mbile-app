// lib/widgets/admin/chart_widget.dart

import 'package:flutter/material.dart';
import '../../core/constants.dart';

class ChartWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<ChartData> data;
  final ChartType type;
  final Color primaryColor;
  final double height;

  const ChartWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.data,
    this.type = ChartType.bar,
    this.primaryColor = Colors.blue,
    this.height = 200,
  });

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
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_getChartIcon(), color: primaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? Colors.white : AppColors.darkText,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
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

          // Chart area
          if (data.isEmpty)
            _buildEmptyChart(isDarkMode)
          else
            Container(height: height, child: _buildChart(isDarkMode)),

          const SizedBox(height: 12),

          // Legend
          if (data.isNotEmpty) _buildLegend(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildEmptyChart(bool isDarkMode) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? Colors.white.withOpacity(0.02)
                : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 48,
              color: isDarkMode ? Colors.white30 : Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              'No data available',
              style: TextStyle(
                color: isDarkMode ? Colors.white30 : Colors.grey.shade400,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(bool isDarkMode) {
    switch (type) {
      case ChartType.bar:
        return _buildBarChart(isDarkMode);
      case ChartType.line:
        return _buildLineChart(isDarkMode);
      case ChartType.pie:
        return _buildPieChart(isDarkMode);
    }
  }

  Widget _buildBarChart(bool isDarkMode) {
    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children:
          data.map((item) {
            final barHeight = (item.value / maxValue) * (height - 40);
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: item.color ?? primaryColor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 10,
                        color:
                            isDarkMode ? Colors.white70 : AppColors.lightText,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${item.value.toInt()}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : AppColors.darkText,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildLineChart(bool isDarkMode) {
    // Simplified line chart representation
    return CustomPaint(
      size: Size(double.infinity, height),
      painter: LineChartPainter(
        data: data,
        color: primaryColor,
        isDarkMode: isDarkMode,
      ),
    );
  }

  Widget _buildPieChart(bool isDarkMode) {
    return CustomPaint(
      size: Size(height, height),
      painter: PieChartPainter(data: data, isDarkMode: isDarkMode),
    );
  }

  Widget _buildLegend(bool isDarkMode) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children:
          data.map((item) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: item.color ?? primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${item.label}: ${item.value.toInt()}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white70 : AppColors.lightText,
                  ),
                ),
              ],
            );
          }).toList(),
    );
  }

  IconData _getChartIcon() {
    switch (type) {
      case ChartType.bar:
        return Icons.bar_chart;
      case ChartType.line:
        return Icons.show_chart;
      case ChartType.pie:
        return Icons.pie_chart;
    }
  }
}

// Chart data model
class ChartData {
  final String label;
  final double value;
  final Color? color;

  ChartData({required this.label, required this.value, this.color});
}

enum ChartType { bar, line, pie }

// Simple Line Chart Painter
class LineChartPainter extends CustomPainter {
  final List<ChartData> data;
  final Color color;
  final bool isDarkMode;

  LineChartPainter({
    required this.data,
    required this.color,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final pointPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    final path = Path();
    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - (data[i].value / maxValue) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // Draw points
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Simple Pie Chart Painter
class PieChartPainter extends CustomPainter {
  final List<ChartData> data;
  final bool isDarkMode;

  PieChartPainter({required this.data, required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    final total = data.fold(0.0, (sum, item) => sum + item.value);

    double startAngle = -90 * (3.14159 / 180); // Start from top

    for (int i = 0; i < data.length; i++) {
      final sweepAngle = (data[i].value / total) * 2 * 3.14159;
      final paint =
          Paint()
            ..color = data[i].color ?? Colors.blue.withOpacity(0.7)
            ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
