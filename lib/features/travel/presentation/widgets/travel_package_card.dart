import 'package:flutter/material.dart';
import 'package:safa_app/core/styles/app_colors.dart';
import 'package:safa_app/features/travel/presentation/widgets/travel_badge.dart';
import 'package:safa_app/features/travel/presentation/widgets/travel_meta_item.dart';

class TravelPackage {
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
}

class TravelBadgeData {
  final String text;
  final Color background;
  final Color foreground;

  const TravelBadgeData(
    this.text,
    this.background, [
    this.foreground = Colors.white,
  ]);
}

class TravelPackageCard extends StatelessWidget {
  final TravelPackage package;

  const TravelPackageCard({
    super.key,
    required this.package,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PackageImage(package: package),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  package.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.place_outlined,
                        size: 18, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        package.location,
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 16),
                _GuideRow(package: package),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
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

  const _PackageImage({required this.package});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 11,
            child: Image.asset(
              package.imagePath,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            left: 16,
            top: 16,
            child: Row(
              children: [
                for (final tag in package.tags) ...[
                  TravelBadge(
                    label: tag.text,
                    backgroundColor: tag.background,
                    foregroundColor: tag.foreground,
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          Positioned(
            right: 16,
            top: 16,
            child: TravelBadge(
              label: package.availabilityLabel,
              backgroundColor: const Color(0xFFE11D48),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFFD1FAE5),
          child: Icon(Icons.person, color: AppColors.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                package.guideName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star_rounded,
                      size: 16, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 4),
                  Text(
                    package.guideRating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Color(0xFF475569),
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
            const Text(
              'per person',
              style: TextStyle(
                color: Color(0xFF94A3B8),
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
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [
              AppColors.primary,
              Color(0xFF2BB7A0),
            ],
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
          'Book Tour - \$$price',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
