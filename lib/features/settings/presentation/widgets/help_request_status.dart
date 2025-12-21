import 'package:flutter/material.dart';
import 'package:safa_app/core/localization/app_localizations.dart';
import 'package:safa_app/features/sadaqa/models/help_request.dart';

String helpRequestStatusLabel(
  AppLocalizations l10n,
  HelpRequestStatus status,
) {
  final key = switch (status) {
    HelpRequestStatus.inProgress => 'admin.helpRequests.status.inProgress',
    HelpRequestStatus.archived => 'admin.helpRequests.status.archived',
    HelpRequestStatus.newRequest => 'admin.helpRequests.status.new',
  };

  final value = l10n.t(key);
  if (value != key) return value;

  return _fallbackStatusLabel(
    status: status,
    languageCode: l10n.locale.languageCode,
  );
}

String _fallbackStatusLabel({
  required HelpRequestStatus status,
  required String languageCode,
}) {
  final map = switch (languageCode) {
    'uz' => _statusLabelsUz,
    'kk' => _statusLabelsKk,
    'ru' => _statusLabelsRu,
    _ => _statusLabelsDefault,
  };
  return map[status] ?? _statusLabelsDefault[status] ?? status.name;
}

const _statusLabelsUz = {
  HelpRequestStatus.inProgress: 'Jarayonda',
  HelpRequestStatus.archived: 'Arxiv',
  HelpRequestStatus.newRequest: 'Yangi',
};

const _statusLabelsKk = {
  HelpRequestStatus.inProgress: 'Үдерісте',
  HelpRequestStatus.archived: 'Мұрағат',
  HelpRequestStatus.newRequest: 'Жаңа',
};

const _statusLabelsRu = {
  HelpRequestStatus.inProgress: 'В процессе',
  HelpRequestStatus.archived: 'Архив',
  HelpRequestStatus.newRequest: 'Новый',
};

const _statusLabelsDefault = {
  HelpRequestStatus.inProgress: 'In progress',
  HelpRequestStatus.archived: 'Archived',
  HelpRequestStatus.newRequest: 'New',
};

class HelpRequestStatusStyle {
  const HelpRequestStatusStyle({
    required this.textColor,
    required this.background,
    required this.borderColor,
  });

  final Color textColor;
  final Color background;
  final Color borderColor;
}

HelpRequestStatusStyle helpRequestStatusStyle(
  ThemeData theme,
  HelpRequestStatus status,
) {
  final base = switch (status) {
    HelpRequestStatus.inProgress => const Color(0xFF1E88E5),
    HelpRequestStatus.archived =>
        theme.disabledColor.withValues(alpha: 0.9),
    HelpRequestStatus.newRequest => const Color(0xFF43A047),
  };

  return HelpRequestStatusStyle(
    textColor: base,
    background: base.withValues(alpha: 0.12),
    borderColor: base.withValues(alpha: 0.35),
  );
}

class HelpRequestStatusChip extends StatelessWidget {
  const HelpRequestStatusChip({
    super.key,
    required this.status,
    required this.l10n,
    this.dense = false,
  });

  final HelpRequestStatus status;
  final AppLocalizations l10n;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = helpRequestStatusStyle(theme, status);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 10,
        vertical: dense ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(dense ? 10 : 12),
        border: Border.all(color: style.borderColor),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        child: Row(
          key: ValueKey(status),
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: dense ? 8 : 10,
              height: dense ? 8 : 10,
              margin: EdgeInsets.only(right: dense ? 6 : 8),
              decoration: BoxDecoration(
                color: style.textColor,
                shape: BoxShape.circle,
              ),
            ),
            Text(
              helpRequestStatusLabel(l10n, status),
              style: TextStyle(
                color: style.textColor,
                fontWeight: FontWeight.w700,
                fontSize: dense ? 12 : 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
