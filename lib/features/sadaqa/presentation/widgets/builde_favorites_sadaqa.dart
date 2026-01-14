import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safa_app/core/localization/app_localizations.dart';

Widget buildFavoritesPlaceholder(BuildContext context) {
  final l10n = context.l10n;
  return Container(
    margin: EdgeInsets.only(top: 12.h),
    padding: EdgeInsets.symmetric(vertical: 36.h, horizontal: 20.w),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(24.r),
      boxShadow: [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.05),
          blurRadius: 15.r,
          offset: Offset(0, 8.h),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.favorite_border,
          size: 40.sp,
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
        ),
        SizedBox(height: 16.h),
        Text(
          l10n.t('sadaqa.placeholder.title'),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        Text(
          l10n.t('sadaqa.placeholder.subtitle'),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(
              context,
            ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
          ),
        ),
      ],
    ),
  );
}
