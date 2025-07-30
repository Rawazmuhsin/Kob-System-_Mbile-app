import 'package:flutter/material.dart';
import '../models/account.dart';
import '../services/qr_service.dart';

class QRProvider extends ChangeNotifier {
  String? _qrData;
  DateTime? _qrGeneratedTime;
  bool _isLoading = false;
  String? _error;

  // Contact info (can be set from settings)
  String? _supportPhone = '+1-800-KOB-BANK';
  String? _supportEmail = 'support@kob.com';

  // Getters
  String? get qrData => _qrData;
  DateTime? get qrGeneratedTime => _qrGeneratedTime;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get supportPhone => _supportPhone;
  String? get supportEmail => _supportEmail;

  // Check if QR is expired (24 hours)
  bool get isQRExpired {
    if (_qrGeneratedTime == null) return true;
    return DateTime.now().difference(_qrGeneratedTime!).inHours >= 24;
  }

  // Get QR expiry time
  DateTime? get qrExpiryTime {
    if (_qrGeneratedTime == null) return null;
    return _qrGeneratedTime!.add(const Duration(hours: 24));
  }

  // Generate QR code
  Future<void> generateQRCode({required Account account}) async {
    _setLoading(true);
    _clearError();

    try {
      _qrData = QRService.generateQRData(
        accountId: account.accountId!,
        username: account.username,
        accountNumber: account.accountNumber ?? '',
      );
      _qrGeneratedTime = DateTime.now();
      notifyListeners();
    } catch (e) {
      _setError('Failed to generate QR code: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Refresh QR code (generate new one)
  Future<void> refreshQRCode({required Account account}) async {
    await generateQRCode(account: account);
  }

  // Get primary color for account type
  Color getPrimaryColorForAccountType(String accountType) {
    switch (accountType.toLowerCase()) {
      case 'premium':
        return const Color(0xFFFFD700); // Gold
      case 'business':
        return const Color(0xFF1565C0); // Blue
      case 'student':
        return const Color(0xFF388E3C); // Green
      case 'corporate':
        return const Color(0xFF6A1B9A); // Purple
      case 'vip':
        return const Color(0xFFD32F2F); // Red
      case 'savings':
        return const Color(0xFF388E3C); // Green
      case 'checking':
        return const Color(0xFF1565C0); // Blue
      default:
        return const Color(0xFF2E7D32); // Default green
    }
  }

  // Get account type display name
  String getAccountTypeDisplayName(String accountType) {
    switch (accountType.toLowerCase()) {
      case 'checking':
        return 'Checking';
      case 'savings':
        return 'Savings';
      case 'premium':
        return 'Premium';
      case 'business':
        return 'Business';
      case 'student':
        return 'Student';
      case 'corporate':
        return 'Corporate';
      case 'vip':
        return 'VIP';
      default:
        return accountType.toUpperCase();
    }
  }

  // Update contact info
  void updateContactInfo({String? phone, String? email}) {
    _supportPhone = phone;
    _supportEmail = email;
    notifyListeners();
  }

  // Clear QR data
  void clearQRData() {
    _qrData = null;
    _qrGeneratedTime = null;
    _clearError();
    notifyListeners();
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
