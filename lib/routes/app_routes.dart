import 'package:flutter/material.dart';
import '../screens/welcome_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/manage_users_screen.dart';
import '../screens/admin/manage_transactions_screen.dart';
import '../screens/balance/balance_screen.dart';
import '../screens/admin/transaction_history_screen.dart';
import '../screens/qr/qr_display_screen.dart';
import '../screens/qr/qr_scanner_screen.dart';
import '../screens/qr/qr_export_screen.dart';
import '../screens/user/account_screen.dart';
import '../screens/user/change_password_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/transaction/deposit_screen.dart';
import '../screens/transaction/withdraw_screen.dart';
import '../screens/admin/transaction_approval_screen.dart';
import '../atm/atm_locations_screen.dart';
import '../atm/atm_qr_screen.dart';
import '../atm/atm_connection_screen.dart';
import '../atm/atm_withdraw_screen.dart';
import '../models/atm_location.dart';
import '../screens/transaction/transfer_screen.dart';
import '../screens/transaction/transaction_page.dart';

// NEW ANALYTICS IMPORTS
import '../screens/admin/admin_reports_screen.dart';
import '../screens/admin/transaction_analytics_screen.dart';
import '../screens/admin/user_analytics_screen.dart';
import '../screens/admin/financial_reports_screen.dart';
import '../screens/admin/performance_metrics_screen.dart';
import '../screens/admin/export_center_screen.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';
  static const String balance = '/balance';
  static const String deposit = '/deposit';
  static const String withdraw = '/withdraw';
  static const String transfer = '/transfer';
  static const String transactions = '/transactions';
  static const String transactionHistory = '/transaction-history';
  static const String qrDisplay = '/qr-display';
  static const String qrScanner = '/qr-scanner';
  static const String qrExport = '/qr-export';

  // ATM routes
  static const String atmLocations = '/atm/locations';
  static const String atmQr = '/atm/qr';
  static const String atmConnection = '/atm/connection';
  static const String atmWithdraw = '/atm/withdraw';

  // User Account routes
  static const String account = '/account';
  static const String changePassword = '/change-password';
  static const String settingsRoute = '/settings';

  // Admin routes
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminTransactions = '/admin/transactions';
  static const String adminTransactionHistory = '/admin/transaction-history';
  static const String adminApprovals = '/admin/approvals';
  static const String adminReports = '/admin/reports';
  static const String adminAudit = '/admin/audit';
  static const String adminSettings = '/admin/settings';

  // NEW ANALYTICS ROUTES
  static const String adminTransactionAnalytics =
      '/admin/reports/transaction-analytics';
  static const String adminUserAnalytics = '/admin/reports/user-analytics';
  static const String adminFinancialReports = '/admin/reports/financial';
  static const String adminPerformanceMetrics = '/admin/reports/performance';
  static const String adminExportCenter = '/admin/reports/export';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const WelcomeScreen(),
          settings: settings,
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
          settings: settings,
        );

      case forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
          settings: settings,
        );

      case dashboard:
        return MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
          settings: settings,
        );

      case balance:
        return MaterialPageRoute(
          builder: (_) => const BalanceScreen(),
          settings: settings,
        );

      // User Account Routes
      case account:
        return MaterialPageRoute(
          builder: (_) => const AccountScreen(),
          settings: settings,
        );

      case changePassword:
        return MaterialPageRoute(
          builder: (_) => const ChangePasswordScreen(),
          settings: settings,
        );

      case settingsRoute:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );

      // Transaction Routes
      case deposit:
        return MaterialPageRoute(
          builder: (_) => const DepositScreen(),
          settings: settings,
        );

      case withdraw:
        return MaterialPageRoute(
          builder: (_) => const WithdrawScreen(),
          settings: settings,
        );

      case transfer:
        return MaterialPageRoute(
          builder: (_) => const TransferScreen(),
          settings: settings,
        );

      case transactions:
        return MaterialPageRoute(
          builder: (_) => const TransactionPage(),
          settings: settings,
        );

      case transactionHistory:
        return MaterialPageRoute(
          builder: (_) => const TransactionPage(),
          settings: settings,
        );

      // QR Code Routes
      case qrDisplay:
        return MaterialPageRoute(
          builder: (_) => const QRDisplayScreen(),
          settings: settings,
        );

      case qrScanner:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder:
              (_) => QRScannerScreen(
                transactionType: args['transaction_type'] ?? 'transfer',
              ),
          settings: settings,
        );

      case qrExport:
        return MaterialPageRoute(
          builder: (_) => const QRExportScreen(),
          settings: settings,
        );

      // ATM Routes
      case atmLocations:
        return MaterialPageRoute(
          builder: (_) => const ATMLocationsScreen(),
          settings: settings,
        );

      case atmQr:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final atmLocation = args['atmLocation'];
        return MaterialPageRoute(
          builder: (_) => ATMQRScreen(atmLocation: atmLocation),
          settings: settings,
        );

      case atmConnection:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final atmLocation = args['atmLocation'] as ATMLocation?;
        final qrData = args['qrData'] as String? ?? '';
        return MaterialPageRoute(
          builder:
              (_) => ATMConnectionScreen(
                atmLocation: atmLocation!,
                qrData: qrData,
              ),
          settings: settings,
        );

      case atmWithdraw:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final atmLocation = args['atmLocation'];
        return MaterialPageRoute(
          builder: (_) => ATMWithdrawScreen(atmLocation: atmLocation),
          settings: settings,
        );

      // Admin routes
      case adminDashboard:
        return MaterialPageRoute(
          builder: (_) => const AdminDashboardScreen(),
          settings: settings,
        );

      case adminUsers:
        return MaterialPageRoute(
          builder: (_) => const ManageUsersScreen(),
          settings: settings,
        );

      case adminTransactions:
        return MaterialPageRoute(
          builder: (_) => const ManageTransactionsScreen(),
          settings: settings,
        );

      case adminTransactionHistory:
        return MaterialPageRoute(
          builder: (_) => const TransactionHistoryScreen(),
          settings: settings,
        );

      case adminApprovals:
        return MaterialPageRoute(
          builder: (_) => const TransactionApprovalScreen(),
          settings: settings,
        );

      // UPDATED REPORTS ROUTE - Now uses actual AdminReportsScreen
      case adminReports:
        return MaterialPageRoute(
          builder: (_) => const AdminReportsScreen(),
          settings: settings,
        );

      // NEW ANALYTICS ROUTES
      case adminTransactionAnalytics:
        return MaterialPageRoute(
          builder: (_) => const TransactionAnalyticsScreen(),
          settings: settings,
        );

      case adminUserAnalytics:
        return MaterialPageRoute(
          builder: (_) => const UserAnalyticsScreen(),
          settings: settings,
        );

      case adminFinancialReports:
        return MaterialPageRoute(
          builder: (_) => const FinancialReportsScreen(),
          settings: settings,
        );

      case adminPerformanceMetrics:
        return MaterialPageRoute(
          builder: (_) => const PerformanceMetricsScreen(),
          settings: settings,
        );

      case adminExportCenter:
        return MaterialPageRoute(
          builder: (_) => const ExportCenterScreen(),
          settings: settings,
        );

      case adminAudit:
        return MaterialPageRoute(
          builder:
              (_) => const Scaffold(
                body: Center(child: Text('Audit Logs - Coming Soon')),
              ),
          settings: settings,
        );

      case adminSettings:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );

      // Default case - route not found
      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                appBar: AppBar(title: const Text('Page Not Found')),
                body: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text(
                        '404 - Page Not Found',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('The requested page does not exist.'),
                    ],
                  ),
                ),
              ),
          settings: settings,
        );
    }
  }

  // Navigation Helper Methods
  static void navigateToLogin(BuildContext context) {
    Navigator.pushNamed(context, login);
  }

  static void navigateToRegister(BuildContext context) {
    Navigator.pushNamed(context, register);
  }

  static void navigateToForgotPassword(BuildContext context) {
    Navigator.pushNamed(context, forgotPassword);
  }

  static void navigateToDashboard(BuildContext context) {
    Navigator.pushReplacementNamed(context, dashboard);
  }

  static void navigateToAdminDashboard(BuildContext context) {
    Navigator.pushReplacementNamed(context, adminDashboard);
  }

  static void navigateToSplash(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, splash, (route) => false);
  }

  // User navigation helpers
  static void navigateToBalance(BuildContext context) {
    Navigator.pushNamed(context, balance);
  }

  static void navigateToDeposit(BuildContext context) {
    Navigator.pushNamed(context, deposit);
  }

  static void navigateToWithdraw(BuildContext context) {
    Navigator.pushNamed(context, withdraw);
  }

  static void navigateToTransfer(BuildContext context) {
    Navigator.pushNamed(context, transfer);
  }

  static void navigateToTransactions(BuildContext context) {
    Navigator.pushNamed(context, transactions);
  }

  static void navigateToTransactionHistory(BuildContext context) {
    Navigator.pushNamed(context, transactionHistory);
  }

  // Account navigation helpers
  static void navigateToAccount(BuildContext context) {
    Navigator.pushNamed(context, account);
  }

  static void navigateToChangePassword(BuildContext context) {
    Navigator.pushNamed(context, changePassword);
  }

  static void navigateToSettings(BuildContext context) {
    Navigator.pushNamed(context, settingsRoute);
  }

  // QR Code navigation helpers
  static void navigateToQrDisplay(BuildContext context) {
    Navigator.pushNamed(context, qrDisplay);
  }

  static Future<Map<String, dynamic>?> navigateToQrScanner(
    BuildContext context,
    String transactionType,
  ) async {
    final result = await Navigator.pushNamed(
      context,
      qrScanner,
      arguments: {'transaction_type': transactionType},
    );
    return result as Map<String, dynamic>?;
  }

  static void navigateToQrExport(BuildContext context) {
    Navigator.pushNamed(context, qrExport);
  }

  // ATM navigation helpers
  static void navigateToAtmLocations(BuildContext context) {
    Navigator.pushNamed(context, atmLocations);
  }

  static void navigateToAtmQr(BuildContext context, ATMLocation atmLocation) {
    Navigator.pushNamed(
      context,
      atmQr,
      arguments: {'atmLocation': atmLocation},
    );
  }

  static void navigateToAtmConnection(
    BuildContext context,
    ATMLocation atmLocation,
    String qrData,
  ) {
    Navigator.pushNamed(
      context,
      atmConnection,
      arguments: {'atmLocation': atmLocation, 'qrData': qrData},
    );
  }

  static void navigateToAtmWithdraw(
    BuildContext context,
    ATMLocation atmLocation,
  ) {
    Navigator.pushNamed(
      context,
      atmWithdraw,
      arguments: {'atmLocation': atmLocation},
    );
  }

  // Admin navigation helpers
  static void navigateToAdminUsers(BuildContext context) {
    Navigator.pushNamed(context, adminUsers);
  }

  static void navigateToAdminTransactions(BuildContext context) {
    Navigator.pushNamed(context, adminTransactions);
  }

  static void navigateToAdminTransactionHistory(BuildContext context) {
    Navigator.pushNamed(context, adminTransactionHistory);
  }

  static void navigateToAdminApprovals(BuildContext context) {
    Navigator.pushNamed(context, adminApprovals);
  }

  static void navigateToAdminReports(BuildContext context) {
    Navigator.pushNamed(context, adminReports);
  }

  static void navigateToAdminAudit(BuildContext context) {
    Navigator.pushNamed(context, adminAudit);
  }

  static void navigateToAdminSettings(BuildContext context) {
    Navigator.pushNamed(context, adminSettings);
  }

  // NEW ANALYTICS NAVIGATION HELPERS
  static void navigateToTransactionAnalytics(BuildContext context) {
    Navigator.pushNamed(context, adminTransactionAnalytics);
  }

  static void navigateToUserAnalytics(BuildContext context) {
    Navigator.pushNamed(context, adminUserAnalytics);
  }

  static void navigateToFinancialReports(BuildContext context) {
    Navigator.pushNamed(context, adminFinancialReports);
  }

  static void navigateToPerformanceMetrics(BuildContext context) {
    Navigator.pushNamed(context, adminPerformanceMetrics);
  }

  static void navigateToExportCenter(BuildContext context) {
    Navigator.pushNamed(context, adminExportCenter);
  }

  // Back navigation helpers
  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }

  static void goBackToRoot(BuildContext context) {
    Navigator.popUntil(context, ModalRoute.withName(splash));
  }

  // Replace current route
  static void replaceWith(BuildContext context, String routeName) {
    Navigator.pushReplacementNamed(context, routeName);
  }

  // Push and clear stack
  static void pushAndClearStack(BuildContext context, String routeName) {
    Navigator.pushNamedAndRemoveUntil(context, routeName, (route) => false);
  }

  // Helper method to get all available routes
  static List<String> getAllRoutes() {
    return [
      splash,
      login,
      register,
      forgotPassword,
      dashboard,
      balance,
      account,
      changePassword,
      settingsRoute,
      deposit,
      withdraw,
      transfer,
      transactions,
      transactionHistory,
      qrDisplay,
      qrScanner,
      qrExport,
      atmLocations,
      atmQr,
      atmConnection,
      atmWithdraw,
      adminDashboard,
      adminUsers,
      adminTransactions,
      adminTransactionHistory,
      adminApprovals,
      adminReports,
      adminAudit,
      adminSettings,
      // NEW ANALYTICS ROUTES
      adminTransactionAnalytics,
      adminUserAnalytics,
      adminFinancialReports,
      adminPerformanceMetrics,
      adminExportCenter,
    ];
  }

  // Helper method to check if route requires authentication
  static bool requiresAuth(String route) {
    const publicRoutes = [splash, login, register, forgotPassword];
    return !publicRoutes.contains(route);
  }

  // Helper method to check if route requires admin privileges
  static bool requiresAdmin(String route) {
    return route.startsWith('/admin');
  }
}
