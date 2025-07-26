// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../widgets/app_logo.dart';
import '../widgets/custom_button.dart';
import '../widgets/feature_card.dart';
import '../widgets/biometric_button.dart';
import '../providers/theme_provider.dart';
import '../routes/app_routes.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors:
                    isDarkMode
                        ? AppColors.darkGradient
                        : AppColors.lightGradient,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header with theme buttons
                  _buildHeader(isDarkMode, themeProvider),

                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          _buildLogo(),
                          const SizedBox(height: 40),
                          _buildWelcomeContent(isDarkMode),
                          const SizedBox(height: 40),
                          _buildFeatures(isDarkMode),
                          const SizedBox(height: 40),
                          _buildActionButtons(),
                          const SizedBox(height: 30),
                          _buildBiometricOptions(isDarkMode),
                          const SizedBox(height: 20),
                          _buildVersion(isDarkMode),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDarkMode, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildThemeButton(
            icon: Icons.wb_sunny,
            isSelected:
                !themeProvider.isDarkMode && !themeProvider.isSystemMode,
            onTap: () => themeProvider.setTheme(false),
            isDarkMode: isDarkMode,
            tooltip: 'Light Mode',
          ),
          const SizedBox(width: 8),
          _buildThemeButton(
            icon: Icons.nightlight_round,
            isSelected: themeProvider.isDarkMode && !themeProvider.isSystemMode,
            onTap: () => themeProvider.setTheme(true),
            isDarkMode: isDarkMode,
            tooltip: 'Dark Mode',
          ),
          const SizedBox(width: 8),
          _buildThemeButton(
            icon: Icons.auto_mode,
            isSelected: themeProvider.isSystemMode,
            onTap: () => themeProvider.setTheme(false, isSystem: true),
            isDarkMode: isDarkMode,
            tooltip: 'System',
          ),
        ],
      ),
    );
  }

  Widget _buildThemeButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDarkMode,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color:
                isSelected
                    ? (isDarkMode
                        ? Colors.white.withOpacity(0.2)
                        : AppColors.primaryDark.withOpacity(0.1))
                    : (isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : Colors.white.withOpacity(0.8)),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color:
                  isSelected
                      ? (isDarkMode
                          ? Colors.white.withOpacity(0.4)
                          : AppColors.primaryDark.withOpacity(0.3))
                      : (isDarkMode
                          ? Colors.white.withOpacity(0.2)
                          : Colors.black.withOpacity(0.1)),
              width: isSelected ? 2 : 1,
            ),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: (isDarkMode
                                ? Colors.white
                                : AppColors.primaryDark)
                            .withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : null,
          ),
          child: Icon(
            icon,
            color:
                isSelected
                    ? (isDarkMode ? Colors.white : AppColors.primaryDark)
                    : (isDarkMode
                        ? Colors.white.withOpacity(0.7)
                        : AppColors.darkText.withOpacity(0.7)),
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            const AppLogo(size: 80),
            const SizedBox(height: 16),
            Text(
              AppConstants.appSubtitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : AppColors.darkText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppConstants.appTagline,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.8)
                        : AppColors.lightText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeContent(bool isDarkMode) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
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
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color:
                    isDarkMode
                        ? Colors.white.withOpacity(0.05)
                        : Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      isDarkMode
                          ? Colors.white.withOpacity(0.15)
                          : Colors.black.withOpacity(0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDarkMode ? Colors.black : Colors.grey)
                        .withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                AppConstants.welcomeMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color:
                      isDarkMode
                          ? Colors.white.withOpacity(0.9)
                          : AppColors.lightText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatures(bool isDarkMode) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color:
                isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
            ),
          ),
          child: const FeatureCard(),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Sign In',
                    onPressed: () => AppRoutes.navigateToLogin(context),
                    isPrimary: false,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: 'Create Account',
                    onPressed: () => AppRoutes.navigateToRegister(context),
                    isPrimary: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBiometricOptions(bool isDarkMode) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            Text(
              'Or use biometric authentication',
              style: TextStyle(
                fontSize: 14,
                color:
                    isDarkMode
                        ? Colors.white.withOpacity(0.7)
                        : AppColors.lightText,
              ),
            ),
            const SizedBox(height: 16),
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
      ),
    );
  }

  Widget _buildVersion(bool isDarkMode) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Text(
        AppConstants.appVersion,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          color:
              isDarkMode
                  ? Colors.white.withOpacity(0.5)
                  : AppColors.lightText.withOpacity(0.7),
        ),
      ),
    );
  }
}
