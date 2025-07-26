// lib/widgets/navigation_drawer.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/auth_provider.dart';
import '../routes/app_routes.dart';
import 'app_logo.dart';

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
              // Add scroll view to prevent overflow
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildNavigationItem(
                    context: context,
                    icon: Icons.dashboard_outlined,
                    activeIcon: Icons.dashboard,
                    title: 'Dashboard',
                    index: 0,
                    onTap: () => _navigateToPage(context, '/dashboard'),
                    isDarkMode: isDarkMode,
                  ),
                  _buildNavigationItem(
                    context: context,
                    icon: Icons.account_balance_wallet_outlined,
                    activeIcon: Icons.account_balance_wallet,
                    title: 'Balance',
                    index: 1,
                    onTap: () => _navigateToPage(context, '/balance'),
                    isDarkMode: isDarkMode,
                  ),
                  _buildNavigationItem(
                    context: context,
                    icon: Icons.account_balance_outlined,
                    activeIcon: Icons.account_balance,
                    title: 'Accounts',
                    index: 2,
                    onTap: () => _navigateToPage(context, '/accounts'),
                    isDarkMode: isDarkMode,
                  ),
                  _buildNavigationItem(
                    context: context,
                    icon: Icons.add_circle_outline,
                    activeIcon: Icons.add_circle,
                    title: 'Deposit',
                    index: 3,
                    onTap: () => _navigateToPage(context, '/deposit'),
                    isDarkMode: isDarkMode,
                  ),
                  _buildNavigationItem(
                    context: context,
                    icon: Icons.remove_circle_outline,
                    activeIcon: Icons.remove_circle,
                    title: 'Withdraw',
                    index: 4,
                    onTap: () => _navigateToPage(context, '/withdraw'),
                    isDarkMode: isDarkMode,
                  ),
                  _buildNavigationItem(
                    context: context,
                    icon: Icons.swap_horiz_outlined,
                    activeIcon: Icons.swap_horiz,
                    title: 'Transfers',
                    index: 5,
                    onTap: () => _navigateToPage(context, '/transfer'),
                    isDarkMode: isDarkMode,
                  ),
                  _buildNavigationItem(
                    context: context,
                    icon: Icons.receipt_long_outlined,
                    activeIcon: Icons.receipt_long,
                    title: 'Transactions',
                    index: 6,
                    onTap: () => _navigateToPage(context, '/transactions'),
                    isDarkMode: isDarkMode,
                  ),
                  _buildNavigationItem(
                    context: context,
                    icon: Icons.credit_card_outlined,
                    activeIcon: Icons.credit_card,
                    title: 'Cards',
                    index: 7,
                    onTap: () => _navigateToPage(context, '/cards'),
                    isDarkMode: isDarkMode,
                  ),
                  _buildNavigationItem(
                    context: context,
                    icon: Icons.qr_code_outlined,
                    activeIcon: Icons.qr_code,
                    title: 'QR Codes',
                    index: 8,
                    onTap: () => _navigateToPage(context, '/qr-codes'),
                    isDarkMode: isDarkMode,
                  ),

                  const Divider(height: 32),

                  // Settings and logout
                  _buildNavigationItem(
                    context: context,
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings,
                    title: 'Settings',
                    index: 9,
                    onTap: () => _navigateToPage(context, '/settings'),
                    isDarkMode: isDarkMode,
                  ),
                  _buildNavigationItem(
                    context: context,
                    icon: Icons.help_outline,
                    activeIcon: Icons.help,
                    title: 'Help & Support',
                    index: 10,
                    onTap: () => _navigateToPage(context, '/help'),
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
            ),
          ),

          // Logout button
          _buildLogoutButton(context, isDarkMode, authProvider),
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isDarkMode
                  ? [AppColors.primaryDark, Colors.black87]
                  : [AppColors.primaryDark, AppColors.primaryGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Important: Use minimum size
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Logo Section
              const SizedBox(height: 22), // Reduced spacing
              // User info
              Row(
                children: [
                  CircleAvatar(
                    radius: 22, // Slightly smaller
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      currentAccount?.username?.substring(0, 1).toUpperCase() ??
                          'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16, // Reduced font size
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min, // Important
                      children: [
                        Text(
                          'Welcome back,',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 11, // Reduced font size
                          ),
                        ),
                        Text(
                          currentAccount?.username ?? 'User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14, // Reduced font size
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1, // Limit to 1 line
                        ),
                        Text(
                          currentAccount?.accountType ?? 'Account',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 10, // Reduced font size
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10), // Reduced spacing
              // Account balance chip - make it smaller
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ), // Reduced padding
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16), // Smaller radius
                ),
                child: Text(
                  'Balance: \$${currentAccount?.balance?.toStringAsFixed(2) ?? '0.00'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11, // Reduced font size
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis, // Prevent overflow
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
  }) {
    final isSelected = selectedIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: Icon(
          isSelected ? activeIcon : icon,
          color:
              isSelected
                  ? AppColors.primaryGreen
                  : (isDarkMode ? Colors.white70 : AppColors.darkText),
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            color:
                isSelected
                    ? AppColors.primaryGreen
                    : (isDarkMode ? Colors.white : AppColors.darkText),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 15,
          ),
        ),
        onTap: onTap,
        selected: isSelected,
        selectedTileColor: AppColors.primaryGreen.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildLogoutButton(
    BuildContext context,
    bool isDarkMode,
    AuthProvider authProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ListTile(
        leading: Icon(Icons.logout, color: Colors.red, size: 22),
        title: const Text(
          'Logout',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        onTap: () => _showLogoutDialog(context, authProvider),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  void _navigateToPage(BuildContext context, String route) {
    Navigator.pop(context); // Close drawer
    if (ModalRoute.of(context)?.settings.name != route) {
      Navigator.pushNamed(context, route);
    }
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close drawer
                authProvider.logout();
                AppRoutes.navigateToSplash(context);
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
