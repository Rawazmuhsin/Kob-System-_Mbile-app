// lib/screens/admin/transaction_analytics_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/admin/admin_navigation_drawer.dart';
import '../../widgets/admin/chart_widget.dart';
import '../../widgets/export_dialog.dart';
import '../../widgets/custom_button.dart';
import '../../services/export_service.dart';

class TransactionAnalyticsScreen extends StatefulWidget {
  const TransactionAnalyticsScreen({super.key});

  @override
  State<TransactionAnalyticsScreen> createState() =>
      _TransactionAnalyticsScreenState();
}

class _TransactionAnalyticsScreenState
    extends State<TransactionAnalyticsScreen> {
  String _selectedPeriod = 'month';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      adminProvider.loadAllTransactions();
    });
  }

  void _exportData() {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final exportData = ExportData(
      title: 'Transaction Analytics Report',
      subtitle: 'Comprehensive transaction analysis and trends',
      userData: {
        'admin_name': adminProvider.currentAdmin?.fullName ?? 'Admin',
        'export_date': DateTime.now().toString(),
        'period': _selectedPeriod,
        'total_transactions': adminProvider.allTransactions.length,
      },
      tableData:
          adminProvider.allTransactions.map((transaction) {
            return {
              'id': transaction.transactionId.toString(),
              'type': transaction.transactionType,
              'amount': transaction.amount.toString(),
              'status': transaction.status,
              'date': transaction.transactionDate?.toString() ?? '',
              'description': transaction.description ?? '',
            };
          }).toList(),
      headers: ['ID', 'Type', 'Amount', 'Status', 'Date', 'Description'],
      summary: _generateSummary(adminProvider.allTransactions),
      period: _selectedPeriod,
    );

    ExportDialogHelper.show(
      context: context,
      exportData: exportData,
      title: 'Export Transaction Analytics',
    );
  }

  Map<String, dynamic> _generateSummary(List transactions) {
    final totalTransactions = transactions.length;
    final totalAmount = transactions.fold(0.0, (sum, t) => sum + t.amount);
    final depositCount =
        transactions.where((t) => t.transactionType == 'deposit').length;
    final withdrawalCount =
        transactions.where((t) => t.transactionType == 'withdrawal').length;
    final transferCount =
        transactions.where((t) => t.transactionType == 'transfer').length;

    return {
      'total_transactions': totalTransactions,
      'total_volume': totalAmount,
      'deposits': depositCount,
      'withdrawals': withdrawalCount,
      'transfers': transferCount,
      'average_amount':
          totalTransactions > 0 ? totalAmount / totalTransactions : 0.0,
      'period': _selectedPeriod,
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
      title: const Text('Transaction Analytics'),
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
          Text('Loading analytics...'),
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
          // Header with period selector
          _buildHeader(isDarkMode),

          const SizedBox(height: 24),

          // Overview Cards
          _buildOverviewCards(adminProvider, isDarkMode),

          const SizedBox(height: 24),

          // Transaction Volume Chart
          ChartWidget(
            title: 'Transaction Volume Trend',
            subtitle: 'Daily transaction counts over time',
            data: _getVolumeChartData(adminProvider.allTransactions),
            type: ChartType.line,
            primaryColor: AppColors.primaryGreen,
            height: 200,
          ),

          const SizedBox(height: 24),

          // Transaction Types Distribution
          ChartWidget(
            title: 'Transaction Types',
            subtitle: 'Distribution by transaction type',
            data: _getTypeChartData(adminProvider.allTransactions),
            type: ChartType.pie,
            primaryColor: AppColors.primaryGreen,
            height: 250,
          ),

          const SizedBox(height: 24),

          // Status Distribution
          ChartWidget(
            title: 'Transaction Status',
            subtitle: 'Current status distribution',
            data: _getStatusChartData(adminProvider.allTransactions),
            type: ChartType.bar,
            primaryColor: Colors.blue,
            height: 200,
          ),

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transaction Analytics',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Detailed insights into transaction patterns',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Period Selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Text(
                    'Period: ',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                ...['week', 'month', 'quarter', 'year'].map((period) {
                  final isSelected = _selectedPeriod == period;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedPeriod = period),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? Colors.white.withOpacity(0.2)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        period.toUpperCase(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCards(AdminProvider adminProvider, bool isDarkMode) {
    final transactions = adminProvider.allTransactions;
    final totalVolume = transactions.fold(0.0, (sum, t) => sum + t.amount);
    final avgAmount =
        transactions.isNotEmpty ? totalVolume / transactions.length : 0.0;
    final todayCount =
        transactions.where((t) {
          final today = DateTime.now();
          final transactionDate = t.transactionDate;
          return transactionDate != null &&
              transactionDate.year == today.year &&
              transactionDate.month == today.month &&
              transactionDate.day == today.day;
        }).length;

    return Row(
      children: [
        Expanded(
          child: _buildOverviewCard(
            'Total Volume',
            '\$${totalVolume.toStringAsFixed(0)}',
            Icons.account_balance_wallet,
            Colors.green,
            isDarkMode,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildOverviewCard(
            'Average Amount',
            '\$${avgAmount.toStringAsFixed(2)}',
            Icons.calculate,
            Colors.blue,
            isDarkMode,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildOverviewCard(
            'Today\'s Count',
            todayCount.toString(),
            Icons.today,
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

  List<ChartData> _getVolumeChartData(List transactions) {
    // Group by day for the last 7 days
    final now = DateTime.now();
    final data = <ChartData>[];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayTransactions =
          transactions.where((t) {
            final transactionDate = t.transactionDate;
            return transactionDate != null &&
                transactionDate.year == date.year &&
                transactionDate.month == date.month &&
                transactionDate.day == date.day;
          }).length;

      data.add(
        ChartData(
          label: '${date.day}/${date.month}',
          value: dayTransactions.toDouble(),
        ),
      );
    }

    return data;
  }

  List<ChartData> _getTypeChartData(List transactions) {
    final typeCount = <String, int>{};

    for (final transaction in transactions) {
      final type = transaction.transactionType ?? 'Unknown';
      typeCount[type] = (typeCount[type] ?? 0) + 1;
    }

    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple];
    int colorIndex = 0;

    return typeCount.entries.map((entry) {
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      return ChartData(
        label: entry.key.toUpperCase(),
        value: entry.value.toDouble(),
        color: color,
      );
    }).toList();
  }

  List<ChartData> _getStatusChartData(List transactions) {
    final statusCount = <String, int>{};

    for (final transaction in transactions) {
      final status = transaction.status ?? 'Unknown';
      statusCount[status] = (statusCount[status] ?? 0) + 1;
    }

    final statusColors = {
      'PENDING': Colors.orange,
      'APPROVED': Colors.green,
      'REJECTED': Colors.red,
      'COMPLETED': Colors.blue,
    };

    return statusCount.entries.map((entry) {
      return ChartData(
        label: entry.key,
        value: entry.value.toDouble(),
        color: statusColors[entry.key] ?? Colors.grey,
      );
    }).toList();
  }
}
