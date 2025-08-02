// lib/screens/transaction/transfer_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/input_field.dart';
import '../../widgets/transaction/amount_input_widget.dart';
import '../../widgets/transaction/quick_amount_widget.dart';
import '../../widgets/transaction/balance_display_widget.dart';
import '../../widgets/transaction/recipient_search_widget.dart';
import '../../models/account.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<double> _quickAmounts = [10, 20, 50, 100, 200, 500];

  Account? _selectedRecipient;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _setAmount(double amount) {
    _amountController.text = amount.toStringAsFixed(2);
  }

  void _onRecipientSelected(Account recipient) {
    setState(() {
      _selectedRecipient = recipient;
    });
  }

  void _clearRecipient() {
    setState(() {
      _selectedRecipient = null;
    });
  }

  Future<void> _handleTransfer() async {
    if (!_formKey.currentState!.validate() || _selectedRecipient == null) {
      return;
    }

    final dashboardProvider = Provider.of<DashboardProvider>(
      context,
      listen: false,
    );
    final transactionProvider = Provider.of<TransactionProvider>(
      context,
      listen: false,
    );

    final accountId = dashboardProvider.currentAccount?.accountId;
    if (accountId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Account information not available. Please try again.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final amount = double.parse(
      _amountController.text.replaceAll(RegExp(r'[^\d\.]'), ''),
    );
    final description =
        _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : 'Transfer to ${_selectedRecipient!.username}';

    final success = await transactionProvider.makeTransfer(
      fromAccountId: accountId,
      toAccountId: _selectedRecipient!.accountId!,
      amount: amount,
      description: description,
    );

    if (success) {
      await dashboardProvider.refreshDashboard();
      if (!mounted) return;
      _showSuccessDialog(amount);
    }
  }

  void _showSuccessDialog(double amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppColors.primaryGreen,
                  size: 28,
                ),
                const SizedBox(width: 10),
                const Text('Transfer Successful'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You have successfully transferred \$${amount.toStringAsFixed(2)} to ${_selectedRecipient?.username}.',
                ),
                const SizedBox(height: 8),
                const Text('The transaction is being processed.'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Go back to dashboard
                },
                child: const Text('Done'),
              ),
            ],
          ),
    );
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
        title: const Text('Transfer Money'),
        elevation: 0,
      ),
      body: Consumer2<DashboardProvider, TransactionProvider>(
        builder: (context, dashboardProvider, transactionProvider, child) {
          final balance = dashboardProvider.currentAccount?.balance ?? 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Balance display
                  BalanceDisplayWidget(
                    account: dashboardProvider.currentAccount,
                    primaryColor: AppColors.primaryGreen,
                    secondaryColor: AppColors.primaryDark,
                  ),
                  const SizedBox(height: 24),

                  // Recipient search section
                  RecipientSearchWidget(
                    selectedRecipient: _selectedRecipient,
                    onRecipientSelected: _onRecipientSelected,
                    onClearRecipient: _clearRecipient,
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 24),

                  // Amount input (only show if recipient is selected)
                  if (_selectedRecipient != null) ...[
                    AmountInputWidget(
                      controller: _amountController,
                      isDarkMode: isDarkMode,
                      validator: (value) {
                        final amount = double.tryParse(
                          value?.replaceAll(RegExp(r'[^\d\.]'), '') ?? '',
                        );
                        if (amount == null || amount <= 0) {
                          return 'Please enter a valid amount';
                        }
                        if (amount > balance) {
                          return 'Amount exceeds available balance';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Quick amounts
                    QuickAmountWidget(
                      amounts: _quickAmounts,
                      onAmountSelected: _setAmount,
                      isDarkMode: isDarkMode,
                      availableBalance: balance,
                    ),
                    const SizedBox(height: 24),

                    // Description
                    InputField(
                      controller: _descriptionController,
                      label: 'Description (Optional)',
                      hintText: 'Enter transfer description',
                      isDarkMode: isDarkMode,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24),

                    // Error message
                    if (transactionProvider.errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          transactionProvider.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Transfer button
                    CustomButton(
                      text: 'Transfer Now',
                      onPressed: _handleTransfer,
                      isLoading: transactionProvider.isLoading,
                      isPrimary: true,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
