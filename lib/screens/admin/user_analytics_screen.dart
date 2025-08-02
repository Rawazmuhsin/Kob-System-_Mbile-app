// lib/screens/admin/user_analytics_screen.dart
// FIXED VERSION - Copy this to replace your current file

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/admin/admin_navigation_drawer.dart';
import '../../widgets/admin/chart_widget.dart';
import '../../widgets/export_dialog.dart';
import '../../widgets/custom_button.dart';
import '../../services/export_service.dart';

class UserAnalyticsScreen extends StatefulWidget {
  const UserAnalyticsScreen({super.key});

  @override
  State<UserAnalyticsScreen> createState() => _UserAnalyticsScreenState();
}

class _UserAnalyticsScreenState extends State<UserAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      Future.wait([
        adminProvider.loadUserAccounts(),
        adminProvider.loadAllTransactions(),
      ]);
    });
  }

  void _exportData() {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final exportData = ExportData(
      title: 'User Analytics Report',
      subtitle: 'User behavior and account insights analysis',
      userData: {
        'admin_name': adminProvider.currentAdmin?.fullName ?? 'Admin',
        'export_date': DateTime.now().toString(),
        'total_users': adminProvider.userAccounts.length,
        'active_users': _getActiveUsersCount(adminProvider),
      },
      tableData:
          adminProvider.userAccounts.map((user) {
            final userTransactions =
                adminProvider.allTransactions
                    .where((t) => t.accountId == user.accountId)
                    .length;
            return {
              'username': user.username,
              'email': user.email ?? '',
              'account_type': user.accountType,
              'balance': user.balance.toString(),
              'transaction_count': userTransactions.toString(),
              'phone': user.phone,
            };
          }).toList(),
      headers: [
        'Username',
        'Email',
        'Account Type',
        'Balance',
        'Transactions',
        'Phone',
      ],
      summary: _generateUserSummary(adminProvider),
    );

    ExportDialogHelper.show(
      context: context,
      exportData: exportData,
      title: 'Export User Analytics',
    );
  }

  Map<String, dynamic> _generateUserSummary(AdminProvider adminProvider) {
    final users = adminProvider.userAccounts;
    final transactions = adminProvider.allTransactions;

    final totalUsers = users.length;
    final totalBalance = users.fold(0.0, (sum, user) => sum + user.balance);
    final checkingAccounts =
        users.where((u) => u.accountType == 'Checking').length;
    final savingsAccounts =
        users.where((u) => u.accountType == 'Savings').length;
    final avgBalance = totalUsers > 0 ? totalBalance / totalUsers : 0.0;
    final activeUsers = _getActiveUsersCount(adminProvider);

    return {
      'total_users': totalUsers,
      'total_balance': totalBalance,
      'checking_accounts': checkingAccounts,
      'savings_accounts': savingsAccounts,
      'average_balance': avgBalance,
      'active_users': activeUsers,
      'total_transactions': transactions.length,
      'export_date': DateTime.now(),
    };
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
                  : _buildAnalyticsContent(context, adminProvider, isDarkMode),
          floatingActionButton: FloatingActionButton(
            onPressed: _exportData,
            backgroundColor: AppColors.primaryGreen,
            child: const Icon(Icons.download, color: Colors.white),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDarkMode) {
    return AppBar(
      backgroundColor:
          isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      foregroundColor: isDarkMode ? Colors.white : AppColors.darkText,
      title: const Text('User Analytics'),
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
          Text('Loading user analytics...'),
        ],
      ),
    );
  }

  Widget _buildAnalyticsContent(
    BuildContext context,
    AdminProvider adminProvider,
    bool isDarkMode,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(isDarkMode),

          const SizedBox(height: 24),

          // Overview Cards
          _buildOverviewCards(adminProvider, isDarkMode),

          const SizedBox(height: 24),

          // Account Types Distribution
          ChartWidget(
            title: 'Account Types Distribution',
            subtitle: 'Breakdown by account type',
            data: _getAccountTypeChartData(adminProvider.userAccounts),
            type: ChartType.pie,
            primaryColor: AppColors.primaryGreen,
            height: 250,
          ),

          const SizedBox(height: 24),

          // Balance Distribution
          ChartWidget(
            title: 'Balance Ranges',
            subtitle: 'User distribution by balance range',
            data: _getBalanceRangeChartData(adminProvider.userAccounts),
            type: ChartType.bar,
            primaryColor: Colors.blue,
            height: 200,
          ),

          const SizedBox(height: 24),

          // User Activity
          ChartWidget(
            title: 'User Activity Levels',
            subtitle: 'Based on transaction frequency',
            data: _getUserActivityChartData(adminProvider),
            type: ChartType.bar,
            primaryColor: Colors.green,
            height: 200,
          ),

          const SizedBox(height: 24),

          // Top Users List
          _buildTopUsersList(adminProvider, isDarkMode),

          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primaryGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(Icons.people_alt, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User Analytics',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'User behavior and account insights',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCards(AdminProvider adminProvider, bool isDarkMode) {
    final users = adminProvider.userAccounts;
    final totalBalance = users.fold(0.0, (sum, user) => sum + user.balance);
    final avgBalance = users.isNotEmpty ? totalBalance / users.length : 0.0;
    final activeUsers = _getActiveUsersCount(adminProvider);

    return Row(
      children: [
        Expanded(
          child: _buildOverviewCard(
            'Total Users',
            users.length.toString(),
            Icons.people,
            Colors.blue,
            isDarkMode,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildOverviewCard(
            'Active Users',
            activeUsers.toString(),
            Icons.person_outline,
            Colors.green,
            isDarkMode,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildOverviewCard(
            'Avg Balance',
            '\$${avgBalance.toStringAsFixed(0)}',
            Icons.account_balance_wallet,
            Colors.orange,
            isDarkMode,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard(
    String title,
    String value,
    IconData icon,
    Color color,
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTopUsersList(AdminProvider adminProvider, bool isDarkMode) {
    final sortedUsers = List.from(adminProvider.userAccounts);
    sortedUsers.sort((a, b) => b.balance.compareTo(a.balance));
    final topUsers = sortedUsers.take(5).toList();

    return Container(
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
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.star, color: Colors.purple, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Top Users by Balance',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : AppColors.darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: topUsers.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final user = topUsers[index];
              final userTransactions =
                  adminProvider.allTransactions
                      .where((t) => t.accountId == user.accountId)
                      .length;

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      isDarkMode
                          ? Colors.white.withOpacity(0.02)
                          : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: _getUserColor(index),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.username,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color:
                                  isDarkMode
                                      ? Colors.white
                                      : AppColors.darkText,
                            ),
                          ),
                          Text(
                            '${user.accountType} • $userTransactions transactions',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  isDarkMode
                                      ? Colors.white70
                                      : AppColors.lightText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '\$${user.balance.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<ChartData> _getAccountTypeChartData(List userAccounts) {
    final typeCount = <String, int>{};

    for (final user in userAccounts) {
      final type = user.accountType;
      typeCount[type] = (typeCount[type] ?? 0) + 1;
    }

    final colors = [AppColors.primaryGreen, Colors.blue, Colors.orange];
    int colorIndex = 0;

    return typeCount.entries.map((entry) {
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      return ChartData(
        label: entry.key,
        value: entry.value.toDouble(),
        color: color,
      );
    }).toList();
  }

  List<ChartData> _getBalanceRangeChartData(List userAccounts) {
    final ranges = {
      '0-100': 0,
      '100-500': 0,
      '500-1K': 0,
      '1K-5K': 0,
      '5K+': 0,
    };

    for (final user in userAccounts) {
      final balance = user.balance;
      if (balance <= 100) {
        ranges['0-100'] = (ranges['0-100'] ?? 0) + 1;
      } else if (balance <= 500) {
        ranges['100-500'] = (ranges['100-500'] ?? 0) + 1;
      } else if (balance <= 1000) {
        ranges['500-1K'] = (ranges['500-1K'] ?? 0) + 1;
      } else if (balance <= 5000) {
        ranges['1K-5K'] = (ranges['1K-5K'] ?? 0) + 1;
      } else {
        ranges['5K+'] = (ranges['5K+'] ?? 0) + 1;
      }
    }

    return ranges.entries.map((entry) {
      return ChartData(
        label: entry.key,
        value: entry.value.toDouble(),
        color: Colors.blue.withOpacity(0.7),
      );
    }).toList();
  }

  List<ChartData> _getUserActivityChartData(AdminProvider adminProvider) {
    final users = adminProvider.userAccounts;
    final transactions = adminProvider.allTransactions;

    final activityLevels = {'Inactive': 0, 'Low': 0, 'Medium': 0, 'High': 0};

    for (final user in users) {
      final userTransactionCount =
          transactions.where((t) => t.accountId == user.accountId).length;

      if (userTransactionCount == 0) {
        activityLevels['Inactive'] = (activityLevels['Inactive'] ?? 0) + 1;
      } else if (userTransactionCount <= 5) {
        activityLevels['Low'] = (activityLevels['Low'] ?? 0) + 1;
      } else if (userTransactionCount <= 15) {
        activityLevels['Medium'] = (activityLevels['Medium'] ?? 0) + 1;
      } else {
        activityLevels['High'] = (activityLevels['High'] ?? 0) + 1;
      }
    }

    final colors = [Colors.grey, Colors.orange, Colors.blue, Colors.green];
    int colorIndex = 0;

    return activityLevels.entries.map((entry) {
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      return ChartData(
        label: entry.key,
        value: entry.value.toDouble(),
        color: color,
      );
    }).toList();
  }

  int _getActiveUsersCount(AdminProvider adminProvider) {
    final users = adminProvider.userAccounts;
    final transactions = adminProvider.allTransactions;
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

    return users.where((user) {
      return transactions.any((transaction) {
        return transaction.accountId == user.accountId &&
            transaction.transactionDate != null &&
            transaction.transactionDate!.isAfter(thirtyDaysAgo);
      });
    }).length;
  }

  Color _getUserColor(int index) {
    final colors = [
      Colors.amber,
      Colors.grey,
      Colors.orange,
      Colors.blue,
      Colors.purple,
    ];
    return colors[index % colors.length];
  }
}
