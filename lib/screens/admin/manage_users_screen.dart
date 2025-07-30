// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/admin/admin_navigation_drawer.dart';
import '../../widgets/admin/user_card_widget.dart';
import '../../widgets/admin/user_details_widget.dart';
import '../../widgets/admin/user_transactions_widget.dart';
import '../../widgets/admin/users_search_widget.dart';
import '../../widgets/export_dialog.dart';
import '../../widgets/dialog_box.dart';
import '../../widgets/input_field.dart';
import '../../models/account.dart';
import '../../models/transaction.dart';
import '../../services/export_service.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Account> _filteredUsers = [];
  Account? _selectedUser;
  List<Transaction> _userTransactions = [];
  bool _isLoadingTransactions = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadUsers() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      adminProvider.loadUserAccounts().then((_) {
        setState(() {
          _filteredUsers = List.from(adminProvider.userAccounts);
        });
      });
    });
  }

  void _searchUsers(String query) {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = List.from(adminProvider.userAccounts);
      } else {
        _filteredUsers =
            adminProvider.userAccounts.where((user) {
              return user.username.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  (user.email?.toLowerCase().contains(query.toLowerCase()) ??
                      false) ||
                  user.phone.contains(query) ||
                  (user.accountNumber?.contains(query) ?? false);
            }).toList();
      }
    });
  }

  Future<void> _loadUserTransactions(Account user) async {
    setState(() {
      _isLoadingTransactions = true;
    });

    try {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      await adminProvider.loadAllTransactions();

      setState(() {
        _userTransactions =
            adminProvider.allTransactions
                .where((transaction) => transaction.accountId == user.accountId)
                .toList();
        _isLoadingTransactions = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingTransactions = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading transactions: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showUserDetails(Account user) {
    setState(() {
      _selectedUser = user;
    });
    _loadUserTransactions(user);
  }

  void _closeUserDetails() {
    setState(() {
      _selectedUser = null;
      _userTransactions = [];
    });
  }

  Future<void> _removeUser(Account user) async {
    final confirmed = await DialogBox.show(
      context: context,
      title: 'Remove User Account',
      message:
          'Are you sure you want to remove ${user.username}\'s account? This action cannot be undone.',
      primaryButtonText: 'Remove',
      secondaryButtonText: 'Cancel',
      icon: Icons.warning,
      iconColor: Colors.red,
    );

    if (confirmed == true) {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      final success = await adminProvider.deactivateUserAccount(
        user.accountId!,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user.username}\'s account has been removed'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        _loadUsers();
        if (_selectedUser?.accountId == user.accountId) {
          _closeUserDetails();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove user account'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateUserBalance(Account user) async {
    final controller = TextEditingController(text: user.balance.toString());

    final newBalance = await showDialog<double>(
      context: context,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDarkMode ? AppColors.darkSurface : Colors.white,
          title: Text('Update Balance for ${user.username}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Current Balance: \$${user.balance.toStringAsFixed(2)}'),
              const SizedBox(height: 16),
              InputField(
                controller: controller,
                label: 'New Balance',
                hintText: 'Enter new balance amount',
                keyboardType: TextInputType.number,
                isDarkMode: isDarkMode,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = double.tryParse(controller.text);
                Navigator.pop(context, value);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Update'),
            ),
          ],
        );
      },
    );

    if (newBalance != null && newBalance != user.balance) {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      final success = await adminProvider.updateUserAccountBalance(
        user.accountId!,
        newBalance,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Balance updated for ${user.username}'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        _loadUsers();
        if (_selectedUser?.accountId == user.accountId) {
          setState(() {
            _selectedUser = _selectedUser!.copyWith(balance: newBalance);
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update balance'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportUsersData() async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    final exportData = ExportData(
      title: 'User Accounts Report',
      subtitle: 'Complete list of all user accounts in the system',
      userData: {
        'admin_name': adminProvider.currentAdmin?.fullName ?? 'Administrator',
        'export_date': DateTime.now().toString().split(' ')[0],
        'total_users': adminProvider.userAccounts.length.toString(),
        'total_balance': adminProvider.formatCurrency(
          adminProvider.userAccounts.fold(
            0.0,
            (sum, user) => sum + user.balance,
          ),
        ),
      },
      tableData:
          adminProvider.userAccounts
              .map(
                (user) => {
                  'username': user.username,
                  'email': user.email ?? 'N/A',
                  'phone': user.phone,
                  'account_type': user.accountType,
                  'balance': '\$${user.balance.toStringAsFixed(2)}',
                  'created_at':
                      user.createdAt?.toString().split(' ')[0] ?? 'N/A',
                  'account_number': user.accountNumber ?? 'N/A',
                },
              )
              .toList(),
      headers: [
        'Username',
        'Email',
        'Phone',
        'Account Type',
        'Balance',
        'Created At',
        'Account Number',
      ],
      summary: {
        'Total Users': adminProvider.userAccounts.length.toString(),
        'Checking Accounts':
            adminProvider.userAccounts
                .where((u) => u.accountType == 'Checking')
                .length
                .toString(),
        'Savings Accounts':
            adminProvider.userAccounts
                .where((u) => u.accountType == 'Savings')
                .length
                .toString(),
        'Total System Balance': adminProvider.formatCurrency(
          adminProvider.userAccounts.fold(
            0.0,
            (sum, user) => sum + user.balance,
          ),
        ),
      },
    );

    ExportDialogHelper.show(
      context: context,
      exportData: exportData,
      title: 'Export Users Data',
    );
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
          drawer: const AdminNavigationDrawer(selectedIndex: 1),
          body:
              _selectedUser == null
                  ? _buildUsersListView(context, adminProvider, isDarkMode)
                  : _buildUserDetailsView(context, isDarkMode),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDarkMode) {
    return AppBar(
      backgroundColor:
          isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      foregroundColor: isDarkMode ? Colors.white : AppColors.darkText,
      elevation: 0,
      title: Text(
        _selectedUser == null ? 'Manage Users' : _selectedUser!.username,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: isDarkMode ? Colors.white : AppColors.darkText,
        ),
      ),
      actions: [
        if (_selectedUser == null) ...[
          IconButton(
            onPressed: _exportUsersData,
            icon: const Icon(Icons.download),
            tooltip: 'Export Users Data',
          ),
          IconButton(
            onPressed: () => _loadUsers(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ] else ...[
          IconButton(
            onPressed: _closeUserDetails,
            icon: const Icon(Icons.close),
            tooltip: 'Close Details',
          ),
        ],
      ],
    );
  }

  Widget _buildUsersListView(
    BuildContext context,
    AdminProvider adminProvider,
    bool isDarkMode,
  ) {
    return Column(
      children: [
        // Search Section using reusable widget
        UsersSearchWidget(
          searchController: _searchController,
          onSearchChanged: _searchUsers,
          totalUsers: _filteredUsers.length,
        ),

        // Users List
        Expanded(
          child:
              adminProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredUsers.isEmpty
                  ? _buildEmptyState(isDarkMode)
                  : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      return UserCardWidget(
                        user: user,
                        onViewDetails: () => _showUserDetails(user),
                        onUpdateBalance: () => _updateUserBalance(user),
                        onRemoveUser: () => _removeUser(user),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildUserDetailsView(BuildContext context, bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Details using reusable widget
          UserDetailsWidget(user: _selectedUser!),
          const SizedBox(height: 16),

          // User Transactions using reusable widget
          UserTransactionsWidget(
            transactions: _userTransactions,
            isLoading: _isLoadingTransactions,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outline,
              size: 48,
              color:
                  isDarkMode
                      ? Colors.white.withOpacity(0.3)
                      : AppColors.lightText.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'No users found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color:
                    isDarkMode
                        ? Colors.white.withOpacity(0.7)
                        : AppColors.lightText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'No user accounts match your search criteria',
              style: TextStyle(
                fontSize: 13,
                color:
                    isDarkMode
                        ? Colors.white.withOpacity(0.5)
                        : AppColors.lightText.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
