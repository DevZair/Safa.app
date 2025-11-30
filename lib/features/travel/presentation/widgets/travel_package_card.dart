import 'package:safa_app/features/travel/presentation/widgets/travel_meta_item.dart';
import 'package:safa_app/features/travel/presentation/widgets/travel_badge.dart';
import 'package:safa_app/core/localization/app_localizations.dart';
import 'package:safa_app/core/styles/app_colors.dart';
import 'package:flutter/material.dart';

class TravelPackage {
  final String id;
  final String companyId;
  final String categoryId;
  final String title;
  final String location;
  final String imagePath;
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
    return TravelPackage(
      id: '${json['id'] ?? ''}',
      companyId: '${json['company_id'] ?? json['companyId'] ?? ''}',
      categoryId: '${json['category_id'] ?? json['categoryId'] ?? 'all'}',
      title: '${json['title'] ?? ''}',
      location: '${json['location'] ?? ''}',
      imagePath: '${json['image'] ?? json['imagePath'] ?? ''}',
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
      margin: const EdgeInsets.only(bottom: 26),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 12),
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  package.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.place_outlined,
                      size: 18,
                      color: AppColors.iconLocation,
                    ),
                    const SizedBox(width: 6),
                   Expanded(
                     child: Text(
                       package.location,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
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
                const SizedBox(height: 16),
                Divider(height: 1, color: Theme.of(context).dividerColor),
                const SizedBox(height: 16),
          _GuideRow(package: package),
                const SizedBox(height: 16),
                Divider(height: 1, color: Theme.of(context).dividerColor),
                const SizedBox(height: 16),
                Row(
                  children: [
                    TravelMetaItem(
                      icon: Icons.calendar_month_outlined,
                      label: package.startDateLabel,
                    ),
                    const SizedBox(width: 18),
                    TravelMetaItem(
                      icon: Icons.schedule_outlined,
                      label: package.durationLabel,
                    ),
                  ],
                ),
                const SizedBox(height: 22),
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
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 11,
            child: _TravelImage(imagePath: package.imagePath),
          ),
          Positioned(
            left: 16,
            top: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
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
                  const SizedBox(height: 10),
                  TravelBadge(
                    label: package.availabilityLabel,
                    backgroundColor: AppColors.badgeDanger,
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            right: 16,
            top: 16,
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
          radius: 24,
          backgroundColor: AppColors.surfaceAvatar,
          child: Icon(Icons.person, color: AppColors.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                package.guideName,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color:
                      Theme.of(context).textTheme.titleMedium?.color ??
                          AppColors.headingDeep,
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: AppColors.ratingStar,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    package.guideRating.toStringAsFixed(1),
                    style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withValues(alpha: 0.7),
                      fontSize: 13,
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
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 16,
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
                fontSize: 12,
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
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.buttonGradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.28),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          l10n.t(
            'travel.book.cta',
            params: {'price': '$price'},
          ),
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 16,
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
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 6),
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

class _TravelImage extends StatelessWidget {
  final String imagePath;

  const _TravelImage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: AppColors.surfaceLight,
          alignment: Alignment.center,
          child: const Icon(Icons.image_not_supported_outlined),
        ),
      );
    }

    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: AppColors.surfaceLight,
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported_outlined),
      ),
    );
  }
}
