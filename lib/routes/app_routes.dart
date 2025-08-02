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
  static const String qrDisplay = '/qr-display';
  static const String qrScanner = '/qr-scanner';
  static const String qrExport = '/qr-export';

  // ATM routes
  static const String atmLocations = '/atm/locations';
  static const String atmQr = '/atm/qr';
  static const String atmConnection = '/atm/connection';
  static const String atmWithdraw = '/atm/withdraw';

  // ADD THESE NEW ACCOUNT ROUTES
  static const String account = '/account';
  static const String changePassword = '/change-password';
  // ADD SETTINGS ROUTE
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

      // ADD THESE NEW ACCOUNT ROUTES
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

      // ADD SETTINGS ROUTE
      case settingsRoute:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
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

      case transfer:
        return MaterialPageRoute(
          builder: (_) => const TransferScreen(),
          settings: settings,
        );

      case atmWithdraw:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final atmLocation = args['atmLocation'];
        return MaterialPageRoute(
          builder: (_) => ATMWithdrawScreen(atmLocation: atmLocation),
          settings: settings,
        );

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
          builder:
              (_) => const Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send, size: 64, color: Colors.blue),
                      SizedBox(height: 16),
                      Text(
                        'Transfer Screen',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Coming Soon'),
                    ],
                  ),
                ),
              ),
          settings: settings,
        );

      case transactions:
        return MaterialPageRoute(
          builder:
              (_) => const Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.purple),
                      SizedBox(height: 16),
                      Text(
                        'Transaction History',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Coming Soon'),
                    ],
                  ),
                ),
              ),
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

      case adminReports:
        return MaterialPageRoute(
          builder:
              (_) => const Scaffold(
                body: Center(child: Text('Reports & Analytics - Coming Soon')),
              ),
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

  // PRESERVE ALL YOUR EXISTING NAVIGATION HELPER METHODS
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

  // ADD NEW ACCOUNT NAVIGATION HELPERS
  static void navigateToAccount(BuildContext context) {
    Navigator.pushNamed(context, account);
  }

  static void navigateToChangePassword(BuildContext context) {
    Navigator.pushNamed(context, changePassword);
  }

  // ADD SETTINGS NAVIGATION HELPER
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
      qrDisplay,
      qrScanner,
      qrExport,
      adminDashboard,
      adminUsers,
      adminTransactions,
      adminTransactionHistory,
      adminApprovals,
      adminReports,
      adminAudit,
      adminSettings,
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
