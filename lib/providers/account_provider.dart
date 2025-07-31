// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../confirmation/auth_service.dart';
import '../confirmation/signup/signup_confirmation.dart';
import '../core/utils.dart'; // Using your existing utils

class AccountProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  File? _profileImage;
  int? _currentAccountId;

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

  // Set current account ID for profile image updates
  void setCurrentAccountId(int accountId) {
    _currentAccountId = accountId;
  }

  // Load profile image from database
  Future<void> loadProfileImage() async {
    if (_currentAccountId == null) return;

    try {
      final account = await _authService.getAccountById(_currentAccountId!);
      if (account?.profileImage != null && account!.profileImage!.isNotEmpty) {
        File file = File(account.profileImage!);

        // Check if the file exists
        if (await file.exists()) {
          _profileImage = file;
          notifyListeners();
          print('Loaded profile image from: ${file.path}');
        } else {
          print('Profile image file not found at: ${account.profileImage}');

          // Try to recover by looking for the file with a known pattern
          final appDir = await getApplicationDocumentsDirectory();
          final profileDir = Directory('${appDir.path}/profile_images');
          final recoveredFilePath =
              '${profileDir.path}/profile_$_currentAccountId.jpg';

          File recoveredFile = File(recoveredFilePath);
          if (await recoveredFile.exists()) {
            _profileImage = recoveredFile;

            // Update the database with the recovered path
            await _authService.updateProfileImage(
              _currentAccountId!,
              recoveredFilePath,
            );
            notifyListeners();
            print('Recovered profile image from: ${recoveredFile.path}');
          } else {
            print('Could not recover profile image');

            // Try to recover from backup
            final backupPath =
                '${appDir.path}/profile_backups/profile_backup_$_currentAccountId.jpg';
            final backupFile = File(backupPath);

            if (await backupFile.exists()) {
              // Restore from backup
              if (!await profileDir.exists()) {
                await profileDir.create(recursive: true);
              }

              final restoredPath =
                  '${profileDir.path}/profile_$_currentAccountId.jpg';
              await backupFile.copy(restoredPath);

              _profileImage = File(restoredPath);
              await _authService.updateProfileImage(
                _currentAccountId!,
                restoredPath,
              );

              notifyListeners();
              print('Restored profile image from backup');
            }
          }
        }
      }
    } catch (e) {
      print('Error loading profile image: $e');
    }
  }

  // Pick profile image from gallery with cropping
  Future<bool> pickProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 90,
      );

      if (image != null) {
        // Crop the image
        final croppedFile = await _cropImage(image.path);
        if (croppedFile != null) {
          // Save to app documents directory
          final savedPath = await _saveImageToAppDirectory(croppedFile);
          if (savedPath != null) {
            _profileImage = File(savedPath);

            // Update database if account ID is available
            if (_currentAccountId != null) {
              await _authService.updateProfileImage(
                _currentAccountId!,
                savedPath,
              );
            }

            notifyListeners();
            await backupProfileImage();
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      _setError('Error picking image: $e');
      return false;
    }
  }

  // Pick profile image from camera with cropping
  Future<bool> takeProfilePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 90,
      );

      if (image != null) {
        // Crop the image
        final croppedFile = await _cropImage(image.path);
        if (croppedFile != null) {
          // Save to app documents directory
          final savedPath = await _saveImageToAppDirectory(croppedFile);
          if (savedPath != null) {
            _profileImage = File(savedPath);

            // Update database if account ID is available
            if (_currentAccountId != null) {
              await _authService.updateProfileImage(
                _currentAccountId!,
                savedPath,
              );
            }

            notifyListeners();
            await backupProfileImage();
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      _setError('Error taking photo: $e');
      return false;
    }
  }

  // Crop image using image_cropper
  Future<File?> _cropImage(String imagePath) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Profile Picture',
            toolbarColor: const Color(0xFF2E7D32),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: 'Crop Profile Picture',
            aspectRatioLockEnabled: true,
            aspectRatioPickerButtonHidden: true,
            resetAspectRatioEnabled: false,
            rotateButtonsHidden: true,
            rotateClockwiseButtonHidden: true,
          ),
        ],
      );
      return croppedFile != null ? File(croppedFile.path) : null;
    } catch (e) {
      print('Error cropping image: $e');
      return null;
    }
  }

  // Save image to app documents directory
  Future<String?> _saveImageToAppDirectory(File imageFile) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final profileDir = Directory('${appDir.path}/profile_images');

      if (!await profileDir.exists()) {
        await profileDir.create(recursive: true);
      }

      // Use account ID in filename for consistent retrieval
      final fileName =
          'profile_${_currentAccountId ?? DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedFile = await imageFile.copy('${profileDir.path}/$fileName');

      print('Image saved to: ${savedFile.path}');
      return savedFile.path;
    } catch (e) {
      print('Error saving image: $e');
      return null;
    }
  }

  // Image path validation helper
  Future<bool> isImagePathValid(String path) async {
    if (path.isEmpty) return false;
    try {
      final file = File(path);
      return await file.exists();
    } catch (e) {
      print('Error checking image path: $e');
      return false;
    }
  }

  // Backup profile image
  Future<void> backupProfileImage() async {
    if (_profileImage == null || _currentAccountId == null) return;

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${appDir.path}/profile_backups');

      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final backupPath =
          '${backupDir.path}/profile_backup_$_currentAccountId.jpg';
      await _profileImage!.copy(backupPath);

      print('Profile image backed up to: $backupPath');
    } catch (e) {
      print('Error backing up profile image: $e');
    }
  }

  // Remove profile image
  Future<void> removeProfileImage() async {
    if (_profileImage != null) {
      // Delete the file
      try {
        await _profileImage!.delete();
      } catch (e) {
        print('Error deleting profile image file: $e');
      }
    }

    _profileImage = null;

    // Update database to remove profile image path
    if (_currentAccountId != null) {
      try {
        await _authService.updateProfileImage(_currentAccountId!, '');
      } catch (e) {
        print('Error removing profile image from database: $e');
      }
    }

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
