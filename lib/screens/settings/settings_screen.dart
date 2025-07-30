// lib/screens/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/settings_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/settings/settings_section_widget.dart';
import '../../widgets/settings/settings_item_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SettingsProvider>(context, listen: false).loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      appBar: _buildAppBar(context, isDarkMode),
      body: Consumer2<SettingsProvider, ThemeProvider>(
        builder: (context, settingsProvider, themeProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Preferences Section
                SettingsSectionWidget(
                  title: 'App Preferences',
                  icon: Icons.tune,
                  children: [
                    SettingsItemWidget(
                      title: 'Theme Mode',
                      subtitle: _getThemeSubtitle(themeProvider),
                      icon: _getThemeIcon(themeProvider),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showThemeDialog(themeProvider),
                    ),
                    SettingsItemWidget(
                      title: 'Language',
                      subtitle: settingsProvider.selectedLanguage,
                      icon: Icons.language,
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showLanguageDialog(settingsProvider),
                    ),
                    SettingsItemWidget(
                      title: 'Font Size',
                      subtitle: settingsProvider.fontSize,
                      icon: Icons.font_download,
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showFontSizeDialog(settingsProvider),
                    ),
                    SettingsItemWidget(
                      title: 'App Notifications',
                      subtitle: 'Enable or disable app notifications',
                      icon: Icons.notifications_outlined,
                      trailing: Switch(
                        value: settingsProvider.appNotificationsEnabled,
                        onChanged:
                            (value) =>
                                settingsProvider.toggleAppNotifications(),
                        activeColor: AppColors.primaryGreen,
                      ),
                    ),
                    SettingsItemWidget(
                      title: 'Sound Effects',
                      subtitle: 'Enable app sound effects',
                      icon: Icons.volume_up_outlined,
                      trailing: Switch(
                        value: settingsProvider.soundEffectsEnabled,
                        onChanged:
                            (value) => settingsProvider.toggleSoundEffects(),
                        activeColor: AppColors.primaryGreen,
                      ),
                    ),
                    SettingsItemWidget(
                      title: 'Haptic Feedback',
                      subtitle: 'Enable vibration feedback',
                      icon: Icons.vibration,
                      trailing: Switch(
                        value: settingsProvider.hapticFeedbackEnabled,
                        onChanged:
                            (value) => settingsProvider.toggleHapticFeedback(),
                        activeColor: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Security & Privacy Section
                SettingsSectionWidget(
                  title: 'Security & Privacy',
                  icon: Icons.security,
                  children: [
                    SettingsItemWidget(
                      title: 'Change PIN',
                      subtitle: 'Update your security PIN',
                      icon: Icons.pin_outlined,
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _navigateToChangePIN(),
                    ),
                    SettingsItemWidget(
                      title: 'Biometric Login',
                      subtitle: 'Use fingerprint or face ID',
                      icon: Icons.fingerprint,
                      trailing: Switch(
                        value: settingsProvider.biometricLoginEnabled,
                        onChanged:
                            (value) => settingsProvider.toggleBiometricLogin(),
                        activeColor: AppColors.primaryGreen,
                      ),
                    ),
                    SettingsItemWidget(
                      title: 'Auto-Logout Timer',
                      subtitle: '${settingsProvider.autoLogoutMinutes} minutes',
                      icon: Icons.timer_outlined,
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showAutoLogoutDialog(settingsProvider),
                    ),
                    SettingsItemWidget(
                      title: 'Screen Lock',
                      subtitle: 'Lock app when minimized',
                      icon: Icons.lock_outline,
                      trailing: Switch(
                        value: settingsProvider.screenLockEnabled,
                        onChanged:
                            (value) => settingsProvider.toggleScreenLock(),
                        activeColor: AppColors.primaryGreen,
                      ),
                    ),
                    SettingsItemWidget(
                      title: 'Privacy Policy',
                      subtitle: 'View our privacy policy',
                      icon: Icons.privacy_tip_outlined,
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _navigateToPrivacyPolicy(),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Transaction Preferences Section
                SettingsSectionWidget(
                  title: 'Transaction Preferences',
                  icon: Icons.account_balance_wallet,
                  children: [
                    SettingsItemWidget(
                      title: 'Transaction Confirmation',
                      subtitle: settingsProvider.transactionConfirmationMethod,
                      icon: Icons.check_circle_outline,
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap:
                          () => _showConfirmationMethodDialog(settingsProvider),
                    ),
                    SettingsItemWidget(
                      title: 'Limit Warnings',
                      subtitle: 'Warn before reaching limits',
                      icon: Icons.warning_outlined,
                      trailing: Switch(
                        value: settingsProvider.limitWarningsEnabled,
                        onChanged:
                            (value) => settingsProvider.toggleLimitWarnings(),
                        activeColor: AppColors.primaryGreen,
                      ),
                    ),
                    SettingsItemWidget(
                      title: 'Receipt Preferences',
                      subtitle: settingsProvider.receiptPreference,
                      icon: Icons.receipt_outlined,
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap:
                          () => _showReceiptPreferencesDialog(settingsProvider),
                    ),
                    SettingsItemWidget(
                      title: 'Auto-Categorize',
                      subtitle: 'Automatically categorize transactions',
                      icon: Icons.category_outlined,
                      trailing: Switch(
                        value: settingsProvider.autoCategorizeEnabled,
                        onChanged:
                            (value) => settingsProvider.toggleAutoCategorize(),
                        activeColor: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Notifications Section
                SettingsSectionWidget(
                  title: 'Notifications',
                  icon: Icons.notifications,
                  children: [
                    SettingsItemWidget(
                      title: 'Transaction Alerts',
                      subtitle: 'Get notified for all transactions',
                      icon: Icons.payment,
                      trailing: Switch(
                        value: settingsProvider.transactionAlertsEnabled,
                        onChanged:
                            (value) =>
                                settingsProvider.toggleTransactionAlerts(),
                        activeColor: AppColors.primaryGreen,
                      ),
                    ),
                    SettingsItemWidget(
                      title: 'Low Balance Warnings',
                      subtitle: 'Alert when balance is low',
                      icon: Icons.account_balance,
                      trailing: Switch(
                        value: settingsProvider.lowBalanceWarningsEnabled,
                        onChanged:
                            (value) =>
                                settingsProvider.toggleLowBalanceWarnings(),
                        activeColor: AppColors.primaryGreen,
                      ),
                    ),
                    SettingsItemWidget(
                      title: 'Security Alerts',
                      subtitle: 'Important security notifications',
                      icon: Icons.security_outlined,
                      trailing: Switch(
                        value: settingsProvider.securityAlertsEnabled,
                        onChanged:
                            (value) => settingsProvider.toggleSecurityAlerts(),
                        activeColor: AppColors.primaryGreen,
                      ),
                    ),
                    SettingsItemWidget(
                      title: 'Marketing Communications',
                      subtitle: 'Promotional offers and updates',
                      icon: Icons.campaign_outlined,
                      trailing: Switch(
                        value: settingsProvider.marketingCommunicationsEnabled,
                        onChanged:
                            (value) =>
                                settingsProvider
                                    .toggleMarketingCommunications(),
                        activeColor: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Backup & Data Section
                SettingsSectionWidget(
                  title: 'Backup & Data',
                  icon: Icons.backup,
                  children: [
                    SettingsItemWidget(
                      title: 'Export Transaction History',
                      subtitle: 'Download your transaction data',
                      icon: Icons.download,
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _exportTransactionHistory(),
                    ),
                    SettingsItemWidget(
                      title: 'Backup Preferences',
                      subtitle: settingsProvider.backupFrequency,
                      icon: Icons.cloud_upload,
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap:
                          () => _showBackupPreferencesDialog(settingsProvider),
                    ),
                    SettingsItemWidget(
                      title: 'Data Sync',
                      subtitle: 'Sync data across devices',
                      icon: Icons.sync,
                      trailing: Switch(
                        value: settingsProvider.dataSyncEnabled,
                        onChanged: (value) => settingsProvider.toggleDataSync(),
                        activeColor: AppColors.primaryGreen,
                      ),
                    ),
                    SettingsItemWidget(
                      title: 'Clear Cache',
                      subtitle: 'Free up storage space',
                      icon: Icons.cleaning_services,
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showClearCacheDialog(),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Support & Legal Section
                SettingsSectionWidget(
                  title: 'Support & Legal',
                  icon: Icons.help,
                  children: [
                    SettingsItemWidget(
                      title: 'Help & FAQ',
                      subtitle: 'Get help and find answers',
                      icon: Icons.help_outline,
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _navigateToHelp(),
                    ),
                    SettingsItemWidget(
                      title: 'Contact Support',
                      subtitle: 'Get in touch with our team',
                      icon: Icons.support_agent,
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _contactSupport(),
                    ),
                    SettingsItemWidget(
                      title: 'Report a Problem',
                      subtitle: 'Report bugs or issues',
                      icon: Icons.bug_report,
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _reportProblem(),
                    ),
                    SettingsItemWidget(
                      title: 'About App',
                      subtitle: 'App version and information',
                      icon: Icons.info_outline,
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showAboutDialog(),
                    ),
                    SettingsItemWidget(
                      title: 'Terms of Service',
                      subtitle: 'View terms and conditions',
                      icon: Icons.description,
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _navigateToTerms(),
                    ),
                    SettingsItemWidget(
                      title: 'Rate the App',
                      subtitle: 'Share your feedback',
                      icon: Icons.star_outline,
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _rateApp(),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  // Build AppBar using your existing pattern
  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDarkMode) {
    return AppBar(
      backgroundColor:
          isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      foregroundColor: isDarkMode ? Colors.white : AppColors.darkText,
      elevation: 0,
      title: Text(
        'Settings',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: isDarkMode ? Colors.white : AppColors.darkText,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _showResetDialog(),
          icon: const Icon(Icons.restore),
          tooltip: 'Reset to Default',
        ),
      ],
    );
  }

  // Theme dialog method
  void _showThemeDialog(ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: const Text('Theme Mode'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('System Default'),
                  subtitle: const Text('Follow system theme'),
                  leading: const Icon(Icons.brightness_auto),
                  trailing:
                      themeProvider.isSystemMode
                          ? const Icon(
                            Icons.check,
                            color: AppColors.primaryGreen,
                          )
                          : null,
                  onTap: () {
                    themeProvider.resetToSystem();
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Light Mode'),
                  subtitle: const Text('Always use light theme'),
                  leading: const Icon(Icons.light_mode),
                  trailing:
                      (!themeProvider.isSystemMode && !themeProvider.isDarkMode)
                          ? const Icon(
                            Icons.check,
                            color: AppColors.primaryGreen,
                          )
                          : null,
                  onTap: () {
                    themeProvider.setTheme(false);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Always use dark theme'),
                  leading: const Icon(Icons.dark_mode),
                  trailing:
                      (!themeProvider.isSystemMode && themeProvider.isDarkMode)
                          ? const Icon(
                            Icons.check,
                            color: AppColors.primaryGreen,
                          )
                          : null,
                  onTap: () {
                    themeProvider.setTheme(true);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
    );
  }

  // Helper methods for theme display
  String _getThemeSubtitle(ThemeProvider themeProvider) {
    if (themeProvider.isSystemMode) {
      return 'System Default';
    }
    return themeProvider.isDarkMode ? 'Dark Mode' : 'Light Mode';
  }

  IconData _getThemeIcon(ThemeProvider themeProvider) {
    if (themeProvider.isSystemMode) {
      return Icons.brightness_auto;
    }
    return themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode;
  }

  void _showLanguageDialog(SettingsProvider provider) {
    showDialog(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: const Text('Select Language'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('English'),
                  trailing:
                      provider.selectedLanguage == 'English'
                          ? const Icon(Icons.check)
                          : null,
                  onTap: () {
                    provider.setLanguage('English');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Kurdish'),
                  trailing:
                      provider.selectedLanguage == 'Kurdish'
                          ? const Icon(Icons.check)
                          : null,
                  onTap: () {
                    provider.setLanguage('Kurdish');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Arabic'),
                  trailing:
                      provider.selectedLanguage == 'Arabic'
                          ? const Icon(Icons.check)
                          : null,
                  onTap: () {
                    provider.setLanguage('Arabic');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showFontSizeDialog(SettingsProvider provider) {
    showDialog(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: const Text('Font Size'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Small'),
                  trailing:
                      provider.fontSize == 'Small'
                          ? const Icon(Icons.check)
                          : null,
                  onTap: () {
                    provider.setFontSize('Small');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Medium'),
                  trailing:
                      provider.fontSize == 'Medium'
                          ? const Icon(Icons.check)
                          : null,
                  onTap: () {
                    provider.setFontSize('Medium');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Large'),
                  trailing:
                      provider.fontSize == 'Large'
                          ? const Icon(Icons.check)
                          : null,
                  onTap: () {
                    provider.setFontSize('Large');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showAutoLogoutDialog(SettingsProvider provider) {
    showDialog(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: const Text('Auto-Logout Timer'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  [5, 10, 15, 30, 60]
                      .map(
                        (minutes) => ListTile(
                          title: Text('$minutes minutes'),
                          trailing:
                              provider.autoLogoutMinutes == minutes
                                  ? const Icon(Icons.check)
                                  : null,
                          onTap: () {
                            provider.setAutoLogoutMinutes(minutes);
                            Navigator.pop(context);
                          },
                        ),
                      )
                      .toList(),
            ),
          ),
    );
  }

  void _showConfirmationMethodDialog(SettingsProvider provider) {
    showDialog(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: const Text('Transaction Confirmation'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  ['PIN', 'Biometric', 'Both']
                      .map(
                        (method) => ListTile(
                          title: Text(method),
                          trailing:
                              provider.transactionConfirmationMethod == method
                                  ? const Icon(Icons.check)
                                  : null,
                          onTap: () {
                            provider.setTransactionConfirmationMethod(method);
                            Navigator.pop(context);
                          },
                        ),
                      )
                      .toList(),
            ),
          ),
    );
  }

  void _showReceiptPreferencesDialog(SettingsProvider provider) {
    showDialog(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: const Text('Receipt Preferences'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  ['Email', 'SMS', 'Both', 'None']
                      .map(
                        (preference) => ListTile(
                          title: Text(preference),
                          trailing:
                              provider.receiptPreference == preference
                                  ? const Icon(Icons.check)
                                  : null,
                          onTap: () {
                            provider.setReceiptPreference(preference);
                            Navigator.pop(context);
                          },
                        ),
                      )
                      .toList(),
            ),
          ),
    );
  }

  void _showBackupPreferencesDialog(SettingsProvider provider) {
    showDialog(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: const Text('Backup Frequency'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  ['Daily', 'Weekly', 'Monthly', 'Manual']
                      .map(
                        (frequency) => ListTile(
                          title: Text(frequency),
                          trailing:
                              provider.backupFrequency == frequency
                                  ? const Icon(Icons.check)
                                  : null,
                          onTap: () {
                            provider.setBackupFrequency(frequency);
                            Navigator.pop(context);
                          },
                        ),
                      )
                      .toList(),
            ),
          ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: const Text('Clear Cache'),
            content: const Text(
              'This will clear temporary files and free up storage space. Continue?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cache cleared successfully')),
                  );
                },
                child: const Text('Clear'),
              ),
            ],
          ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: const Text(AppConstants.appName),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppConstants.appSubtitle),
                const SizedBox(height: 8),
                Text(AppConstants.appVersion),
                const SizedBox(height: 16),
                const Text(
                  'A secure and modern banking application designed for your financial needs.',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  // Navigation Methods (Placeholders for future implementation)
  void _navigateToChangePIN() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Change PIN feature coming soon')),
    );
  }

  void _navigateToPrivacyPolicy() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy Policy feature coming soon')),
    );
  }

  void _exportTransactionHistory() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Export feature coming soon')));
  }

  void _navigateToHelp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help & FAQ feature coming soon')),
    );
  }

  void _contactSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact Support feature coming soon')),
    );
  }

  void _reportProblem() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report Problem feature coming soon')),
    );
  }

  void _navigateToTerms() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terms of Service feature coming soon')),
    );
  }

  void _rateApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rate App feature coming soon')),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: const Text('Reset Settings'),
            content: const Text(
              'Are you sure you want to reset all settings to default?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Provider.of<SettingsProvider>(
                    context,
                    listen: false,
                  ).resetToDefaults();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Settings have been reset to default'),
                    ),
                  );
                },
                child: const Text('Reset'),
              ),
            ],
          ),
    );
  }
}
