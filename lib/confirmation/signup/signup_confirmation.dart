import '../../models/account.dart';
import '../auth_service.dart';

// Signup result class
class SignupResult {
  final bool success;
  final Account? account;
  final String? errorMessage;

  SignupResult({required this.success, this.account, this.errorMessage});
}

class SignupConfirmation {
  static final SignupConfirmation _instance = SignupConfirmation._internal();
  static SignupConfirmation get instance => _instance;

  SignupConfirmation._internal();

  final AuthService _authService = AuthService.instance;

  // Validate individual fields
  String? validateUsername(String username) {
    if (username.isEmpty) {
      return 'Please enter your full name';
    }
    if (username.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (username.trim().length > 50) {
      return 'Name must be less than 50 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(username.trim())) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  String? validateEmail(String email) {
    if (email.isEmpty) {
      return 'Please enter your email';
    }
    if (!_authService.isValidEmail(email)) {
      return 'Please enter a valid email address';
    }
    if (email.length > 255) {
      return 'Email is too long';
    }
    return null;
  }

  String? validatePhone(String phone) {
    if (phone.isEmpty) {
      return 'Please enter your phone number';
    }
    if (!_authService.isValidPhone(phone)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Please enter your password';
    }
    if (!_authService.isStrongPassword(password)) {
      return 'Password must be at least 8 characters with uppercase, lowercase, and number';
    }
    return null;
  }

  String? validateConfirmPassword(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? validateAccountType(String accountType) {
    if (accountType.isEmpty) {
      return 'Please select an account type';
    }
    if (!['Checking', 'Savings'].contains(accountType)) {
      return 'Invalid account type';
    }
    return null;
  }

  // Check if email is available
  Future<String?> validateEmailAvailability(String email) async {
    try {
      final emailError = validateEmail(email);
      if (emailError != null) {
        return emailError;
      }

      final exists = await _authService.emailExists(email);
      if (exists) {
        return 'Email address is already registered';
      }
      return null;
    } catch (e) {
      return 'Error checking email availability';
    }
  }

  // Validate entire signup form
  Future<Map<String, String?>> validateSignupForm({
    required String username,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    required String accountType,
  }) async {
    return {
      'username': validateUsername(username),
      'email': await validateEmailAvailability(email),
      'phone': validatePhone(phone),
      'password': validatePassword(password),
      'confirmPassword': validateConfirmPassword(password, confirmPassword),
      'accountType': validateAccountType(accountType),
    };
  }

  // Perform signup
  Future<SignupResult> performSignup({
    required String username,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    required String accountType,
  }) async {
    try {
      // Validate all fields
      final validationErrors = await validateSignupForm(
        username: username,
        email: email,
        phone: phone,
        password: password,
        confirmPassword: confirmPassword,
        accountType: accountType,
      );

      // Check if there are any validation errors
      final firstError = validationErrors.values.firstWhere(
        (error) => error != null,
        orElse: () => null,
      );

      if (firstError != null) {
        return SignupResult(success: false, errorMessage: firstError);
      }

      // Create account
      final account = await _authService.createAccount(
        username: username,
        email: email,
        password: password,
        phone: phone,
        accountType: accountType,
      );

      if (account != null) {
        return SignupResult(success: true, account: account);
      } else {
        return SignupResult(
          success: false,
          errorMessage: 'Failed to create account. Please try again.',
        );
      }
    } catch (e) {
      return SignupResult(
        success: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  // Quick validation for real-time feedback
  bool isSignupFormValid({
    required String username,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    required String accountType,
  }) {
    return validateUsername(username) == null &&
        validateEmail(email) == null &&
        validatePhone(phone) == null &&
        validatePassword(password) == null &&
        validateConfirmPassword(password, confirmPassword) == null &&
        validateAccountType(accountType) == null;
  }

  // Get password strength level
  int getPasswordStrength(String password) {
    int strength = 0;

    if (password.length >= 8) strength++;
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;

    return strength;
  }

  // Get password strength description
  String getPasswordStrengthDescription(String password) {
    final strength = getPasswordStrength(password);

    switch (strength) {
      case 0:
      case 1:
        return 'Very Weak';
      case 2:
        return 'Weak';
      case 3:
        return 'Fair';
      case 4:
        return 'Good';
      case 5:
        return 'Strong';
      default:
        return 'Weak';
    }
  }
}
