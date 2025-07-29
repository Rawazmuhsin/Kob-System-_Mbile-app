// lib/screens/user/change_password_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/account_provider.dart';
import '../../confirmation/signup/signup_confirmation.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/input_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final SignupConfirmation _signupConfirmation = SignupConfirmation.instance;

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accountProvider = Provider.of<AccountProvider>(
      context,
      listen: false,
    );
    final account = authProvider.currentAccount;

    if (account?.email == null) {
      _showErrorSnackBar('Account email not found');
      return;
    }

    final success = await accountProvider.changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
      email: account!.email!,
    );

    if (success) {
      _showSuccessSnackBar('Password changed successfully!');
      Navigator.of(context).pop();
    } else {
      _showErrorSnackBar(
        accountProvider.errorMessage ?? 'Failed to change password',
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      appBar: AppBar(
        title: Text(
          'Change Password',
          style: TextStyle(
            color: isDarkMode ? Colors.white : AppColors.darkText,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: isDarkMode ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : AppColors.darkText,
        ),
      ),
      body: Consumer<AccountProvider>(
        builder: (context, accountProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Header Section
                  _buildHeaderSection(isDarkMode),

                  const SizedBox(height: 32),

                  // Password Fields
                  _buildPasswordFields(isDarkMode, accountProvider),

                  const SizedBox(height: 32),

                  // Change Password Button
                  CustomButton(
                    text:
                        accountProvider.isLoading
                            ? 'Changing Password...'
                            : 'Change Password',
                    onPressed:
                        accountProvider.isLoading ? null : _changePassword,
                    isPrimary: true,
                    isLoading: accountProvider.isLoading,
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection(bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.lock_outline, size: 48, color: AppColors.primaryGreen),
          const SizedBox(height: 16),
          Text(
            'Change Your Password',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your current password and choose a new secure password',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.white70 : AppColors.lightText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordFields(
    bool isDarkMode,
    AccountProvider accountProvider,
  ) {
    return Column(
      children: [
        // Current Password Field
        InputField(
          controller: _currentPasswordController,
          label: 'Current Password',
          hintText: 'Enter your current password',
          obscureText: !_showCurrentPassword,
          isDarkMode: isDarkMode,
          suffixIcon: IconButton(
            icon: Icon(
              _showCurrentPassword ? Icons.visibility_off : Icons.visibility,
              color: isDarkMode ? Colors.white70 : AppColors.lightText,
            ),
            onPressed: () {
              setState(() {
                _showCurrentPassword = !_showCurrentPassword;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your current password';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        // New Password Field
        InputField(
          controller: _newPasswordController,
          label: 'New Password',
          hintText: 'Enter your new password',
          obscureText: !_showNewPassword,
          isDarkMode: isDarkMode,
          onChanged: (value) {
            setState(() {}); // Rebuild to update password strength indicator
          },
          suffixIcon: IconButton(
            icon: Icon(
              _showNewPassword ? Icons.visibility_off : Icons.visibility,
              color: isDarkMode ? Colors.white70 : AppColors.lightText,
            ),
            onPressed: () {
              setState(() {
                _showNewPassword = !_showNewPassword;
              });
            },
          ),
          validator:
              (value) => _signupConfirmation.validatePassword(value ?? ''),
        ),

        // Password Strength Indicator
        if (_newPasswordController.text.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildPasswordStrengthIndicator(accountProvider),
        ],

        const SizedBox(height: 20),

        // Confirm Password Field
        InputField(
          controller: _confirmPasswordController,
          label: 'Confirm New Password',
          hintText: 'Confirm your new password',
          obscureText: !_showConfirmPassword,
          isDarkMode: isDarkMode,
          suffixIcon: IconButton(
            icon: Icon(
              _showConfirmPassword ? Icons.visibility_off : Icons.visibility,
              color: isDarkMode ? Colors.white70 : AppColors.lightText,
            ),
            onPressed: () {
              setState(() {
                _showConfirmPassword = !_showConfirmPassword;
              });
            },
          ),
          validator:
              (value) => _signupConfirmation.validateConfirmPassword(
                _newPasswordController.text,
                value ?? '',
              ),
        ),

        const SizedBox(height: 20),

        // Password Requirements
        _buildPasswordRequirements(isDarkMode),
      ],
    );
  }

  Widget _buildPasswordStrengthIndicator(AccountProvider accountProvider) {
    final password = _newPasswordController.text;
    final strength = accountProvider.getPasswordStrength(password);
    final strengthText = accountProvider.getPasswordStrengthDescription(
      password,
    );
    final strengthColor = accountProvider.getPasswordStrengthColor(password);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Password Strength: ',
              style: TextStyle(
                fontSize: 12,
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : AppColors.lightText,
              ),
            ),
            Text(
              strengthText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: strengthColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: strength / 5,
          backgroundColor: Colors.grey.withOpacity(0.3),
          valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
        ),
      ],
    );
  }

  Widget _buildPasswordRequirements(bool isDarkMode) {
    final password = _newPasswordController.text;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? Colors.white.withOpacity(0.03)
                : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password Requirements:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          _buildRequirementItem(
            'At least 8 characters',
            password.length >= 8,
            isDarkMode,
          ),
          _buildRequirementItem(
            'Contains uppercase letter',
            password.contains(RegExp(r'[A-Z]')),
            isDarkMode,
          ),
          _buildRequirementItem(
            'Contains lowercase letter',
            password.contains(RegExp(r'[a-z]')),
            isDarkMode,
          ),
          _buildRequirementItem(
            'Contains number',
            password.contains(RegExp(r'[0-9]')),
            isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool isMet, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color:
                isMet
                    ? AppColors.primaryGreen
                    : (isDarkMode ? Colors.white30 : Colors.grey),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color:
                  isMet
                      ? (isDarkMode ? Colors.white : AppColors.darkText)
                      : (isDarkMode ? Colors.white70 : AppColors.lightText),
            ),
          ),
        ],
      ),
    );
  }
}
