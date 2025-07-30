import '../auth_service.dart';

class ForgotPasswordResult {
  final bool success;
  final String? message;
  final String? verificationCode;

  ForgotPasswordResult({
    required this.success,
    this.message,
    this.verificationCode,
  });
}

class ForgotPasswordService {
  static final ForgotPasswordService _instance =
      ForgotPasswordService._internal();
  static ForgotPasswordService get instance => _instance;

  ForgotPasswordService._internal();

  final AuthService _authService = AuthService.instance;

  // Generate random verification code
  String _generateVerificationCode() {
    final random = DateTime.now().millisecondsSinceEpoch % 999999;
    return random.toString().padLeft(6, '0');
  }

  // Step 1: Send verification code
  Future<ForgotPasswordResult> sendVerificationCode(String email) async {
    try {
      // Validate email
      if (!_authService.isValidEmail(email)) {
        return ForgotPasswordResult(
          success: false,
          message: 'Please enter a valid email address',
        );
      }

      // Check if email exists
      final emailExists = await _authService.emailExists(email);
      if (!emailExists) {
        return ForgotPasswordResult(
          success: false,
          message: 'No account found with this email address',
        );
      }

      // Generate verification code
      final verificationCode = _generateVerificationCode();

      // In real app, send email here
      // await EmailService.sendVerificationCode(email, verificationCode);

      return ForgotPasswordResult(
        success: true,
        message: 'Verification code sent to your email',
        verificationCode: verificationCode, // Remove this in production
      );
    } catch (e) {
      return ForgotPasswordResult(
        success: false,
        message: 'Failed to send verification code: ${e.toString()}',
      );
    }
  }

  // Step 2: Verify code
  ForgotPasswordResult verifyCode(String inputCode, String expectedCode) {
    if (inputCode.trim() == expectedCode) {
      return ForgotPasswordResult(
        success: true,
        message: 'Code verified successfully',
      );
    } else {
      return ForgotPasswordResult(
        success: false,
        message: 'Invalid verification code',
      );
    }
  }

  // Step 3: Reset password
  Future<ForgotPasswordResult> resetPassword(
    String email,
    String newPassword,
  ) async {
    try {
      // Validate password
      if (!_authService.isStrongPassword(newPassword)) {
        return ForgotPasswordResult(
          success: false,
          message:
              'Password must be at least 8 characters with uppercase, lowercase, and number',
        );
      }

      // Reset password using AuthService
      final success = await _authService.resetPassword(email, newPassword);

      if (success) {
        return ForgotPasswordResult(
          success: true,
          message: 'Password reset successfully',
        );
      } else {
        return ForgotPasswordResult(
          success: false,
          message: 'Failed to reset password',
        );
      }
    } catch (e) {
      return ForgotPasswordResult(
        success: false,
        message: 'Password reset failed: ${e.toString()}',
      );
    }
  }

  // Validation methods
  String? validateEmail(String email) {
    if (email.isEmpty) {
      return 'Please enter your email';
    }
    if (!_authService.isValidEmail(email)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validateVerificationCode(String code) {
    if (code.isEmpty) {
      return 'Please enter the verification code';
    }
    if (code.length != 6) {
      return 'Code must be 6 digits';
    }
    return null;
  }

  String? validateNewPassword(String password) {
    if (password.isEmpty) {
      return 'Please enter new password';
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
}
