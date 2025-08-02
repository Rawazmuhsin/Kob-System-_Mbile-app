// lib/screens/transactions/transaction_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/navigation_drawer.dart';
import '../../widgets/transaction/transaction_filter_widget.dart';
import '../../services/export_service.dart';
import '../../models/transaction.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  String _selectedPeriod = 'All Time';
  String _selectedType = 'All Types';

  List<Transaction> _filterTransactions(List<Transaction> transactions) {
    if (transactions.isEmpty) return [];

    List<Transaction> filtered = transactions;

    // Filter by period
    if (_selectedPeriod != 'All Time') {
      final now = DateTime.now();
      if (_selectedPeriod == 'Today') {
        filtered =
            filtered
                .where(
                  (t) =>
                      t.transactionDate != null &&
                      t.transactionDate!.year == now.year &&
                      t.transactionDate!.month == now.month &&
                      t.transactionDate!.day == now.day,
                )
                .toList();
      } else if (_selectedPeriod == 'Last 7 Days') {
        final sevenDaysAgo = now.subtract(const Duration(days: 7));
        filtered =
            filtered
                .where(
                  (t) =>
                      t.transactionDate != null &&
                      t.transactionDate!.isAfter(sevenDaysAgo),
                )
                .toList();
      } else if (_selectedPeriod == 'Last 30 Days') {
        final thirtyDaysAgo = now.subtract(const Duration(days: 30));
        filtered =
            filtered
                .where(
                  (t) =>
                      t.transactionDate != null &&
                      t.transactionDate!.isAfter(thirtyDaysAgo),
                )
                .toList();
      }
    }

    // Filter by type
    if (_selectedType != 'All Types') {
      String filterType = _selectedType.toLowerCase();
      filtered =
          filtered.where((t) {
            final transactionType = t.transactionType?.toLowerCase() ?? '';
            switch (filterType) {
              case 'deposit':
                return transactionType == 'deposit';
              case 'withdrawal':
                return transactionType == 'withdrawal';
              case 'transfer':
                return transactionType == 'transfer';

              default:
                return true;
            }
          }).toList();
    }

    return filtered;
  }

  void _shareTransactions() async {
    final dashboardProvider = Provider.of<DashboardProvider>(
      context,
      listen: false,
    );
    final allTransactions = dashboardProvider.recentTransactions;
    final transactions = _filterTransactions(allTransactions);

    if (transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No transactions to share'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Prepare export data
    final account = dashboardProvider.currentAccount;
    final exportData = ExportData(
      title: 'Transaction History',
      subtitle: 'Recent transactions for ${account?.username ?? 'Account'}',
      userData: {
        'username': account?.username ?? '',
        'account_number': account?.accountNumber ?? '',
        'account_type': account?.accountType ?? '',
      },
      tableData:
          transactions
              .map(
                (t) => {
                  'transaction_id': t.transactionId?.toString() ?? '',
                  'transaction_type': t.transactionType ?? '',
                  'amount': t.amount.toStringAsFixed(2),
                  'transaction_date':
                      t.transactionDate?.toString().split(' ')[0] ?? '',
                  'description': t.description ?? '',
                  'status': t.status,
                },
              )
              .toList(),
      headers: [
        'Transaction ID',
        'Transaction Type',
        'Amount',
        'Transaction Date',
        'Description',
        'Status',
      ],
      summary: {
        'Total Transactions': transactions.length,
        'Total Amount': transactions
            .fold<double>(0.0, (sum, t) => sum + t.amount)
            .toStringAsFixed(2),
      },
    );

    // Export to PDF
    final pdfPath = await ExportService.instance.exportData(
      data: exportData,
      type: ExportType.pdf,
      customFileName: null,
    );

    if (pdfPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to generate PDF'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Share PDF file
    await Share.shareXFiles([
      XFile(pdfPath, mimeType: 'application/pdf'),
    ], subject: 'KÖB Banking - Transaction History PDF');
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      drawer: const AppNavigationDrawer(),
      appBar: AppBar(
        backgroundColor:
            isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        foregroundColor: isDarkMode ? Colors.white : AppColors.darkText,
        elevation: 0,
        title: Text(
          'Transaction History',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: isDarkMode ? Colors.white : AppColors.darkText,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              final dashboardProvider = Provider.of<DashboardProvider>(
                context,
                listen: false,
              );
              dashboardProvider.refreshDashboard();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          IconButton(
            onPressed: _shareTransactions,
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Share as PDF',
          ),
        ],
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, dashboardProvider, child) {
          if (dashboardProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          try {
            final transactions = dashboardProvider.recentTransactions;
            final filteredTransactions = _filterTransactions(transactions);

            return Column(
              children: [
                // Filter widget
                TransactionFilterWidget(
                  selectedPeriod: _selectedPeriod,
                  selectedType: _selectedType,
                  onPeriodChanged: (period) {
                    setState(() {
                      _selectedPeriod = period;
                    });
                  },
                  onTypeChanged: (type) {
                    setState(() {
                      _selectedType = type;
                    });
                  },
                ),
                if (filteredTransactions.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color:
                                isDarkMode
                                    ? Colors.white30
                                    : AppColors.lightText,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No transactions found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color:
                                  isDarkMode
                                      ? Colors.white70
                                      : AppColors.lightText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredTransactions.length,
                      itemBuilder: (context, index) {
                        try {
                          final transaction = filteredTransactions[index];
                          final isDebit =
                              transaction.transactionType != null &&
                              (transaction.transactionType == 'withdrawal' ||
                                  transaction.transactionType == 'transfer');

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
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
                                // Transaction Icon
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: (isDebit
                                            ? Colors.red
                                            : AppColors.primaryGreen)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    isDebit
                                        ? Icons.remove_circle_outline
                                        : Icons.add_circle_outline,
                                    color:
                                        isDebit
                                            ? Colors.red
                                            : AppColors.primaryGreen,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Transaction Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        transaction.description ??
                                            'Transaction',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              isDarkMode
                                                  ? Colors.white
                                                  : AppColors.darkText,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${transaction.transactionType?.toUpperCase() ?? 'UNKNOWN'} • ${transaction.transactionDate != null ? transaction.transactionDate!.toString().split(' ')[0] : 'N/A'}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              isDarkMode
                                                  ? Colors.white60
                                                  : AppColors.lightText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Amount and Status
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${isDebit ? '-' : '+'}${r'$'}${transaction.amount.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color:
                                            isDebit
                                                ? Colors.red
                                                : AppColors.primaryGreen,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(
                                          transaction.status,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        transaction.status.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: _getStatusColor(
                                            transaction.status,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        } catch (e) {
                          // Return empty container if there's an error with this transaction
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            child: Text('Error loading transaction: $e'),
                          );
                        }
                      },
                    ),
                  ),
              ],
            );
          } catch (e) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: isDarkMode ? Colors.white30 : AppColors.lightText,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading transactions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white70 : AppColors.lightText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    e.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white60 : AppColors.lightText,
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'completed':
        return AppColors.primaryGreen;
      case 'pending':
        return Colors.orange;
      case 'rejected':
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
