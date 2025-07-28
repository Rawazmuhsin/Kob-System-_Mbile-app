// QR export screen
// lib/screens/qr/qr_export_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../widgets/navigation_drawer.dart';
import '../../widgets/custom_button.dart';
import '../../providers/dashboard_provider.dart';
import '../../services/qr_service.dart';

class QRExportScreen extends StatefulWidget {
  const QRExportScreen({super.key});

  @override
  State<QRExportScreen> createState() => _QRExportScreenState();
}

class _QRExportScreenState extends State<QRExportScreen> {
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
        title: const Text('Export QR Code'),
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
                // Info Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primaryGreen.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primaryGreen,
                        size: 32,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Export QR Code',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Export your QR code data for external use or backup purposes.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Export Options
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
                        'Export Options',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Copy to Clipboard
                      _buildExportOption(
                        icon: Icons.copy,
                        title: 'Copy to Clipboard',
                        subtitle: 'Copy QR data to clipboard',
                        onTap: () => _copyToClipboard(),
                        isDarkMode: isDarkMode,
                      ),

                      const SizedBox(height: 12),

                      // Share QR Code
                      _buildExportOption(
                        icon: Icons.share,
                        title: 'Share QR Code',
                        subtitle: 'Share via other apps',
                        onTap: () => _shareQRCode(),
                        isDarkMode: isDarkMode,
                      ),

                      const SizedBox(height: 12),

                      // Save as File
                      _buildExportOption(
                        icon: Icons.save,
                        title: 'Save as File',
                        subtitle: 'Download QR data file',
                        onTap: () => _saveAsFile(),
                        isDarkMode: isDarkMode,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // QR Data Preview
                if (qrData != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          isDarkMode
                              ? Colors.white.withOpacity(0.05)
                              : Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
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
                          'QR Data Preview',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color:
                                isDarkMode ? Colors.white : AppColors.darkText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                isDarkMode
                                    ? Colors.black.withOpacity(0.3)
                                    : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            qrData!,
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                              color:
                                  isDarkMode ? Colors.white70 : Colors.black54,
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

  Widget _buildExportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isDarkMode
                  ? Colors.white.withOpacity(0.05)
                  : Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryGreen, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : AppColors.darkText,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isDarkMode ? Colors.white70 : Colors.black54,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard() {
    if (qrData != null) {
      Clipboard.setData(ClipboardData(text: qrData!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR data copied to clipboard'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    }
  }

  void _shareQRCode() {
    if (qrData != null) {
      // For now, just copy to clipboard
      // In a real app, you would use a share plugin
      Clipboard.setData(ClipboardData(text: qrData!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR data copied to clipboard for sharing'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    }
  }

  void _saveAsFile() {
    if (qrData != null) {
      // For now, just copy to clipboard
      // In a real app, you would use a file saving plugin
      Clipboard.setData(ClipboardData(text: qrData!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR data copied to clipboard for saving'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    }
  }
}
