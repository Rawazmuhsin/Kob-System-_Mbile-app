// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../widgets/input_field.dart';

class TransactionsFilterWidget extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String) onSearchChanged;
  final String selectedStatus;
  final String selectedType;
  final Function(String) onStatusChanged;
  final Function(String) onTypeChanged;
  final int totalTransactions;
  final VoidCallback onClearFilters;

  const TransactionsFilterWidget({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.selectedStatus,
    required this.selectedType,
    required this.onStatusChanged,
    required this.onTypeChanged,
    required this.totalTransactions,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final hasActiveFilters =
        selectedStatus != 'all' ||
        selectedType != 'all' ||
        searchController.text.isNotEmpty;

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
          // Search Field
          InputField(
            controller: searchController,
            label: 'Search Transactions',
            hintText: 'Search by description, amount, or user',
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
          const SizedBox(height: 16),

          // Filter Chips
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Text(
                        'Status:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : AppColors.darkText,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'All',
                        'all',
                        selectedStatus,
                        onStatusChanged,
                        isDarkMode,
                      ),
                      _buildFilterChip(
                        'Pending',
                        'pending',
                        selectedStatus,
                        onStatusChanged,
                        isDarkMode,
                      ),
                      _buildFilterChip(
                        'Approved',
                        'approved',
                        selectedStatus,
                        onStatusChanged,
                        isDarkMode,
                      ),
                      _buildFilterChip(
                        'Rejected',
                        'rejected',
                        selectedStatus,
                        onStatusChanged,
                        isDarkMode,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Text(
                        'Type:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : AppColors.darkText,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'All',
                        'all',
                        selectedType,
                        onTypeChanged,
                        isDarkMode,
                      ),
                      _buildFilterChip(
                        'Deposit',
                        'deposit',
                        selectedType,
                        onTypeChanged,
                        isDarkMode,
                      ),
                      _buildFilterChip(
                        'Withdrawal',
                        'withdrawal',
                        selectedType,
                        onTypeChanged,
                        isDarkMode,
                      ),
                      _buildFilterChip(
                        'Transfer',
                        'transfer',
                        selectedType,
                        onTypeChanged,
                        isDarkMode,
                      ),
                      _buildFilterChip(
                        'Purchase',
                        'purchase',
                        selectedType,
                        onTypeChanged,
                        isDarkMode,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Results and Clear Filters
          Row(
            children: [
              Icon(
                Icons.receipt_long,
                size: 16,
                color: isDarkMode ? Colors.white70 : AppColors.lightText,
              ),
              const SizedBox(width: 8),
              Text(
                '$totalTransactions transactions found',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white70 : AppColors.lightText,
                ),
              ),
              const Spacer(),
              if (hasActiveFilters) ...[
                TextButton.icon(
                  onPressed: onClearFilters,
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: const Text('Clear Filters'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  ),
                ),
              ] else ...[
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
                    'All Results',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String value,
    String selectedValue,
    Function(String) onChanged,
    bool isDarkMode,
  ) {
    final isSelected = selectedValue == value;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primaryGreen
                  : (isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected
                    ? AppColors.primaryGreen
                    : (isDarkMode
                        ? Colors.white.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.3)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color:
                isSelected
                    ? Colors.white
                    : (isDarkMode ? Colors.white70 : AppColors.lightText),
          ),
        ),
      ),
    );
  }
}
