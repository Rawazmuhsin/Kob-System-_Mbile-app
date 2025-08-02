// lib/screens/admin/export_center_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../core/constants.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/admin/admin_navigation_drawer.dart';
import '../../widgets/custom_button.dart';
import '../../services/export_service.dart';

class ExportCenterScreen extends StatefulWidget {
  const ExportCenterScreen({super.key});

  @override
  State<ExportCenterScreen> createState() => _ExportCenterScreenState();
}

class _ExportCenterScreenState extends State<ExportCenterScreen> {
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

  Future<void> _shareReportAsPDF(
    String reportType,
    AdminProvider adminProvider,
  ) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      ExportData exportData;

      switch (reportType) {
        case 'all_users':
          exportData = ExportData(
            title: 'All Users Report',
            subtitle: 'Complete user database with account details',
            userData: {
              'admin_name': adminProvider.currentAdmin?.fullName ?? 'Admin',
              'export_date': DateTime.now().toString(),
              'total_users': adminProvider.userAccounts.length,
            },
            tableData:
                adminProvider.userAccounts
                    .map(
                      (user) => {
                        'username': user.username,
                        'email': user.email ?? '',
                        'account_type': user.accountType,
                        'balance': user.balance.toString(),
                        'phone': user.phone,
                      },
                    )
                    .toList(),
            headers: ['Username', 'Email', 'Account Type', 'Balance', 'Phone'],
            summary: _getUserSummary(adminProvider),
          );
          break;

        case 'all_transactions':
          exportData = ExportData(
            title: 'All Transactions Report',
            subtitle: 'Complete transaction history and details',
            userData: {
              'admin_name': adminProvider.currentAdmin?.fullName ?? 'Admin',
              'export_date': DateTime.now().toString(),
              'total_transactions': adminProvider.allTransactions.length,
            },
            tableData:
                adminProvider.allTransactions
                    .map(
                      (transaction) => {
                        'id': transaction.transactionId.toString(),
                        'account_id': transaction.accountId.toString(),
                        'type': transaction.transactionType,
                        'amount': transaction.amount.toString(),
                        'status': transaction.status,
                        'date': transaction.transactionDate?.toString() ?? '',
                        'description': transaction.description ?? '',
                      },
                    )
                    .toList(),
            headers: [
              'ID',
              'Account ID',
              'Type',
              'Amount',
              'Status',
              'Date',
              'Description',
            ],
            summary: _getTransactionSummary(adminProvider),
          );
          break;

        case 'pending_approvals':
          exportData = ExportData(
            title: 'Pending Approvals Report',
            subtitle: 'Transactions awaiting administrative approval',
            userData: {
              'admin_name': adminProvider.currentAdmin?.fullName ?? 'Admin',
              'export_date': DateTime.now().toString(),
              'pending_count': adminProvider.pendingTransactions.length,
            },
            tableData:
                adminProvider.pendingTransactions
                    .map(
                      (transaction) => {
                        'id': transaction.transactionId.toString(),
                        'account_id': transaction.accountId.toString(),
                        'type': transaction.transactionType,
                        'amount': transaction.amount.toString(),
                        'date': transaction.transactionDate?.toString() ?? '',
                        'description': transaction.description ?? '',
                      },
                    )
                    .toList(),
            headers: [
              'ID',
              'Account ID',
              'Type',
              'Amount',
              'Date',
              'Description',
            ],
            summary: _getPendingSummary(adminProvider),
          );
          break;

        case 'dashboard_summary':
          final summary = adminProvider.getDashboardSummary();
          exportData = ExportData(
            title: 'Dashboard Summary Report',
            subtitle: 'Key metrics and statistics overview',
            userData: {
              'admin_name': adminProvider.currentAdmin?.fullName ?? 'Admin',
              'export_date': DateTime.now().toString(),
            },
            tableData: [
              {
                'metric': 'Total Accounts',
                'value': summary['total_accounts'].toString(),
              },
              {
                'metric': 'Total Balance',
                'value': adminProvider.formatCurrency(
                  summary['total_balance'].toDouble(),
                ),
              },
              {
                'metric': 'Total Transactions',
                'value': summary['total_transactions'].toString(),
              },
              {
                'metric': 'Pending Approvals',
                'value': summary['pending_approvals'].toString(),
              },
              {
                'metric': 'Approved Transactions',
                'value': summary['approved_transactions'].toString(),
              },
              {
                'metric': 'Rejected Transactions',
                'value': summary['rejected_transactions'].toString(),
              },
            ],
            headers: ['Metric', 'Value'],
            summary: {'generated_date': DateTime.now()},
          );
          break;

        default:
          if (mounted) Navigator.pop(context);
          return;
      }

      // Generate PDF file
      final pdfPath = await ExportService.instance.exportData(
        data: exportData,
        type: ExportType.pdf,
      );

      // Close loading indicator
      if (mounted) Navigator.pop(context);

      if (pdfPath != null) {
        // Share the PDF file
        await Share.shareXFiles([
          XFile(pdfPath),
        ], text: '${_getReportTitle(reportType)} - KOB Banking System');

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${_getReportTitle(reportType)} shared successfully!',
              ),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
        }
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to generate PDF. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Close loading indicator if still open
      if (mounted) Navigator.pop(context);

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getReportTitle(String reportType) {
    switch (reportType) {
      case 'all_users':
        return 'Users Report';
      case 'all_transactions':
        return 'Transactions Report';
      case 'pending_approvals':
        return 'Pending Approvals';
      case 'dashboard_summary':
        return 'Dashboard Summary';
      default:
        return 'Report';
    }
  }

  Map<String, dynamic> _getUserSummary(AdminProvider adminProvider) {
    final users = adminProvider.userAccounts;
    final totalBalance = users.fold(0.0, (sum, user) => sum + user.balance);
    final checkingCount =
        users.where((u) => u.accountType == 'Checking').length;
    final savingsCount = users.where((u) => u.accountType == 'Savings').length;

    return {
      'total_users': users.length,
      'total_balance': totalBalance,
      'checking_accounts': checkingCount,
      'savings_accounts': savingsCount,
      'export_date': DateTime.now(),
    };
  }

  Map<String, dynamic> _getTransactionSummary(AdminProvider adminProvider) {
    final transactions = adminProvider.allTransactions;
    final totalAmount = transactions.fold(0.0, (sum, t) => sum + t.amount);
    final pendingCount =
        transactions.where((t) => t.status == 'PENDING').length;
    final approvedCount =
        transactions.where((t) => t.status == 'APPROVED').length;

    return {
      'total_transactions': transactions.length,
      'total_volume': totalAmount,
      'pending_count': pendingCount,
      'approved_count': approvedCount,
      'export_date': DateTime.now(),
    };
  }

  Map<String, dynamic> _getPendingSummary(AdminProvider adminProvider) {
    final pending = adminProvider.pendingTransactions;
    final totalAmount = pending.fold(0.0, (sum, t) => sum + t.amount);

    return {
      'pending_count': pending.length,
      'total_pending_amount': totalAmount,
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
                  : _buildExportContent(context, adminProvider, isDarkMode),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDarkMode) {
    return AppBar(
      backgroundColor:
          isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      foregroundColor: isDarkMode ? Colors.white : AppColors.darkText,
      title: const Text('Export Center'),
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
          Text('Loading export options...'),
        ],
      ),
    );
  }

  Widget _buildExportContent(
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

          // Quick Export Section
          _buildQuickExportSection(adminProvider, isDarkMode),

          const SizedBox(height: 24),

          // Available Reports
          _buildAvailableReports(adminProvider, isDarkMode),

          const SizedBox(height: 24),
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
            child: const Icon(Icons.download, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Export Center',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Generate and download comprehensive reports',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickExportSection(
    AdminProvider adminProvider,
    bool isDarkMode,
  ) {
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
          Text(
            'Quick Export',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? Colors.white : AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Export commonly requested reports instantly',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.white70 : AppColors.lightText,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),

          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Share Users PDF',
                  onPressed:
                      () => _shareReportAsPDF('all_users', adminProvider),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Share Dashboard PDF',
                  onPressed:
                      () =>
                          _shareReportAsPDF('dashboard_summary', adminProvider),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableReports(AdminProvider adminProvider, bool isDarkMode) {
    final reports = [
      {
        'title': 'All Users Report',
        'subtitle': 'Complete user database with account details',
        'icon': Icons.people,
        'color': Colors.blue,
        'count': adminProvider.userAccounts.length,
        'type': 'all_users',
      },
      {
        'title': 'All Transactions Report',
        'subtitle': 'Complete transaction history',
        'icon': Icons.receipt_long,
        'color': Colors.green,
        'count': adminProvider.allTransactions.length,
        'type': 'all_transactions',
      },
      {
        'title': 'Pending Approvals Report',
        'subtitle': 'Transactions awaiting approval',
        'icon': Icons.pending_actions,
        'color': Colors.orange,
        'count': adminProvider.pendingTransactions.length,
        'type': 'pending_approvals',
      },
      {
        'title': 'Dashboard Summary',
        'subtitle': 'Key metrics and statistics overview',
        'icon': Icons.dashboard,
        'color': Colors.purple,
        'count': 6, // Number of metrics
        'type': 'dashboard_summary',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Reports',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDarkMode ? Colors.white : AppColors.darkText,
          ),
        ),
        const SizedBox(height: 16),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reports.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final report = reports[index];
            return _buildReportCard(report, adminProvider, isDarkMode);
          },
        ),
      ],
    );
  }

  Widget _buildReportCard(
    Map<String, dynamic> report,
    AdminProvider adminProvider,
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
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: (report['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(report['icon'], color: report['color'], size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report['title'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : AppColors.darkText,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  report['subtitle'],
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white70 : AppColors.lightText,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${report['count']} records',
                  style: TextStyle(
                    fontSize: 12,
                    color: report['color'],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: ElevatedButton(
              onPressed: () => _shareReportAsPDF(report['type'], adminProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor: report['color'],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                minimumSize: const Size(80, 36),
              ),
              child: const Text('Export', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}
