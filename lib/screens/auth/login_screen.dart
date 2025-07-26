// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/input_field.dart';
import '../../routes/app_routes.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _rememberMe = false;
  bool _showPassword = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  void _toggleRememberMe() {
    setState(() {
      _rememberMe = !_rememberMe;
    });
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      try {
        final success = await authProvider.login(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          if (success) {
            // Show success message with user's name
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Welcome back, ${authProvider.currentAccount?.username ?? 'User'}!',
                ),
                backgroundColor: AppColors.primaryGreen,
                duration: const Duration(seconds: 2),
              ),
            );

            // Navigate to dashboard
            AppRoutes.navigateToDashboard(context);
          } else {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Invalid email or password. Please check your credentials and try again.',
                ),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login failed: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }
  // Update the _handleForgotPassword method in your login_screen.dart

  void _handleForgotPassword() {
    AppRoutes.navigateToForgotPassword(context);
  }

  void _handleCreateAccount() {
    AppRoutes.navigateToRegister(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
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
                child: Padding(
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
                        _buildHeader(isDarkMode),
                        _buildWelcomeSection(isDarkMode),
                        _buildLoginForm(isDarkMode),
                        _buildFooter(isDarkMode),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(top: 40, bottom: 40),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color:
                    isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color:
                      isDarkMode
                          ? Colors.white.withOpacity(0.2)
                          : Colors.black.withOpacity(0.1),
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
          ),
          Column(
            children: [
              const SizedBox(height: 30),
              const AppLogo(),
              const SizedBox(height: 20),
              Text(
                AppConstants.appSubtitle,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : AppColors.darkText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppConstants.appTagline,
                style: TextStyle(
                  fontSize: 14,
                  color:
                      isDarkMode
                          ? Colors.white.withOpacity(0.8)
                          : AppColors.lightText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(bool isDarkMode) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 30),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? Colors.white.withOpacity(0.1)
                : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isDarkMode
                  ? Colors.white.withOpacity(0.2)
                  : Colors.black.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Welcome Back!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? Colors.white : AppColors.darkText,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Log in to access your accounts, transfer funds, and manage your banking needs securely.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color:
                  isDarkMode
                      ? Colors.white.withOpacity(0.8)
                      : AppColors.lightText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(bool isDarkMode) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          ShaderMask(
            shaderCallback:
                (bounds) => const LinearGradient(
                  colors: [Color(0xFF1F2937), Color(0xFF10B981)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ).createShader(bounds),
            child: const Text(
              'Login to Your Account',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Enter your credentials to access your account',
            style: TextStyle(
              fontSize: 16,
              color:
                  isDarkMode
                      ? Colors.white.withOpacity(0.8)
                      : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 32),

          // Email Field
          InputField(
            controller: _emailController,
            label: 'Email Address',
            hintText: 'Enter your email address',
            keyboardType: TextInputType.emailAddress,
            isDarkMode: isDarkMode,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Password Field
          InputField(
            controller: _passwordController,
            label: 'Password',
            hintText: 'Enter your password',
            obscureText: !_showPassword,
            isDarkMode: isDarkMode,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Form Options
          _buildFormOptions(isDarkMode),
          const SizedBox(height: 32),

          // Login Button
          CustomButton(
            text: _isLoading ? 'Logging in...' : 'Login',
            onPressed: _isLoading ? null : _handleLogin,
            isPrimary: true,
            isLoading: _isLoading,
          ),
          const SizedBox(height: 16),

          // Forgot Password
          TextButton(
            onPressed: _handleForgotPassword,
            child: Text(
              'Forgot your password?',
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Divider
          _buildDivider(isDarkMode),
          const SizedBox(height: 24),

          // Create Account Button
          CustomButton(
            text: 'Create New Account',
            onPressed: _handleCreateAccount,
            isPrimary: false,
          ),
        ],
      ),
    );
  }

  Widget _buildFormOptions(bool isDarkMode) {
    return Column(
      children: [
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (value) => _toggleRememberMe(),
              activeColor: AppColors.primaryDark,
            ),
            Expanded(
              child: GestureDetector(
                onTap: _toggleRememberMe,
                child: Text(
                  'Remember me',
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        isDarkMode
                            ? Colors.white.withOpacity(0.8)
                            : AppColors.lightText,
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Checkbox(
              value: _showPassword,
              onChanged: (value) => _togglePasswordVisibility(),
              activeColor: AppColors.primaryDark,
            ),
            Expanded(
              child: GestureDetector(
                onTap: _togglePasswordVisibility,
                child: Text(
                  'Show password',
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        isDarkMode
                            ? Colors.white.withOpacity(0.8)
                            : AppColors.lightText,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDivider(bool isDarkMode) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color:
                isDarkMode
                    ? Colors.white.withOpacity(0.2)
                    : Colors.black.withOpacity(0.1),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(
              fontSize: 14,
              color:
                  isDarkMode
                      ? Colors.white.withOpacity(0.8)
                      : AppColors.lightText,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color:
                isDarkMode
                    ? Colors.white.withOpacity(0.2)
                    : Colors.black.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, top: 20),
      child: TextButton(
        onPressed: () => Navigator.pop(context),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back, size: 16, color: AppColors.primaryGreen),
            const SizedBox(width: 8),
            Text(
              'Back to Homepage',
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
