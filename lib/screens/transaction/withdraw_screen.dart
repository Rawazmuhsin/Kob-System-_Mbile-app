// lib/screens/transaction/withdraw_screen.dart
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
import '../../widgets/transaction/withdraw_method_widget.dart';
import '../../services/qr_service.dart';
import '../../routes/app_routes.dart';
import '../../atm/atm_locations_screen.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<double> _quickAmounts = [10, 20, 50, 100, 200, 500];
  final List<String> _withdrawMethods = ['Admin Check', 'ATM'];

  String _selectedMethod = 'Admin Check';

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _setAmount(double amount) {
    _amountController.text = amount.toStringAsFixed(2);
  }

  void _setWithdrawMethod(String method) {
    setState(() {
      _selectedMethod = method;
    });
  }

  Future<void> _handleWithdraw() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if ATM is selected
    if (_selectedMethod == 'ATM') {
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ATMLocationsScreen()),
        );
      }
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
            : 'Withdrawal via $_selectedMethod';

    final success = await transactionProvider.makeWithdrawal(
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

    // Check if ATM is selected
    if (_selectedMethod == 'ATM') {
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ATMLocationsScreen()),
        );
      }
      return;
    }

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
            : 'Withdrawal via $_selectedMethod';

    // Generate QR data
    final qrData = QRService.generateTransactionQRData(
      accountId: account.accountId!,
      username: account.username,
      accountNumber: account.accountNumber ?? '',
      transactionType: 'withdrawal',
      amount: amount,
      description: description,
      method: _selectedMethod,
    );

    if (!mounted) return;

    // Navigate to QR display screen
    Navigator.pushNamed(
      context,
      AppRoutes.qrDisplay,
      arguments: {
        'qrData': qrData,
        'title': 'Withdrawal QR Code',
        'amount': amount,
        'description': description,
      },
    );
  }

  void _scanQRCode() {
    Navigator.pushNamed(
      context,
      AppRoutes.qrScanner,
      arguments: {'transactionType': 'withdrawal'},
    ).then((result) {
      if (result != null && result is Map<String, dynamic>) {
        if (result.containsKey('amount')) {
          _amountController.text = result['amount'].toString();
        }
        if (result.containsKey('description')) {
          _descriptionController.text = result['description'];
        }
        if (result.containsKey('method')) {
          _setWithdrawMethod(result['method']);
        }
      }
    });
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
                  Icons.check_circle,
                  color: AppColors.primaryGreen,
                  size: 28,
                ),
                SizedBox(width: 10),
                Text('Withdrawal Request'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You have successfully sent a request to withdraw \$${amount.toStringAsFixed(2)} from your account.',
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
                child: const Text('New Withdrawal'),
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
    final balance = dashboardProvider.currentAccount?.balance ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdraw Funds'),
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
                  // Balance display with red theme for withdrawals
                  BalanceDisplayWidget(
                    account: dashboardProvider.currentAccount,
                    primaryColor: const Color(0xFFE53935),
                    secondaryColor: const Color(0xFFD32F2F),
                  ),
                  const SizedBox(height: 24),

                  // Withdraw method selector
                  WithdrawMethodWidget(
                    methods: _withdrawMethods,
                    selectedMethod: _selectedMethod,
                    onMethodSelected: _setWithdrawMethod,
                    isDarkMode: isDarkMode,
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
                      if (amount > balance) {
                        return 'Amount exceeds available balance';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Quick amounts (disabled if exceeds balance)
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
                    label: 'Purpose (Optional)',
                    hintText: 'Enter a purpose for this withdrawal',
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
                    text: 'Withdraw Now',
                    onPressed: _handleWithdraw,
                    isLoading: transactionProvider.isLoading,
                    isPrimary: true,
                  ),
                  const SizedBox(height: 12),

                  // QR code buttons
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Generate QR',
                          onPressed: _showQRCode,
                          isPrimary: false,
                          icon: Icons.qr_code,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CustomButton(
                          text: 'Scan QR',
                          onPressed: _scanQRCode,
                          isPrimary: false,
                          icon: Icons.qr_code_scanner,
                        ),
                      ),
                    ],
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
