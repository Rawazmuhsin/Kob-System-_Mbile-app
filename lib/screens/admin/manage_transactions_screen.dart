// lib/screens/admin/manage_transactions_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/admin/admin_navigation_drawer.dart';
import '../../widgets/admin/transaction_card_widget.dart';
import '../../widgets/admin/transaction_details_widget.dart';
import '../../widgets/admin/transactions_filter_widget.dart';
import '../../widgets/admin/transactions_stats_widget.dart';
import '../../widgets/export_dialog.dart';
import '../../widgets/dialog_box.dart';
import '../../widgets/input_field.dart';
import '../../models/transaction.dart';
import '../../models/account.dart';
import '../../services/export_service.dart';

class ManageTransactionsScreen extends StatefulWidget {
  const ManageTransactionsScreen({super.key});

  @override
  State<ManageTransactionsScreen> createState() =>
      _ManageTransactionsScreenState();
}

class _ManageTransactionsScreenState extends State<ManageTransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Transaction> _filteredTransactions = [];
  Transaction? _selectedTransaction;
  Account? _selectedTransactionUser;
  String _selectedStatus = 'all';
  String _selectedType = 'all';
  Map<int, Account> _userAccounts = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
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
          _filteredTransactions = List.from(adminProvider.allTransactions);
        });
        _applyFilters();
      });
    });
  }

  void _applyFilters() {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    setState(() {
      _filteredTransactions =
          adminProvider.allTransactions.where((transaction) {
            // Status filter
            if (_selectedStatus != 'all' &&
                transaction.status.toLowerCase() !=
                    _selectedStatus.toLowerCase()) {
              return false;
            }

            // Type filter
            if (_selectedType != 'all' &&
                transaction.transactionType?.toLowerCase() !=
                    _selectedType.toLowerCase()) {
              return false;
            }

            // Search filter
            if (_searchController.text.isNotEmpty) {
              final query = _searchController.text.toLowerCase();
              final user = _userAccounts[transaction.accountId];

              return (transaction.description?.toLowerCase().contains(query) ??
                      false) ||
                  transaction.amount.toString().contains(query) ||
                  (user?.username.toLowerCase().contains(query) ?? false) ||
                  (user?.email?.toLowerCase().contains(query) ?? false);
            }

            return true;
          }).toList();

      // Sort by date (newest first)
      _filteredTransactions.sort((a, b) {
        final aDate = a.transactionDate ?? DateTime.now();
        final bDate = b.transactionDate ?? DateTime.now();
        return bDate.compareTo(aDate);
      });
    });
  }

  void _onSearchChanged(String query) => _applyFilters();
  void _onStatusChanged(String status) {
    setState(() => _selectedStatus = status);
    _applyFilters();
  }

  void _onTypeChanged(String type) {
    setState(() => _selectedType = type);
    _applyFilters();
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = 'all';
      _selectedType = 'all';
      _searchController.clear();
    });
    _applyFilters();
  }

  void _onStatTap(String statType) {
    setState(() {
      _selectedStatus = statType;
      _selectedType = 'all';
      _searchController.clear();
    });
    _applyFilters();
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

  Future<void> _approveTransaction(Transaction transaction) async {
    try {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      final success = await adminProvider.approveTransaction(
        transaction.transactionId!,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction approved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData();
        _closeTransactionDetails();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _rejectTransaction(Transaction transaction) async {
    final reason = await _showRejectDialog();
    if (reason == null || reason.isEmpty) return;

    try {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      final success = await adminProvider.rejectTransaction(
        transaction.transactionId!,
        reason,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction rejected'),
            backgroundColor: Colors.orange,
          ),
        );
        _loadData();
        _closeTransactionDetails();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<String?> _showRejectDialog() async {
    final controller = TextEditingController();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Custom dialog using AlertDialog instead of DialogBox
    return showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor:
                isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
            title: const Text('Reject Transaction'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Please provide a reason for rejecting this transaction:',
                ),
                const SizedBox(height: 16),
                InputField(
                  controller: controller,
                  label: 'Rejection Reason',
                  hintText: 'Enter reason for rejection...',
                  isDarkMode: isDarkMode,
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, controller.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Reject'),
              ),
            ],
          ),
    );
  }

  Future<void> _exportTransactionsData() async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    final exportData = ExportData(
      title: 'Transaction Management Report',
      subtitle:
          'Complete list of all transactions with management capabilities',
      userData: {
        'admin_name': adminProvider.currentAdmin?.fullName ?? 'Administrator',
        'export_date': DateTime.now().toString().split(' ')[0],
        'total_transactions': _filteredTransactions.length.toString(),
        'filters_applied':
            '${_selectedStatus != 'all' ? 'Status: $_selectedStatus, ' : ''}${_selectedType != 'all' ? 'Type: $_selectedType, ' : ''}${_searchController.text.isNotEmpty ? 'Search: ${_searchController.text}' : ''}',
      },
      tableData:
          _filteredTransactions.map((transaction) {
            final user = _userAccounts[transaction.accountId];
            return {
              'transaction_id': '#${transaction.transactionId ?? 'N/A'}',
              'user_name': user?.username ?? 'Unknown User',
              'type': transaction.transactionType ?? 'Unknown',
              'amount': '\$${transaction.amount.toStringAsFixed(2)}',
              'status': transaction.status,
              'description': transaction.description ?? 'No description',
              'date':
                  transaction.transactionDate?.toString().split(' ')[0] ??
                  'N/A',
            };
          }).toList(),
      headers: [
        'Transaction ID',
        'User Name',
        'Type',
        'Amount',
        'Status',
        'Description',
        'Date',
      ],
      summary: _calculateTransactionsSummary(),
    );

    ExportDialogHelper.show(
      context: context,
      exportData: exportData,
      title: 'Export Transaction Management Data',
    );
  }

  Map<String, String> _calculateTransactionsSummary() {
    final totalAmount = _filteredTransactions.fold(
      0.0,
      (sum, t) => sum + t.amount,
    );
    final pendingCount =
        _filteredTransactions
            .where((t) => t.status.toLowerCase() == 'pending')
            .length;
    final approvedCount =
        _filteredTransactions
            .where((t) => t.status.toLowerCase() == 'approved')
            .length;
    final rejectedCount =
        _filteredTransactions
            .where((t) => t.status.toLowerCase() == 'rejected')
            .length;

    return {
      'Total Transactions': _filteredTransactions.length.toString(),
      'Total Volume': '\$${totalAmount.toStringAsFixed(2)}',
      'Pending': pendingCount.toString(),
      'Approved': approvedCount.toString(),
      'Rejected': rejectedCount.toString(),
      'Average Amount':
          _filteredTransactions.isNotEmpty
              ? '\$${(totalAmount / _filteredTransactions.length).toStringAsFixed(2)}'
              : '\$0.00',
    };
  }

  Map<String, dynamic> _getTransactionStats() {
    final allTransactions =
        Provider.of<AdminProvider>(context, listen: false).allTransactions;
    final totalVolume = allTransactions.fold(0.0, (sum, t) => sum + t.amount);
    final averageAmount =
        allTransactions.isNotEmpty ? totalVolume / allTransactions.length : 0.0;

    return {
      'total': allTransactions.length,
      'pending':
          allTransactions
              .where((t) => t.status.toLowerCase() == 'pending')
              .length,
      'approved':
          allTransactions
              .where((t) => t.status.toLowerCase() == 'approved')
              .length,
      'rejected':
          allTransactions
              .where((t) => t.status.toLowerCase() == 'rejected')
              .length,
      'total_volume': totalVolume,
      'average_amount': averageAmount,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      appBar: AppBar(
        backgroundColor:
            isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        foregroundColor: isDarkMode ? Colors.white : AppColors.darkText,
        elevation: 0,
        title: Text(
          _selectedTransaction == null
              ? 'Manage Transactions'
              : 'Transaction #${_selectedTransaction!.transactionId}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: isDarkMode ? Colors.white : AppColors.darkText,
          ),
        ),
        actions: [
          if (_selectedTransaction == null) ...[
            IconButton(
              onPressed:
                  () => Navigator.pushNamed(
                    context,
                    '/admin/transaction-history',
                  ),
              icon: const Icon(Icons.history),
              tooltip: 'View History',
            ),
            IconButton(
              onPressed: _exportTransactionsData,
              icon: const Icon(Icons.download),
              tooltip: 'Export Data',
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
      drawer: const AdminNavigationDrawer(),
      body:
          _selectedTransaction != null
              ? TransactionDetailsWidget(
                transaction: _selectedTransaction!,
                userName: _selectedTransactionUser?.username,
                userEmail: _selectedTransactionUser?.email,
              )
              : _buildManagementView(context, isDarkMode),
    );
  }

  Widget _buildManagementView(BuildContext context, bool isDarkMode) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        return Column(
          children: [
            // Use existing TransactionsStatsWidget
            TransactionsStatsWidget(
              stats: _getTransactionStats(),
              onStatTap: _onStatTap,
            ),

            // Use existing TransactionsFilterWidget
            TransactionsFilterWidget(
              searchController: _searchController,
              onSearchChanged: _onSearchChanged,
              selectedStatus: _selectedStatus,
              selectedType: _selectedType,
              onStatusChanged: _onStatusChanged,
              onTypeChanged: _onTypeChanged,
              totalTransactions: _filteredTransactions.length,
              onClearFilters: _clearFilters,
            ),

            // Connection to History Page
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      color:
                          isDarkMode
                              ? AppColors.primaryGreen.withOpacity(0.1)
                              : AppColors.primaryGreen.withOpacity(0.05),
                      child: InkWell(
                        onTap:
                            () => Navigator.pushNamed(
                              context,
                              '/admin/transaction-history',
                            ),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(
                                Icons.history,
                                color: AppColors.primaryGreen,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'View Complete Transaction History',
                                  style: TextStyle(
                                    color: AppColors.primaryGreen,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: AppColors.primaryGreen,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Transactions List
            Expanded(
              child:
                  adminProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _filteredTransactions.isEmpty
                      ? _buildEmptyState(isDarkMode)
                      : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = _filteredTransactions[index];
                          final user = _userAccounts[transaction.accountId];

                          return TransactionCardWidget(
                            transaction: transaction,
                            userName: user?.username,
                            onApprove:
                                transaction.status.toLowerCase() == 'pending'
                                    ? () => _approveTransaction(transaction)
                                    : null,
                            onReject:
                                transaction.status.toLowerCase() == 'pending'
                                    ? () => _rejectTransaction(transaction)
                                    : null,
                            onViewDetails:
                                () => _showTransactionDetails(transaction),
                          );
                        },
                      ),
            ),
          ],
        );
      },
    );
  }

  // Fix for the _buildEmptyState method in manage_transactions_screen.dart

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.manage_accounts_outlined,
              size: 48,
              color:
                  isDarkMode
                      ? Colors.white.withAlpha(77) // 0.3 opacity
                      : AppColors.lightText.withAlpha(128), // 0.5 opacity
            ),
            const SizedBox(height: 12),
            Text(
              'No transactions to manage',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color:
                    isDarkMode
                        ? Colors.white.withAlpha(179) // 0.7 opacity
                        : AppColors.lightText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Transactions requiring management will appear here',
              style: TextStyle(
                fontSize: 13,
                color:
                    isDarkMode
                        ? Colors.white.withAlpha(128) // 0.5 opacity
                        : AppColors.lightText.withAlpha(179), // 0.7 opacity
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed:
                  () => Navigator.pushNamed(
                    context,
                    '/admin/transaction-history',
                  ),
              icon: const Icon(Icons.history),
              label: const Text('View All Transactions'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
