// lib/atm/atm_withdraw_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/atm_location.dart';
import '../models/transaction.dart';
import '../providers/auth_provider.dart';
import '../core/db_helper.dart';
import '../utils/database_debug_util.dart';

class ATMWithdrawScreen extends StatefulWidget {
  final ATMLocation atmLocation;

  const ATMWithdrawScreen({super.key, required this.atmLocation});

  @override
  State<ATMWithdrawScreen> createState() => _ATMWithdrawScreenState();
}

class _ATMWithdrawScreenState extends State<ATMWithdrawScreen> {
  final TextEditingController _amountController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;

  // Quick amount options
  final List<double> _quickAmounts = [20, 50, 100, 200, 500, 1000];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _selectQuickAmount(double amount) {
    _amountController.text = amount.toStringAsFixed(0);
  }

  Future<void> _processWithdrawal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final account = authProvider.currentAccount;
    if (account == null) {
      _showErrorMessage('Authentication error. Please login again.');
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showErrorMessage('Please enter a valid amount.');
      return;
    }

    if (amount > account.balance) {
      _showErrorMessage(
        'Insufficient funds. Your balance is \$${account.balance.toStringAsFixed(2)}',
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Create ATM withdrawal transaction
      final transaction = Transaction(
        accountId: account.accountId!,
        amount: amount,
        transactionType: 'withdrawal',
        description: 'ATM Withdrawal - ${widget.atmLocation.name}',
        status: 'COMPLETED', // ATM withdrawals are processed immediately
        transactionDate: DateTime.now(),
      );

      print('=== ATM Withdrawal Debug ===');
      print('Account ID: ${account.accountId}');
      print('Current Balance: ${account.balance}');
      print('Withdrawal Amount: $amount');
      print('Transaction Data: ${transaction.toMap()}');

      // Debug: Print account info before transaction
      await DatabaseDebugUtil.printAccountInfo(account.accountId!);

      // Use database transaction for atomicity
      final dbHelper = DatabaseHelper();
      final db = await dbHelper.database;

      await db.transaction((txn) async {
        // Insert transaction record
        final transactionId = await txn.insert(
          'transactions',
          transaction.toMap(),
        );
        print('Transaction inserted with ID: $transactionId');

        // Update account balance
        final updateCount = await txn.rawUpdate(
          'UPDATE accounts SET balance = balance - ? WHERE account_id = ?',
          [amount, account.accountId],
        );
        print('Account balance updated, rows affected: $updateCount');
      });

      // Refresh account balance in provider
      await _refreshAccountBalance(authProvider, account.accountId!);

      print('ATM withdrawal completed successfully');

      // Debug: Print account info after transaction
      await DatabaseDebugUtil.printAccountInfo(account.accountId!);

      // Show success
      if (mounted) {
        _showSuccessDialog(amount);
      }
    } catch (e) {
      print('❌ ATM Withdrawal Error: $e');
      if (mounted) {
        _showErrorMessage('Transaction failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _refreshAccountBalance(
    AuthProvider authProvider,
    int accountId,
  ) async {
    try {
      print('=== Refreshing Account Balance ===');
      print('Account ID: $accountId');

      final dbHelper = DatabaseHelper();
      final db = await dbHelper.database;

      final result = await db.query(
        'accounts',
        where: 'account_id = ?',
        whereArgs: [accountId],
        limit: 1,
      );

      if (result.isNotEmpty) {
        final updatedBalance = (result.first['balance'] as num).toDouble();
        print('Updated balance from DB: $updatedBalance');
        print(
          'Previous balance in provider: ${authProvider.currentAccount?.balance}',
        );

        // Update the account in the provider
        final updatedAccount = authProvider.currentAccount!.copyWith(
          balance: updatedBalance,
        );

        // Update the provider
        authProvider.updateCurrentAccount(updatedAccount);
        print('✅ Account balance updated in provider: $updatedBalance');
      } else {
        print('❌ No account found with ID: $accountId');
      }
    } catch (e) {
      print('❌ Error refreshing account balance: $e');
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessDialog(double amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 40,
                  color: Colors.green[600],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Withdrawal Successful',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Amount:'),
                        Text(
                          '\$${amount.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('ATM:'),
                        Flexible(
                          child: Text(
                            widget.atmLocation.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Transaction ID:'),
                        Text(
                          'ATM${DateTime.now().millisecondsSinceEpoch}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Please collect your cash from the ATM dispenser.',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog first
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/dashboard', (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Return to Dashboard'),
              ),
            ),
          ],
        );
      },
    );
  }

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an amount';
    }

    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid number';
    }

    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }

    if (amount < 10) {
      return 'Minimum withdrawal amount is \$10';
    }

    if (amount > 5000) {
      return 'Maximum withdrawal amount is \$5,000';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final account = authProvider.currentAccount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ATM Withdrawal'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // ATM Info
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.atm, size: 40, color: Colors.blue[800]),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.atmLocation.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Connected • Ready for withdrawal',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.green[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Account Balance
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue[700]!, Colors.blue[900]!],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Available Balance',
                          style: TextStyle(
                            color: Colors.blue[100],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$${account?.balance.toStringAsFixed(2) ?? '0.00'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Quick Amount Buttons
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Quick Select',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        _quickAmounts.map((amount) {
                          return SizedBox(
                            width: (MediaQuery.of(context).size.width - 48) / 3,
                            child: OutlinedButton(
                              onPressed: () => _selectQuickAmount(amount),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blue[800],
                                side: BorderSide(color: Colors.blue[300]!),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: Text('\$${amount.toStringAsFixed(0)}'),
                            ),
                          );
                        }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Amount Input
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    validator: _validateAmount,
                    decoration: InputDecoration(
                      labelText: 'Enter Amount',
                      hintText: 'Enter withdrawal amount',
                      prefixText: '\$ ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue[800]!),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Withdraw Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _processWithdrawal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                          _isProcessing
                              ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text('Processing...'),
                                ],
                              )
                              : const Text(
                                'Process Withdrawal',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
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
