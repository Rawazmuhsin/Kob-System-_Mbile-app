// lib/widgets/transaction/withdraw_method_widget.dart
import 'package:flutter/material.dart';
import '../../core/constants.dart';

class WithdrawMethodWidget extends StatelessWidget {
  final List<String> methods;
  final String selectedMethod;
  final Function(String) onMethodSelected;
  final bool isDarkMode;

  const WithdrawMethodWidget({
    super.key,
    required this.methods,
    required this.selectedMethod,
    required this.onMethodSelected,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Withdrawal Method',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : AppColors.darkText,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children:
                methods.map((method) {
                  final isSelected = selectedMethod == method;
                  return GestureDetector(
                    onTap: () => onMethodSelected(method),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? AppColors.primaryGreen
                                : (isDarkMode
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.white.withOpacity(0.8)),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isSelected
                                  ? AppColors.primaryGreen
                                  : (isDarkMode
                                      ? Colors.white.withOpacity(0.1)
                                      : Colors.black.withOpacity(0.05)),
                        ),
                      ),
                      child: Text(
                        method,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color:
                              isSelected
                                  ? Colors.white
                                  : (isDarkMode
                                      ? Colors.white
                                      : AppColors.darkText),
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}
