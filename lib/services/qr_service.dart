import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io' show Platform, File;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

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

  static Future<bool> saveQRToGallery({
    required String qrData,
    required String filename,
    String? username,
  }) async {
    try {
      print('Starting QR save to gallery with filename: $filename');

      // Use the existing saveQRImageToGallery method with username
      return await saveQRImageToGallery(qrData, username: username);
    } catch (e) {
      print('Error in saveQRToGallery: $e');
      return false;
    }
  }

  // Additional utility method for sharing QR as image file
  static Future<String?> saveQRToTempFile({
    required String qrData,
    required String filename,
    String? username,
  }) async {
    try {
      // Generate QR image bytes with enhanced styling if username provided
      final imageBytes = await generateQRImageBytes(qrData, username: username);

      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$filename.png');

      // Write image bytes to file
      await file.writeAsBytes(imageBytes);

      return file.path;
    } catch (e) {
      print('Error saving QR to temp file: $e');
      return null;
    }
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

  // Check if running on iOS simulator
  static bool get isIOSSimulator {
    if (!Platform.isIOS) return false;

    // iOS simulator has specific characteristics
    try {
      // Check if we can access photo gallery (simulator can't)
      return true; // For now, assume iOS = simulator for testing
    } catch (e) {
      return true;
    }
  }

  // Enhanced QR code image generation with branding and profile
  static Future<Uint8List> generateEnhancedQRImageBytes({
    required String qrData,
    required String username,
    String? profileImagePath, // For future use when you add profile images
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Canvas dimensions
    const double canvasWidth = 600;
    const double canvasHeight = 800;
    const double padding = 40;

    // Colors
    const backgroundColor = Color(0xFFF0F4F8);
    const primaryColor = Color(0xFF2E7D32); // Green color
    const cardColor = Colors.white;
    const textColor = Color(0xFF1A1A1A);

    // Draw background
    final backgroundPaint = Paint()..color = backgroundColor;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, canvasWidth, canvasHeight),
      backgroundPaint,
    );

    // Draw main card
    final cardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        padding,
        padding * 2,
        canvasWidth - (padding * 2),
        canvasHeight - (padding * 4),
      ),
      const Radius.circular(20),
    );
    final cardPaint =
        Paint()
          ..color = cardColor
          ..style = PaintingStyle.fill;

    // Add shadow
    final shadowPaint =
        Paint()
          ..color = Colors.black.withOpacity(0.1)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawRRect(cardRect.shift(const Offset(0, 5)), shadowPaint);
    canvas.drawRRect(cardRect, cardPaint);

    // Draw app name/branding at top
    final brandTextPainter = TextPainter(
      text: TextSpan(
        text: 'KOB',
        style: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: primaryColor,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    brandTextPainter.layout();
    brandTextPainter.paint(
      canvas,
      Offset((canvasWidth - brandTextPainter.width) / 2, padding * 2 + 30),
    );

    // Draw subtitle
    final subtitleTextPainter = TextPainter(
      text: const TextSpan(
        text: 'Banking System',
        style: TextStyle(
          fontSize: 16,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    subtitleTextPainter.layout();
    subtitleTextPainter.paint(
      canvas,
      Offset((canvasWidth - subtitleTextPainter.width) / 2, padding * 2 + 80),
    );

    // Generate QR code
    final qrPainter = QrPainter(
      data: qrData,
      version: QrVersions.auto,
      eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square, color: textColor),
      dataModuleStyle: QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: textColor,
      ),
      gapless: true,
    );

    // QR code position and size
    const double qrSize = 300;
    const double qrTop = 150;
    final qrLeft = (canvasWidth - qrSize) / 2;

    // Draw QR code background
    final qrBackgroundRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(qrLeft - 15, qrTop - 15, qrSize + 30, qrSize + 30),
      const Radius.circular(15),
    );
    final qrBackgroundPaint = Paint()..color = cardColor;
    canvas.drawRRect(qrBackgroundRect, qrBackgroundPaint);

    // Paint QR code
    canvas.save();
    canvas.translate(qrLeft, qrTop);
    qrPainter.paint(canvas, Size(qrSize, qrSize));
    canvas.restore();

    // Draw profile placeholder in center of QR code
    const double profileSize = 80;
    final profileCenter = Offset(canvasWidth / 2, qrTop + qrSize / 2);

    // Profile background (white circle with border)
    final profileBackgroundPaint =
        Paint()
          ..color = cardColor
          ..style = PaintingStyle.fill;
    canvas.drawCircle(
      profileCenter,
      profileSize / 2 + 5,
      profileBackgroundPaint,
    );

    // Profile border
    final profileBorderPaint =
        Paint()
          ..color = primaryColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;
    canvas.drawCircle(profileCenter, profileSize / 2 + 2, profileBorderPaint);

    // Profile placeholder (gray circle with icon)
    final profilePlaceholderPaint =
        Paint()
          ..color = Colors.grey.shade200
          ..style = PaintingStyle.fill;
    canvas.drawCircle(profileCenter, profileSize / 2, profilePlaceholderPaint);

    // Draw person icon in profile placeholder
    final iconPaint =
        Paint()
          ..color = Colors.grey.shade600
          ..style = PaintingStyle.fill;

    // Simple person icon - head
    canvas.drawCircle(
      Offset(profileCenter.dx, profileCenter.dy - 15),
      12,
      iconPaint,
    );

    // Simple person icon - body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(profileCenter.dx, profileCenter.dy + 10),
          width: 30,
          height: 20,
        ),
        const Radius.circular(10),
      ),
      iconPaint,
    );

    // Draw username below QR code
    final usernameTextPainter = TextPainter(
      text: TextSpan(
        text: username,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    usernameTextPainter.layout();
    usernameTextPainter.paint(
      canvas,
      Offset(
        (canvasWidth - usernameTextPainter.width) / 2,
        qrTop + qrSize + 40,
      ),
    );

    // Draw scan instruction
    final instructionTextPainter = TextPainter(
      text: const TextSpan(
        text: 'Scan to send money',
        style: TextStyle(
          fontSize: 16,
          color: textColor,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    instructionTextPainter.layout();
    instructionTextPainter.paint(
      canvas,
      Offset(
        (canvasWidth - instructionTextPainter.width) / 2,
        qrTop + qrSize + 80,
      ),
    );

    // Add decorative elements (optional)
    final decorPaint =
        Paint()
          ..color = primaryColor.withOpacity(0.1)
          ..style = PaintingStyle.fill;

    // Top left corner decoration
    canvas.drawCircle(Offset(padding + 20, padding * 2 + 20), 8, decorPaint);

    // Top right corner decoration
    canvas.drawCircle(
      Offset(canvasWidth - padding - 20, padding * 2 + 20),
      8,
      decorPaint,
    );

    // Bottom decorative line
    final decorLinePaint =
        Paint()
          ..color = primaryColor.withOpacity(0.2)
          ..strokeWidth = 2;
    canvas.drawLine(
      Offset(padding + 50, canvasHeight - padding * 2 - 30),
      Offset(canvasWidth - padding - 50, canvasHeight - padding * 2 - 30),
      decorLinePaint,
    );

    // Convert to image
    final picture = recorder.endRecording();
    final image = await picture.toImage(
      canvasWidth.toInt(),
      canvasHeight.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  // Updated method to use enhanced QR generation
  static Future<Uint8List> generateQRImageBytes(
    String qrData, {
    String? username,
  }) async {
    // For backward compatibility, if no username provided, use simple generation
    if (username == null) {
      return _generateSimpleQRImageBytes(qrData);
    }

    // Use enhanced generation with username
    return generateEnhancedQRImageBytes(qrData: qrData, username: username);
  }

  // Keep the original simple method for backward compatibility
  static Future<Uint8List> _generateSimpleQRImageBytes(String qrData) async {
    final qrPainter = QrPainter(
      data: qrData,
      version: QrVersions.auto,
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: Color(0xFF000000),
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: Color(0xFF000000),
      ),
      gapless: true,
    );

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = const Size(400, 400);

    qrPainter.paint(canvas, size);
    final picture = recorder.endRecording();
    final image = await picture.toImage(
      size.width.toInt(),
      size.height.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  // Updated save method to use enhanced generation
  static Future<bool> saveQRImageToGallery(
    String qrData, {
    String? username,
  }) async {
    try {
      print('Starting QR image save process...');

      // Generate QR image bytes (enhanced if username provided)
      print('Generating QR image bytes...');
      final imageBytes = await generateQRImageBytes(qrData, username: username);
      print('QR image bytes generated: ${imageBytes.length} bytes');

      // Request appropriate permissions based on platform
      bool permissionGranted = false;

      if (Platform.isAndroid) {
        // For Android 13+ (API 33+), we need different permissions
        final photosStatus = await Permission.photos.request();
        final storageStatus = await Permission.storage.request();
        permissionGranted = photosStatus.isGranted || storageStatus.isGranted;
        print(
          'Android permissions - Photos: ${photosStatus.isGranted}, Storage: ${storageStatus.isGranted}',
        );
      } else if (Platform.isIOS) {
        final photosStatus = await Permission.photos.request();
        permissionGranted = photosStatus.isGranted;
        print('iOS permissions - Photos: ${photosStatus.isGranted}');

        // For iOS simulator, try photo gallery first, then fallback
        if (isIOSSimulator) {
          print('iOS simulator detected - trying photo gallery first...');
          try {
            final result = await ImageGallerySaver.saveImage(
              imageBytes,
              quality: 100,
              name: 'kob_qr_${DateTime.now().millisecondsSinceEpoch}',
            );
            print('Simulator photo gallery result: $result');
            if (result['isSuccess'] == true) {
              return true;
            }
          } catch (e) {
            print('Simulator photo gallery failed: $e');
          }
          // Fallback to documents directory
          print('Using documents directory fallback for simulator');
          return await _saveToDocumentsDirectory(imageBytes);
        }
      }

      // Only try to save to gallery if permissions are granted
      if (!permissionGranted) {
        print('Permission not granted for saving images');
        return false;
      }

      print('Saving image to gallery...');
      // Save to gallery
      final result = await ImageGallerySaver.saveImage(
        imageBytes,
        quality: 100,
        name: 'kob_qr_${DateTime.now().millisecondsSinceEpoch}',
      );

      print('Save result: $result');
      return result['isSuccess'] == true;
    } catch (e, stackTrace) {
      print('Error saving QR image: $e');
      print('Stack trace: $stackTrace');

      // If gallery save fails, try documents directory as fallback
      if (Platform.isIOS) {
        print('Gallery save failed, trying documents directory fallback...');
        try {
          final imageBytes = await generateQRImageBytes(
            qrData,
            username: username,
          );
          return await _saveToDocumentsDirectory(imageBytes);
        } catch (fallbackError) {
          print('Fallback also failed: $fallbackError');
          return false;
        }
      }

      return false;
    }
  }

  // Fallback method for iOS simulator - save to documents directory
  static Future<bool> _saveToDocumentsDirectory(Uint8List imageBytes) async {
    try {
      print('Saving image to documents directory');

      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'kob_qr_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${directory.path}/$fileName');

      await file.writeAsBytes(imageBytes);
      print('QR image saved to: ${file.path}');

      return true;
    } catch (e) {
      print('Error saving to documents directory: $e');
      return false;
    }
  }

  // Test method to debug QR image saving
  static Future<void> testQRSave(String qrData, {String? username}) async {
    try {
      print('=== QR Save Test ===');
      print('QR Data length: ${qrData.length}');
      print('QR Data preview: ${qrData.substring(0, 50)}...');
      print('Username: $username');

      // Test image generation
      print('Testing image generation...');
      final imageBytes = await generateQRImageBytes(qrData, username: username);
      print('Image bytes generated: ${imageBytes.length} bytes');

      // Test permissions
      print('Testing permissions...');
      if (Platform.isAndroid) {
        final photosStatus = await Permission.photos.status;
        final storageStatus = await Permission.storage.status;
        print('Photos permission: $photosStatus');
        print('Storage permission: $storageStatus');
      } else if (Platform.isIOS) {
        final photosStatus = await Permission.photos.status;
        print('Photos permission: $photosStatus');
      }

      print('=== Test Complete ===');
    } catch (e, stackTrace) {
      print('Test failed: $e');
      print('Stack trace: $stackTrace');
    }
  }
}
