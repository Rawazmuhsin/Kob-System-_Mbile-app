import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../widgets/input_field.dart';

class UsersSearchWidget extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String) onSearchChanged;
  final int totalUsers;

  const UsersSearchWidget({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.totalUsers,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.8),
        border: Border(
          bottom: BorderSide(
            color:
                isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
          ),
        ),
      ),
      child: Column(
        children: [
          InputField(
            controller: searchController,
            label: 'Search Users',
            hintText: 'Search by name, email, phone, or account number',
            isDarkMode: isDarkMode,
            onChanged: onSearchChanged,
            suffixIcon:
                searchController.text.isNotEmpty
                    ? IconButton(
                      onPressed: () {
                        searchController.clear();
                        onSearchChanged('');
                      },
                      icon: const Icon(Icons.clear),
                    )
                    : const Icon(Icons.search),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Icon(
                Icons.people,
                size: 16,
                color: isDarkMode ? Colors.white70 : AppColors.lightText,
              ),
              const SizedBox(width: 8),
              Text(
                '$totalUsers users found',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white70 : AppColors.lightText,
                ),
              ),
              const Spacer(),
              if (searchController.text.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Filtered',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
