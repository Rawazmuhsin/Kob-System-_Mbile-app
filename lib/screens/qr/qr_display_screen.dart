// QR display screen
// lib/screens/qr/qr_display_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../widgets/navigation_drawer.dart';
import '../../widgets/custom_button.dart';
import '../../providers/dashboard_provider.dart';
import '../../services/qr_service.dart';

class QRDisplayScreen extends StatefulWidget {
  const QRDisplayScreen({super.key});

  @override
  State<QRDisplayScreen> createState() => _QRDisplayScreenState();
}

class _QRDisplayScreenState extends State<QRDisplayScreen> {
  String? qrData;

  @override
  void initState() {
    super.initState();
    _generateQRCode();
  }

  void _generateQRCode() {
    final dashboardProvider = Provider.of<DashboardProvider>(
      context,
      listen: false,
    );
    final account = dashboardProvider.currentAccount;

    if (account != null) {
      setState(() {
        qrData = QRService.generateQRData(
          accountId: account.accountId!,
          username: account.username,
          accountNumber: account.accountNumber ?? '',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      appBar: AppBar(
        backgroundColor:
            isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        title: const Text('My QR Code'),
        elevation: 0,
      ),
      drawer: const AppNavigationDrawer(selectedIndex: 8),
      body: Consumer<DashboardProvider>(
        builder: (context, dashboardProvider, child) {
          final account = dashboardProvider.currentAccount;

          if (account == null) {
            return const Center(child: Text('Account not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // User Info Card
                Container(
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
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.primaryGreen.withOpacity(
                          0.1,
                        ),
                        child: Text(
                          account.username.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        account.username,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Account: ****${(account.accountNumber ?? '').length >= 4 ? (account.accountNumber!).substring((account.accountNumber!).length - 4) : '****'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // QR Code Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Scan to Send Money',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // QR Code
                      if (qrData != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: QrImageView(
                            data: qrData!,
                            version: QrVersions.auto,
                            size: 200,
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                          ),
                        )
                      else
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Refresh QR',
                        onPressed: _generateQRCode,
                        isPrimary: false,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: 'Copy Code',
                        onPressed: () => _copyQRCode(),
                        isPrimary: true,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Info Text
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primaryGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Share this QR code with others to receive payments. QR code expires after 24 hours.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _copyQRCode() {
    if (qrData != null) {
      Clipboard.setData(ClipboardData(text: qrData!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR code copied to clipboard'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    }
  }
}
