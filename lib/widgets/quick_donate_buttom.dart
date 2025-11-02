import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show BoxDecoration, Colors;
import 'package:safa_app/core/styles/app_colors.dart';

class QuickDonationButton extends StatelessWidget {
  final int amount;
  final bool isSelected;
  final VoidCallback onTap;

  const QuickDonationButton({
    super.key,
    required this.amount,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 70,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors
                      .primary // актив
                : Colors.grey.shade200, // неактив
            width: 2,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          '$amount\₸',
          style: TextStyle(
            color: isSelected ? AppColors.primary : const Color(0xFF2F855A),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
