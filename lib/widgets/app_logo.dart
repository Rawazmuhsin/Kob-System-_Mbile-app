import 'package:flutter/material.dart';
import '../core/constants.dart';

class AppLogo extends StatefulWidget {
  final double size;
  final bool showText;
  final bool animated;

  const AppLogo({
    super.key,
    this.size = 100,
    this.showText = true,
    this.animated = true,
  });

  @override
  State<AppLogo> createState() => _AppLogoState();
}

class _AppLogoState extends State<AppLogo> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();

    // Create animation controller for floating effect
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Create floating animation (moves up and down gently)
    _floatingAnimation = Tween<double>(
      begin: -8.0, // Move up by 8 pixels
      end: 8.0, // Move down by 8 pixels
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Start the floating animation if enabled
    if (widget.animated) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo Container with floating animation
        widget.animated
            ? AnimatedBuilder(
              animation: _floatingAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatingAnimation.value),
                  child: _buildLogoContainer(),
                );
              },
            )
            : _buildLogoContainer(),

        if (widget.showText) ...[
          const SizedBox(height: 24),
          const Text(
            AppConstants.appSubtitle,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            AppConstants.appTagline,
            style: TextStyle(
              fontSize: 16,
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.8)
                      : AppColors.lightText,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLogoContainer() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(widget.size * 0.25),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.4),
            blurRadius: 60,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Center(
        child: Text(
          AppConstants.appLogo,
          style: TextStyle(
            fontSize: widget.size * 0.36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
