import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:safa_app/core/localization/app_localizations.dart';
import 'package:safa_app/features/sadaqa/data/sadaqa_repository.dart';
import 'package:safa_app/features/sadaqa/models/sadaqa_cause.dart';
import 'package:safa_app/features/sadaqa/models/sadaqa_post.dart';
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
  late Future<List<SadaqaPost>> _postsFuture;
  late Future<SadaqaPost?> _activeNoteFuture;
  final _repository = SadaqaRepository();

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
    _postsFuture = _loadPosts();
    _activeNoteFuture = _loadActiveNote();
  }

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    widget.onFavoriteChanged(_isFavorite);
  }

  Future<List<SadaqaPost>> _loadPosts() async {
    return _repository.fetchPosts(companyId: widget.cause.companyId);
  }

  Future<SadaqaPost?> _loadActiveNote() async {
    return _repository.fetchActiveNote(companyId: widget.cause.companyId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SadaqaPost?>(
      future: _activeNoteFuture,
      builder: (context, snapshot) {
        final activeNote = snapshot.data;
        final effectiveCause =
            _mergeCauseWithActiveNote(widget.cause, activeNote);

        final l10n = context.l10n;
        final displayCompanyName = _resolveCompanyName(effectiveCause);
        final noteTypeLabel = (effectiveCause.noteType ?? '').trim();
        final normalizedNoteType = noteTypeLabel.toLowerCase();
        final progress = effectiveCause.goal <= 0
            ? 0.0
            : (effectiveCause.raised / effectiveCause.goal)
                .clamp(0.0, 1.0)
                .toDouble();
        final statusLabel = noteTypeLabel.isNotEmpty
            ? noteTypeLabel
            : progress < 0.55
                ? l10n.t('sadaqa.detail.status.critical')
                : progress < 0.8
                    ? l10n.t('sadaqa.detail.status.urgent')
                    : l10n.t('sadaqa.detail.status.onTrack');
        final statusColor = noteTypeLabel.isNotEmpty
            ? switch (normalizedNoteType) {
                'критично' => const Color(0xFFE11D48),
                'обычный' => const Color(0xFFF59E0B),
                'средний' => const Color(0xFFF59E0B),
                'срочный' => const Color(0xFFF97316),
                'очень срочный' => const Color(0xFFE11D48),
                _ => const Color(0xFFF97316),
              }
            : progress < 0.55
                ? const Color(0xFFE11D48)
                : progress < 0.8
                    ? const Color(0xFFF97316)
                    : const Color(0xFF0D9488);

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SingleChildScrollView(
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
                      title: effectiveCause.title,
                      subtitle: '',
                      companyName: displayCompanyName,
                      companyLogo: effectiveCause.companyLogo,
                      isFavorite: _isFavorite,
                      onFavorite: _toggleFavorite,
                    ),
                    Positioned(
                      left: 24,
                      right: 24,
                      bottom: -170,
                      child: SadaqaPinnedFundCard(
                        companyName: displayCompanyName,
                        companyLogo: effectiveCause.companyLogo,
                        causeTitle: effectiveCause.title,
                        causeSubtitle: effectiveCause.subtitle,
                      ),
                    ),
                    Positioned(
                      left: 24,
                      right: 24,
                      bottom: -330,
                      child: SadaqaBeneficiaryOverviewCard(
                        imagePath: effectiveCause.imagePath,
                        title: effectiveCause.title,
                        subtitle: effectiveCause.subtitle,
                        description: effectiveCause.description,
                        raised: effectiveCause.raised,
                        goal: effectiveCause.goal,
                        donors: effectiveCause.donors,
                        progress: progress,
                        statusLabel: statusLabel,
                        statusColor: statusColor,
                        donateLabel: l10n.t('sadaqa.detail.donateNow'),
                        onDonate: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text(l10n.t('sadaqa.snackbar.donateSoon')),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 390),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SadaqaQuickStatsRow(),
                      const SizedBox(height: 32),
                      SadaqaCompanyPostsSection(
                        futurePosts: _postsFuture,
                        companyName: displayCompanyName,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

String _resolveCompanyName(SadaqaCause cause) {
  final name = (cause.companyName ?? '').trim();
  if (name.isNotEmpty) return name;
  final subtitle = cause.subtitle.trim();
  if (subtitle.isNotEmpty) return subtitle;
  final title = cause.title.trim();
  if (title.isNotEmpty) return title;
  return 'Без названия';
}

SadaqaCause _mergeCauseWithActiveNote(
  SadaqaCause cause,
  SadaqaPost? note,
) {
  if (note == null) return cause;
  final title = note.title.isNotEmpty ? note.title : cause.title;
  final subtitle = (note.address ?? '').trim().isNotEmpty
      ? note.address!.trim()
      : note.content.isNotEmpty
          ? note.content
          : cause.subtitle;
  final description = note.content.isNotEmpty ? note.content : cause.description;
  final imagePath = note.image.isNotEmpty ? note.image : cause.imagePath;
  final goal = note.goalMoney ?? note.goal ?? cause.goal;
  final raised = note.collectedMoney ?? note.collected ?? cause.raised;
  final noteType = note.noteType?.isNotEmpty == true
      ? note.noteType
      : cause.noteType;
  final companyId = note.companyId?.isNotEmpty == true
      ? note.companyId
      : cause.companyId;

  return cause.copyWith(
    id: cause.id,
    title: title,
    subtitle: subtitle,
    description: description,
    imagePath: imagePath,
    goal: goal,
    raised: raised,
    noteType: noteType,
    companyId: companyId,
  );
}
