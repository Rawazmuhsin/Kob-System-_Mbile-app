// lib/widgets/admin/recent_activities_section.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../core/constants.dart';

class RecentActivitiesSection extends StatelessWidget {
  final List<Map<String, dynamic>> activities;
  final VoidCallback onViewAll;

  const RecentActivitiesSection({
    super.key,
    required this.activities,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isDarkMode
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.history, color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Activities',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? Colors.white : AppColors.darkText,
                      ),
                    ),
                    Text(
                      'Latest admin actions and system events',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            isDarkMode ? Colors.white70 : AppColors.lightText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Activities list
          if (activities.isEmpty)
            _buildEmptyState(isDarkMode)
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activities.length > 5 ? 5 : activities.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return ActivityItem(activity: activities[index]);
              },
            ),

          const SizedBox(height: 20),

          // View all button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onViewAll,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'View Full Audit Log',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.history_outlined,
            size: 64,
            color:
                isDarkMode
                    ? Colors.white.withValues(alpha: 0.3)
                    : AppColors.lightText.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No recent activities',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color:
                  isDarkMode
                      ? Colors.white.withValues(alpha: 0.7)
                      : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Admin activities will appear here',
            style: TextStyle(
              fontSize: 14,
              color:
                  isDarkMode
                      ? Colors.white.withValues(alpha: 0.5)
                      : AppColors.lightText.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class ActivityItem extends StatelessWidget {
  final Map<String, dynamic> activity;

  const ActivityItem({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? Colors.white.withValues(alpha: 0.03)
                : Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              isDarkMode
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
        ),
      ),
      child: Row(
        children: [
          // Activity icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _getActivityColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getActivityIcon(),
              color: _getActivityColor(),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),

          // Activity details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['activity'] ?? 'Unknown Activity',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : AppColors.darkText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  activity['description'] ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white70 : AppColors.lightText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Time and amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (activity['amount'] != null)
                Text(
                  '\$${(activity['amount'] as num).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getActivityColor(),
                  ),
                ),
              Text(
                _formatDate(activity['date']),
                style: TextStyle(
                  fontSize: 10,
                  color: isDarkMode ? Colors.white60 : AppColors.lightText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon() {
    final activityType = activity['activity'] as String? ?? '';
    if (activityType.contains('APPROVED')) {
      return Icons.check_circle;
    } else if (activityType.contains('REJECTED')) {
      return Icons.cancel;
    } else if (activityType.contains('Transaction')) {
      return Icons.receipt;
    } else {
      return Icons.info;
    }
  }

  Color _getActivityColor() {
    final activityType = activity['activity'] as String? ?? '';
    if (activityType.contains('APPROVED')) {
      return Colors.green;
    } else if (activityType.contains('REJECTED')) {
      return Colors.red;
    } else {
      return Colors.blue;
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';

    DateTime dateTime;
    if (date is String) {
      try {
        dateTime = DateTime.parse(date);
      } catch (e) {
        return '';
      }
    } else if (date is DateTime) {
      dateTime = date;
    } else {
      return '';
    }

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}
