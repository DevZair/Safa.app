import 'package:safa_app/features/travel/presentation/widgets/travel_package_card.dart';
import 'package:safa_app/features/travel/presentation/pages/travel_company_page.dart';
import 'package:safa_app/features/travel/presentation/cubit/travel_cubit.dart';
import 'package:safa_app/features/travel/domain/entities/travel_company.dart';
import 'package:safa_app/features/travel/presentation/widgets/company_image.dart';
import 'package:safa_app/core/localization/app_localizations.dart';
import 'package:safa_app/core/navigation/app_router.dart';
import 'package:safa_app/widgets/gradient_header.dart';
import 'package:safa_app/core/styles/app_colors.dart';
import 'package:safa_app/widgets/segmented_tabs.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class TravelPage extends StatelessWidget {
  const TravelPage({super.key});

  static const routeName = '/travel';

  @override
  Widget build(BuildContext context) => const _TravelView();
}

class _TravelView extends StatelessWidget {
  const _TravelView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TravelCubit, TravelState>(
      builder: (context, state) {
        final cubit = context.read<TravelCubit>();
        final l10n = context.l10n;
        final theme = Theme.of(context);
        final packages = state.packages;
        final favorites = packages
            .where((p) => state.favoritePackageIds.contains(p.id))
            .toList();
        final favoritesCount = favorites.length;
        final packageCountByCompany = <String, int>{};
        for (final package in packages) {
          packageCountByCompany[package.companyId] =
              (packageCountByCompany[package.companyId] ?? 0) + 1;
        }
        final horizontalPadding = 20.w;
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: Builder(
            builder: (context) {
              if (state.isLoading &&
                  state.companies.isEmpty &&
                  state.packages.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              final content = ListView(
                padding: EdgeInsets.only(bottom: 40.h),
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeroHeader(
                        title: state.heroTitle,
                        subtitle: state.heroSubtitle,
                        metrics: state.metrics,
                      ),
                      SizedBox(height: 90.h),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildSegmentedTabs(
                              context: context,
                              tabs: [
                                SegmentedTabConfig(
                                  label: l10n.t('travel.tabs.companies'),
                                  icon: Icons.apartment_rounded,
                                ),
                                SegmentedTabConfig(
                                  label: l10n.t(
                                    'travel.tabs.saved',
                                    params: {'count': '$favoritesCount'},
                                  ),
                                  icon: Icons.favorite_border_rounded,
                                  activeIcon: Icons.favorite_rounded,
                                ),
                              ],
                              selectedIndex: state.activeTab.index,
                              onTabSelected: (index) =>
                                  cubit.selectTab(TravelTab.values[index]),
                            ),
                            SizedBox(height: 28.h),
                            if (state.activeTab == TravelTab.all) ...[
                              _SectionHeader(
                                title: l10n.t('travel.section.companies'),
                              ),
                              SizedBox(height: 18.h),
                              if (state.isLoading && state.companies.isEmpty)
                                const _TravelLoadingCard()
                              else if (state.companies.isEmpty)
                                _PlaceholderText(
                                  text: l10n.t('travel.section.noCompanies'),
                                )
                              else
                                for (final company in state.companies) ...[
                                  _CompanyCard(
                                    company: company,
                                    toursCount:
                                        packageCountByCompany[company.id] ?? 0,
                                    onTap: () => context.pushNamed(
                                      AppRoute.travelCompany.name,
                                      extra: TravelCompanyDetailArgs(
                                        company: company,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 16.h),
                                ],
                            ] else ...[
                              _SectionHeader(
                                title: l10n.t(
                                  'travel.tabs.saved',
                                  params: {'count': '$favoritesCount'},
                                ),
                              ),
                              SizedBox(height: 14.h),
                              if (state.isLoading && favorites.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 30.h,
                                    ),
                                    child: const CircularProgressIndicator(),
                                  ),
                                )
                              else if (favorites.isEmpty)
                                Text(
                                  l10n.t('travel.saved.empty'),
                                  style: TextStyle(
                                    color: theme.textTheme.bodyMedium?.color
                                        ?.withValues(alpha: 0.7),
                                    fontSize: 15.sp,
                                  ),
                                )
                              else
                                for (final package in favorites) ...[
                                  TravelPackageCard(
                                    package: package,
                                    isFavorite: true,
                                    onFavoriteToggle: () =>
                                        cubit.toggleFavorite(package.id),
                                  ),
                                  SizedBox(height: 16.h),
                                ],
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );

              return content;
            },
          ),
        );
      },
    );
  }
}

class _HeroHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<TravelMetric> metrics;

  const _HeroHeader({
    required this.title,
    required this.subtitle,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320.h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GradientHeader(
            icon: Icons.travel_explore_rounded,
            title: title,
            subtitle: subtitle,
          ),
          Positioned(
            left: 20.w,
            right: 20.w,
            bottom: -60.h,
            child: _MetricsCard(metrics: metrics),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderText extends StatelessWidget {
  final String text;

  const _PlaceholderText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(
            context,
          ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
          fontSize: 15.sp,
        ),
      ),
    );
  }
}

class _MetricsCard extends StatelessWidget {
  final List<TravelMetric> metrics;

  const _MetricsCard({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(38.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 32.r,
            offset: Offset(0, 22.h),
          ),
        ],
      ),
      child: Row(
        children: [
          for (int i = 0; i < metrics.length; i++) ...[
            Expanded(child: _MetricTile(metric: metrics[i])),
            if (i != metrics.length - 1)
              Container(
                width: 1.w,
                height: 56.h,
                color: AppColors.metricDivider,
              ),
          ],
        ],
      ),
    );
  }
}

class _TravelLoadingCard extends StatelessWidget {
  const _TravelLoadingCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.r),
        gradient: const LinearGradient(
          colors: [Color(0xFF48C6B6), Color(0xFF35A0D3)],
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 28.r,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 140.w,
            height: 140.h,
            child: Lottie.asset(
              'assets/lotties/loading_plane.json',
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'Загружаем туры',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Собираем лучшие предложения прямо сейчас',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final TravelMetric metric;

  const _MetricTile({required this.metric});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final valueColor = isDark ? Colors.white : AppColors.textPrimary;
    final labelColor = isDark
        ? Colors.white.withValues(alpha: 0.7)
        : AppColors.textMuted;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 52.r,
          height: 52.r,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            gradient: const LinearGradient(
              colors: [AppColors.mintTint, AppColors.skyTint],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Icon(metric.icon, color: AppColors.iconAccent),
        ),
        SizedBox(height: 10.h),
        Text(
          metric.value,
          style: TextStyle(
            color: valueColor,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          metric.label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: labelColor,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final color =
        Theme.of(context).textTheme.titleMedium?.color ?? AppColors.headingDark;
    return Text(
      title,
      style: TextStyle(
        color: color,
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _CompanyCard extends StatelessWidget {
  final TravelCompany company;
  final int toursCount;
  final VoidCallback onTap;

  const _CompanyCard({
    required this.company,
    required this.toursCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final l10n = context.l10n;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(30.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 26.r,
              offset: Offset(0, 18.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18.r),
                child: CompanyImage(imagePath: company.thumbnail, size: 56.r),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    company.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color:
                          Theme.of(context).textTheme.titleMedium?.color ??
                          AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: AppColors.primary,
                        size: 18.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        company.rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color:
                              Theme.of(context).textTheme.bodyLarge?.color ??
                              AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        l10n.t(
                          'travel.company.toursCount',
                          params: {'count': '$toursCount'},
                        ),
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 42.r,
              height: 42.r,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                gradient: const LinearGradient(
                  colors: [
                    AppColors.arrowGradientStart,
                    AppColors.arrowGradientEnd,
                  ],
                ),
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16.sp,
                color: AppColors.iconArrow,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
