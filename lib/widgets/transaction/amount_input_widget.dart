// lib/widgets/transaction/amount_input_widget.dart
import 'package:flutter/material.dart';
import '../../core/constants.dart';

class AmountInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool isDarkMode;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;

  const AmountInputWidget({
    super.key,
    required this.controller,
    required this.isDarkMode,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : AppColors.darkText,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : AppColors.darkText,
          ),
          decoration: InputDecoration(
            hintText: '0.00',
            prefixText: '\$ ',
            prefixStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : AppColors.darkText,
            ),
            filled: true,
            fillColor:
                isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : Colors.white.withOpacity(0.9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color:
                    isDarkMode
                        ? Colors.white.withOpacity(0.15)
                        : Colors.black.withOpacity(0.15),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color:
                    isDarkMode
                        ? Colors.white.withOpacity(0.15)
                        : Colors.black.withOpacity(0.15),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
            ),
          ),
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }
}
