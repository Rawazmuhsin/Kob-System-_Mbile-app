// lib/screens/qr/qr_scanner_screen.dart - COMPATIBLE WITH qr_code_scanner ^1.0.1
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../../core/constants.dart';
import '../../services/qr_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/dialog_box.dart';

class QRScannerScreen extends StatefulWidget {
  final String transactionType; // 'deposit', 'transfer', 'withdraw'

  const QRScannerScreen({super.key, required this.transactionType});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isScanning = true;
  String? scannedData;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Scan QR Code - ${widget.transactionType.toUpperCase()}',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Stack(
              alignment: Alignment.center,
              children: [
                QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                  overlay: QrScannerOverlayShape(
                    borderColor: AppColors.primaryGreen,
                    borderRadius: 12,
                    borderLength: 30,
                    borderWidth: 8,
                    cutOutSize: 250,
                  ),
                  onPermissionSet:
                      (ctrl, p) => _onPermissionSet(context, ctrl, p),
                ),

                // Scanning indicator
                if (isScanning)
                  Positioned(
                    bottom: 100,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Point camera at QR code',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Expanded(
            flex: 1,
            child: Container(
              color:
                  isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Scan QR code to ${widget.transactionType} money',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Toggle Flash',
                          onPressed: _toggleFlash,
                          isPrimary: false,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          text: 'Manual Entry',
                          onPressed: _showManualEntry,
                          isPrimary: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (isScanning && scanData.code != null) {
        setState(() {
          isScanning = false;
        });
        _handleScannedData(scanData.code!);
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Camera permission denied')));
    }
  }

  void _handleScannedData(String scannedCode) {
    final qrData = QRService.parseQRData(scannedCode);

    if (qrData == null || !QRService.isValidQRData(qrData)) {
      _showError('Invalid or expired QR code');
      return;
    }

    // Pass the scanned data back to previous screen
    Navigator.pop(context, {
      'account_id': qrData['account_id'],
      'username': qrData['username'],
      'account_number': qrData['account_number'],
      'transaction_type': widget.transactionType,
    });
  }

  void _toggleFlash() async {
    await controller?.toggleFlash();
  }

  void _showManualEntry() {
    showDialog(
      context: context,
      builder:
          (context) => _ManualEntryDialog(
            onSubmit: (code) {
              Navigator.pop(context);
              _handleScannedData(code);
            },
          ),
    );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder:
          (context) => DialogBox(
            title: 'Scan Error',
            message: message,
            primaryButtonText: 'Try Again',
            onPrimaryPressed: () {
              Navigator.pop(context);
              setState(() {
                isScanning = true;
              });
            },
          ),
    );
  }
}

class _ManualEntryDialog extends StatefulWidget {
  final Function(String) onSubmit;

  const _ManualEntryDialog({required this.onSubmit});

  @override
  State<_ManualEntryDialog> createState() => _ManualEntryDialogState();
}

class _ManualEntryDialogState extends State<_ManualEntryDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter QR Code'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: 'Paste QR code here',
          border: OutlineInputBorder(),
        ),
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              widget.onSubmit(_controller.text);
            }
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
