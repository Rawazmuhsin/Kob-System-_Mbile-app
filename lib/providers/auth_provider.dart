// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/account.dart';
import '../confirmation/auth_service.dart';
import '../confirmation/login/login_confirmation.dart';
import '../confirmation/signup/signup_confirmation.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  Account? _currentAccount;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  Account? get currentAccount => _currentAccount;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  final AuthService _authService = AuthService.instance;
  final LoginConfirmation _loginConfirmation = LoginConfirmation.instance;
  final SignupConfirmation _signupConfirmation = SignupConfirmation.instance;

  // Login method
  Future<bool> login(String email, String password) async {
    _setLoading(true);

    try {
      final result = await _loginConfirmation.performLogin(
        email: email,
        password: password,
      );

      if (result.success && result.account != null) {
        _currentAccount = result.account;
        _currentUser = User(
          userId: result.account!.accountId,
          username: result.account!.username,
          email: result.account!.email,
        );
        _isAuthenticated = true;

        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setLoading(false);
        debugPrint('Login failed: ${result.errorMessage}');
        return false;
      }
    } catch (e) {
      _setLoading(false);
      debugPrint('Login error: $e');
      return false;
    }
  }

  // Register method
  Future<RegisterResult> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    required String phone,
    required String accountType,
  }) async {
    _setLoading(true);

    try {
      final result = await _signupConfirmation.performSignup(
        username: username,
        email: email,
        phone: phone,
        password: password,
        confirmPassword: confirmPassword,
        accountType: accountType,
      );

      _setLoading(false);

      if (result.success && result.account != null) {
        // Optionally auto-login after successful registration
        _currentAccount = result.account;
        _currentUser = User(
          userId: result.account!.accountId,
          username: result.account!.username,
          email: result.account!.email,
        );
        _isAuthenticated = true;
        notifyListeners();

        return RegisterResult(
          success: true,
          message: 'Account created successfully!',
        );
      } else {
        return RegisterResult(
          success: false,
          message: result.errorMessage ?? 'Registration failed',
        );
      }
    } catch (e) {
      _setLoading(false);
      debugPrint('Registration error: $e');
      return RegisterResult(
        success: false,
        message: 'Registration failed: ${e.toString()}',
      );
    }
  }

  // Logout method
  void logout() {
    _currentUser = null;
    _currentAccount = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  // Update account balance
  Future<bool> updateBalance(double newBalance) async {
    if (_currentAccount != null) {
      try {
        final success = await _authService.updateAccountBalance(
          _currentAccount!.accountId!,
          newBalance,
        );

        if (success) {
          _currentAccount = _currentAccount!.copyWith(balance: newBalance);
          notifyListeners();
          return true;
        }
        return false;
      } catch (e) {
        debugPrint('Update balance error: $e');
        return false;
      }
    }
    return false;
  }

  // Refresh current account data
  Future<void> refreshAccountData() async {
    if (_currentAccount?.accountId != null) {
      try {
        final updatedAccount = await _authService.getAccountById(
          _currentAccount!.accountId!,
        );
        if (updatedAccount != null) {
          _currentAccount = updatedAccount;
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Refresh account data error: $e');
      }
    }
  }

  // Check if email exists (for validation)
  Future<bool> checkEmailExists(String email) async {
    try {
      return await _authService.emailExists(email);
    } catch (e) {
      debugPrint('Check email exists error: $e');
      return false;
    }
  }

  // Validate login form
  Map<String, String?> validateLoginForm(String email, String password) {
    return _loginConfirmation.validateLoginForm(
      email: email,
      password: password,
    );
  }

  // Validate signup form
  Future<Map<String, String?>> validateSignupForm({
    required String username,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    required String accountType,
  }) async {
    return await _signupConfirmation.validateSignupForm(
      username: username,
      email: email,
      phone: phone,
      password: password,
      confirmPassword: confirmPassword,
      accountType: accountType,
    );
  }

  // Get password strength
  int getPasswordStrength(String password) {
    return _signupConfirmation.getPasswordStrength(password);
  }

  // Get password strength description
  String getPasswordStrengthDescription(String password) {
    return _signupConfirmation.getPasswordStrengthDescription(password);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

// Register result class
class RegisterResult {
  final bool success;
  final String message;

  RegisterResult({required this.success, required this.message});
}
