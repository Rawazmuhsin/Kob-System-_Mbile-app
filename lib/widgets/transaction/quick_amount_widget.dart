// lib/widgets/transaction/quick_amount_widget.dart
import 'package:flutter/material.dart';
import '../../core/constants.dart';

class QuickAmountWidget extends StatelessWidget {
  final List<double> amounts;
  final Function(double) onAmountSelected;
  final bool isDarkMode;
  final double? availableBalance;

  const QuickAmountWidget({
    super.key,
    required this.amounts,
    required this.onAmountSelected,
    required this.isDarkMode,
    this.availableBalance,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Amounts',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : AppColors.darkText,
          ),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.5,
          ),
          itemCount: amounts.length,
          itemBuilder: (context, index) {
            final amount = amounts[index];
            final isDisabled =
                availableBalance != null && amount > availableBalance!;

            return GestureDetector(
              onTap: isDisabled ? null : () => onAmountSelected(amount),
              child: Container(
                decoration: BoxDecoration(
                  color:
                      isDisabled
                          ? Colors.grey.withOpacity(0.1)
                          : (isDarkMode
                              ? Colors.white.withOpacity(0.05)
                              : Colors.white.withOpacity(0.8)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        isDisabled
                            ? Colors.grey.withOpacity(0.3)
                            : (isDarkMode
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.05)),
                  ),
                ),
                child: Center(
                  child: Text(
                    '\$${amount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color:
                          isDisabled
                              ? Colors.grey
                              : (isDarkMode
                                  ? Colors.white
                                  : AppColors.darkText),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
