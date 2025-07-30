import '../../models/account.dart';
import '../auth_service.dart';

// Login result class
class LoginResult {
  final bool success;
  final Account? account;
  final String? errorMessage;

  LoginResult({required this.success, this.account, this.errorMessage});
}

class LoginConfirmation {
  static final LoginConfirmation _instance = LoginConfirmation._internal();
  static LoginConfirmation get instance => _instance;

  LoginConfirmation._internal();

  final AuthService _authService = AuthService.instance;

  // Validate login inputs
  String? validateEmail(String email) {
    if (email.isEmpty) {
      return 'Please enter your email';
    }
    if (!_authService.isValidEmail(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Please enter your password';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // Perform login
  Future<LoginResult> performLogin({
    required String email,
    required String password,
  }) async {
    try {
      // Validate inputs
      final emailError = validateEmail(email);
      if (emailError != null) {
        return LoginResult(success: false, errorMessage: emailError);
      }

      final passwordError = validatePassword(password);
      if (passwordError != null) {
        return LoginResult(success: false, errorMessage: passwordError);
      }

      // Authenticate user
      final account = await _authService.authenticate(email, password);

      if (account != null) {
        return LoginResult(success: true, account: account);
      } else {
        return LoginResult(
          success: false,
          errorMessage:
              'Invalid email or password. Please check your credentials and try again.',
        );
      }
    } catch (e) {
      return LoginResult(
        success: false,
        errorMessage: 'Login failed: ${e.toString()}',
      );
    }
  }

  // Check if user exists
  Future<bool> checkUserExists(String email) async {
    try {
      return await _authService.emailExists(email);
    } catch (e) {
      return false;
    }
  }

  // Validate login form
  Map<String, String?> validateLoginForm({
    required String email,
    required String password,
  }) {
    return {
      'email': validateEmail(email),
      'password': validatePassword(password),
    };
  }

  // Quick login validation (for real-time feedback)
  bool isLoginFormValid({required String email, required String password}) {
    final errors = validateLoginForm(email: email, password: password);
    return errors.values.every((error) => error == null);
  }
}
