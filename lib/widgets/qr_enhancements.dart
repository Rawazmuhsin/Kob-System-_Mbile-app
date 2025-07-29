// lib/widgets/qr_enhancements.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../core/constants.dart';
import '../providers/dashboard_provider.dart';

// ENHANCEMENT 1: Account Type Badge Widget
class AccountTypeBadge extends StatelessWidget {
  final String accountType;

  const AccountTypeBadge({super.key, required this.accountType});

  Color _getBadgeColor(String type) {
    switch (type.toLowerCase()) {
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
        return AppColors.primaryGreen; // Default
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getBadgeColor(accountType),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: _getBadgeColor(accountType).withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        accountType.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ENHANCEMENT 2: QR Expiry Timer Widget
class QRExpiryIndicator extends StatefulWidget {
  final DateTime expiryTime;

  const QRExpiryIndicator({super.key, required this.expiryTime});

  @override
  State<QRExpiryIndicator> createState() => _QRExpiryIndicatorState();
}

class _QRExpiryIndicatorState extends State<QRExpiryIndicator> {
  late Duration _timeRemaining;

  @override
  void initState() {
    super.initState();
    _updateTimeRemaining();
    // Update every minute
    Stream.periodic(const Duration(minutes: 1), (i) => i).listen((_) {
      if (mounted) {
        setState(() {
          _updateTimeRemaining();
        });
      }
    });
  }

  void _updateTimeRemaining() {
    _timeRemaining = widget.expiryTime.difference(DateTime.now());
  }

  Color _getTimerColor() {
    if (_timeRemaining.inHours > 6) {
      return const Color(0xFF4CAF50); // Green
    } else if (_timeRemaining.inHours > 1) {
      return const Color(0xFFFF9800); // Orange
    } else {
      return const Color(0xFFF44336); // Red
    }
  }

  String _getTimerText() {
    if (_timeRemaining.inHours > 1) {
      return 'Expires in: ${_timeRemaining.inHours}h ${_timeRemaining.inMinutes % 60}m';
    } else if (_timeRemaining.inMinutes > 0) {
      return 'Expires in: ${_timeRemaining.inMinutes}m';
    } else {
      return 'EXPIRED';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _getTimerColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _getTimerColor().withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time, size: 14, color: _getTimerColor()),
          const SizedBox(width: 6),
          Text(
            _getTimerText(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _getTimerColor(),
            ),
          ),
        ],
      ),
    );
  }
}

// ENHANCEMENT 3: Security Badge Widget
class SecurityBadge extends StatelessWidget {
  final Color primaryColor;

  const SecurityBadge({super.key, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.security, size: 16, color: primaryColor),
          const SizedBox(height: 2),
          Text(
            'SECURE',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: primaryColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ENHANCEMENT 4: Dynamic Theme Provider
class QRThemeProvider extends ChangeNotifier {
  Color getPrimaryColorForUser(String accountType) {
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
        return AppColors.primaryGreen; // Default
    }
  }

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
        return accountType;
    }
  }
}

// ENHANCEMENT 5: Watermark Widget
class QRWatermark extends StatelessWidget {
  const QRWatermark({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Center(
        child: Transform.rotate(
          angle: -0.3,
          child: Text(
            'KOB BANKING',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: Colors.black.withOpacity(0.03),
              letterSpacing: 8,
            ),
          ),
        ),
      ),
    );
  }
}

// ENHANCEMENT 6: Contact Info Widget
class ContactInfoWidget extends StatelessWidget {
  final String? phone;
  final String? email;

  const ContactInfoWidget({super.key, this.phone, this.email});

  @override
  Widget build(BuildContext context) {
    if (phone == null && email == null) {
      return const SizedBox.shrink();
    }

    String contactText = 'Support: ';
    if (phone != null) contactText += phone!;
    if (phone != null && email != null) contactText += ' | ';
    if (email != null) contactText += email!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        contactText,
        style: TextStyle(
          fontSize: 10,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w400,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// Main Enhanced QR Card Widget
class EnhancedQRCard extends StatelessWidget {
  final String qrData;
  final String username;
  final String accountType;
  final String? phone;
  final String? email;

  const EnhancedQRCard({
    super.key,
    required this.qrData,
    required this.username,
    required this.accountType,
    this.phone,
    this.email,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = QRThemeProvider();
    final primaryColor = themeProvider.getPrimaryColorForUser(accountType);
    final expiryTime = DateTime.now().add(const Duration(hours: 24));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Watermark
          const QRWatermark(),

          // Main content
          Column(
            children: [
              // Header with badges
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SecurityBadge(primaryColor: primaryColor),
                  AccountTypeBadge(accountType: accountType),
                ],
              ),

              const SizedBox(height: 16),

              // KOB Branding
              Text(
                'KOB',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'Banking System',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 24),

              // QR Code with profile circle
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 250,
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                  ),

                  // Profile circle overlay
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryColor, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.grey.shade200,
                      child: Icon(
                        Icons.person,
                        size: 30,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Username
              Text(
                username,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 8),

              // Scan instruction
              Text(
                'Scan to send money',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 16),

              // Expiry timer
              QRExpiryIndicator(expiryTime: expiryTime),

              if (phone != null || email != null) ...[
                const SizedBox(height: 16),
                ContactInfoWidget(phone: phone, email: email),
              ],

              const SizedBox(height: 16),

              // Decorative line
              Container(
                width: 100,
                height: 2,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
