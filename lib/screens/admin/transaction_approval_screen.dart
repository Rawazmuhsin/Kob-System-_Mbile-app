// lib/screens/admin/transaction_approval_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/transaction.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/admin/admin_navigation_drawer.dart';
import '../../widgets/admin/pending_transaction_card.dart';

class TransactionApprovalScreen extends StatefulWidget {
  const TransactionApprovalScreen({super.key});

  @override
  State<TransactionApprovalScreen> createState() =>
      _TransactionApprovalScreenState();
}

class _TransactionApprovalScreenState extends State<TransactionApprovalScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);

      // Load data needed for this screen
      adminProvider.loadPendingTransactions();
      adminProvider.loadPendingTransactionsWithDetails();
      adminProvider.loadUserAccounts();
      adminProvider.loadTransactionStatusCounts();
    });
  }

  Future<void> _handleApprove(int transactionId) async {
    print('🔄 Screen: Attempting to approve transaction ID: $transactionId');

    if (transactionId <= 0) {
      print('❌ Screen: Invalid transaction ID: $transactionId');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid transaction ID'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    print('🔄 Screen: Calling adminProvider.approveTransaction...');
    final success = await adminProvider.approveTransaction(transactionId);

    if (success && mounted) {
      print('✅ Screen: Transaction approved successfully');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction approved successfully'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    } else if (!success && mounted) {
      print('❌ Screen: Transaction approval failed');
      final errorMessage =
          adminProvider.errorMessage ?? 'Failed to approve transaction';
      print('❌ Screen: Error message: $errorMessage');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _handleReject(int transactionId, String reason) async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final success = await adminProvider.rejectTransaction(
      transactionId,
      reason,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction rejected'),
          backgroundColor: Colors.orange,
        ),
      );
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            adminProvider.errorMessage ?? 'Failed to reject transaction',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Approvals'),
        backgroundColor:
            isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        foregroundColor: isDarkMode ? Colors.white : AppColors.darkText,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final provider = Provider.of<AdminProvider>(
                context,
                listen: false,
              );
              provider.loadPendingTransactions();
              provider.loadPendingTransactionsWithDetails();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      drawer: const AdminNavigationDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors:
                isDarkMode
                    ? [AppColors.darkSurface, AppColors.darkText]
                    : [AppColors.lightSurface, AppColors.primaryGreen],
          ),
        ),
        child: Consumer<AdminProvider>(
          builder: (context, adminProvider, child) {
            if (adminProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Decide which list to use based on what's available
            final useDetailedList =
                adminProvider.pendingTransactionsWithDetails.isNotEmpty;
            final pendingCount =
                useDetailedList
                    ? adminProvider.pendingTransactionsWithDetails.length
                    : adminProvider.pendingTransactions.length;

            if (pendingCount == 0) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 64,
                      color: isDarkMode ? Colors.white70 : Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No pending transactions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white : AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'All transactions have been processed',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                await adminProvider.loadPendingTransactions();
                await adminProvider.loadPendingTransactionsWithDetails();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: pendingCount,
                itemBuilder: (context, index) {
                  if (useDetailedList) {
                    // Use the detailed pending transactions
                    final pendingTx =
                        adminProvider.pendingTransactionsWithDetails[index];

                    // Convert to a Transaction for the card
                    final transaction = Transaction(
                      transactionId: pendingTx.transactionId,
                      accountId: pendingTx.accountId,
                      transactionType: pendingTx.transactionType,
                      amount: pendingTx.amount,
                      transactionDate: pendingTx.transactionDate,
                      description: pendingTx.description,
                      status: pendingTx.status,
                    );

                    return PendingTransactionCard(
                      transaction: transaction,
                      username: pendingTx.username,
                      accountNumber: pendingTx.accountNumber,
                      onApprove: _handleApprove,
                      onReject: _handleReject,
                      isProcessing: adminProvider.isProcessingApproval,
                    );
                  } else {
                    // Use the regular pending transactions
                    final transaction =
                        adminProvider.pendingTransactions[index];
                    final account = adminProvider.getUserById(
                      transaction.accountId,
                    );

                    return PendingTransactionCard(
                      transaction: transaction,
                      username: account?.username ?? 'Unknown User',
                      accountNumber:
                          account?.accountNumber ?? 'Unknown Account',
                      onApprove: _handleApprove,
                      onReject: _handleReject,
                      isProcessing: adminProvider.isProcessingApproval,
                    );
                  }
                },
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          final pendingCount =
              adminProvider.transactionStatusCounts['PENDING'] ?? 0;

          return Container(
            color: isDarkMode ? AppColors.darkSurface : Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Text(
              'Pending Transactions: $pendingCount',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color:
                    pendingCount > 0
                        ? Colors.amber
                        : (isDarkMode ? Colors.white70 : Colors.grey),
              ),
            ),
          );
        },
      ),
    );
  }
}
