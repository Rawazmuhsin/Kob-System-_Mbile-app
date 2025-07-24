// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/utils.dart';
import '../widgets/app_logo.dart';
import '../widgets/custom_button.dart';
import '../widgets/feature_card.dart';
import '../widgets/biometric_button.dart';
import '../widgets/theme_toggle_button.dart';

// action page for login and signup page
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isDarkMode = true;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = _isDarkMode ? darkColorScheme : lightColorScheme;
    final textTheme = _isDarkMode ? darkTextTheme : lightTextTheme;

    return Theme(
      data: Theme.of(
        context,
      ).copyWith(colorScheme: colorScheme, textTheme: textTheme),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors:
                  _isDarkMode
                      ? AppColors.darkGradient
                      : AppColors.lightGradient,
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            // Header Section
                            _buildHeader(),

                            // Main Content
                            Expanded(child: _buildMainContent()),

                            // Action Section
                            _buildActionSection(),

                            // Footer
                            _buildFooter(),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 40, bottom: 10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: ThemeToggleButton(
              isDarkMode: _isDarkMode,
              onToggle: _toggleTheme,
            ),
          ),
          const AppLogo(),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ShaderMask(
          shaderCallback:
              (bounds) => const LinearGradient(
                colors: [Color(0xFF1F2937), Color(0xFF10B981)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(bounds),
          child: const Text(
            'Welcome to KOB',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppConstants.welcomeMessage,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 17,
            height: 1.5,
            color:
                _isDarkMode
                    ? Colors.white.withOpacity(0.8)
                    : AppColors.lightText,
          ),
        ),
        const SizedBox(height: 40),
        const FeatureCard(),
      ],
    );
  }

  Widget _buildActionSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        children: [
          const SizedBox(height: 40),
          CustomButton(
            text: 'Log In',
            onPressed: () => AppUtils.navigateToLogin(context),
            isPrimary: true,
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Create Account',
            onPressed: () => AppUtils.navigateToRegister(context),
            isPrimary: false,
          ),
          const SizedBox(height: 24),
          const Text(
            'Or use biometric authentication',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BiometricButton(icon: Icons.fingerprint, type: 'fingerprint'),
              SizedBox(width: 16),
              BiometricButton(icon: Icons.face, type: 'face'),
              SizedBox(width: 16),
              BiometricButton(icon: Icons.password, type: 'pin'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        AppConstants.appVersion,
        style: TextStyle(
          fontSize: 12,
          color:
              _isDarkMode ? Colors.white.withOpacity(0.8) : AppColors.lightText,
        ),
      ),
    );
  }
}
