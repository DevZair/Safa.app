import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:safa_app/core/localization/app_localizations.dart';
import 'package:safa_app/core/styles/app_colors.dart';
import 'package:safa_app/features/travel/models/travel_company.dart';
import 'package:safa_app/features/travel/presentation/cubit/travel_cubit.dart';
import 'package:safa_app/features/travel/presentation/widgets/travel_package_card.dart';
import 'package:safa_app/widgets/segmented_tabs.dart';

class TravelCompanyDetailArgs {
  final TravelCompany company;

  const TravelCompanyDetailArgs({required this.company});
}

class TravelCompanyPage extends StatefulWidget {
  final TravelCompany company;

  const TravelCompanyPage({super.key, required this.company});

  @override
  State<TravelCompanyPage> createState() => _TravelCompanyPageState();
}

class _TravelCompanyPageState extends State<TravelCompanyPage> {
  String _selectedCategoryId = 'all';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TravelCubit, TravelState>(
      builder: (context, state) {
        final l10n = context.l10n;
        final cubit = context.read<TravelCubit>();
        final categories = state.categories;
        final companyPackages = state.packages
            .where((p) => p.companyId == widget.company.id)
            .toList();
        final selectedId = categories.any((c) => c.id == _selectedCategoryId)
            ? _selectedCategoryId
            : (categories.isNotEmpty ? categories.first.id : '');
        final selectedIndex = categories.indexWhere(
          (category) => category.id == selectedId,
        );
        final filteredPackages = selectedId == 'all' || selectedId.isEmpty
            ? companyPackages
            : companyPackages
                .where((p) => p.categoryId == selectedId)
                .toList();
        final tabConfigs = categories
            .map(
              (category) => SegmentedTabConfig(
                label:
                    '${category.label} (${category.id == 'all' ? companyPackages.length : companyPackages.where((p) => p.categoryId == category.id).length})',
              ),
            )
            .toList();
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(
                  children: [
                    _CompanyHeader(company: widget.company),
                    if (categories.isNotEmpty)
                      Transform.translate(
                        offset: const Offset(0, -26),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: buildSegmentedTabs(
                            context: context,
                            tabs: tabConfigs,
                            selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
                            onTabSelected: (index) {
                              setState(
                                () => _selectedCategoryId =
                                    categories[index].id,
                              );
                            },
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (state.errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _CompanyError(message: state.errorMessage!),
                            ),
                          if (state.isLoading && filteredPackages.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else ...[
                            if (categories.isNotEmpty) const SizedBox(height: 6),
                            Text(
                              l10n.t(
                                'travel.section.availableCount',
                                params: {
                                  'count': '${filteredPackages.length}',
                                },
                              ),
                              style: const TextStyle(
                                color: AppColors.textInfo,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (filteredPackages.isEmpty)
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 8, bottom: 12),
                                child: Text(
                                  l10n.t('travel.section.noPackages'),
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withValues(alpha: 0.7),
                                    fontSize: 15,
                                  ),
                                ),
                              )
                            else
                              for (final package in filteredPackages) ...[
                                TravelPackageCard(
                                  package: package,
                                  isFavorite: state.favoritePackageIds
                                      .contains(package.id),
                                  onFavoriteToggle: () =>
                                      cubit.toggleFavorite(package.id),
                                ),
                                const SizedBox(height: 10),
                              ],
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: CircleAvatar(
                    backgroundColor: Theme.of(context).cardColor,
                    radius: 22,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      color: Theme.of(context).iconTheme.color,
                      onPressed: () => context.pop(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CompanyThumbnail extends StatelessWidget {
  final String imagePath;

  const _CompanyThumbnail({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        width: 76,
        height: 76,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
      );
    }
    return Image.asset(
      imagePath,
      width: 76,
      height: 76,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
    );
  }
}

class _CompanyError extends StatelessWidget {
  final String message;

  const _CompanyError({required this.message});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.error;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanyHeader extends StatelessWidget {
  final TravelCompany company;

  const _CompanyHeader({required this.company});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final topInset = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topInset + 26, 20, 62),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF48C6B6), Color(0xFF35A0D3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: _CompanyThumbnail(imagePath: company.thumbnail),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            company.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.star_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                company.rating.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 14),
              const Icon(
                Icons.people_alt_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                l10n.t(
                  'travel.company.toursCount',
                  params: {'count': '${company.tours}'},
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
