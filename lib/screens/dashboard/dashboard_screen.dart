// lib/screens/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/navigation_drawer.dart';
import '../../widgets/dashboard/account_balance_card.dart';
import '../../widgets/dashboard/quick_action_grid.dart';
import '../../widgets/dashboard/recent_transactions_section.dart';
import '../../routes/app_routes.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _initializeDashboard();
  }

  void _initializeDashboard() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final dashboardProvider = Provider.of<DashboardProvider>(
        context,
        listen: false,
      );

      if (authProvider.currentAccount?.accountId != null) {
        dashboardProvider.loadDashboardData(
          authProvider.currentAccount!.accountId!,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<AuthProvider, DashboardProvider, ThemeProvider>(
      builder: (
        context,
        authProvider,
        dashboardProvider,
        themeProvider,
        child,
      ) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final currentAccount = authProvider.currentAccount;

        if (currentAccount == null) {
          return _buildErrorState('No account found');
        }

        return Scaffold(
          backgroundColor:
              isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
          appBar: _buildAppBar(context, isDarkMode, currentAccount),
          drawer: const AppNavigationDrawer(selectedIndex: 0),
          body: RefreshIndicator(
            onRefresh: () => dashboardProvider.refreshDashboard(),
            child:
                dashboardProvider.isLoading &&
                        dashboardProvider.currentAccount == null
                    ? _buildLoadingState()
                    : dashboardProvider.errorMessage != null
                    ? _buildErrorState(dashboardProvider.errorMessage!)
                    : _buildDashboardContent(
                      context,
                      dashboardProvider,
                      isDarkMode,
                    ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    bool isDarkMode,
    dynamic currentAccount,
  ) {
    return AppBar(
      backgroundColor:
          isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      foregroundColor: isDarkMode ? Colors.white : AppColors.darkText,
      elevation: 0,
      titleSpacing: 8, // Reduce space between drawer icon and title
      title: Text(
        'KÖB', // Just KOB, moved closer to drawer icon
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: isDarkMode ? Colors.white : AppColors.darkText,
        ),
      ),
      actions: [
        // Date and time (kept in original place)
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

  Widget _buildDashboardContent(
    BuildContext context,
    DashboardProvider dashboardProvider,
    bool isDarkMode,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info Section (NEW)
          _buildUserInfoSection(context, dashboardProvider, isDarkMode),

          // Account Summary Section
          _buildAccountSummarySection(context, dashboardProvider),

          // Account Balance Card
          AccountBalanceCard(
            accountType:
                dashboardProvider.currentAccount?.accountType ?? 'Account',
            balance: dashboardProvider.getFormattedBalance(),
            accountNumber: dashboardProvider.getMaskedAccountNumber(),
            balanceVisible: dashboardProvider.balanceVisible,
            onToggleVisibility: dashboardProvider.toggleBalanceVisibility,
            onDeposit: () => _navigateToDeposit(context),
            onWithdraw: () => _navigateToWithdraw(context),
          ),

          // Recent Transactions Section
          RecentTransactionsSection(
            transactions: dashboardProvider.recentTransactions,
            transactionCount: dashboardProvider.transactionCount,
            lastTransactionDescription:
                dashboardProvider.getLastTransactionDescription(),
            onViewAll: () => _navigateToTransactions(context),
          ),

          // Quick Actions Grid
          QuickActionGrid(
            onDeposit: () => _navigateToDeposit(context),
            onWithdraw: () => _navigateToWithdraw(context),
            onTransfer: () => _navigateToTransfer(context),
            onQRCodes: () => _navigateToQRCodes(context),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // NEW: User Info Section
  Widget _buildUserInfoSection(
    BuildContext context,
    DashboardProvider dashboardProvider,
    bool isDarkMode,
  ) {
    return Container(
      width: double.infinity,
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
          // User Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
            child: Text(
              dashboardProvider.currentAccount?.username
                      ?.substring(0, 1)
                      .toUpperCase() ??
                  'U',
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // User Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dashboardProvider.currentAccount?.username ?? 'User Name',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : AppColors.darkText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  dashboardProvider.currentAccount?.phone ?? 'Phone Number',
                  style: TextStyle(
                    fontSize: 14,
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

  Widget _buildAccountSummarySection(
    BuildContext context,
    DashboardProvider dashboardProvider,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
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
          Text(
            'Account Summary',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? Colors.white : AppColors.darkText,
            ),
          ),
          const SizedBox(height: 16),

          // Quick stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Balance',
                  dashboardProvider.getFormattedBalance(),
                  Icons.account_balance_wallet,
                  AppColors.primaryGreen,
                  isDarkMode,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Transactions',
                  '${dashboardProvider.transactionCount}',
                  Icons.receipt_long,
                  Colors.blue,
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
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? Colors.white : AppColors.darkText,
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

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading dashboard...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
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
            ElevatedButton(
              onPressed: () {
                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                final dashboardProvider = Provider.of<DashboardProvider>(
                  context,
                  listen: false,
                );

                if (authProvider.currentAccount?.accountId != null) {
                  dashboardProvider.loadDashboardData(
                    authProvider.currentAccount!.accountId!,
                  );
                }
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // Navigation methods
  void _navigateToDeposit(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.deposit);
  }

  void _navigateToWithdraw(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.withdraw);
  }

  void _navigateToTransfer(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.transfer);
  }

  void _navigateToTransactions(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.transactions);
  }

  void _navigateToQRCodes(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.qrDisplay);
  }

  // Helper methods
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
