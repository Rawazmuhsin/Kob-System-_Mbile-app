// lib/screens/auth/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/input_field.dart';
import '../../routes/app_routes.dart';
import '../../providers/theme_provider.dart';
import '../../providers/forgot_password_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    // Reset provider state when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ForgotPasswordProvider>(context, listen: false).reset();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Handle step 1: Send verification code
  Future<void> _handleSendCode() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<ForgotPasswordProvider>(
      context,
      listen: false,
    );
    final success = await provider.sendVerificationCode(
      _emailController.text.trim(),
    );

    if (success) {
      _showSuccessMessage('Verification code sent to your email!');
      // Show code using snackbar to avoid freezing
      _showVerificationCodeSnackbar(provider.verificationCode);
    } else {
      _showErrorMessage(provider.errorMessage ?? 'Failed to send code');
    }
  }

  // Handle step 2: Verify code
  void _handleVerifyCode() {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<ForgotPasswordProvider>(
      context,
      listen: false,
    );
    final success = provider.verifyCode(_codeController.text.trim());

    if (success) {
      _showSuccessMessage('Code verified! Enter your new password.');
    } else {
      _showErrorMessage(provider.errorMessage ?? 'Invalid code');
    }
  }

  // Handle step 3: Reset password
  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<ForgotPasswordProvider>(
      context,
      listen: false,
    );
    final success = await provider.resetPassword(
      _newPasswordController.text,
      _confirmPasswordController.text,
    );

    if (success) {
      _showSuccessDialog();
    } else {
      _showErrorMessage(provider.errorMessage ?? 'Failed to reset password');
    }
  }

  // Resend verification code
  Future<void> _handleResendCode() async {
    final provider = Provider.of<ForgotPasswordProvider>(
      context,
      listen: false,
    );
    final success = await provider.resendVerificationCode();

    if (success) {
      _showSuccessMessage('New verification code sent!');
      _showVerificationCodeSnackbar(provider.verificationCode);
    } else {
      _showErrorMessage(provider.errorMessage ?? 'Failed to resend code');
    }
  }

  // Show verification code as snackbar (no freezing)
  void _showVerificationCodeSnackbar(String code) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.email, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text(
                    'Verification Code (Demo):',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      code,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3.0,
                        color: Colors.white,
                      ),
                    ),
                    const Icon(Icons.copy, color: Colors.white),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter this code in the next step',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ),
        backgroundColor: AppColors.primaryGreen,
        duration: const Duration(seconds: 10),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Got it!',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Show success dialog
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 32),
                const SizedBox(width: 12),
                const Text('Success!'),
              ],
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.security, color: Colors.green, size: 64),
                SizedBox(height: 16),
                Text(
                  'Your password has been reset successfully!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'You can now login with your new password.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  AppRoutes.navigateToLogin(context); // Go to login
                },
                child: Text(
                  'Go to Login',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  // Helper methods for messages
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, ForgotPasswordProvider>(
      builder: (context, themeProvider, forgotProvider, child) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors:
                    isDarkMode
                        ? AppColors.darkGradient
                        : AppColors.lightGradient,
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    children: [
                      _buildHeader(isDarkMode, forgotProvider),
                      _buildProgressIndicator(isDarkMode, forgotProvider),
                      _buildContent(isDarkMode, forgotProvider),
                      _buildFooter(isDarkMode, forgotProvider),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDarkMode, ForgotPasswordProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(top: 40, bottom: 30),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color:
                      isDarkMode
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color:
                        isDarkMode
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.black.withValues(alpha: 0.1),
                  ),
                ),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.arrow_back,
                    color: isDarkMode ? Colors.white : AppColors.darkText,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          const AppLogo(size: 70),
          const SizedBox(height: 16),
          ShaderMask(
            shaderCallback:
                (bounds) => const LinearGradient(
                  colors: [Color(0xFF1F2937), Color(0xFF10B981)],
                ).createShader(bounds),
            child: Text(
              provider.getStepTitle(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            provider.getStepDescription(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color:
                  isDarkMode
                      ? Colors.white.withValues(alpha: 0.8)
                      : AppColors.lightText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(
    bool isDarkMode,
    ForgotPasswordProvider provider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      child: Row(
        children: List.generate(3, (index) {
          final stepNumber = index + 1;
          final isActive = stepNumber <= provider.currentStep;

          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
              decoration: BoxDecoration(
                color:
                    isActive
                        ? AppColors.primaryGreen
                        : isDarkMode
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildContent(bool isDarkMode, ForgotPasswordProvider provider) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (provider.currentStep == 1) _buildEmailStep(isDarkMode, provider),
          if (provider.currentStep == 2) _buildCodeStep(isDarkMode, provider),
          if (provider.currentStep == 3)
            _buildPasswordStep(isDarkMode, provider),
        ],
      ),
    );
  }

  Widget _buildEmailStep(bool isDarkMode, ForgotPasswordProvider provider) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color:
                isDarkMode
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  isDarkMode
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.email_outlined,
                size: 64,
                color: AppColors.primaryGreen,
              ),
              const SizedBox(height: 16),
              Text(
                'Enter Your Email',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : AppColors.darkText,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Enter the email address associated with your account. We\'ll send you a verification code to reset your password.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color:
                      isDarkMode
                          ? Colors.white.withValues(alpha: 0.8)
                          : AppColors.lightText,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        InputField(
          controller: _emailController,
          label: 'Email Address',
          hintText: 'Enter your registered email',
          keyboardType: TextInputType.emailAddress,
          isDarkMode: isDarkMode,
          validator: (value) => provider.validateEmail(value ?? ''),
        ),
        const SizedBox(height: 32),
        CustomButton(
          text:
              provider.isLoading ? 'Sending Code...' : 'Send Verification Code',
          onPressed: provider.isLoading ? null : _handleSendCode,
          isPrimary: true,
          isLoading: provider.isLoading,
        ),
      ],
    );
  }

  Widget _buildCodeStep(bool isDarkMode, ForgotPasswordProvider provider) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color:
                isDarkMode
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  isDarkMode
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: [
              Icon(Icons.security, size: 64, color: AppColors.primaryGreen),
              const SizedBox(height: 16),
              Text(
                'Enter Verification Code',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : AppColors.darkText,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Enter the 6-digit verification code that was shown to you in the previous step.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color:
                      isDarkMode
                          ? Colors.white.withValues(alpha: 0.8)
                          : AppColors.lightText,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        InputField(
          controller: _codeController,
          label: 'Verification Code',
          hintText: 'Enter 6-digit code',
          keyboardType: TextInputType.number,
          isDarkMode: isDarkMode,
          validator: (value) => provider.validateVerificationCode(value ?? ''),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _handleResendCode,
          child: Text(
            'Didn\'t receive code? Resend',
            style: TextStyle(
              color: AppColors.primaryGreen,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 16),
        CustomButton(
          text: 'Verify Code',
          onPressed: _handleVerifyCode,
          isPrimary: true,
        ),
      ],
    );
  }

  Widget _buildPasswordStep(bool isDarkMode, ForgotPasswordProvider provider) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color:
                isDarkMode
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  isDarkMode
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: [
              Icon(Icons.lock_reset, size: 64, color: AppColors.primaryGreen),
              const SizedBox(height: 16),
              Text(
                'Create New Password',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : AppColors.darkText,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Choose a strong password for your account. Make sure it\'s at least 8 characters with uppercase, lowercase, and numbers.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color:
                      isDarkMode
                          ? Colors.white.withValues(alpha: 0.8)
                          : AppColors.lightText,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        InputField(
          controller: _newPasswordController,
          label: 'New Password',
          hintText: 'Enter new password',
          obscureText: !_showNewPassword,
          isDarkMode: isDarkMode,
          validator: (value) => provider.validateNewPassword(value ?? ''),
        ),
        const SizedBox(height: 20),
        InputField(
          controller: _confirmPasswordController,
          label: 'Confirm New Password',
          hintText: 'Confirm new password',
          obscureText: !_showConfirmPassword,
          isDarkMode: isDarkMode,
          validator:
              (value) => provider.validateConfirmPassword(
                _newPasswordController.text,
                value ?? '',
              ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: CheckboxListTile(
                title: const Text('Show passwords'),
                value: _showNewPassword,
                onChanged: (value) {
                  setState(() {
                    _showNewPassword = value!;
                    _showConfirmPassword = value;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        CustomButton(
          text: provider.isLoading ? 'Resetting Password...' : 'Reset Password',
          onPressed: provider.isLoading ? null : _handleResetPassword,
          isPrimary: true,
          isLoading: provider.isLoading,
        ),
      ],
    );
  }

  Widget _buildFooter(bool isDarkMode, ForgotPasswordProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back, size: 16, color: AppColors.primaryGreen),
                const SizedBox(width: 8),
                Text(
                  'Back to Login',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (provider.currentStep > 1)
            TextButton(
              onPressed: provider.startOver,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, size: 16, color: AppColors.primaryGreen),
                  const SizedBox(width: 8),
                  Text(
                    'Start Over',
                    style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
