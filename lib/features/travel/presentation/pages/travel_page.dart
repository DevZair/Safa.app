import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safa_app/core/localization/app_localizations.dart';
import 'package:safa_app/core/styles/app_colors.dart';
import 'package:safa_app/features/travel/presentation/cubit/travel_cubit.dart';
import 'package:safa_app/features/travel/presentation/widgets/travel_package_card.dart';
import 'package:safa_app/widgets/gradient_header.dart';
import 'package:safa_app/widgets/segmented_tabs.dart';

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
        final packages = state.activeTab == TravelTab.saved
            ? state.packages
                  .where((p) => state.favoritePackageIds.contains(p.id))
                  .toList()
            : state.packages;
        final favoritesCount = state.favoritePackageIds.length;
        final l10n = context.l10n;
        final theme = Theme.of(context);
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 40),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeroHeader(
                    title: state.heroTitle,
                    subtitle: state.heroSubtitle,
                    metrics: state.metrics,
                  ),
                  const SizedBox(height: 90),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionHeader(title: l10n.t('travel.section.categories')),
                        const SizedBox(height: 14),
                        _CategoriesChips(
                          categories: state.categories,
                          selectedId: state.selectedCategoryId,
                        ),
                        const SizedBox(height: 26),
                        buildSegmentedTabs(
                          context: context,
                          tabs: [
                            SegmentedTabConfig(
                              label: l10n.t('travel.tabs.all'),
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
                        const SizedBox(height: 32),
                        if (state.activeTab == TravelTab.all) ...[
                          _SectionHeader(title: l10n.t('travel.section.companies')),
                          const SizedBox(height: 18),
                          for (final company in state.companies) ...[
                            _CompanyCard(company: company),
                            const SizedBox(height: 16),
                          ],
                        ],
                        const SizedBox(height: 24),
                        _SectionHeader(title: l10n.t('travel.section.allTours')),
                        const SizedBox(height: 6),
                        Text(
                          l10n.t(
                            'travel.section.availableCount',
                            params: {'count': '${packages.length}'},
                          ),
                          style: const TextStyle(
                            color: AppColors.textInfo,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 20),
                        for (final package in packages) ...[
                          TravelPackageCard(
                            package: package,
                            isFavorite: state.favoritePackageIds.contains(
                              package.id,
                            ),
                            onFavoriteToggle: () =>
                                cubit.toggleFavorite(package.id),
                          ),
                          const SizedBox(height: 18),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
      height: 320,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GradientHeader(
            icon: Icons.travel_explore_rounded,
            title: title,
            subtitle: subtitle,
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: -60,
            child: _MetricsCard(metrics: metrics),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(38),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 32,
            offset: const Offset(0, 22),
          ),
        ],
      ),
      child: Row(
        children: [
          for (int i = 0; i < metrics.length; i++) ...[
            Expanded(child: _MetricTile(metric: metrics[i])),
            if (i != metrics.length - 1)
              Container(width: 1, height: 56, color: AppColors.metricDivider),
          ],
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
    final valueColor =
        isDark ? Colors.white : AppColors.textPrimary;
    final labelColor = isDark
        ? Colors.white.withValues(alpha: 0.7)
        : AppColors.textMuted;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [AppColors.mintTint, AppColors.skyTint],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Icon(metric.icon, color: AppColors.iconAccent),
        ),
        const SizedBox(height: 10),
        Text(
          metric.value,
          style: TextStyle(
            color: valueColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          metric.label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: labelColor,
            fontSize: 12,
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
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _CategoriesChips extends StatelessWidget {
  final List<TravelCategory> categories;
  final String selectedId;

  const _CategoriesChips({required this.categories, required this.selectedId});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TravelCubit>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final unselectedColor =
        theme.cardColor;
    final unselectedBorder = isDark
        ? AppColors.darkStroke
        : AppColors.borderLight;
    final unselectedText =
        theme.textTheme.bodyMedium?.color ?? AppColors.textSecondary;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final category in categories) ...[
            GestureDetector(
              onTap: () => cubit.selectCategory(category.id),
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  color: selectedId == category.id
                      ? AppColors.primary
                      : unselectedColor,
                  border: selectedId == category.id
                      ? null
                      : Border.all(color: unselectedBorder),
                  boxShadow: [],
                ),
                child: Row(
                  children: [
                    Icon(
                      category.icon,
                      size: 18,
                      color: selectedId == category.id
                          ? AppColors.white
                          : unselectedText.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category.label,
                      style: TextStyle(
                        color: selectedId == category.id
                            ? AppColors.white
                            : unselectedText,
                        fontSize: 14,
                        fontWeight: selectedId == category.id
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CompanyCard extends StatelessWidget {
  final TravelCompany company;

  const _CompanyCard({required this.company});

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 26,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(24),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                company.thumbnail,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  company.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.titleMedium?.color ??
                        AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      company.rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color:
                            Theme.of(context).textTheme.bodyLarge?.color ??
                                AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      l10n.t(
                        'travel.company.toursCount',
                        params: {'count': '${company.tours}'},
                      ),
                      style: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [
                  AppColors.arrowGradientStart,
                  AppColors.arrowGradientEnd,
                ],
              ),
            ),
            child: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.iconArrow,
            ),
          ),
        ],
      ),
    );
  }
}
