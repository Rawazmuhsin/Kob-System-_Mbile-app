// lib/widgets/settings/settings_section_widget.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../core/constants.dart';

class SettingsSectionWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final bool showDivider;

  const SettingsSectionWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isDarkMode ? Colors.white70 : AppColors.lightText,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : AppColors.darkText,
                ),
              ),
            ],
          ),
        ),

        // Section Content
        Container(
          decoration: BoxDecoration(
            color:
                isDarkMode
                    ? Colors.white.withOpacity(0.03)
                    : Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isDarkMode
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.05),
            ),
          ),
          child: Column(children: _buildChildren()),
        ),
      ],
    );
  }

  List<Widget> _buildChildren() {
    List<Widget> widgets = [];

    for (int i = 0; i < children.length; i++) {
      widgets.add(children[i]);

      // Add divider between items (except for the last item)
      if (showDivider && i < children.length - 1) {
        widgets.add(
          Divider(
            height: 1,
            thickness: 0.5,
            color: Colors.grey.withOpacity(0.3),
            indent: 16,
            endIndent: 16,
          ),
        );
      }
    }

    return widgets;
  }
}
