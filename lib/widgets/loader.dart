// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../core/constants.dart';

class Loader extends StatefulWidget {
  final String? message;
  final Color? color;
  final double? size;

  const Loader({super.key, this.message, this.color, this.size});

  @override
  State<Loader> createState() => _LoaderState();
}

class _LoaderState extends State<Loader> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value * 2 * 3.14159,
              child: Container(
                width: widget.size ?? 40,
                height: widget.size ?? 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: (widget.color ?? AppColors.primaryGreen).withOpacity(
                      0.3,
                    ),
                    width: 3,
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border(
                      top: BorderSide(
                        color: widget.color ?? AppColors.primaryGreen,
                        width: 3,
                      ),
                      right: BorderSide.none,
                      bottom: BorderSide.none,
                      left: BorderSide.none,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: TextStyle(
              fontSize: 16,
              color:
                  isDarkMode
                      ? Colors.white.withOpacity(0.8)
                      : AppColors.lightText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  static void show(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkSurface
                        : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Loader(message: message),
            ),
          ),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}
