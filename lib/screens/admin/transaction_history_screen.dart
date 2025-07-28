// lib/screens/admin/transaction_history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/admin/admin_navigation_drawer.dart';
import '../../widgets/admin/transaction_details_widget.dart';
import '../../models/transaction.dart';
import '../../models/account.dart';
import '../../routes/app_routes.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  List<Transaction> _transactions = [];
  Transaction? _selectedTransaction;
  Account? _selectedTransactionUser;
  Map<int, Account> _userAccounts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() => _isLoading = true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);

      Future.wait([
        adminProvider.loadAllTransactions(),
        adminProvider.loadUserAccounts(),
      ]).then((_) {
        setState(() {
          _userAccounts = {
            for (var account in adminProvider.userAccounts)
              account.accountId!: account,
          };
          _transactions = List.from(adminProvider.allTransactions);

          // Sort by date (newest first)
          _transactions.sort((a, b) {
            final aDate = a.transactionDate ?? DateTime.now();
            final bDate = b.transactionDate ?? DateTime.now();
            return bDate.compareTo(aDate);
          });

          _isLoading = false;
        });
      });
    });
  }

  void _showTransactionDetails(Transaction transaction) {
    setState(() {
      _selectedTransaction = transaction;
      _selectedTransactionUser = _userAccounts[transaction.accountId];
    });
  }

  void _closeTransactionDetails() {
    setState(() {
      _selectedTransaction = null;
      _selectedTransactionUser = null;
    });
  }

  void _navigateToManageTransactions() {
    Navigator.pushReplacementNamed(context, AppRoutes.adminTransactions);
  }

  String _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'orange';
      case 'approved':
        return 'green';
      case 'rejected':
        return 'red';
      default:
        return 'grey';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: _navigateToManageTransactions,
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to Manage Transactions',
        ),
        title: Text(
          _selectedTransaction == null
              ? 'Transaction History'
              : 'Transaction #${_selectedTransaction!.transactionId}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        actions: [
          if (_selectedTransaction == null) ...[
            IconButton(
              onPressed: _navigateToManageTransactions,
              icon: const Icon(Icons.settings),
              tooltip: 'Manage Transactions',
            ),
            IconButton(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
            ),
          ] else ...[
            IconButton(
              onPressed: _closeTransactionDetails,
              icon: const Icon(Icons.close),
              tooltip: 'Close Details',
            ),
          ],
        ],
      ),
      drawer: const AdminNavigationDrawer(
        selectedIndex: 2,
      ), // Set selectedIndex to 2 for Transactions
      body:
          _selectedTransaction != null
              ? TransactionDetailsWidget(
                transaction: _selectedTransaction!,
                userName: _selectedTransactionUser?.username,
                userEmail: _selectedTransactionUser?.email,
              )
              : _buildTransactionTable(isDarkMode),
    );
  }

  Widget _buildTransactionTable(bool isDarkMode) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_transactions.isEmpty) {
      return _buildEmptyState(isDarkMode);
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All Transactions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : AppColors.darkText,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      columnSpacing: 20,
                      horizontalMargin: 16,
                      headingRowColor: WidgetStateProperty.all(
                        isDarkMode
                            ? AppColors.primaryDark.withAlpha(51) // 0.2 opacity
                            : AppColors.primaryDark.withAlpha(
                              26,
                            ), // 0.1 opacity
                      ),
                      columns: [
                        DataColumn(
                          label: Text(
                            'ID',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  isDarkMode
                                      ? Colors.white
                                      : AppColors.darkText,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'User',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  isDarkMode
                                      ? Colors.white
                                      : AppColors.darkText,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Type',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  isDarkMode
                                      ? Colors.white
                                      : AppColors.darkText,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Amount',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  isDarkMode
                                      ? Colors.white
                                      : AppColors.darkText,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Status',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  isDarkMode
                                      ? Colors.white
                                      : AppColors.darkText,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Date',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  isDarkMode
                                      ? Colors.white
                                      : AppColors.darkText,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Action',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  isDarkMode
                                      ? Colors.white
                                      : AppColors.darkText,
                            ),
                          ),
                        ),
                      ],
                      rows:
                          _transactions.map((transaction) {
                            final user = _userAccounts[transaction.accountId];
                            final statusColor = _getStatusColor(
                              transaction.status,
                            );

                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    '#${transaction.transactionId ?? 'N/A'}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color:
                                          isDarkMode
                                              ? Colors.white70
                                              : AppColors.darkText,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    user?.username ?? 'Unknown',
                                    style: TextStyle(
                                      color:
                                          isDarkMode
                                              ? Colors.white70
                                              : AppColors.darkText,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    transaction.transactionType ?? 'N/A',
                                    style: TextStyle(
                                      color:
                                          isDarkMode
                                              ? Colors.white70
                                              : AppColors.darkText,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '\$${transaction.amount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color:
                                          isDarkMode
                                              ? Colors.white70
                                              : AppColors.darkText,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(
                                        statusColor == 'green'
                                            ? 0xFF10B981
                                            : statusColor == 'orange'
                                            ? 0xFFF59E0B
                                            : statusColor == 'red'
                                            ? 0xFFEF4444
                                            : 0xFF64748B,
                                      ).withAlpha(51), // 0.2 opacity
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      transaction.status,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(
                                          statusColor == 'green'
                                              ? 0xFF10B981
                                              : statusColor == 'orange'
                                              ? 0xFFF59E0B
                                              : statusColor == 'red'
                                              ? 0xFFEF4444
                                              : 0xFF64748B,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    transaction.transactionDate != null
                                        ? '${transaction.transactionDate!.year}-${transaction.transactionDate!.month.toString().padLeft(2, '0')}-${transaction.transactionDate!.day.toString().padLeft(2, '0')}'
                                        : 'N/A',
                                    style: TextStyle(
                                      color:
                                          isDarkMode
                                              ? Colors.white70
                                              : AppColors.darkText,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  ElevatedButton(
                                    onPressed:
                                        () => _showTransactionDetails(
                                          transaction,
                                        ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryDark,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      minimumSize: const Size(80, 32),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text('Details'),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_outlined,
            size: 64,
            color:
                isDarkMode
                    ? Colors.white.withAlpha(77) // 0.3 opacity
                    : AppColors.lightText.withAlpha(128), // 0.5 opacity
          ),
          const SizedBox(height: 16),
          Text(
            'No transaction history',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color:
                  isDarkMode
                      ? Colors.white.withAlpha(179) // 0.7 opacity
                      : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your transaction history will appear here',
            style: TextStyle(
              fontSize: 14,
              color:
                  isDarkMode
                      ? Colors.white.withAlpha(128) // 0.5 opacity
                      : AppColors.lightText.withAlpha(179), // 0.7 opacity
            ),
          ),
        ],
      ),
    );
  }
}
