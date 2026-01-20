import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safa_app/core/styles/app_colors.dart';

class SettingsUserCard extends StatelessWidget {
  final String name;
  final String email;
  final VoidCallback? onPressed;

  const SettingsUserCard({
    super.key,
    required this.name,
    required this.email,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cardColor = Theme.of(context).cardColor;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(26.r),
        child: Ink(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(26.r),
            boxShadow: const [],
          ),
          child: Row(
            children: [
              Container(
                width: 56.r,
                height: 56.r,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF35C3A7), Color(0xFF1A9CD1)],
                  ),
                ),
                child: Icon(
                  Icons.person_outline,
                  color: Colors.white,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: onSurface,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      email,
                      style: textTheme.bodyMedium?.copyWith(
                        color: onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
