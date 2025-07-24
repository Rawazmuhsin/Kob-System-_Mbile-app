import 'package:flutter/material.dart';
import '../core/utils.dart';

class BiometricButton extends StatelessWidget {
  final IconData icon;
  final String type;

  const BiometricButton({super.key, required this.icon, required this.type});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => AppUtils.showBiometricFeedback(context, type),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color:
              isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                isDark
                    ? Colors.white.withOpacity(0.2)
                    : Colors.black.withOpacity(0.1),
          ),
        ),
        child: Icon(
          icon,
          size: 24,
          color: isDark ? Colors.white : const Color(0xFF1E293B),
        ),
      ),
    );
  }
}
