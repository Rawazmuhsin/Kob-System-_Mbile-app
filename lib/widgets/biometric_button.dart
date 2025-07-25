import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/utils.dart';

class BiometricButton extends StatefulWidget {
  final IconData icon;
  final String type;

  const BiometricButton({super.key, required this.icon, required this.type});

  @override
  State<BiometricButton> createState() => _BiometricButtonState();
}

class _BiometricButtonState extends State<BiometricButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() async {
    await _animationController.forward();
    await _animationController.reverse();

    if (mounted) {
      AppUtils.showBiometricFeedback(context, widget.type);

      // Simulate biometric authentication
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        AppUtils.showSnackBar(
          context,
          '${widget.type} authentication simulated',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: _handleTap,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color:
                isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color:
                  isDarkMode
                      ? Colors.white.withOpacity(0.2)
                      : Colors.black.withOpacity(0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: (isDarkMode ? Colors.black : Colors.grey).withOpacity(
                  0.1,
                ),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            widget.icon,
            size: 28,
            color:
                isDarkMode
                    ? Colors.white.withOpacity(0.8)
                    : AppColors.darkText.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}
