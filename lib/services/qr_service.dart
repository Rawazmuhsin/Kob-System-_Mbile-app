// lib/services/qr_service.dart
import 'dart:convert';
import 'dart:math';

class QRService {
  // Generate QR data for user account
  static String generateQRData({
    required int accountId,
    required String username,
    required String accountNumber,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999);

    final qrData = {
      'account_id': accountId,
      'username': username,
      'account_number': accountNumber.substring(
        accountNumber.length - 4,
      ), // Last 4 digits only
      'timestamp': timestamp,
      'security_code': random,
      'version': '1.0',
    };

    return base64Encode(utf8.encode(jsonEncode(qrData)));
  }

  // Parse QR data
  static Map<String, dynamic>? parseQRData(String qrCode) {
    try {
      final decodedBytes = base64Decode(qrCode);
      final decodedString = utf8.decode(decodedBytes);
      final data = jsonDecode(decodedString);

      // Validate timestamp (QR expires after 24 hours)
      final timestamp = data['timestamp'] as int;
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - timestamp > 86400000) {
        // 24 hours
        return null; // Expired
      }

      return data;
    } catch (e) {
      return null;
    }
  }

  // Validate QR data structure
  static bool isValidQRData(Map<String, dynamic> data) {
    return data.containsKey('account_id') &&
        data.containsKey('username') &&
        data.containsKey('account_number') &&
        data.containsKey('timestamp') &&
        data.containsKey('security_code');
  }
}
