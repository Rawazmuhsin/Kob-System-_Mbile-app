import 'package:flutter/material.dart';
import '../../core/constants.dart';

class PeriodSelector extends StatelessWidget {
  final String selectedPeriod;
  final Function(String) onPeriodChanged;
  final bool isDarkMode;

  const PeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final periods = ['7D', '1M', '3M', '6M', '1Y'];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children:
            periods.map((period) {
              final isSelected = selectedPeriod == period;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onPeriodChanged(period),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? AppColors.primaryGreen
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      period,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color:
                            isSelected
                                ? Colors.white
                                : (isDarkMode
                                    ? Colors.white70
                                    : AppColors.lightText),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
