// lib/widgets/transactions/transaction_filter_widget.dart
import 'package:flutter/material.dart';
import '../../core/constants.dart';

class TransactionFilterWidget extends StatelessWidget {
  final String selectedPeriod;
  final Function(String) onPeriodChanged;

  const TransactionFilterWidget({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final periods = ['All Time', 'Last 30 Days', 'Last 7 Days', 'Today'];

    return Container(
      margin: const EdgeInsets.all(16),
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
            Icons.filter_list,
            color: isDarkMode ? Colors.white70 : AppColors.lightText,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedPeriod,
                isExpanded: true,
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
    );
  }
}
