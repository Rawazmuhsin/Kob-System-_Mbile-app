// lib/screens/transaction/deposit_screen.dart
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
import '../../services/qr_service.dart';
import '../../routes/app_routes.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<double> _quickAmounts = [10, 20, 50, 100, 200, 500];

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _setAmount(double amount) {
    _amountController.text = amount.toStringAsFixed(2);
  }

  Future<void> _handleDeposit() async {
    if (!_formKey.currentState!.validate()) return;

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
            : 'Cash Deposit';

    final success = await transactionProvider.makeDeposit(
      accountId,
      amount,
      description,
    );

    if (success) {
      await dashboardProvider.refreshDashboard();
      if (!mounted) return;
      _showSuccessDialog(amount);
    }
  }

  void _showQRCode() async {
    if (!_formKey.currentState!.validate()) return;

    final dashboardProvider = Provider.of<DashboardProvider>(
      context,
      listen: false,
    );
    final account = dashboardProvider.currentAccount;
    if (account == null) {
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
            : 'Cash Deposit';

    // Generate QR data
    final qrData = QRService.generateTransactionQRData(
      accountId: account.accountId!,
      username: account.username,
      accountNumber: account.accountNumber ?? '',
      transactionType: 'deposit',
      amount: amount,
      description: description,
    );

    if (!mounted) return;

    // Navigate to QR display screen
    Navigator.pushNamed(
      context,
      AppRoutes.qrDisplay,
      arguments: {
        'qrData': qrData,
        'title': 'Deposit QR Code',
        'amount': amount,
        'description': description,
      },
    );
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
            title: const Row(
              children: [
                Icon(
                  Icons.timer,
                  color: Color.fromARGB(255, 25, 91, 69),
                  size: 28,
                ),
                SizedBox(width: 10),
                Text('Deposit Request Sent'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You have successfully send request to deposite \$${amount.toStringAsFixed(2)} to your account.',
                ),
                const SizedBox(height: 8),
                const Text('The transaction is being processed.'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('Back to Dashboard'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _amountController.clear();
                  _descriptionController.clear();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                ),
                child: const Text('New Deposit'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deposit Funds'),
        backgroundColor:
            isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        foregroundColor: isDarkMode ? Colors.white : AppColors.darkText,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors:
                isDarkMode ? AppColors.darkGradient : AppColors.lightGradient,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
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

                  // Amount input
                  AmountInputWidget(
                    controller: _amountController,
                    isDarkMode: isDarkMode,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      final amount = double.tryParse(
                        value.replaceAll(RegExp(r'[^\d\.]'), ''),
                      );
                      if (amount == null || amount <= 0) {
                        return 'Please enter a valid amount';
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
                  ),
                  const SizedBox(height: 24),

                  // Description
                  InputField(
                    controller: _descriptionController,
                    label: 'Description (Optional)',
                    hintText: 'Enter a description for this deposit',
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
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Text(
                        transactionProvider.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Action buttons
                  CustomButton(
                    text: 'Deposit Now',
                    onPressed: _handleDeposit,
                    isLoading: transactionProvider.isLoading,
                    isPrimary: true,
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: 'Generate QR Code',
                    onPressed: _showQRCode,
                    isPrimary: false,
                    icon: Icons.qr_code,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
