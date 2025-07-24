// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../core/constants.dart';

//centre container with specification
class FeatureCard extends StatelessWidget {
  const FeatureCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color:
            isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isDark
                  ? Colors.white.withOpacity(0.2)
                  : Colors.black.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children:
            AppConstants.features.map((feature) {
              return _buildFeatureItem(
                icon: feature['icon'] as String,
                text: feature['text'] as String,
                color: feature['color'] as Color,
              );
            }).toList(),
      ),
    );
  }

  Widget _buildFeatureItem({
    required String icon,
    required String text,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(1),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(icon, style: const TextStyle(fontSize: 20)),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          text,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
