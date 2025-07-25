import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/input_field.dart';
import '../../routes/app_routes.dart';
import '../../core/utils.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;
  bool _emailChecking = false;
  String _selectedAccountType = 'Checking';
  String? _emailError;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Check email availability as user types
  void _checkEmailAvailability() async {
    final email = _emailController.text.trim();
    if (email.isNotEmpty && AppUtils.isValidEmail(email)) {
      setState(() {
        _emailChecking = true;
        _emailError = null;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final exists = await authProvider.checkEmailExists(email);

      if (mounted) {
        setState(() {
          _emailChecking = false;
          _emailError = exists ? 'Email address is already registered' : null;
        });
      }
    }
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate() && _emailError == null) {
      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      try {
        final result = await authProvider.register(
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
          phone: _phoneController.text.trim(),
          accountType: _selectedAccountType,
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          if (result.success) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Welcome to KOB, ${_usernameController.text}! Your account has been created successfully.',
                ),
                backgroundColor: AppColors.primaryGreen,
                duration: const Duration(seconds: 3),
              ),
            );

            // Navigate to dashboard (user is auto-logged in)
            AppRoutes.navigateToDashboard(context);
          } else {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
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
              content: Text('Registration failed: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  // Get password strength color
  Color _getPasswordStrengthColor(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.amber;
      case 4:
        return AppColors.primaryGreen;
      case 5:
        return Colors.green[700]!;
      default:
        return Colors.grey;
    }
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
                        _buildRegistrationForm(isDarkMode),
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
      padding: const EdgeInsets.only(top: 40, bottom: 30),
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
              const AppLogo(size: 70),
              const SizedBox(height: 16),
              ShaderMask(
                shaderCallback:
                    (bounds) => const LinearGradient(
                      colors: [Color(0xFF1F2937), Color(0xFF10B981)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ).createShader(bounds),
                child: const Text(
                  'Create Your Account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Join KOB and start your banking journey',
                style: TextStyle(
                  fontSize: 16,
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

  Widget _buildRegistrationForm(bool isDarkMode) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          InputField(
            controller: _usernameController,
            label: 'Full Name',
            hintText: 'Enter your full name',
            isDarkMode: isDarkMode,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your full name';
              }
              if (value.trim().length < 2) {
                return 'Name must be at least 2 characters';
              }
              if (value.trim().length > 50) {
                return 'Name must be less than 50 characters';
              }
              if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
                return 'Name can only contain letters and spaces';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Email Field with availability checking
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InputField(
                controller: _emailController,
                label: 'Email Address',
                hintText: 'Enter your email address',
                keyboardType: TextInputType.emailAddress,
                isDarkMode: isDarkMode,
                onChanged: (value) {
                  // Check email availability as user types (with debounce)
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (_emailController.text == value) {
                      _checkEmailAvailability();
                    }
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!AppUtils.isValidEmail(value)) {
                    return 'Please enter a valid email';
                  }
                  if (_emailError != null) {
                    return _emailError;
                  }
                  return null;
                },
              ),
              if (_emailChecking)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryGreen,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Checking availability...',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isDarkMode
                                  ? Colors.white.withOpacity(0.7)
                                  : AppColors.lightText,
                        ),
                      ),
                    ],
                  ),
                ),
              if (_emailError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 12),
                  child: Text(
                    _emailError!,
                    style: const TextStyle(fontSize: 12, color: Colors.red),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          InputField(
            controller: _phoneController,
            label: 'Phone Number',
            hintText: 'Enter your phone number',
            keyboardType: TextInputType.phone,
            isDarkMode: isDarkMode,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              if (!AppUtils.isValidPhone(value)) {
                return 'Please enter a valid phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Account Type Selection
          _buildAccountTypeSelection(isDarkMode),
          const SizedBox(height: 20),

          // Password Field with strength indicator
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InputField(
                controller: _passwordController,
                label: 'Password',
                hintText: 'Enter your password',
                obscureText: !_showPassword,
                isDarkMode: isDarkMode,
                onChanged: (value) {
                  setState(() {}); // Rebuild for password strength indicator
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (!AppUtils.isStrongPassword(value)) {
                    return 'Password must be at least 8 characters with uppercase, lowercase, and number';
                  }
                  return null;
                },
              ),
              if (_passwordController.text.isNotEmpty)
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    final strength = authProvider.getPasswordStrength(
                      _passwordController.text,
                    );
                    final description = authProvider
                        .getPasswordStrengthDescription(
                          _passwordController.text,
                        );

                    return Padding(
                      padding: const EdgeInsets.only(top: 8, left: 12),
                      child: Row(
                        children: [
                          Text(
                            'Password strength: ',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  isDarkMode
                                      ? Colors.white.withOpacity(0.7)
                                      : AppColors.lightText,
                            ),
                          ),
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _getPasswordStrengthColor(strength),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 20),

          InputField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            hintText: 'Confirm your password',
            obscureText: !_showConfirmPassword,
            isDarkMode: isDarkMode,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Password visibility toggles
          _buildPasswordToggles(isDarkMode),
          const SizedBox(height: 32),

          CustomButton(
            text: _isLoading ? 'Creating Account...' : 'Create Account',
            onPressed:
                (_isLoading || _emailChecking || _emailError != null)
                    ? null
                    : _handleRegister,
            isPrimary: true,
            isLoading: _isLoading,
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account? ',
                style: TextStyle(
                  color:
                      isDarkMode
                          ? Colors.white.withOpacity(0.8)
                          : AppColors.lightText,
                ),
              ),
              TextButton(
                onPressed: () => AppRoutes.navigateToLogin(context),
                child: Text(
                  'Sign In',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTypeSelection(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : AppColors.darkText,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color:
                isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isDarkMode
                      ? Colors.white.withOpacity(0.15)
                      : Colors.black.withOpacity(0.15),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: Text(
                    'Checking',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : AppColors.darkText,
                    ),
                  ),
                  value: 'Checking',
                  groupValue: _selectedAccountType,
                  onChanged: (value) {
                    setState(() {
                      _selectedAccountType = value!;
                    });
                  },
                  activeColor: AppColors.primaryGreen,
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: Text(
                    'Savings',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : AppColors.darkText,
                    ),
                  ),
                  value: 'Savings',
                  groupValue: _selectedAccountType,
                  onChanged: (value) {
                    setState(() {
                      _selectedAccountType = value!;
                    });
                  },
                  activeColor: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordToggles(bool isDarkMode) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Checkbox(
                value: _showPassword,
                onChanged: (value) {
                  setState(() {
                    _showPassword = value!;
                  });
                },
                activeColor: AppColors.primaryDark,
              ),
              Expanded(
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
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Checkbox(
                value: _showConfirmPassword,
                onChanged: (value) {
                  setState(() {
                    _showConfirmPassword = value!;
                  });
                },
                activeColor: AppColors.primaryDark,
              ),
              Expanded(
                child: Text(
                  'Show confirm',
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        isDarkMode
                            ? Colors.white.withOpacity(0.8)
                            : AppColors.lightText,
                  ),
                ),
              ),
            ],
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
