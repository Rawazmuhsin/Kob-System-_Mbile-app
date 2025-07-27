// lib/routes/app_routes.dart - UPDATED VERSION WITH BALANCE ROUTE
import 'package:flutter/material.dart';
import '../screens/welcome_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/balance/balance_screen.dart'; // ADD THIS IMPORT

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
  static const String qrExport = '/qr-export';

  // Admin routes
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminTransactions = '/admin/transactions';
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

      case balance: // ADD THIS CASE
        return MaterialPageRoute(
          builder: (_) => const BalanceScreen(),
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
          builder:
              (_) => const Scaffold(
                body: Center(child: Text('User Management - Coming Soon')),
              ),
          settings: settings,
        );

      case adminTransactions:
        return MaterialPageRoute(
          builder:
              (_) => const Scaffold(
                body: Center(
                  child: Text('Transaction Management - Coming Soon'),
                ),
              ),
          settings: settings,
        );

      case adminApprovals:
        return MaterialPageRoute(
          builder:
              (_) => const Scaffold(
                body: Center(child: Text('Approval Queue - Coming Soon')),
              ),
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
          builder:
              (_) => const Scaffold(
                body: Center(child: Text('Admin Settings - Coming Soon')),
              ),
          settings: settings,
        );

      // Add placeholder routes for other screens
      case deposit:
        return MaterialPageRoute(
          builder:
              (_) => const Scaffold(
                body: Center(child: Text('Deposit Screen - Coming Soon')),
              ),
          settings: settings,
        );

      case withdraw:
        return MaterialPageRoute(
          builder:
              (_) => const Scaffold(
                body: Center(child: Text('Withdraw Screen - Coming Soon')),
              ),
          settings: settings,
        );

      case transfer:
        return MaterialPageRoute(
          builder:
              (_) => const Scaffold(
                body: Center(child: Text('Transfer Screen - Coming Soon')),
              ),
          settings: settings,
        );

      case transactions:
        return MaterialPageRoute(
          builder:
              (_) => const Scaffold(
                body: Center(child: Text('Transactions Screen - Coming Soon')),
              ),
          settings: settings,
        );

      case qrDisplay:
        return MaterialPageRoute(
          builder:
              (_) => const Scaffold(
                body: Center(child: Text('QR Display Screen - Coming Soon')),
              ),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const WelcomeScreen(),
          settings: settings,
        );
    }
  }

  // Navigation helpers
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

  static void navigateToQrDisplay(BuildContext context) {
    Navigator.pushNamed(context, qrDisplay);
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
}
