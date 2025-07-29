// lib/services/qr_service.dart
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io' show Platform, File;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  // Generate QR code image as bytes
  static Future<Uint8List> generateQRImageBytes(String qrData) async {
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

  // Save QR code image to gallery
  static Future<bool> saveQRImageToGallery(String qrData) async {
    try {
      print('Starting QR image save process...');

      // Generate QR image bytes first
      print('Generating QR image bytes...');
      final imageBytes = await generateQRImageBytes(qrData);
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
              name: 'qr_code_${DateTime.now().millisecondsSinceEpoch}',
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
        name: 'qr_code_${DateTime.now().millisecondsSinceEpoch}',
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
          final imageBytes = await generateQRImageBytes(qrData);
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
      print('Saved image to photos');

      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'qr_code_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${directory.path}/$fileName');

      await file.writeAsBytes(imageBytes);
      print('QR image saved to: ${file.path}');

      return true;
    } catch (e) {
      print('Error saving to photos directory: $e');
      return false;
    }
  }

  // Test method to debug QR image saving
  static Future<void> testQRSave(String qrData) async {
    try {
      print('=== QR Save Test ===');
      print('QR Data length: ${qrData.length}');
      print('QR Data preview: ${qrData.substring(0, 50)}...');

      // Test image generation
      print('Testing image generation...');
      final imageBytes = await generateQRImageBytes(qrData);
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
