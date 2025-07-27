// lib/widgets/export_dialog.dart
// Replace your entire export_dialog.dart file with this:

import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../services/export_service.dart';

class ExportDialog extends StatefulWidget {
  final ExportData exportData;
  final String title;

  const ExportDialog({
    super.key,
    required this.exportData,
    this.title = 'Export Data',
  });

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  ExportType _selectedType = ExportType.pdf;
  bool _isExporting = false;
  String? _savedPath;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDarkMode ? AppColors.darkSurface : Colors.white,
      title: Text(
        widget.title,
        style: TextStyle(
          color: isDarkMode ? Colors.white : AppColors.darkText,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose export format:',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.white70 : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 16),

          // Export type selection
          ...ExportType.values.map((type) {
            final isSelected = _selectedType == type;
            return _buildExportOption(
              type: type,
              isSelected: isSelected,
              isDarkMode: isDarkMode,
              onTap: () => setState(() => _selectedType = type),
            );
          }),

          if (_savedPath != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primaryGreen.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColors.primaryGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Export Successful!',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Saved to: ${_savedPath!.split('/').last}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    'Location: ${_getReadablePath(_savedPath!)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDarkMode ? Colors.white60 : AppColors.lightText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close', style: TextStyle(color: AppColors.primaryGreen)),
        ),
        ElevatedButton(
          onPressed: _isExporting ? null : _handleExport,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
          ),
          child:
              _isExporting
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : Text(_savedPath != null ? 'Export Again' : 'Export'),
        ),
      ],
    );
  }

  Widget _buildExportOption({
    required ExportType type,
    required bool isSelected,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    final info = _getExportTypeInfo(type);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primaryGreen.withOpacity(0.1)
                  : (isDarkMode
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isSelected
                    ? AppColors.primaryGreen
                    : (isDarkMode
                        ? Colors.white.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.3)),
          ),
        ),
        child: Row(
          children: [
            Radio<ExportType>(
              value: type,
              groupValue: _selectedType,
              onChanged: (value) => setState(() => _selectedType = value!),
              activeColor: AppColors.primaryGreen,
            ),
            const SizedBox(width: 8),
            Icon(info['icon'], color: info['color'], size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info['title'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : AppColors.darkText,
                    ),
                  ),
                  Text(
                    info['description'],
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.white60 : AppColors.lightText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getExportTypeInfo(ExportType type) {
    switch (type) {
      case ExportType.pdf:
        return {
          'title': 'PDF Document',
          'description': 'Formatted report with charts and styling',
          'icon': Icons.picture_as_pdf,
          'color': Colors.red,
        };
      case ExportType.csv:
        return {
          'title': 'CSV Spreadsheet',
          'description': 'Raw data for Excel/Google Sheets',
          'icon': Icons.table_chart,
          'color': Colors.green,
        };
      case ExportType.excel:
        return {
          'title': 'Excel File',
          'description': 'Native Excel format (Coming Soon)',
          'icon': Icons.description,
          'color': Colors.blue,
        };
    }
  }

  Future<void> _handleExport() async {
    setState(() {
      _isExporting = true;
      _savedPath = null;
    });

    try {
      final path = await ExportService.instance.exportData(
        data: widget.exportData,
        type: _selectedType,
      );

      if (path != null) {
        setState(() {
          _savedPath = path;
        });
      } else {
        _showError('Export failed. Please try again.');
      }
    } catch (e) {
      _showError('Export error: ${e.toString()}');
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  String _getReadablePath(String path) {
    if (path.contains('Download')) {
      return 'Downloads folder';
    } else if (path.contains('Documents')) {
      return 'Documents folder';
    } else {
      return 'App folder';
    }
  }
}

// Helper class for showing export dialog
class ExportDialogHelper {
  static Future<void> show({
    required BuildContext context,
    required ExportData exportData,
    String title = 'Export Data',
  }) {
    return showDialog(
      context: context,
      builder: (context) => ExportDialog(exportData: exportData, title: title),
    );
  }
}
