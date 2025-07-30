import 'package:flutter/foundation.dart';
import '../confirmation/forgot_password/forgot_password_service.dart';

class ForgotPasswordProvider with ChangeNotifier {
  bool _isLoading = false;
  int _currentStep = 1; // 1: Email, 2: Code, 3: Password
  String _email = '';
  String _verificationCode = '';
  String? _errorMessage;

  bool get isLoading => _isLoading;
  int get currentStep => _currentStep;
  String get email => _email;
  String get verificationCode => _verificationCode;
  String? get errorMessage => _errorMessage;

  final ForgotPasswordService _forgotPasswordService =
      ForgotPasswordService.instance;

  // Reset to initial state
  void reset() {
    _isLoading = false;
    _currentStep = 1;
    _email = '';
    _verificationCode = '';
    _errorMessage = null;
    notifyListeners();
  }

  // Step 1: Send verification code
  Future<bool> sendVerificationCode(String email) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _forgotPasswordService.sendVerificationCode(email);

      if (result.success) {
        _email = email;
        _verificationCode = result.verificationCode ?? '';
        _currentStep = 2;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError(result.message ?? 'Failed to send verification code');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('An error occurred: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Step 2: Verify code
  bool verifyCode(String inputCode) {
    _clearError();

    final result = _forgotPasswordService.verifyCode(
      inputCode,
      _verificationCode,
    );

    if (result.success) {
      _currentStep = 3;
      notifyListeners();
      return true;
    } else {
      _setError(result.message ?? 'Invalid verification code');
      return false;
    }
  }

  // Step 3: Reset password
  Future<bool> resetPassword(String newPassword, String confirmPassword) async {
    _setLoading(true);
    _clearError();

    // Validate passwords match
    final confirmError = _forgotPasswordService.validateConfirmPassword(
      newPassword,
      confirmPassword,
    );
    if (confirmError != null) {
      _setError(confirmError);
      _setLoading(false);
      return false;
    }

    try {
      final result = await _forgotPasswordService.resetPassword(
        _email,
        newPassword,
      );

      _setLoading(false);

      if (result.success) {
        return true;
      } else {
        _setError(result.message ?? 'Failed to reset password');
        return false;
      }
    } catch (e) {
      _setError('An error occurred: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Resend verification code
  Future<bool> resendVerificationCode() async {
    if (_email.isEmpty) return false;

    _setLoading(true);
    _clearError();

    try {
      final result = await _forgotPasswordService.sendVerificationCode(_email);

      if (result.success) {
        _verificationCode = result.verificationCode ?? '';
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError(result.message ?? 'Failed to resend code');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('An error occurred: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Go back to previous step
  void goToPreviousStep() {
    if (_currentStep > 1) {
      _currentStep--;
      _clearError();
      notifyListeners();
    }
  }

  // Start over
  void startOver() {
    _currentStep = 1;
    _clearError();
    notifyListeners();
  }

  // Validation methods
  String? validateEmail(String email) {
    return _forgotPasswordService.validateEmail(email);
  }

  String? validateVerificationCode(String code) {
    return _forgotPasswordService.validateVerificationCode(code);
  }

  String? validateNewPassword(String password) {
    return _forgotPasswordService.validateNewPassword(password);
  }

  String? validateConfirmPassword(String password, String confirmPassword) {
    return _forgotPasswordService.validateConfirmPassword(
      password,
      confirmPassword,
    );
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Get step description
  String getStepDescription() {
    switch (_currentStep) {
      case 1:
        return 'Enter your email to get started';
      case 2:
        return 'Check your email for verification code';
      case 3:
        return 'Create a new secure password';
      default:
        return '';
    }
  }

  // Get step title
  String getStepTitle() {
    switch (_currentStep) {
      case 1:
        return 'Enter Your Email';
      case 2:
        return 'Enter Verification Code';
      case 3:
        return 'Create New Password';
      default:
        return 'Reset Password';
    }
  }
}
