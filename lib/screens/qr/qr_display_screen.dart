// lib/screens/qr/qr_display_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/constants.dart';
import '../../widgets/navigation_drawer.dart';
import '../../widgets/custom_button.dart';
import '../../providers/dashboard_provider.dart';
import '../../services/qr_service.dart';
import '../../routes/app_routes.dart';

class QRDisplayScreen extends StatefulWidget {
  const QRDisplayScreen({super.key});

  @override
  State<QRDisplayScreen> createState() => _QRDisplayScreenState();
}

class _QRDisplayScreenState extends State<QRDisplayScreen> {
  String? qrData;
  bool isLoading = false;

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

  void _copyQRCode() {
    if (qrData != null && qrData!.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: qrData!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR code copied to clipboard'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR code not available'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // SHARE QR CODE AS TEXT
  void _shareQRCode() {
    if (qrData != null && qrData!.isNotEmpty) {
      Share.share(qrData!, subject: 'KOB QR Payment Info');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR data not available'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // SHARE QR CODE AS FILE
  void _shareQRCodeAsFile() async {
    if (qrData != null && qrData!.isNotEmpty) {
      try {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => const Center(child: CircularProgressIndicator()),
        );

        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/kob_qr_data.txt');
        await file.writeAsString(qrData!);

        // Close loading indicator
        if (mounted) Navigator.pop(context);

        await Share.shareXFiles([
          XFile(file.path),
        ], text: 'KOB QR Payment Info (File)');
      } catch (e) {
        // Close loading indicator if still open
        if (mounted) Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR data not available'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // SHARE QR CODE AS IMAGE - ENHANCED VERSION
  void _shareQRCodeAsImage() async {
    final dashboardProvider = Provider.of<DashboardProvider>(
      context,
      listen: false,
    );
    final account = dashboardProvider.currentAccount;

    if (qrData != null && qrData!.isNotEmpty && account != null) {
      try {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => const Center(child: CircularProgressIndicator()),
        );

        // Generate enhanced QR image bytes with username
        final imageBytes = await QRService.generateEnhancedQRImageBytes(
          qrData: qrData!,
          username: account.username,
        );

        // Save to temporary file
        final directory = await getTemporaryDirectory();
        final fileName = 'kob_qr_${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(imageBytes);

        // Close loading indicator
        if (mounted) Navigator.pop(context);

        // Share the enhanced image file
        await Share.shareXFiles(
          [XFile(file.path)],
          text:
              'KOB QR Payment Code - Scan to send money to ${account.username}',
        );
      } catch (e) {
        // Close loading indicator if still open
        if (mounted) Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing QR image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR data not available'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToExport() {
    AppRoutes.navigateToQrExport(context);
  }

  // SAVE QR IMAGE - ENHANCED VERSION
  void _saveQRImage() async {
    final dashboardProvider = Provider.of<DashboardProvider>(
      context,
      listen: false,
    );
    final account = dashboardProvider.currentAccount;

    if (qrData != null && account != null) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        print('Starting enhanced QR image save from display screen...');
        final success = await QRService.saveQRImageToGallery(
          qrData!,
          username: account.username,
        );

        // Check if widget is still mounted before using context
        if (!mounted) return;

        // Hide loading indicator
        Navigator.pop(context);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                Platform.isIOS && QRService.isIOSSimulator
                    ? 'Enhanced QR code saved to documents directory (iOS simulator)'
                    : 'Enhanced QR code saved to photo gallery',
              ),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Failed to save QR code. Please check permissions in Settings.',
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        }
      } catch (e) {
        print('Error in _saveQRImage: $e');

        // Check if widget is still mounted before using context
        if (!mounted) return;

        // Hide loading indicator
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving enhanced QR code: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR code data not available'),
          backgroundColor: Colors.red,
        ),
      );
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account Holder',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        account.username,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 8),
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

                // Action Buttons Row 1
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
                        onPressed: _copyQRCode,
                        isPrimary: true,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Action Buttons Row 2 - SHARING OPTIONS
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Share QR',
                        onPressed: _shareQRCode,
                        isPrimary: false,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: 'Share File',
                        onPressed: _shareQRCodeAsFile,
                        isPrimary: false,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Action Buttons Row 3 - IMAGE SHARING & SAVE
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Share Image',
                        onPressed: _shareQRCodeAsImage,
                        isPrimary: false,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: 'Save Image',
                        onPressed: _saveQRImage,
                        isPrimary: false,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Export Button
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'Export QR Code',
                    onPressed: _navigateToExport,
                    isPrimary: false,
                    icon: Icons.download,
                  ),
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
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.primaryGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Share this QR code with others to receive payments. QR code expires after 24 hours for security.',
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
}
