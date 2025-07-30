import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/admin/admin_navigation_drawer.dart';
import '../../widgets/admin/admin_stats_grid.dart';
import '../../widgets/admin/pending_approvals_section.dart';
import '../../widgets/admin/recent_activities_section.dart';
import '../../routes/app_routes.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _initializeAdminDashboard();
  }

  void _initializeAdminDashboard() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);

      if (authProvider.isAdmin && authProvider.currentAdmin != null) {
        adminProvider.setCurrentAdmin(authProvider.currentAdmin!);
        adminProvider.loadAdminDashboard();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, AdminProvider>(
      builder: (context, authProvider, adminProvider, child) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        // Redirect if not admin
        if (!authProvider.isAdmin) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            AppRoutes.navigateToSplash(context);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor:
              isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
          appBar: _buildAppBar(context, isDarkMode, authProvider),
          drawer: const AdminNavigationDrawer(selectedIndex: 0),
          body: RefreshIndicator(
            onRefresh: () => adminProvider.refreshDashboard(),
            child:
                adminProvider.isLoading && adminProvider.currentAdmin == null
                    ? _buildLoadingState()
                    : adminProvider.errorMessage != null
                    ? _buildErrorState(
                      adminProvider.errorMessage!,
                      adminProvider,
                    )
                    : _buildDashboardContent(
                      context,
                      adminProvider,
                      isDarkMode,
                    ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    bool isDarkMode,
    AuthProvider authProvider,
  ) {
    return AppBar(
      backgroundColor:
          isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      foregroundColor: isDarkMode ? Colors.white : AppColors.darkText,
      elevation: 0,
      titleSpacing: 8,
      title: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate available width for title
          final availableWidth = constraints.maxWidth;
          final showFullTitle = availableWidth > 200;

          return Row(
            children: [
              Expanded(
                child: Text(
                  'KÖB Admin',
                  style: TextStyle(
                    fontSize: showFullTitle ? 20 : 18,
                    fontWeight: FontWeight.w800,
                    color: isDarkMode ? Colors.white : AppColors.darkText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showFullTitle) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    authProvider.getCurrentUserRole(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ] else ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'ADMIN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
      actions: [
        // Notifications icon
        IconButton(
          onPressed: () {
            // TODO: Navigate to notifications
          },
          icon: Stack(
            children: [
              const Icon(Icons.notifications_outlined),
              Positioned(
                right: 0,
                top: 0,
                child: Consumer<AdminProvider>(
                  builder: (context, adminProvider, child) {
                    final pendingCount =
                        adminProvider.pendingTransactions.length;
                    if (pendingCount > 0) {
                      return Container(
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
                          pendingCount > 99 ? '99+' : pendingCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
        // Date and time - made more compact
        Container(
          width: 80, // Fixed width to prevent overflow
          padding: const EdgeInsets.only(right: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _getCurrentDate(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : AppColors.darkText,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                _getCurrentTime(),
                style: TextStyle(
                  fontSize: 9,
                  color: isDarkMode ? Colors.white70 : AppColors.lightText,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    AdminProvider adminProvider,
    bool isDarkMode,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          _buildWelcomeSection(context, adminProvider, isDarkMode),

          // Statistics Grid
          AdminStatsGrid(
            statistics: adminProvider.getDashboardSummary(),
            onStatTap: (statType) => _handleStatTap(context, statType),
          ),

          // Pending Approvals Section
          PendingApprovalsSection(
            pendingTransactions: adminProvider.pendingTransactions,
            onApprove:
                (transactionId) => _handleApproveTransaction(
                  context,
                  adminProvider,
                  transactionId,
                ),
            onReject:
                (transactionId) => _handleRejectTransaction(
                  context,
                  adminProvider,
                  transactionId,
                ),
            onViewAll: () => _navigateToApprovals(context),
          ),

          // Recent Activities Section
          RecentActivitiesSection(
            activities: adminProvider.recentActivities,
            onViewAll: () => _navigateToAuditLogs(context),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(
    BuildContext context,
    AdminProvider adminProvider,
    bool isDarkMode,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primaryGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      adminProvider.currentAdmin?.fullName ?? 'Administrator',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Last login: ${_formatLastLogin(adminProvider.currentAdmin?.lastLogin)}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  'Today\'s Overview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Make overview responsive
                    if (constraints.maxWidth < 300) {
                      // Small screens - stack vertically
                      return Column(
                        children: [
                          _buildQuickStat(
                            'Pending',
                            '${adminProvider.transactionStatusCounts['PENDING'] ?? 0}',
                            Icons.pending_actions,
                          ),
                          const SizedBox(height: 8),
                          _buildQuickStat(
                            'Accounts',
                            '${adminProvider.statistics['total_accounts'] ?? 0}',
                            Icons.people,
                          ),
                          const SizedBox(height: 8),
                          _buildQuickStat(
                            'Balance',
                            adminProvider.formatCurrency(
                              (adminProvider.statistics['total_balance'] ?? 0.0)
                                  .toDouble(),
                            ),
                            Icons.account_balance_wallet,
                          ),
                        ],
                      );
                    } else {
                      // Larger screens - row layout
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: _buildQuickStat(
                              'Pending',
                              '${adminProvider.transactionStatusCounts['PENDING'] ?? 0}',
                              Icons.pending_actions,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildQuickStat(
                              'Accounts',
                              '${adminProvider.statistics['total_accounts'] ?? 0}',
                              Icons.people,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildQuickStat(
                              'Balance',
                              adminProvider.formatCurrency(
                                (adminProvider.statistics['total_balance'] ??
                                        0.0)
                                    .toDouble(),
                              ),
                              Icons.account_balance_wallet,
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading admin dashboard...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMessage, AdminProvider adminProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Dashboard',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.red.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => adminProvider.refreshDashboard(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // Event handlers
  void _handleStatTap(BuildContext context, String statType) {
    switch (statType) {
      case 'accounts':
        _navigateToUserManagement(context);
        break;
      case 'transactions':
        _navigateToTransactionManagement(context);
        break;
      case 'approvals':
        _navigateToApprovals(context);
        break;
      default:
        break;
    }
  }

  Future<void> _handleApproveTransaction(
    BuildContext context,
    AdminProvider adminProvider,
    int transactionId,
  ) async {
    final success = await adminProvider.approveTransaction(transactionId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction approved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            adminProvider.errorMessage ?? 'Failed to approve transaction',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleRejectTransaction(
    BuildContext context,
    AdminProvider adminProvider,
    int transactionId,
  ) async {
    final reason = await _showRejectDialog(context);
    if (reason != null && reason.isNotEmpty) {
      final success = await adminProvider.rejectTransaction(
        transactionId,
        reason,
      );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction rejected successfully'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
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
  }

  Future<String?> _showRejectDialog(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reject Transaction'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Please provide a reason for rejecting this transaction:',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Enter rejection reason...',
                    border: OutlineInputBorder(),
                  ),
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
                child: const Text('Reject'),
              ),
            ],
          ),
    );
  }

  // Navigation methods
  void _navigateToUserManagement(BuildContext context) {
    Navigator.pushNamed(context, '/admin/users');
  }

  void _navigateToTransactionManagement(BuildContext context) {
    Navigator.pushNamed(context, '/admin/transactions');
  }

  void _navigateToApprovals(BuildContext context) {
    Navigator.pushNamed(context, '/admin/approvals');
  }

  void _navigateToAuditLogs(BuildContext context) {
    Navigator.pushNamed(context, '/admin/audit');
  }

  // Helper methods
  String _getCurrentDate() {
    final now = DateTime.now();
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${weekdays[now.weekday - 1]} ${now.day} ${months[now.month - 1]}';
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final hour =
        now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  String _formatLastLogin(DateTime? lastLogin) {
    if (lastLogin == null) return 'Never';

    final now = DateTime.now();
    final difference = now.difference(lastLogin);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${lastLogin.day}/${lastLogin.month}/${lastLogin.year}';
    }
  }
}
