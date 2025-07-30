import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/auth_provider.dart';
import '../providers/account_provider.dart';
import '../routes/app_routes.dart';

class AppNavigationDrawer extends StatelessWidget {
  final int selectedIndex;

  const AppNavigationDrawer({super.key, this.selectedIndex = 0});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    final currentAccount = authProvider.currentAccount;

    return Drawer(
      backgroundColor: isDarkMode ? AppColors.darkSurface : Colors.white,
      child: Column(
        children: [
          // Header with user info
          _buildDrawerHeader(context, isDarkMode, currentAccount),

          // Navigation items
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildNavigationItem(
                    context: context,
                    icon: Icons.dashboard_outlined,
                    activeIcon: Icons.dashboard,
                    title: 'Dashboard',
                    index: 0,
                    onTap: () => _navigateToPage(context, AppRoutes.dashboard),
                    isDarkMode: isDarkMode,
                  ),
                  _buildNavigationItem(
                    context: context,
                    icon: Icons.account_balance_wallet_outlined,
                    activeIcon: Icons.account_balance_wallet,
                    title: 'Balance',
                    index: 1,
                    onTap: () => _navigateToPage(context, AppRoutes.balance),
                    isDarkMode: isDarkMode,
                  ),
                  _buildNavigationItem(
                    context: context,
                    icon: Icons.account_balance_outlined,
                    activeIcon: Icons.account_balance,
                    title: 'Accounts',
                    index: 2,
                    onTap: () => _navigateToPage(context, AppRoutes.account),
                    isDarkMode: isDarkMode,
                  ),
                  _buildNavigationItem(
                    context: context,
                    icon: Icons.add_circle_outline,
                    activeIcon: Icons.add_circle,
                    title: 'Deposit',
                    index: 3,
                    onTap: () => _navigateToPage(context, AppRoutes.deposit),
                    isDarkMode: isDarkMode,
                  ),
                  _buildNavigationItem(
                    context: context,
                    icon: Icons.remove_circle_outline,
                    activeIcon: Icons.remove_circle,
                    title: 'Withdraw',
                    index: 4,
                    onTap: () => _navigateToPage(context, AppRoutes.withdraw),
                    isDarkMode: isDarkMode,
                  ),
                  _buildNavigationItem(
                    context: context,
                    icon: Icons.send_outlined,
                    activeIcon: Icons.send,
                    title: 'Transfer',
                    index: 5,
                    onTap: () => _navigateToPage(context, AppRoutes.transfer),
                    isDarkMode: isDarkMode,
                  ),
                  _buildNavigationItem(
                    context: context,
                    icon: Icons.history_outlined,
                    activeIcon: Icons.history,
                    title: 'Transactions',
                    index: 6,
                    onTap:
                        () => _navigateToPage(context, AppRoutes.transactions),
                    isDarkMode: isDarkMode,
                  ),
                  _buildNavigationItem(
                    context: context,
                    icon: Icons.qr_code_outlined,
                    activeIcon: Icons.qr_code,
                    title: 'QR Codes',
                    index: 7,
                    onTap: () => _navigateToPage(context, AppRoutes.qrDisplay),
                    isDarkMode: isDarkMode,
                  ),

                  // Divider before account section
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Divider(
                      color:
                          isDarkMode
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.1),
                    ),
                  ),

                  // Account Management Section
                  _buildNavigationItem(
                    context: context,
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    title: 'My Account',
                    index: 8,
                    onTap: () => _navigateToPage(context, AppRoutes.account),
                    isDarkMode: isDarkMode,
                  ),
                  _buildNavigationItem(
                    context: context,
                    icon: Icons.lock_outline,
                    activeIcon: Icons.lock,
                    title: 'Change Password',
                    index: 9,
                    onTap:
                        () =>
                            _navigateToPage(context, AppRoutes.changePassword),
                    isDarkMode: isDarkMode,
                  ),
                  _buildNavigationItem(
                    context: context,
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings,
                    title: 'Settings',
                    index: 10,
                    onTap:
                        () => _navigateToPage(context, AppRoutes.adminSettings),
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
            ),
          ),

          // Logout section at bottom
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color:
                      isDarkMode
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.1),
                ),
              ),
            ),
            child: _buildNavigationItem(
              context: context,
              icon: Icons.logout_outlined,
              activeIcon: Icons.logout,
              title: 'Logout',
              index: -1, // Special index for logout
              onTap: () => _handleLogout(context),
              isDarkMode: isDarkMode,
              isLogout: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(
    BuildContext context,
    bool isDarkMode,
    dynamic currentAccount,
  ) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 120),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primaryGreen],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // User Avatar with Profile Picture
              Consumer<AccountProvider>(
                builder: (context, accountProvider, _) {
                  // Ensure account ID is set for loading profile image
                  if (currentAccount?.accountId != null &&
                      (accountProvider.profileImage == null)) {
                    accountProvider.setCurrentAccountId(
                      currentAccount.accountId!,
                    );
                    accountProvider.loadProfileImage();
                  }

                  return Center(
                    child: GestureDetector(
                      onTap:
                          () => _showProfileImageOptions(
                            context,
                            accountProvider,
                          ),
                      child: CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        backgroundImage:
                            accountProvider.profileImage != null
                                ? FileImage(accountProvider.profileImage!)
                                : (currentAccount?.profileImage != null
                                    ? FileImage(
                                      File(currentAccount.profileImage!),
                                    )
                                    : null),
                        child:
                            (accountProvider.profileImage == null &&
                                    currentAccount?.profileImage == null)
                                ? Text(
                                  currentAccount?.username
                                          .substring(0, 1)
                                          .toUpperCase() ??
                                      'U',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                                : null,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // User Name
              Center(
                child: Text(
                  currentAccount?.username ?? 'User Name',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Account Type
              Center(
                child: Text(
                  '${currentAccount?.accountType ?? 'Account'} Account',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ),

              // Account Number
              if (currentAccount?.accountNumber != null)
                Center(
                  child: Text(
                    'Account: ${currentAccount!.accountNumber}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String title,
    required int index,
    required VoidCallback onTap,
    required bool isDarkMode,
    bool isLogout = false,
  }) {
    final isSelected = selectedIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color:
            isSelected
                ? (isDarkMode
                    ? AppColors.primaryGreen.withOpacity(0.2)
                    : AppColors.primaryGreen.withOpacity(0.1))
                : Colors.transparent,
      ),
      child: ListTile(
        leading: Icon(
          isSelected ? activeIcon : icon,
          color:
              isSelected
                  ? AppColors.primaryGreen
                  : (isLogout
                      ? Colors.red
                      : (isDarkMode ? Colors.white70 : AppColors.lightText)),
        ),
        title: Text(
          title,
          style: TextStyle(
            color:
                isSelected
                    ? AppColors.primaryGreen
                    : (isLogout
                        ? Colors.red
                        : (isDarkMode ? Colors.white : AppColors.darkText)),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _navigateToPage(BuildContext context, String route) {
    print('🔄 Navigating to route: $route');
    Navigator.of(context).pop(); // Close drawer

    // Don't navigate if already on the same route
    if (ModalRoute.of(context)?.settings.name != route) {
      print('✅ Pushing to route: $route');
      Navigator.of(context).pushNamed(route);
    } else {
      print('⚠️ Already on route: $route');
    }
  }

  void _handleLogout(BuildContext context) {
    Navigator.of(context).pop(); // Close drawer

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return AlertDialog(
          backgroundColor: isDarkMode ? AppColors.darkSurface : Colors.white,
          title: Text(
            'Logout',
            style: TextStyle(
              color: isDarkMode ? Colors.white : AppColors.darkText,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : AppColors.lightText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : AppColors.lightText,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Method to show profile image options
  void _showProfileImageOptions(
    BuildContext context,
    AccountProvider accountProvider,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final success = await accountProvider.pickProfileImage();
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile picture updated')),
                    );
                  }
                },
              ),
              if (accountProvider.profileImage != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Remove Profile Picture',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    // TODO: Implement remove profile picture
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
