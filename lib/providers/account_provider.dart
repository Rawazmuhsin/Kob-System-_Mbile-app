// lib/providers/account_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/account.dart';
import '../confirmation/auth_service.dart';
import '../confirmation/signup/signup_confirmation.dart';
import '../core/utils.dart'; // Using your existing utils

class AccountProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  File? _profileImage;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  File? get profileImage => _profileImage;

  final AuthService _authService = AuthService.instance;
  final SignupConfirmation _signupConfirmation = SignupConfirmation.instance;
  final ImagePicker _picker = ImagePicker();

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error message
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Pick profile image from gallery
  Future<bool> pickProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        _profileImage = File(image.path);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Error picking image: $e');
      return false;
    }
  }

  // Pick profile image from camera
  Future<bool> takeProfilePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        _profileImage = File(image.path);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Error taking photo: $e');
      return false;
    }
  }

  // Remove profile image
  void removeProfileImage() {
    _profileImage = null;
    notifyListeners();
  }

  // Update user account information
  Future<bool> updateAccountInfo({
    required int accountId,
    required String username,
    required String email,
    required String phone,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // Use your existing validation from utils
      if (username.trim().isEmpty) {
        throw Exception('Username cannot be empty');
      }

      if (!AppUtils.isValidEmail(email)) {
        throw Exception('Please enter a valid email address');
      }

      if (!AppUtils.isValidPhone(phone)) {
        throw Exception('Please enter a valid phone number');
      }

      // Use the AuthService method to update account info
      final success = await _authService.updateAccountInfo(
        accountId: accountId,
        username: username.trim(),
        email: email.trim(),
        phone: phone.trim(),
      );

      _setLoading(false);
      return success;
    } catch (e) {
      _setError('Failed to update account: $e');
      _setLoading(false);
      return false;
    }
  }

  // Change user password using your existing AuthService
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // Use your existing validation from AuthService
      if (!_authService.isStrongPassword(newPassword)) {
        throw Exception(
          'Password must be at least 8 characters with uppercase, lowercase, and number',
        );
      }

      // First verify current password by trying to authenticate
      final account = await _authService.authenticate(email, currentPassword);
      if (account == null) {
        throw Exception('Current password is incorrect');
      }

      // Use your existing resetPassword method
      final success = await _authService.resetPassword(email, newPassword);

      _setLoading(false);

      if (success) {
        return true;
      } else {
        throw Exception('Failed to change password');
      }
    } catch (e) {
      _setError('$e');
      _setLoading(false);
      return false;
    }
  }

  // Get password strength using your existing SignupConfirmation
  int getPasswordStrength(String password) {
    return _signupConfirmation.getPasswordStrength(password);
  }

  // Get password strength description using your existing SignupConfirmation
  String getPasswordStrengthDescription(String password) {
    return _signupConfirmation.getPasswordStrengthDescription(password);
  }

  // Get password strength color
  Color getPasswordStrengthColor(String password) {
    int strength = getPasswordStrength(password);

    switch (strength) {
      case 0:
      case 1:
        return const Color(0xFFEF4444); // Red
      case 2:
        return const Color(0xFFF97316); // Orange
      case 3:
        return const Color(0xFFF59E0B); // Amber
      case 4:
        return const Color(0xFF10B981); // Green
      case 5:
        return const Color(0xFF059669); // Dark green
      default:
        return const Color(0xFFEF4444);
    }
  }
}
