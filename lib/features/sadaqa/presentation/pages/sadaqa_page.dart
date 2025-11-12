import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:safa_app/core/localization/app_localizations.dart';
import 'package:safa_app/core/navigation/app_router.dart';
import 'package:safa_app/features/sadaqa/presentation/cubit/sadaqa_cubit.dart';
import 'package:safa_app/features/sadaqa/presentation/pages/sadaqa_detail.dart';
import 'package:safa_app/features/sadaqa/presentation/widgets/builde_favorites_sadaqa.dart';
import 'package:safa_app/features/sadaqa/presentation/widgets/cause_card_sadaqa.dart';
import 'package:safa_app/widgets/gradient_header.dart';
import 'package:safa_app/widgets/segmented_tabs.dart';

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

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 32),
            child: SafeArea(
              child: Stack(
                children: [
                  GradientHeader(
                    icon: Icons.favorite,
                    title: l10n.t('sadaqa.header.title'),
                    subtitle: l10n.t('sadaqa.header.subtitle'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 200),
                        _AssistanceCard(
                          title: l10n.t('sadaqa.assistance.title'),
                          subtitle: l10n.t('sadaqa.assistance.subtitle'),
                          buttonLabel: l10n.t('sadaqa.assistance.button'),
                          onPressed: () =>
                              context.pushNamed(AppRoute.requestHelp.name),
                        ),
                        const SizedBox(height: 16),
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
                        const SizedBox(height: 24),
                        Text(
                          state.activeTab == SadaqaTab.all
                              ? l10n.t('sadaqa.section.current')
                              : l10n.t('sadaqa.section.favorites'),
                          style: TextStyle(
                            fontSize: 22,
                            fontFamily: 'Poppins',
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.82),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (causes.isEmpty)
                          buildFavoritesPlaceholder(context)
                        else
                          ...causes.map(
                            (cause) => CauseCard(
                              imagePath: cause.imagePath,
                              title: cause.title,
                              subtitle: cause.subtitle,
                              amount: cause.amount,
                              isFavorite: state.isFavorite(cause.id),
                              recommendedLabel:
                                  l10n.t('sadaqa.cause.recommendedAmount'),
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
        },
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
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(46, 125, 110, 0.20),
            blurRadius: 25,
            offset: Offset(0, 18),
          ),
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 12,
            offset: Offset(0, 8),
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
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: gradientColors.first, width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(33, 147, 108, 0.18),
                      blurRadius: 14,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.help_outline, color: Color(0xFF1FAB82)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.72),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: gradientColors,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(33, 147, 108, 0.35),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: onPressed,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text(
                      buttonLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
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
