// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../core/constants.dart';

class QuickActionGrid extends StatelessWidget {
  final VoidCallback onDeposit;
  final VoidCallback onWithdraw;
  final VoidCallback onTransfer;
  final VoidCallback onQRCodes;

  const QuickActionGrid({
    super.key,
    required this.onDeposit,
    required this.onWithdraw,
    required this.onTransfer,
    required this.onQRCodes,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      {
        'title': 'Deposit',
        'subtitle': 'Quickly deposit funds',
        'icon': Icons.add_circle_outline,
        'color': AppColors.primaryGreen,
        'onTap': onDeposit,
      },
      {
        'title': 'Withdraw',
        'subtitle': 'Withdraw your funds',
        'icon': Icons.remove_circle_outline,
        'color': Colors.orange,
        'onTap': onWithdraw,
      },
      {
        'title': 'Transfer',
        'subtitle': 'Transfer between accounts',
        'icon': Icons.swap_horiz,
        'color': Colors.blue,
        'onTap': onTransfer,
      },
      {
        'title': 'QR Codes',
        'subtitle': 'View your account QR',
        'icon': Icons.qr_code,
        'color': Colors.purple,
        'onTap': onQRCodes,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3, // Adjusted ratio to prevent overflow
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return QuickActionCard(
                title: action['title'] as String,
                subtitle: action['subtitle'] as String,
                icon: action['icon'] as IconData,
                color: action['color'] as Color,
                onTap: action['onTap'] as VoidCallback,
              );
            },
          ),
        ],
      ),
    );
  }
}

class QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const QuickActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isDarkMode
                  ? Colors.white.withOpacity(0.05)
                  : Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: (isDarkMode ? Colors.black : Colors.grey).withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Add this to prevent overflow
          children: [
            Container(
              width: 40, // Reduced size
              height: 40, // Reduced size
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20), // Reduced icon size
            ),
            const SizedBox(height: 8), // Reduced spacing
            Flexible(
              // Add Flexible to prevent overflow
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14, // Reduced font size
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : AppColors.darkText,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2), // Reduced spacing
            Flexible(
              // Add Flexible to prevent overflow
              child: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10, // Reduced font size
                  color:
                      isDarkMode
                          ? Colors.white.withOpacity(0.7)
                          : AppColors.lightText,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2, // Limit to 2 lines
              ),
            ),
          ],
        ),
      ),
    );
  }
}
