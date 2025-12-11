import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:safa_app/core/localization/app_localizations.dart';
import 'package:safa_app/core/styles/app_colors.dart';
import 'package:safa_app/features/travel/models/travel_company.dart';
import 'package:safa_app/features/travel/presentation/cubit/travel_cubit.dart';
import 'package:safa_app/features/travel/presentation/widgets/travel_package_card.dart';
import 'package:safa_app/widgets/segmented_tabs.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        final horizontalPadding = 20.w;
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 40.h),
                child: Column(
                  children: [
                    _CompanyHeader(company: widget.company),
                    if (categories.isNotEmpty)
                      Transform.translate(
                        offset: Offset(0, -26.h),
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: horizontalPadding),
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
                      padding:
                          EdgeInsets.symmetric(horizontal: horizontalPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          if (state.isLoading && filteredPackages.isEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 24.h),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else ...[
                            if (categories.isNotEmpty) SizedBox(height: 6.h),
                            Text(
                              l10n.t(
                                'travel.section.availableCount',
                                params: {
                                  'count': '${filteredPackages.length}',
                                },
                              ),
                              style: TextStyle(
                                color: AppColors.textInfo,
                                fontSize: 14.sp,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            if (filteredPackages.isEmpty)
                              Padding(
                                padding:
                                    EdgeInsets.only(top: 8.h, bottom: 12.h),
                                child: Text(
                                  l10n.t('travel.section.noPackages'),
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withValues(alpha: 0.7),
                                    fontSize: 15.sp,
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
                                SizedBox(height: 10.h),
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
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                  child: CircleAvatar(
                    backgroundColor: Theme.of(context).cardColor,
                    radius: 22.r,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18.sp,
                      ),
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
        width: 76.r,
        height: 76.r,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.image_not_supported),
      );
    }
    return Image.asset(
      imagePath,
      width: 76.r,
      height: 76.r,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.image_not_supported),
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
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: color),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontSize: 13.sp),
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
      padding: EdgeInsets.fromLTRB(
        20.w,
        topInset + 26.h,
        20.w,
        62.h,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF48C6B6), Color(0xFF35A0D3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18.r),
              child: _CompanyThumbnail(imagePath: company.thumbnail),
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            company.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star_rounded,
                color: Colors.white,
                size: 18.sp,
              ),
              SizedBox(width: 6.w),
              Text(
                company.rating.toStringAsFixed(1),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 14.w),
              Icon(
                Icons.people_alt_rounded,
                color: Colors.white,
                size: 18.sp,
              ),
              SizedBox(width: 6.w),
              Text(
                l10n.t(
                  'travel.company.toursCount',
                  params: {'count': '${company.tours}'},
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
