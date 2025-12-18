import 'package:safa_app/features/sadaqa/presentation/widgets/cause_card_sadaqa.dart';
import 'package:safa_app/features/sadaqa/presentation/pages/sadaqa_detail.dart';
import 'package:safa_app/features/sadaqa/presentation/cubit/sadaqa_cubit.dart';
import 'package:safa_app/core/localization/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safa_app/core/navigation/app_router.dart';
import 'package:safa_app/widgets/gradient_header.dart';
import 'package:safa_app/widgets/segmented_tabs.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class SadaqaPage extends StatelessWidget {
  const SadaqaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SadaqaCubit(),
      child: BlocBuilder<SadaqaCubit, SadaqaState>(
        builder: (context, state) {
          final cubit = context.read<SadaqaCubit>();
          final causes = state.visibleCauses;
          final l10n = context.l10n;
          final isLoading = state.isLoading;
          final errorMessage = state.errorMessage;
          final emptyTitle = state.activeTab == SadaqaTab.favorites
              ? l10n.t('sadaqa.placeholder.title')
              : 'Публичных сборов пока нет';
          final emptySubtitle = state.activeTab == SadaqaTab.favorites
              ? l10n.t('sadaqa.placeholder.subtitle')
              : 'Попробуйте обновить страницу или зайдите позже.';

          final content = SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(bottom: 32.h),
            child: SafeArea(
              child: Stack(
                children: [
                  GradientHeader(
                    icon: Icons.favorite,
                    title: l10n.t('sadaqa.header.title'),
                    subtitle: l10n.t('sadaqa.header.subtitle'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 200.h),
                        _AssistanceCard(
                          title: l10n.t('sadaqa.assistance.title'),
                          subtitle: l10n.t('sadaqa.assistance.subtitle'),
                          buttonLabel: l10n.t('sadaqa.assistance.button'),
                          onPressed: () =>
                              context.pushNamed(AppRoute.requestHelp.name),
                        ),
                        SizedBox(height: 16.h),
                        if (errorMessage != null && errorMessage.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: _ErrorBanner(
                              message: errorMessage,
                              onRetry: cubit.loadCauses,
                            ),
                          ),
                        buildSegmentedTabs(
                          context: context,
                          tabs: [
                            SegmentedTabConfig(
                              label: l10n.t('sadaqa.tabs.all'),
                            ),
                            SegmentedTabConfig(
                              label: l10n.t(
                                'sadaqa.tabs.favorites',
                                params: {'count': '${state.favoritesCount}'},
                              ),
                              icon: Icons.star_border,
                              activeIcon: Icons.star,
                            ),
                          ],
                          selectedIndex: state.activeTab.index,
                          onTabSelected: (index) {
                            cubit.selectTab(SadaqaTab.values[index]);
                          },
                        ),
                        SizedBox(height: 24.h),
                        Text(
                          state.activeTab == SadaqaTab.all
                              ? l10n.t('sadaqa.section.current')
                              : l10n.t('sadaqa.section.favorites'),
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontFamily: 'Poppins',
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.82),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        if (isLoading && causes.isEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.h),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (causes.isEmpty)
                          _EmptyCausesPlaceholder(
                            title: emptyTitle,
                            subtitle: emptySubtitle,
                            onRefresh: cubit.loadCauses,
                            isFavorites: state.activeTab == SadaqaTab.favorites,
                          )
                        else
                          ...causes.map(
                            (cause) => CauseCard(
                              imagePath: cause.imagePath,
                              title: cause.title,
                              subtitle: cause.subtitle,
                              gallery: cause.gallery,
                              companyName: cause.companyName,
                              amount: cause.amount,
                              isFavorite: state.isFavorite(cause.id),
                              recommendedLabel: l10n.t(
                                'sadaqa.cause.recommendedAmount',
                              ),
                              donateLabel: l10n.t('sadaqa.cause.donate'),
                              onFavoriteToggle: () =>
                                  cubit.toggleFavorite(cause.id),
                              onDonate: () {
                                context.pushNamed(
                                  AppRoute.sadaqaDetail.name,
                                  extra: SadaqaDetailArgs(
                                    cause: cause,
                                    isFavorite: state.isFavorite(cause.id),
                                    onFavoriteChanged: (_) =>
                                        cubit.toggleFavorite(cause.id),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );

          return RefreshIndicator(onRefresh: cubit.loadCauses, child: content);
        },
      ),
    );
  }
}

class _EmptyCausesPlaceholder extends StatelessWidget {
  const _EmptyCausesPlaceholder({
    required this.title,
    required this.subtitle,
    required this.onRefresh,
    required this.isFavorites,
  });

  final String title;
  final String subtitle;
  final Future<void> Function() onRefresh;
  final bool isFavorites;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 12.h),
      padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFavorites ? Icons.favorite_border : Icons.cloud_off_outlined,
            size: 40,
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
          ),
          SizedBox(height: 14.h),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 14.h),
          TextButton(
            onPressed: () => onRefresh(),
            child: Text(l10n.t('sadaqaHistory.refresh')),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, this.onRetry});

  final String message;
  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.error;
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: color),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(message, style: TextStyle(color: color)),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: () => onRetry!(),
              child: Text(l10n.t('sadaqaHistory.retry')),
            ),
        ],
      ),
    );
  }
}

class _AssistanceCard extends StatelessWidget {
  const _AssistanceCard({
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const gradientColors = [Color(0xFF1FAB82), Color(0xFF1A9CCB)];

    final cardColor = Theme.of(context).cardColor;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 16.h),
      padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 24.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(46, 125, 110, 0.20),
            blurRadius: 25.r,
            offset: Offset(0, 18.h),
          ),
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 12.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : const Color(0xFF1A2B4F),
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: gradientColors.first, width: 1.5.w),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromRGBO(33, 147, 108, 0.18),
                      blurRadius: 14.r,
                      offset: Offset(0, 6.h),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.help_outline,
                  color: const Color(0xFF1FAB82),
                  size: 20.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.72),
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 24.h),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: gradientColors,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(28.r),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromRGBO(33, 147, 108, 0.35),
                  blurRadius: 20.r,
                  offset: Offset(0, 8.h),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(28.r),
                onTap: onPressed,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Center(
                    child: Text(
                      buttonLabel,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
