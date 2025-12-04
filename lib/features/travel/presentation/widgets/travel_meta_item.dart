import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safa_app/core/styles/app_colors.dart';

class TravelMetaItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const TravelMetaItem({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context)
            .textTheme
            .bodyMedium
            ?.color
            ?.withValues(alpha: 0.8) ??
        AppColors.textGrey;
    return Row(
      children: [
        Icon(
          icon,
          size: 18.sp,
          color: Theme.of(context).colorScheme.primary,
        ),
        SizedBox(width: 6.w),
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
