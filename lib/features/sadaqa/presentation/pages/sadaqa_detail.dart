import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:safa_app/core/localization/app_localizations.dart';
import 'package:safa_app/core/constants/api_constants.dart';
import 'package:safa_app/core/service/db_service.dart';
import 'package:safa_app/features/sadaqa/data/sadaqa_repository.dart';
import 'package:safa_app/features/sadaqa/models/sadaqa_cause.dart';
import 'package:safa_app/features/sadaqa/models/sadaqa_post.dart';
import 'package:url_launcher/url_launcher.dart';
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
  SadaqaPost? _activeNote;
  List<SadaqaPost>? _postsSnapshot;
  String? _paymentUrl;
  String? _currentCompanyId;
  final _repository = SadaqaRepository();

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
    _paymentUrl = _normalizeUrl(widget.cause.payment);
    _postsFuture = _loadPosts();
    _activeNoteFuture = _loadActiveNote().then((note) {
      _activeNote = note;
      _loadCompanyDetail(note);
      return note;
    });
    _loadCompanyDetail();
  }

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    widget.onFavoriteChanged(_isFavorite);
  }

  Future<List<SadaqaPost>> _loadPosts() async {
    final companyId = widget.cause.companyId;
    final cached = _repository.readCachedPosts(companyId: companyId);
    if (cached != null && cached.isNotEmpty) {
      _postsSnapshot = cached;
      unawaited(_refreshPostsInBackground());
      return cached;
    }

    try {
      final fresh = await _repository.fetchPosts(companyId: companyId);
      _postsSnapshot = fresh;
      return fresh;
    } catch (error) {
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }
      rethrow;
    }
  }

  Future<SadaqaPost?> _loadActiveNote() async {
    final companyId = widget.cause.companyId;
    final cached = _repository.readCachedActiveNote(companyId: companyId);
    if (cached != null) {
      unawaited(_refreshActiveNoteInBackground());
      return cached;
    }
    final fresh = await _repository.fetchActiveNote(companyId: companyId);
    return fresh;
  }

  Future<void> _refreshActiveNoteInBackground() async {
    final companyId = widget.cause.companyId;
    try {
      final fresh = await _repository.fetchActiveNote(companyId: companyId);
      if (fresh == null) return;
      final hasChanged = !_postJsonEquals(_activeNote, fresh);
      _activeNote = fresh;
      if (mounted && hasChanged) {
        setState(() {
          _activeNoteFuture = Future.value(fresh);
        });
      }
      _loadCompanyDetail(fresh);
    } catch (error) {
      debugPrint('Failed to refresh active note: $error');
    }
  }

  Future<void> _refreshPostsInBackground() async {
    try {
      final fresh = await _repository.fetchPosts(
        companyId: widget.cause.companyId,
      );
      final hasChanged = !_postsListEquals(_postsSnapshot, fresh);
      _postsSnapshot = fresh;
      if (mounted && hasChanged) {
        setState(() {
          _postsFuture = Future.value(fresh);
        });
      }
    } catch (error) {
      debugPrint('Failed to refresh posts: $error');
    }
  }

  Future<void> _loadCompanyDetail([SadaqaPost? note]) async {
    final companyId = _resolveCompanyId(note);
    if (companyId == null || companyId.isEmpty) return;
    if (_currentCompanyId == companyId && _paymentUrl != null) return;

    _currentCompanyId = companyId;
    try {
      final company = await _repository.fetchCompanyDetail(companyId);
      if (!mounted) return;
      setState(() {
        _paymentUrl = _normalizeUrl(company?.payment);
      });
    } catch (_) {
      // Ignore errors; donation fallback will handle missing URL.
    }
  }

  String? _resolveCompanyId(SadaqaPost? note) {
    final fromNote = note?.companyId?.trim();
    if (fromNote != null && fromNote.isNotEmpty) return fromNote;
    final fromCause = widget.cause.companyId?.trim();
    if (fromCause != null && fromCause.isNotEmpty) return fromCause;
    return null;
  }

  Future<void> _handleDonate(
    BuildContext context,
    String fallbackMessage, {
    String? paymentUrl,
  }) async {
    paymentUrl ??= _paymentUrl;

    if ((paymentUrl ?? '').isEmpty) {
      await _loadCompanyDetail(_activeNote);
      paymentUrl = _paymentUrl;
    }

    final url = (paymentUrl ?? '').trim();
    if (url.isEmpty) {
      _showDonateFallback(context, fallbackMessage);
      return;
    }

    final uri = _buildUri(url);
    if (uri == null) {
      _showDonateFallback(context, fallbackMessage);
      return;
    }

    try {
      if (await _tryLaunch(uri, LaunchMode.platformDefault)) return;
      if (await _tryLaunch(uri, LaunchMode.externalApplication)) return;
      if (await _tryLaunch(uri, LaunchMode.inAppBrowserView)) return;
      _showDonateFallback(context, fallbackMessage);
    } catch (error) {
      debugPrint('Launch donate failed: $error');
      if (mounted) {
        _showDonateFallback(context, fallbackMessage);
      }
    }
  }

  void _showDonateFallback(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String? _normalizeUrl(String? raw) {
    final value = (raw ?? '').trim();
    if (value.isEmpty) return null;
    final hasScheme = value.contains('://');
    if (value.startsWith('/')) {
      final base = DBService.baseUrl.isNotEmpty
          ? DBService.baseUrl
          : ApiConstants.baseUrl;
      final baseWithScheme = base.startsWith('http') ? base : 'https://$base';
      return Uri.parse(baseWithScheme).resolve(value).toString();
    }
    if (hasScheme) return value;
    return 'https://$value';
  }

  Uri? _buildUri(String raw) {
    final normalized = _normalizeUrl(raw);
    if (normalized == null) return null;

    Uri? uri = Uri.tryParse(normalized);
    if (uri == null || uri.scheme.isEmpty) {
      final encoded = Uri.encodeFull(normalized);
      uri = Uri.tryParse(encoded);
    }
    return uri;
  }

  Future<bool> _tryLaunch(Uri uri, LaunchMode mode) async {
    try {
      final launched = await launchUrl(uri, mode: mode);
      debugPrint('Launch $uri with $mode -> $launched');
      return launched;
    } catch (error) {
      debugPrint('Launch $uri with $mode failed: $error');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SadaqaPost?>(
      future: _activeNoteFuture,
      builder: (context, snapshot) {
        final activeNote = snapshot.data;
        final effectiveCause = _mergeCauseWithActiveNote(
          widget.cause,
          activeNote,
        );
        _paymentUrl ??= _normalizeUrl(effectiveCause.payment);

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

        // Keep stack tall enough for the overlaid card so taps remain hit-testable.
        const cardTopOffset = 270.0;
        const cardMinHeight = 470.0;
        const stackHeight = cardTopOffset + cardMinHeight + 40;
        const headerHeight = 360.0;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: stackHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        height: headerHeight,
                        child: SadaqaDetailHeader(
                          progress: progress,
                          onBack: () => context.pop(),
                          title: effectiveCause.title,
                          subtitle: '',
                          companyName: displayCompanyName,
                          companyLogo: effectiveCause.companyLogo,
                          isFavorite: _isFavorite,
                          onFavorite: _toggleFavorite,
                        ),
                      ),
                      Positioned(
                        left: 24,
                        right: 24,
                        top: cardTopOffset,
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
                          paymentUrl: _paymentUrl ?? effectiveCause.payment,
                          donateLabel: l10n.t('sadaqa.detail.donateNow'),
                          onDonate: (paymentUrl) => _handleDonate(
                            context,
                            l10n.t('sadaqa.snackbar.donateSoon'),
                            paymentUrl: paymentUrl,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
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

bool _postsListEquals(List<SadaqaPost>? a, List<SadaqaPost>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (!_postJsonEquals(a[i], b[i])) return false;
  }
  return true;
}

bool _postJsonEquals(SadaqaPost? a, SadaqaPost? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;
  return mapEquals(a.toJson(), b.toJson());
}

SadaqaCause _mergeCauseWithActiveNote(SadaqaCause cause, SadaqaPost? note) {
  if (note == null) return cause;
  final title = note.title.isNotEmpty ? note.title : cause.title;
  final subtitle = (note.address ?? '').trim().isNotEmpty
      ? note.address!.trim()
      : note.content.isNotEmpty
      ? note.content
      : cause.subtitle;
  final description = note.content.isNotEmpty
      ? note.content
      : cause.description;
  final imagePath = note.image.isNotEmpty ? note.image : cause.imagePath;
  final goal = note.goalMoney ?? note.goal ?? cause.goal;
  final raised = note.collectedMoney ?? note.collected ?? cause.raised;
  final noteType = note.noteType?.isNotEmpty == true
      ? note.noteType
      : cause.noteType;
  final companyId = note.companyId?.isNotEmpty == true
      ? note.companyId
      : cause.companyId;
  final payment = cause.payment;

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
    payment: payment,
  );
}
