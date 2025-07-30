// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/account.dart';
import '../models/admin.dart';
import '../confirmation/auth_service.dart';
import '../confirmation/login/login_confirmation.dart';
import '../confirmation/signup/signup_confirmation.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  Account? _currentAccount;
  Admin? _currentAdmin;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  UserType _userType = UserType.unknown;

  // Getters
  User? get currentUser => _currentUser;
  Account? get currentAccount => _currentAccount;
  Admin? get currentAdmin => _currentAdmin;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  UserType get userType => _userType;

  // Check if current user is admin
  bool get isAdmin => _userType == UserType.admin && _currentAdmin != null;
  bool get isUser => _userType == UserType.user && _currentAccount != null;

  final AuthService _authService = AuthService.instance;
  final LoginConfirmation _loginConfirmation = LoginConfirmation.instance;
  final SignupConfirmation _signupConfirmation = SignupConfirmation.instance;

  // Universal login method - UPDATED
  Future<bool> login(String email, String password) async {
    _setLoading(true);

    try {
      print('=== UNIVERSAL LOGIN ATTEMPT ===');
      print('Email: $email');

      // Use the new universal authentication
      final result = await _authService.authenticateUser(email, password);

      if (result.success) {
        _userType = result.userType;

        if (result.userType == UserType.admin && result.admin != null) {
          print('✅ Admin login successful');
          _currentAdmin = result.admin;
          _currentUser = User(
            userId: result.admin!.adminId,
            username: result.admin!.username,
            email: result.admin!.email,
          );
          _isAuthenticated = true;
        } else if (result.userType == UserType.user && result.account != null) {
          print('✅ User login successful');
          _currentAccount = result.account;
          _currentUser = User(
            userId: result.account!.accountId,
            username: result.account!.username,
            email: result.account!.email,
          );
          _isAuthenticated = true;
        }

        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        print('❌ Login failed: ${result.errorMessage}');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      print('❌ Login error: $e');
      _setLoading(false);
      return false;
    }
  }

  // Register method - remains same for users only
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
      print('=== USER REGISTRATION ATTEMPT ===');
      print('Username: $username');
      print('Email: $email');
      print('Phone: $phone');
      print('Account Type: $accountType');

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
        print('✅ User registration successful!');

        // Auto-login after successful registration
        _currentAccount = result.account;
        _currentUser = User(
          userId: result.account!.accountId,
          username: result.account!.username,
          email: result.account!.email,
        );
        _userType = UserType.user;
        _isAuthenticated = true;
        notifyListeners();

        return RegisterResult(
          success: true,
          message: 'Account created successfully!',
        );
      } else {
        print('❌ User registration failed: ${result.errorMessage}');
        return RegisterResult(
          success: false,
          message: result.errorMessage ?? 'Registration failed',
        );
      }
    } catch (e) {
      _setLoading(false);
      print('❌ Registration error: $e');
      return RegisterResult(
        success: false,
        message: 'Registration failed: ${e.toString()}',
      );
    }
  }

  // Logout method - UPDATED to handle both user types
  void logout() {
    _currentUser = null;
    _currentAccount = null;
    _currentAdmin = null;
    _isAuthenticated = false;
    _userType = UserType.unknown;
    notifyListeners();
  }

  // Update account balance (for users only)
  Future<bool> updateBalance(double newBalance) async {
    if (_currentAccount != null && _userType == UserType.user) {
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

  // Refresh current account data (for users)
  Future<void> refreshAccountData() async {
    if (_currentAccount?.accountId != null && _userType == UserType.user) {
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

  // Check if email exists and return user type - NEW METHOD
  Future<UserType> checkEmailType(String email) async {
    try {
      return await _authService.detectUserType(email);
    } catch (e) {
      print('❌ Check email type error: $e');
      return UserType.unknown;
    }
  }

  // Check if email exists (for validation) - UPDATED
  Future<bool> checkEmailExists(String email) async {
    try {
      final userType = await _authService.detectUserType(email);
      return userType != UserType.unknown;
    } catch (e) {
      print('❌ Check email exists error: $e');
      return false;
    }
  }

  // Initialize system - NEW METHOD
  Future<void> initializeSystem() async {
    try {
      await _authService.initializeSystem();
    } catch (e) {
      print('❌ Initialize system error: $e');
    }
  }

  // Get current user display name - NEW METHOD
  String getCurrentUserDisplayName() {
    if (_userType == UserType.admin && _currentAdmin != null) {
      return _currentAdmin!.fullName;
    } else if (_userType == UserType.user && _currentAccount != null) {
      return _currentAccount!.username;
    }
    return 'User';
  }

  // Get current user role - NEW METHOD
  String getCurrentUserRole() {
    if (_userType == UserType.admin && _currentAdmin != null) {
      return _currentAdmin!.role.toUpperCase();
    } else if (_userType == UserType.user && _currentAccount != null) {
      return _currentAccount!.accountType.toUpperCase();
    }
    return 'UNKNOWN';
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
