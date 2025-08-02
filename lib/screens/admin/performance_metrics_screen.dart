// lib/screens/admin/performance_metrics_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/admin/admin_navigation_drawer.dart';

class PerformanceMetricsScreen extends StatefulWidget {
  const PerformanceMetricsScreen({super.key});

  @override
  State<PerformanceMetricsScreen> createState() =>
      _PerformanceMetricsScreenState();
}

class _PerformanceMetricsScreenState extends State<PerformanceMetricsScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          backgroundColor:
              isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
          appBar: AppBar(
            backgroundColor:
                isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
            foregroundColor: isDarkMode ? Colors.white : AppColors.darkText,
            title: const Text('Performance Metrics'),
            elevation: 0,
          ),
          drawer: const AdminNavigationDrawer(selectedIndex: 4),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.speed, size: 80, color: Colors.orange),
                SizedBox(height: 24),
                Text(
                  'Performance Metrics',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                  'System performance, operational KPIs, and\ndetailed performance analytics coming soon!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 24),
                Text(
                  '📊 Under Development 📊',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
