// lib/screens/admin/financial_reports_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/admin/admin_navigation_drawer.dart';

class FinancialReportsScreen extends StatefulWidget {
  const FinancialReportsScreen({super.key});

  @override
  State<FinancialReportsScreen> createState() => _FinancialReportsScreenState();
}

class _FinancialReportsScreenState extends State<FinancialReportsScreen> {
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
            title: const Text('Financial Reports'),
            elevation: 0,
          ),
          drawer: const AdminNavigationDrawer(selectedIndex: 4),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_balance, size: 80, color: Colors.purple),
                SizedBox(height: 24),
                Text(
                  'Financial Reports',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                  'Balance trends, financial overview, and comprehensive\nfinancial analytics coming soon!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 24),
                Text(
                  '🚧 Under Development 🚧',
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
