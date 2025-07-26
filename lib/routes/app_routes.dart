import 'package:flutter/material.dart';
import '../screens/welcome_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';

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
  static const String admin = '/admin';

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

  static void navigateToSplash(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, splash, (route) => false);
  }

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

  static void navigateToAdmin(BuildContext context) {
    Navigator.pushNamed(context, admin);
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
