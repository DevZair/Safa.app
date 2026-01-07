import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safa_app/core/styles/app_colors.dart';
import 'package:safa_app/features/travel/domain/entities/travel_package.dart';
import 'package:safa_app/features/travel/presentation/widgets/travel_badge.dart';
import 'package:safa_app/features/travel/presentation/widgets/travel_meta_item.dart';

class TravelBadgeData {
  final String text;
  final Color background;
  final Color foreground;

  const TravelBadgeData(
    this.text,
    this.background, [
    this.foreground = AppColors.white,
  ]);
}

class TravelPackageCard extends StatelessWidget {
  final TravelPackage package;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const TravelPackageCard({
    super.key,
    required this.package,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badges = _buildBadges(package);
    return Container(
      margin: EdgeInsets.only(bottom: 26.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 26.r,
            offset: Offset(0, 18.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 5 / 4,
                  child: _TravelImageCarousel(
                    images: package.gallery.isNotEmpty
                        ? package.gallery
                        : [package.imagePath],
                  ),
                ),
                Positioned(
                  left: 16.w,
                  top: 16.h,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final badge in badges)
                        Padding(
                          padding: EdgeInsets.only(right: 6.w),
                          child: TravelBadge(
                            label: badge.text,
                            backgroundColor: badge.background,
                            foregroundColor: badge.foreground,
                          ),
                        ),
                      if (package.availabilityLabel.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(right: 6.w),
                          child: TravelBadge(
                            label: package.availabilityLabel,
                            backgroundColor: AppColors.badgeDanger,
                            foregroundColor: AppColors.white,
                          ),
                        ),
                    ],
                  ),
                ),
                Positioned(
                  right: 16.w,
                  top: 16.h,
                  child: _FavoriteButton(
                    isFavorite: isFavorite,
                    onTap: onFavoriteToggle,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.place_outlined,
                      size: 16.sp,
                      color: theme.textTheme.bodyMedium?.color?.withValues(
                        alpha: 0.7,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        package.location,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                _GuideInfoRow(package: package),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    TravelMetaItem(
                      icon: Icons.calendar_month_outlined,
                      label: package.dateRangeLabel,
                    ),
                    SizedBox(width: 16.w),
                    TravelMetaItem(
                      icon: Icons.schedule_outlined,
                      label: package.durationLabel,
                    ),
                  ],
                ),
                if (package.groupSizeLabel.isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Text(
                      package.groupSizeLabel,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: theme.textTheme.bodyMedium?.color?.withValues(
                          alpha: 0.75,
                        ),
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 16.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.mintTint,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        package.priceLabel,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      if (package.priceSubtitle.isNotEmpty)
                        Text(
                          package.priceSubtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12.sp,
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: Text(
                      'Забронировать',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkTextPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<TravelBadgeData> _buildBadges(TravelPackage package) {
    final badges = <TravelBadgeData>[];
    if (package.isNew) {
      badges.add(const TravelBadgeData('Новинка', AppColors.badgeNew));
    }
    if (package.categoryLabel.isNotEmpty) {
      badges.add(
        TravelBadgeData(
          package.categoryLabel,
          AppColors.badgeLightBackground,
          AppColors.headingDeep,
        ),
      );
    }
    return badges;
  }
}

class _GuideInfoRow extends StatelessWidget {
  final TravelPackage package;

  const _GuideInfoRow({required this.package});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 24.r,
          backgroundColor: const Color.fromARGB(255, 50, 175, 111),
          child: Text(
            _initials(package.guideName),
            style: TextStyle(
              color: AppColors.darkTextPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 16.sp,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                package.guideName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Icon(
                    Icons.star_rounded,
                    color: AppColors.ratingStar,
                    size: 16.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    package.guideRating.toStringAsFixed(1),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withValues(
                        alpha: 0.7,
                      ),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'сертифицированный гид',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _initials(String name) {
    final parts = name.split(' ').where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class _FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;

  const _FavoriteButton({required this.isFavorite, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42.r,
        height: 42.r,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.12),
              blurRadius: 12.r,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite
              ? AppColors.primary
              : Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : AppColors.favoriteInactive,
        ),
      ),
    );
  }
}

class _TravelImageCarousel extends StatefulWidget {
  const _TravelImageCarousel({required this.images});

  final List<String> images;

  @override
  State<_TravelImageCarousel> createState() => _TravelImageCarouselState();
}

class _TravelImageCarouselState extends State<_TravelImageCarousel> {
  late final PageController _controller;
  Timer? _timer;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer?.cancel();
    if (widget.images.length < 2) return;
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      _current = (_current + 1) % widget.images.length;
      _controller.animateToPage(
        _current,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    return Stack(
      children: [
        PageView.builder(
          controller: _controller,
          onPageChanged: (index) => setState(() => _current = index),
          itemCount: images.length,
          itemBuilder: (context, index) {
            final path = images[index];
            final isNetwork = path.startsWith('http');
            return isNetwork
                ? Image.network(
                    path,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _fallback(),
                  )
                : Image.asset(
                    path,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _fallback(),
                  );
          },
        ),
        if (images.length > 1)
          Positioned(
            bottom: 10.h,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  width: _current == index ? 10.w : 6.w,
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: _current == index ? 0.95 : 0.6,
                    ),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _fallback() {
    return Container(
      color: AppColors.surfaceLight,
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported_outlined),
    );
  }
}
