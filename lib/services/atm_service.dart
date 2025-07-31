// lib/services/atm_service.dart
import 'dart:convert';
import '../models/atm_location.dart';

class ATMService {
  static final ATMService _instance = ATMService._internal();
  static ATMService get instance => _instance;

  ATMService._internal();

  // Predefined ATM locations
  final List<ATMLocation> _atmLocations = [
    ATMLocation(
      id: 'ATM001',
      name: 'Downtown ATM #001',
      address: 'Main Street, Downtown Plaza',
      status: 'Online',
    ),
    ATMLocation(
      id: 'ATM002',
      name: 'Mall ATM #002',
      address: 'Shopping Mall, Level 1',
      status: 'Online',
    ),
    ATMLocation(
      id: 'ATM003',
      name: 'Airport ATM #003',
      address: 'International Airport, Terminal A',
      status: 'Online',
    ),
    ATMLocation(
      id: 'ATM004',
      name: 'University ATM #004',
      address: 'University Campus, Student Center',
      status: 'Online',
    ),
    ATMLocation(
      id: 'ATM005',
      name: 'Hospital ATM #005',
      address: 'City Hospital, Main Lobby',
      status: 'Online',
    ),
  ];

  // Get all ATM locations
  List<ATMLocation> getAllATMLocations() {
    return _atmLocations;
  }

  // Get ATM by ID
  ATMLocation? getATMById(String id) {
    try {
      return _atmLocations.firstWhere((atm) => atm.id == id);
    } catch (e) {
      return null;
    }
  }

  // Generate QR data for ATM
  String generateATMQRData({
    required String atmId,
    required String atmName,
    required String userAccountId,
    required String username,
  }) {
    final qrData = {
      'type': 'ATM_CONNECTION',
      'atm_id': atmId,
      'atm_name': atmName,
      'user_account_id': userAccountId,
      'username': username,
      'timestamp': DateTime.now().toIso8601String(),
      'version': '1.0',
    };

    return jsonEncode(qrData);
  }

  // Validate ATM QR code
  Map<String, dynamic>? validateATMQRCode(String qrDataString) {
    try {
      final qrData = jsonDecode(qrDataString) as Map<String, dynamic>;

      // Check if it's an ATM QR code
      if (qrData['type'] != 'ATM_CONNECTION') {
        return null;
      }

      // Check if ATM exists
      final atmId = qrData['atm_id'] as String?;
      if (atmId == null || getATMById(atmId) == null) {
        return null;
      }

      // Check timestamp (QR valid for 24 hours)
      final timestamp = DateTime.parse(qrData['timestamp']);
      final now = DateTime.now();
      final difference = now.difference(timestamp);

      if (difference.inHours > 24) {
        return null; // QR code expired
      }

      return qrData;
    } catch (e) {
      return null;
    }
  }
}
