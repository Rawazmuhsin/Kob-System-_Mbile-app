import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../routes/app_routes.dart';
import '../app_logo.dart';

class AdminNavigationDrawer extends StatelessWidget {
  final int selectedIndex;

  const AdminNavigationDrawer({super.key, this.selectedIndex = 0});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    final currentAdmin = authProvider.currentAdmin;

    return Drawer(
      backgroundColor: isDarkMode ? AppColors.darkSurface : Colors.white,
      child: Column(
        children: [
          // Header with admin info
          _buildDrawerHeader(context, isDarkMode, currentAdmin),

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
                    onTap: () => _navigateToPage(context, '/admin/dashboard'),
                    isDarkMode: isDarkMode,
                  ),
                  _buildNavigationItem(
                    context: context,
                    icon: Icons.people_outline,
                    activeIcon: Icons.people,
                    title: 'User Accounts',
                    index: 1,
                    onTap: () => _navigateToPage(context, '/admin/users'),
                    isDarkMode: isDarkMode,
                  ),
                  _buildNavigationItem(
                    context: context,
                    icon: Icons.receipt_long_outlined,
                    activeIcon: Icons.receipt_long,
                    title: 'Transactions',
                    index: 2,
                    onTap:
                        () => _navigateToPage(context, '/admin/transactions'),
                    isDarkMode: isDarkMode,
                  ),
                  _buildNavigationItem(
                    context: context,
                    icon: Icons.approval_outlined,
                    activeIcon: Icons.approval,
                    title: 'Approval Queue',
                    index: 3,
                    onTap: () => _navigateToPage(context, '/admin/approvals'),
                    isDarkMode: isDarkMode,
                    badge: _getPendingCount(context),
                  ),
                  _buildNavigationItem(
                    context: context,
                    icon: Icons.analytics_outlined,
                    activeIcon: Icons.analytics,
                    title: 'Reports & Analytics',
                    index: 4,
                    onTap: () => _navigateToPage(context, '/admin/reports'),
                    isDarkMode: isDarkMode,
                  ),
                  _buildNavigationItem(
                    context: context,
                    icon: Icons.history_outlined,
                    activeIcon: Icons.history,
                    title: 'Audit Logs',
                    index: 5,
                    onTap: () => _navigateToPage(context, '/admin/audit'),
                    isDarkMode: isDarkMode,
                  ),

                  const Divider(height: 32),

                  // Settings and logout
                  _buildNavigationItem(
                    context: context,
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings,
                    title: 'Admin Settings',
                    index: 6,
                    onTap: () => _navigateToPage(context, '/admin/settings'),
                    isDarkMode: isDarkMode,
                  ),
                  _buildNavigationItem(
                    context: context,
                    icon: Icons.help_outline,
                    activeIcon: Icons.help,
                    title: 'Help & Support',
                    index: 7,
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
    dynamic currentAdmin,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade700, Colors.purple.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Admin badge and logo
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'ADMIN PANEL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const AppLogo(size: 30),
                ],
              ),
              const SizedBox(height: 16),

              // Admin info
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: const Icon(
                      Icons.admin_panel_settings,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Welcome back,',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          currentAdmin?.fullName ?? 'Administrator',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          currentAdmin?.role?.toUpperCase() ?? 'ADMIN',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Status chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Online',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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
    String? badge,
  }) {
    final isSelected = selectedIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: Stack(
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color:
                  isSelected
                      ? Colors.purple
                      : (isDarkMode ? Colors.white70 : AppColors.darkText),
              size: 22,
            ),
            if (badge != null)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          title,
          style: TextStyle(
            color:
                isSelected
                    ? Colors.purple
                    : (isDarkMode ? Colors.white : AppColors.darkText),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 15,
          ),
        ),
        onTap: onTap,
        selected: isSelected,
        selectedTileColor: Colors.purple.withOpacity(0.1),
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
        leading: const Icon(Icons.logout, color: Colors.red, size: 22),
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

  String? _getPendingCount(BuildContext context) {
    try {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      final pendingCount = adminProvider.pendingTransactions.length;
      return pendingCount > 0 ? pendingCount.toString() : null;
    } catch (e) {
      return null;
    }
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Admin Logout'),
          content: const Text(
            'Are you sure you want to logout from admin panel?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close drawer
                final adminProvider = Provider.of<AdminProvider>(
                  context,
                  listen: false,
                );
                adminProvider.clearAdminData();
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
