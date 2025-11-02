import 'package:flutter/material.dart';
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
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF475569),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
