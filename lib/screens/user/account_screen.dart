// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/account_provider.dart';
import '../../confirmation/signup/signup_confirmation.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/input_field.dart';
import 'change_password_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final SignupConfirmation _signupConfirmation = SignupConfirmation.instance;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final account = authProvider.currentAccount;

    if (account != null) {
      _usernameController.text = account.username;
      _emailController.text = account.email ?? '';
      _phoneController.text = account.phone;

      // Set current account ID and load profile image
      final accountProvider = Provider.of<AccountProvider>(
        context,
        listen: false,
      );
      accountProvider.setCurrentAccountId(account.accountId!);
      accountProvider.loadProfileImage();
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final accountProvider = Provider.of<AccountProvider>(
      context,
      listen: false,
    );
    final account = authProvider.currentAccount;

    if (account?.accountId == null) return;

    final success = await accountProvider.updateAccountInfo(
      accountId: account!.accountId!,
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    if (success) {
      setState(() {
        _isEditing = false;
      });

      _showSuccessSnackBar('Account updated successfully!');

      // Refresh account data
      await authProvider.refreshAccountData();
    } else {
      _showErrorSnackBar(
        accountProvider.errorMessage ?? 'Failed to update account',
      );
    }
  }

  void _showImagePickerDialog() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? AppColors.darkSurface : Colors.white,
          title: Text(
            'Select Profile Picture',
            style: TextStyle(
              color: isDarkMode ? Colors.white : AppColors.darkText,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _takePhoto();
                },
              ),
              if (Provider.of<AccountProvider>(context).profileImage != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Photo'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _removePhoto();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromGallery() async {
    final accountProvider = Provider.of<AccountProvider>(
      context,
      listen: false,
    );
    final success = await accountProvider.pickProfileImage();

    if (!success && accountProvider.errorMessage != null) {
      _showErrorSnackBar(accountProvider.errorMessage!);
    }
  }

  Future<void> _takePhoto() async {
    final accountProvider = Provider.of<AccountProvider>(
      context,
      listen: false,
    );
    final success = await accountProvider.takeProfilePhoto();

    if (!success && accountProvider.errorMessage != null) {
      _showErrorSnackBar(accountProvider.errorMessage!);
    }
  }

  Future<void> _removePhoto() async {
    final accountProvider = Provider.of<AccountProvider>(
      context,
      listen: false,
    );
    await accountProvider.removeProfileImage();
  }

  void _navigateToChangePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
    );
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
          'My Account',
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
        actions: [
          if (!_isEditing)
            IconButton(
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              icon: const Icon(Icons.edit),
            ),
          if (_isEditing)
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _loadUserData(); // Reset form
                });
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : AppColors.lightText,
                ),
              ),
            ),
        ],
      ),
      body: Consumer2<AuthProvider, AccountProvider>(
        builder: (context, authProvider, accountProvider, child) {
          final account = authProvider.currentAccount;

          if (account == null) {
            return Center(
              child: Text(
                'No account data found',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : AppColors.lightText,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // Profile Picture Section
                  _buildProfilePictureSection(
                    context,
                    isDarkMode,
                    accountProvider,
                    account,
                  ),

                  const SizedBox(height: 32),

                  // Account Information Card
                  _buildAccountInfoCard(context, isDarkMode, account),

                  const SizedBox(height: 24),

                  // Form Fields
                  _buildFormFields(isDarkMode),

                  const SizedBox(height: 32),

                  // Action Buttons
                  _buildActionButtons(accountProvider),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfilePictureSection(
    BuildContext context,
    bool isDarkMode,
    AccountProvider accountProvider,
    dynamic account,
  ) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryGreen, width: 3),
              ),
              child: ClipOval(
                child:
                    accountProvider.profileImage != null
                        ? Image.file(
                          accountProvider.profileImage!,
                          fit: BoxFit.cover,
                          width: 120,
                          height: 120,
                        )
                        : Container(
                          color: AppColors.primaryGreen.withOpacity(0.1),
                          child: Center(
                            child: Text(
                              account.username.substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ),
                        ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _showImagePickerDialog,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDarkMode ? AppColors.darkSurface : Colors.white,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          account.username,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : AppColors.darkText,
          ),
        ),
        Text(
          '${account.accountType} Account',
          style: TextStyle(
            fontSize: 16,
            color: isDarkMode ? Colors.white70 : AppColors.lightText,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountInfoCard(
    BuildContext context,
    bool isDarkMode,
    dynamic account,
  ) {
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
          _buildInfoRow(
            'Account Number',
            account.accountNumber ?? 'Not provided',
            Icons.credit_card,
            isDarkMode,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'Balance',
            '\$${account.balance.toStringAsFixed(2)}',
            Icons.account_balance_wallet,
            isDarkMode,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'Member Since',
            account.createdAt != null
                ? '${account.createdAt!.year}'
                : 'Unknown',
            Icons.calendar_today,
            isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon,
    bool isDarkMode,
  ) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryGreen, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.white70 : AppColors.lightText,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : AppColors.darkText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields(bool isDarkMode) {
    return Column(
      children: [
        // Username Field
        InputField(
          controller: _usernameController,
          label: 'Username',
          hintText: 'Enter your username',
          isDarkMode: isDarkMode,
          enabled: _isEditing,
          validator:
              (value) => _signupConfirmation.validateUsername(value ?? ''),
        ),
        const SizedBox(height: 20),

        // Email Field
        InputField(
          controller: _emailController,
          label: 'Email Address',
          hintText: 'Enter your email address',
          keyboardType: TextInputType.emailAddress,
          isDarkMode: isDarkMode,
          enabled: _isEditing,
          validator: (value) => _signupConfirmation.validateEmail(value ?? ''),
        ),
        const SizedBox(height: 20),

        // Phone Field
        InputField(
          controller: _phoneController,
          label: 'Phone Number',
          hintText: 'Enter your phone number',
          keyboardType: TextInputType.phone,
          isDarkMode: isDarkMode,
          enabled: _isEditing,
          validator: (value) => _signupConfirmation.validatePhone(value ?? ''),
        ),
      ],
    );
  }

  Widget _buildActionButtons(AccountProvider accountProvider) {
    return Column(
      children: [
        // Save/Edit Button
        if (_isEditing)
          CustomButton(
            text: accountProvider.isLoading ? 'Saving...' : 'Save Changes',
            onPressed: accountProvider.isLoading ? null : _saveChanges,
            isPrimary: true,
            isLoading: accountProvider.isLoading,
          ),

        const SizedBox(height: 16),

        // Change Password Button
        CustomButton(
          text: 'Change Password',
          onPressed: _navigateToChangePassword,
          isPrimary: false,
          icon: Icons.lock_outline,
        ),
      ],
    );
  }
}
