// lib/widgets/settings/settings_item_widget.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../core/constants.dart';

class SettingsItemWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;
  final Color? iconColor;

  const SettingsItemWidget({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.trailing,
    this.onTap,
    this.enabled = true,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              // Leading Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.primaryGreen).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color:
                      enabled
                          ? (iconColor ?? AppColors.primaryGreen)
                          : (isDarkMode ? Colors.white30 : Colors.grey),
                ),
              ),

              const SizedBox(width: 16),

              // Title and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color:
                            enabled
                                ? (isDarkMode
                                    ? Colors.white
                                    : AppColors.darkText)
                                : (isDarkMode ? Colors.white54 : Colors.grey),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              enabled
                                  ? (isDarkMode
                                      ? Colors.white70
                                      : AppColors.lightText)
                                  : (isDarkMode ? Colors.white30 : Colors.grey),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Trailing Widget
              if (trailing != null) ...[const SizedBox(width: 12), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}
