// lib/screens/balance/balance_screen.dart
// Replace the existing balance_screen.dart content with this

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/balance_provider.dart';
import '../../widgets/navigation_drawer.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/balance/balance_chart_widget.dart';
import '../../widgets/balance/balance_stats_card.dart';
import '../../widgets/balance/period_selector.dart';
import '../../widgets/balance/balance_insights_widget.dart';
import '../../routes/app_routes.dart';
import '../../services/export_service.dart'; // Add this import
import '../../widgets/export_dialog.dart'; // Add this import
// This imports both ExportDialog and ExportDialogHelper

class BalanceScreen extends StatefulWidget {
  const BalanceScreen({super.key});

  @override
  State<BalanceScreen> createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBalanceData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadBalanceData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final balanceProvider = Provider.of<BalanceProvider>(
        context,
        listen: false,
      );

      if (authProvider.currentAccount?.accountId != null) {
        balanceProvider.loadBalanceData(
          authProvider.currentAccount!.accountId!,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, BalanceProvider>(
      builder: (context, authProvider, balanceProvider, child) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          backgroundColor:
              isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
          appBar: _buildAppBar(context, isDarkMode, balanceProvider),
          drawer: const AppNavigationDrawer(selectedIndex: 1),
          body:
              balanceProvider.isLoading
                  ? _buildLoadingState()
                  : balanceProvider.errorMessage != null
                  ? _buildErrorState(
                    balanceProvider.errorMessage!,
                    balanceProvider,
                  )
                  : _buildBalanceContent(context, balanceProvider, isDarkMode),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    bool isDarkMode,
    BalanceProvider balanceProvider,
  ) {
    return AppBar(
      backgroundColor:
          isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      foregroundColor: isDarkMode ? Colors.white : AppColors.darkText,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Balance',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDarkMode ? Colors.white : AppColors.darkText,
            ),
          ),
          Text(
            'Monitor and manage your balances',
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.white70 : AppColors.lightText,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => _showExportDialog(context, balanceProvider),
          icon: const Icon(Icons.download),
          tooltip: 'Export Balance Report',
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _getCurrentDate(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : AppColors.darkText,
                ),
              ),
              Text(
                _getCurrentTime(),
                style: TextStyle(
                  fontSize: 10,
                  color: isDarkMode ? Colors.white70 : AppColors.lightText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceContent(
    BuildContext context,
    BalanceProvider balanceProvider,
    bool isDarkMode,
  ) {
    return RefreshIndicator(
      onRefresh: () => balanceProvider.refreshBalanceData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Info Section
            _buildAccountInfoSection(context, balanceProvider, isDarkMode),

            // Main Balance Card
            _buildMainBalanceCard(context, balanceProvider, isDarkMode),

            // Statistics Cards
            _buildStatisticsSection(context, balanceProvider, isDarkMode),

            // Tab Section
            _buildTabSection(context, isDarkMode),

            // Tab Content
            _buildTabContent(context, balanceProvider, isDarkMode),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountInfoSection(
    BuildContext context,
    BalanceProvider balanceProvider,
    bool isDarkMode,
  ) {
    final account = balanceProvider.currentAccount;
    if (account == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
            child: Text(
              account.username.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${account.username} - ${account.accountType}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : AppColors.darkText,
                  ),
                ),
                Text(
                  'Account #${account.accountNumber?.substring(account.accountNumber!.length - 4) ?? '****'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white70 : AppColors.lightText,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, color: AppColors.primaryGreen, size: 8),
                const SizedBox(width: 6),
                const Text(
                  'Active',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _testExportDialog(BuildContext context) {
    // Create sample export data for testing
    final sampleExportData = ExportData(
      title: 'Test Balance Report',
      subtitle: 'Sample data for testing PDF export',
      userData: {
        'username': 'Test User',
        'account_type': 'Checking',
        'account_number': 'KOB123456',
        'current_balance': '1456.75',
      },
      tableData: [
        {
          'date': '2025-07-26',
          'amount': '\$1456.75',
          'day_of_week': 'Saturday',
        },
        {'date': '2025-07-25', 'amount': '\$1380.90', 'day_of_week': 'Friday'},
        {
          'date': '2025-07-24',
          'amount': '\$1420.15',
          'day_of_week': 'Thursday',
        },
      ],
      headers: ['Date', 'Amount', 'Day of Week'],
      summary: {
        'Current Balance': '\$1456.75',
        'Account Type': 'Checking',
        'Account Status': 'Active',
        'Total Records': '3',
        'Report Generated': DateTime.now().toString().split(' ')[0],
      },
      period: '1M',
    );

    ExportDialogHelper.show(
      context: context,
      exportData: sampleExportData,
      title: 'Test Export',
    );
  }

  Widget _buildMainBalanceCard(
    BuildContext context,
    BalanceProvider balanceProvider,
    bool isDarkMode,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1F2937), Color(0xFF111827)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Current Balance',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                onPressed: balanceProvider.toggleBalanceVisibility,
                icon: Icon(
                  balanceProvider.balanceVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            balanceProvider.getFormattedBalance(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildBalanceInfo(
                'Available',
                balanceProvider.getFormattedBalance(),
              ),
              const SizedBox(width: 32),
              _buildBalanceInfo('Pending', '\$0.00'),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  'Deposit',
                  Icons.add_circle_outline,
                  AppColors.primaryGreen,
                  () => AppRoutes.navigateToDeposit(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  'Withdraw',
                  Icons.remove_circle_outline,
                  Colors.orange,
                  () => AppRoutes.navigateToWithdraw(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  'Transfer',
                  Icons.swap_horiz,
                  Colors.blue,
                  () => AppRoutes.navigateToTransfer(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceInfo(String label, String amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(
    BuildContext context,
    BalanceProvider balanceProvider,
    bool isDarkMode,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Balance Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? Colors.white : AppColors.darkText,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: BalanceStatsCard(
                  title: 'Highest',
                  value:
                      '\$${balanceProvider.getHighestBalance().toStringAsFixed(2)}',
                  icon: Icons.trending_up,
                  color: AppColors.primaryGreen,
                  isDarkMode: isDarkMode,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BalanceStatsCard(
                  title: 'Average',
                  value:
                      '\$${balanceProvider.getAverageBalance().toStringAsFixed(2)}',
                  icon: Icons.show_chart,
                  color: Colors.blue,
                  isDarkMode: isDarkMode,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection(BuildContext context, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primaryGreen,
        unselectedLabelColor: isDarkMode ? Colors.white60 : AppColors.lightText,
        indicatorColor: AppColors.primaryGreen,
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'History'),
          Tab(text: 'Insights'),
        ],
      ),
    );
  }

  Widget _buildTabContent(
    BuildContext context,
    BalanceProvider balanceProvider,
    bool isDarkMode,
  ) {
    return Container(
      height: 400,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(context, balanceProvider, isDarkMode),
          _buildHistoryTab(context, balanceProvider, isDarkMode),
          _buildInsightsTab(context, balanceProvider, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(
    BuildContext context,
    BalanceProvider balanceProvider,
    bool isDarkMode,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          BalanceChartWidget(
            balanceHistory: balanceProvider.balanceHistory,
            period: balanceProvider.selectedPeriod,
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 16),
          _buildQuickStats(context, balanceProvider, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(
    BuildContext context,
    BalanceProvider balanceProvider,
    bool isDarkMode,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          PeriodSelector(
            selectedPeriod: balanceProvider.selectedPeriod,
            onPeriodChanged: (period) {
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              if (authProvider.currentAccount?.accountId != null) {
                balanceProvider.changePeriod(
                  period,
                  authProvider.currentAccount!.accountId!,
                );
              }
            },
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 16),
          BalanceChartWidget(
            balanceHistory: balanceProvider.balanceHistory,
            period: balanceProvider.selectedPeriod,
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsTab(
    BuildContext context,
    BalanceProvider balanceProvider,
    bool isDarkMode,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          BalanceInsightsWidget(
            insights: balanceProvider.balanceInsights,
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(
    BuildContext context,
    BalanceProvider balanceProvider,
    bool isDarkMode,
  ) {
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
            'Quick Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : AppColors.darkText,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Balance Health',
                  balanceProvider.getBalanceHealthStatus(),
                  Icons.health_and_safety,
                  balanceProvider.isBalanceHealthy()
                      ? AppColors.primaryGreen
                      : Colors.orange,
                  isDarkMode,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryItem(
                  'Trend',
                  balanceProvider.getBalanceTrend().toUpperCase(),
                  Icons.trending_up,
                  _getTrendColor(balanceProvider.getBalanceTrend()),
                  isDarkMode,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
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
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.white70 : AppColors.lightText,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTrendColor(String trend) {
    switch (trend) {
      case 'positive':
        return AppColors.primaryGreen;
      case 'negative':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading balance data...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    String errorMessage,
    BalanceProvider balanceProvider,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.red.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Retry',
              onPressed: () => balanceProvider.refreshBalanceData(),
              isPrimary: true,
            ),
          ],
        ),
      ),
    );
  }

  void _showExportDialog(
    BuildContext context,
    BalanceProvider balanceProvider,
  ) async {
    print('=== EXPORT DIALOG TRIGGERED ===');

    try {
      // First, make sure we have some data to export
      if (balanceProvider.currentAccount == null) {
        print('❌ No current account - loading data first');
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.currentAccount?.accountId != null) {
          await balanceProvider.loadBalanceData(
            authProvider.currentAccount!.accountId!,
          );
        }
      }

      // Generate sample data if needed (for testing)
      if (balanceProvider.balanceHistory.isEmpty) {
        print('❌ No balance history - generating sample data');
      }
      final exportData = await balanceProvider.prepareBalanceExportData();

      if (context.mounted) {
        ExportDialogHelper.show(
          context: context,
          exportData: exportData,
          title: 'Export Balance Report',
        );
      }
    } catch (e, stackTrace) {
      print('❌ Export preparation failed: $e');
      print('❌ Stack trace: $stackTrace');

      if (context.mounted) {
        // Show test dialog as fallback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export preparation failed. Showing test export.'),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'Test Export',
              onPressed: () => _testExportDialog(context),
            ),
          ),
        );
      }
    }
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final hour =
        now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }
}
