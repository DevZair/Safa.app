import 'dart:async';

import 'package:safa_app/features/travel/presentation/widgets/travel_meta_item.dart';
import 'package:safa_app/features/travel/presentation/widgets/travel_badge.dart';
import 'package:safa_app/core/localization/app_localizations.dart';
import 'package:safa_app/core/styles/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';

class TravelPackage {
  final String id;
  final String companyId;
  final String categoryId;
  final String title;
  final String location;
  final String imagePath;
  final List<String> gallery;
  final String guideName;
  final double guideRating;
  final int priceUsd;
  final String availabilityLabel;
  final List<TravelBadgeData> tags;
  final String startDateLabel;
  final String durationLabel;

  const TravelPackage({
    required this.id,
    required this.companyId,
    required this.categoryId,
    required this.title,
    required this.location,
    required this.imagePath,
    required this.gallery,
    required this.guideName,
    required this.guideRating,
    required this.priceUsd,
    required this.availabilityLabel,
    required this.tags,
    required this.startDateLabel,
    required this.durationLabel,
  });

  factory TravelPackage.fromJson(Map<String, Object?> json) {
    final price = json['price_usd'] ?? json['price'] ?? 0;
    final guideRatingRaw = json['guide_rating'] ?? json['guideRating'];
    final guideRating = guideRatingRaw is num
        ? guideRatingRaw.toDouble()
        : double.tryParse('$guideRatingRaw') ?? 0;
    final images = <String>[];
    final rawImages = json['images'] ?? json['gallery'];
    if (rawImages is List) {
      images.addAll(
        rawImages
            .map((e) => '$e')
            .where((path) => path.trim().isNotEmpty)
            .toList(),
      );
    }
    return TravelPackage(
      id: '${json['id'] ?? ''}',
      companyId: '${json['company_id'] ?? json['companyId'] ?? ''}',
      categoryId: '${json['category_id'] ?? json['categoryId'] ?? 'all'}',
      title: '${json['title'] ?? ''}',
      location: '${json['location'] ?? ''}',
      imagePath: '${json['image'] ?? json['imagePath'] ?? ''}',
      gallery: images,
      guideName: '${json['guide_name'] ?? json['guideName'] ?? ''}',
      guideRating: guideRating,
      priceUsd: price is num ? price.toInt() : int.tryParse('$price') ?? 0,
      availabilityLabel:
          '${json['availability_label'] ?? json['availability'] ?? ''}',
      startDateLabel: '${json['start_date_label'] ?? json['start_date'] ?? ''}',
      durationLabel: '${json['duration_label'] ?? json['duration'] ?? ''}',
      tags: const [],
    );
  }
}

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
    return Container(
      margin: EdgeInsets.only(bottom: 26.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 20.r,
            offset: Offset(0, 12.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PackageImage(
            package: package,
            isFavorite: isFavorite,
            onFavoriteToggle: onFavoriteToggle,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  package.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(
                      Icons.place_outlined,
                      size: 18.sp,
                      color: AppColors.iconLocation,
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        package.location,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 14.sp,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withValues(alpha: 0.75),
                            ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Divider(height: 1.h, color: Theme.of(context).dividerColor),
                SizedBox(height: 16.h),
                _GuideRow(package: package),
                SizedBox(height: 16.h),
                Divider(height: 1.h, color: Theme.of(context).dividerColor),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    TravelMetaItem(
                      icon: Icons.calendar_month_outlined,
                      label: package.startDateLabel,
                    ),
                    SizedBox(width: 18.w),
                    TravelMetaItem(
                      icon: Icons.schedule_outlined,
                      label: package.durationLabel,
                    ),
                  ],
                ),
                SizedBox(height: 22.h),
                _BookButton(price: package.priceUsd),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PackageImage extends StatelessWidget {
  final TravelPackage package;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const _PackageImage({
    required this.package,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 11,
            child: _TravelImageCarousel(
              images:
                  package.gallery.isNotEmpty ? package.gallery : [package.imagePath],
            ),
          ),
          Positioned(
            left: 16.w,
            top: 16.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8.w,
                  runSpacing: 6.h,
                  children: [
                    for (final tag in package.tags)
                      TravelBadge(
                        label: tag.text,
                        backgroundColor: tag.background,
                        foregroundColor: tag.foreground,
                      ),
                  ],
                ),
                if (package.availabilityLabel.isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  TravelBadge(
                    label: package.availabilityLabel,
                    backgroundColor: AppColors.badgeDanger,
                  ),
                ],
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
    );
  }
}

class _GuideRow extends StatelessWidget {
  final TravelPackage package;

  const _GuideRow({required this.package});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 24.r,
          backgroundColor: AppColors.surfaceAvatar,
          child: Icon(Icons.person, color: AppColors.primary),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                package.guideName,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color:
                      Theme.of(context).textTheme.titleMedium?.color ??
                          AppColors.headingDeep,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.star_rounded,
                    size: 16.sp,
                    color: AppColors.ratingStar,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    package.guideRating.toStringAsFixed(1),
                    style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withValues(alpha: 0.7),
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${package.priceUsd}',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              l10n.t('travel.book.perPerson'),
              style: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withValues(alpha: 0.7),
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BookButton extends StatelessWidget {
  final int price;

  const _BookButton({required this.price});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 52.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.buttonGradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.28),
              blurRadius: 18.r,
              offset: Offset(0, 10.h),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          l10n.t(
            'travel.book.cta',
            params: {'price': '$price'},
          ),
          style: TextStyle(
            color: AppColors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
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
                    color: Colors.white.withValues(alpha: _current == index ? 0.95 : 0.6),
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
