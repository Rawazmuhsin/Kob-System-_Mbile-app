// ignore_for_file: avoid_print

import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:csv/csv.dart';

enum ExportType { pdf, csv, excel }

class ExportData {
  final String title;
  final String subtitle;
  final Map<String, dynamic> userData;
  final List<Map<String, dynamic>> tableData;
  final List<String> headers;
  final Map<String, dynamic>? summary;
  final String? period;

  ExportData({
    required this.title,
    required this.subtitle,
    required this.userData,
    required this.tableData,
    required this.headers,
    this.summary,
    this.period,
  });
}

class ExportService {
  static final ExportService _instance = ExportService._internal();
  static ExportService get instance => _instance;

  ExportService._internal();

  // Main export function
  Future<String?> exportData({
    required ExportData data,
    required ExportType type,
    String? customFileName,
  }) async {
    try {
      // Request storage permission
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }

      switch (type) {
        case ExportType.pdf:
          return await _exportToPDF(data, customFileName);
        case ExportType.csv:
          return await _exportToCSV(data, customFileName);
        case ExportType.excel:
          // Future implementation
          throw Exception('Excel export not implemented yet');
      }
    } catch (e) {
      print('Export error: $e');
      return null;
    }
  }

  // Export to PDF
  Future<String?> _exportToPDF(ExportData data, String? customFileName) async {
    print('=== STARTING PDF EXPORT ===');
    print('Title: ${data.title}');
    print('Subtitle: ${data.subtitle}');
    print('User Data: ${data.userData}');
    print('Table Data Length: ${data.tableData.length}');
    print('Headers: ${data.headers}');
    print('Summary: ${data.summary}');

    final pdf = pw.Document();

    try {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            print('✅ Building PDF content...');

            final widgets = <pw.Widget>[
              // Header
              _buildPDFHeader(data),
              pw.SizedBox(height: 20),

              // User Info
              _buildPDFUserInfo(data),
              pw.SizedBox(height: 20),

              // Summary (if available)
              if (data.summary != null && data.summary!.isNotEmpty) ...[
                _buildPDFSummary(data),
                pw.SizedBox(height: 20),
              ],

              // Table Data
              if (data.tableData.isNotEmpty) ...[
                _buildPDFTable(data),
                pw.SizedBox(height: 20),
              ],

              // Footer
              _buildPDFFooter(),
            ];

            print('✅ PDF widgets created: ${widgets.length}');
            return widgets;
          },
        ),
      );

      // Generate file name
      final fileName = customFileName ?? _generateFileName(data.title, 'pdf');
      print('✅ Generated filename: $fileName');

      // Get save directory
      final directory = await _getSaveDirectory();
      print('✅ Save directory: ${directory.path}');

      final file = File('${directory.path}/$fileName');
      print('✅ Full file path: ${file.path}');

      // Save PDF
      final pdfBytes = await pdf.save();
      print('✅ PDF bytes generated: ${pdfBytes.length} bytes');

      await file.writeAsBytes(pdfBytes);
      print('✅ PDF file written successfully');
      print('✅ File exists: ${await file.exists()}');
      print('✅ File size: ${await file.length()} bytes');
      print('=============================');

      return file.path;
    } catch (e) {
      print('❌ PDF Export Error: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      return null;
    }
  }

  // Export to CSV
  Future<String?> _exportToCSV(ExportData data, String? customFileName) async {
    final rows = <List<String>>[];

    // Add headers
    rows.add(data.headers);

    // Add data rows
    for (final item in data.tableData) {
      final row = <String>[];
      for (final header in data.headers) {
        final key = header.toLowerCase().replaceAll(' ', '_');
        row.add(item[key]?.toString() ?? '');
      }
      rows.add(row);
    }

    // Convert to CSV
    final csv = const ListToCsvConverter().convert(rows);

    // Save CSV
    final fileName = customFileName ?? _generateFileName(data.title, 'csv');
    final directory = await _getSaveDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(csv);

    return file.path;
  }

  // PDF Building Methods
  pw.Widget _buildPDFHeader(ExportData data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'KÖB Banking',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey800,
                  ),
                ),
                pw.Text(
                  'Kurdish-O-Banking',
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                ),
              ],
            ),
            pw.Text(
              DateTime.now().toString().split(' ')[0],
              style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
            ),
          ],
        ),
        pw.SizedBox(height: 20),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                data.title,
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                data.subtitle,
                style: pw.TextStyle(fontSize: 14, color: PdfColors.grey600),
              ),
              if (data.period != null) ...[
                pw.SizedBox(height: 4),
                pw.Text(
                  'Period: ${data.period}',
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildPDFUserInfo(ExportData data) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Account Information',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      'Account Holder',
                      data.userData['username'] ?? 'N/A',
                    ),
                    _buildInfoRow(
                      'Account Type',
                      data.userData['account_type'] ?? 'N/A',
                    ),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      'Account Number',
                      data.userData['account_number'] ?? 'N/A',
                    ),
                    _buildInfoRow(
                      'Generated On',
                      DateTime.now().toString().split(' ')[0],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: 2,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Expanded(
            flex: 3,
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 12, color: PdfColors.grey800),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPDFSummary(ExportData data) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.green50,
        border: pw.Border.all(color: PdfColors.green200),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Summary',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          pw.Wrap(
            spacing: 20,
            runSpacing: 8,
            children:
                data.summary!.entries.map((entry) {
                  return pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.white,
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(
                      '${entry.key}: ${entry.value}',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPDFTable(ExportData data) {
    print('Building PDF table with ${data.tableData.length} rows');

    if (data.tableData.isEmpty) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(16),
        child: pw.Text(
          'No transaction data available for the selected period.',
          style: pw.TextStyle(fontSize: 14, color: PdfColors.grey600),
        ),
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Balance History',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          children: [
            // Header row
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey100),
              children:
                  data.headers.map((header) {
                    return pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        header,
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
            ),
            // Data rows
            ...data.tableData.take(20).map((row) {
              return pw.TableRow(
                children:
                    data.headers.map((header) {
                      final key = header.toLowerCase().replaceAll(' ', '_');
                      final value = row[key]?.toString() ?? 'N/A';
                      return pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          value,
                          style: pw.TextStyle(fontSize: 10),
                        ),
                      );
                    }).toList(),
              );
            }),
          ],
        ),
        if (data.tableData.length > 20)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 8),
            child: pw.Text(
              'Note: Only first 20 records shown. Export to CSV for complete data.',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  pw.Widget _buildPDFFooter() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'This report was generated by KÖB Banking System',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Generated on: ${DateTime.now()}',
            style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
          ),
        ],
      ),
    );
  }

  // Helper Methods
  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      if (status.isDenied) {
        final result = await Permission.storage.request();
        return result.isGranted;
      }
      return status.isGranted;
    }
    return true;
  }

  Future<Directory> _getSaveDirectory() async {
    if (Platform.isAndroid) {
      // Try Downloads folder first
      Directory? directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        directory = await getExternalStorageDirectory();
      }
      return directory ?? await getApplicationDocumentsDirectory();
    } else {
      // iOS Documents folder
      return await getApplicationDocumentsDirectory();
    }
  }

  String _generateFileName(String title, String extension) {
    final now = DateTime.now();
    final dateString =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final timeString =
        '${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}';
    final cleanTitle = title
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^\w\s-]'), '');
    return 'KOB_${cleanTitle}_${dateString}_$timeString.$extension';
  }
}
