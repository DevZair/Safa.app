import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:safa_app/core/localization/app_localizations.dart';
import 'package:safa_app/features/sadaqa/presentation/cubit/sadaqa_cubit.dart';
import '../widgets/sadaqa_detail_components.dart';

class SadaqaDetailArgs {
  const SadaqaDetailArgs({
    required this.cause,
    required this.isFavorite,
    required this.onFavoriteChanged,
  });

  final SadaqaCause cause;
  final bool isFavorite;
  final ValueChanged<bool> onFavoriteChanged;
}

class SadaqaDetail extends StatefulWidget {
  const SadaqaDetail({
    super.key,
    required this.cause,
    required this.isFavorite,
    required this.onFavoriteChanged,
  });

  final SadaqaCause cause;
  final bool isFavorite;
  final ValueChanged<bool> onFavoriteChanged;

  @override
  State<SadaqaDetail> createState() => _SadaqaDetailState();
}

class _SadaqaDetailState extends State<SadaqaDetail> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    widget.onFavoriteChanged(_isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final progress = (widget.cause.raised / widget.cause.goal)
        .clamp(0.0, 1.0)
        .toDouble();
    final statusLabel = progress < 0.55
        ? l10n.t('sadaqa.detail.status.critical')
        : progress < 0.8
        ? l10n.t('sadaqa.detail.status.urgent')
        : l10n.t('sadaqa.detail.status.onTrack');
    final statusColor = progress < 0.55
        ? const Color(0xFFE11D48)
        : progress < 0.8
        ? const Color(0xFFF97316)
        : const Color(0xFF0D9488);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  SadaqaDetailHeader(
                    progress: progress,
                    onBack: () => context.pop(),
                    title: widget.cause.title,
                    subtitle: widget.cause.subtitle,
                    companyName: widget.cause.companyName,
                    companyLogo: widget.cause.companyLogo,
                    isFavorite: _isFavorite,
                    onFavorite: _toggleFavorite,
                  ),
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: -280,
                    child: SadaqaBeneficiaryOverviewCard(
                      imagePath: widget.cause.imagePath,
                      title: widget.cause.title,
                      subtitle: widget.cause.subtitle,
                      description: widget.cause.description,
                      raised: widget.cause.raised,
                      goal: widget.cause.goal,
                      donors: widget.cause.donors,
                      progress: progress,
                      statusLabel: statusLabel,
                      statusColor: statusColor,
                      donateLabel: l10n.t('sadaqa.detail.donateNow'),
                      onDonate: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.t('sadaqa.snackbar.donateSoon')),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 300),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SadaqaQuickStatsRow(),
                    const SizedBox(height: 32),
                    const SadaqaUpdatesSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
