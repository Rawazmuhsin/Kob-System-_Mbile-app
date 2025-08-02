// lib/screens/admin/admin_reports_screen.dart
// FIXED VERSION - Copy this to replace your current file

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/admin/admin_navigation_drawer.dart';
import '../../widgets/admin/analytics_overview_widget.dart';
import '../../widgets/admin/analytics_quick_stats_widget.dart';
import '../../widgets/admin/analytics_category_card_widget.dart';
import '../../routes/app_routes.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      adminProvider.refreshDashboard();
    });
  }

  void _handleStatTap(String statType) {
    switch (statType) {
      case 'pending':
        Navigator.pushNamed(context, AppRoutes.adminApprovals);
        break;
      case 'approved':
      case 'rejected':
      case 'processing':
        Navigator.pushNamed(context, AppRoutes.adminTransactionAnalytics);
        break;
    }
  }

  void _navigateToCategory(String route) {
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          backgroundColor:
              isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
          appBar: _buildAppBar(context, isDarkMode),
          drawer: const AdminNavigationDrawer(selectedIndex: 4),
          body:
              adminProvider.isLoading
                  ? _buildLoadingState()
                  : _buildReportsContent(context, adminProvider, isDarkMode),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDarkMode) {
    return AppBar(
      backgroundColor:
          isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      foregroundColor: isDarkMode ? Colors.white : AppColors.darkText,
      title: const Text('Reports & Analytics'),
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => _loadData(),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading reports...'),
        ],
      ),
    );
  }

  Widget _buildReportsContent(
    BuildContext context,
    AdminProvider adminProvider,
    bool isDarkMode,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview Header
          AnalyticsOverviewWidget(
            statistics: adminProvider.statistics,
            onRefresh: _loadData,
          ),

          const SizedBox(height: 24),

          // Quick Stats Grid
          AnalyticsQuickStatsWidget(
            summary: adminProvider.getDashboardSummary(),
            onStatTap: _handleStatTap,
          ),

          const SizedBox(height: 32),

          // Reports Categories
          _buildReportCategories(context, adminProvider, isDarkMode),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildReportCategories(
    BuildContext context,
    AdminProvider adminProvider,
    bool isDarkMode,
  ) {
    final pendingCount =
        adminProvider.getDashboardSummary()['pending_approvals'] ?? 0;

    // Define categories with proper types
    final List<CategoryData> categories = [
      CategoryData(
        title: 'Transaction Analytics',
        subtitle: 'Detailed transaction trends & patterns',
        icon: Icons.trending_up,
        color: Colors.blue,
        route: AppRoutes.adminTransactionAnalytics,
        badge: null,
      ),
      CategoryData(
        title: 'User Analytics',
        subtitle: 'User behavior & account insights',
        icon: Icons.people_alt,
        color: Colors.green,
        route: AppRoutes.adminUserAnalytics,
        badge: null,
      ),
      CategoryData(
        title: 'Financial Reports',
        subtitle: 'Balance trends & financial overview',
        icon: Icons.account_balance,
        color: Colors.purple,
        route: AppRoutes.adminFinancialReports,
        badge: null,
      ),
      CategoryData(
        title: 'Performance Metrics',
        subtitle: 'System performance & operational KPIs',
        icon: Icons.speed,
        color: Colors.orange,
        route: AppRoutes.adminPerformanceMetrics,
        badge: null,
      ),
      CategoryData(
        title: 'Audit & Compliance',
        subtitle: 'Security logs & compliance reports',
        icon: Icons.security,
        color: Colors.red,
        route: AppRoutes.adminAudit,
        badge: pendingCount > 5 ? '!' : null,
      ),
      CategoryData(
        title: 'Export Center',
        subtitle: 'Generate & download custom reports',
        icon: Icons.download,
        color: Colors.teal,
        route: AppRoutes.adminExportCenter,
        badge: null,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Report Categories',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : AppColors.darkText,
          ),
        ),
        const SizedBox(height: 16),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final category = categories[index];
            return AnalyticsCategoryCardWidget(
              title: category.title,
              subtitle: category.subtitle,
              icon: category.icon,
              color: category.color,
              onTap: () => _navigateToCategory(category.route),
              badge: category.badge,
            );
          },
        ),
      ],
    );
  }
}

// Helper class to ensure proper typing
class CategoryData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;
  final String? badge;

  CategoryData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
    this.badge,
  });
}
