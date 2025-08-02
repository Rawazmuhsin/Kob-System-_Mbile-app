// lib/widgets/transactions/transaction_filter_widget.dart
import 'package:flutter/material.dart';
import '../../core/constants.dart';

class TransactionFilterWidget extends StatelessWidget {
  final String selectedPeriod;
  final String selectedType;
  final Function(String) onPeriodChanged;
  final Function(String) onTypeChanged;

  const TransactionFilterWidget({
    super.key,
    required this.selectedPeriod,
    required this.selectedType,
    required this.onPeriodChanged,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final periods = ['All Time', 'Last 30 Days', 'Last 7 Days', 'Today'];
    final types = ['All Types', 'Deposit', 'Withdrawal', 'Transfer', 'ATM'];

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Period Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color:
                  isDarkMode
                      ? Colors.white.withOpacity(0.05)
                      : Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: isDarkMode ? Colors.white70 : AppColors.lightText,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedPeriod,
                      isExpanded: true,
                      hint: const Text('Select Period'),
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : AppColors.darkText,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      dropdownColor:
                          isDarkMode ? AppColors.darkSurface : Colors.white,
                      items:
                          periods.map((period) {
                            return DropdownMenuItem(
                              value: period,
                              child: Text(period),
                            );
                          }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          onPeriodChanged(value);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Type Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color:
                  isDarkMode
                      ? Colors.white.withOpacity(0.05)
                      : Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.category,
                  color: isDarkMode ? Colors.white70 : AppColors.lightText,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedType,
                      isExpanded: true,
                      hint: const Text('Select Type'),
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : AppColors.darkText,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      dropdownColor:
                          isDarkMode ? AppColors.darkSurface : Colors.white,
                      items:
                          types.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          onTypeChanged(value);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
