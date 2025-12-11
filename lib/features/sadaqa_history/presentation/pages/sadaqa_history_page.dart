import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safa_app/core/localization/app_localizations.dart';
import 'package:safa_app/core/styles/app_colors.dart';
import 'package:safa_app/features/sadaqa_history/models/sadaqa_history_item.dart';
import 'package:safa_app/features/sadaqa_history/presentation/cubit/sadaqa_history_cubit.dart';

class SadaqaHistoryPage extends StatelessWidget {
  const SadaqaHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SadaqaHistoryCubit(),
      child: const _SadaqaHistoryView(),
    );
  }
}

class _SadaqaHistoryView extends StatelessWidget {
  const _SadaqaHistoryView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          l10n.t('sadaqaHistory.title'),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: BlocBuilder<SadaqaHistoryCubit, SadaqaHistoryState>(
        builder: (context, state) {
          final cubit = context.read<SadaqaHistoryCubit>();

          if (state.isLoading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null && state.items.isEmpty) {
            return _HistoryMessage(
              icon: Icons.error_outline,
              title: l10n.t('sadaqaHistory.error.title'),
              subtitle: l10n.t('sadaqaHistory.error.subtitle'),
              actionLabel: l10n.t('sadaqaHistory.retry'),
              onAction: () => cubit.loadHistory(),
            );
          }

          if (state.items.isEmpty) {
            return _HistoryMessage(
              icon: Icons.inbox_outlined,
              title: l10n.t('sadaqaHistory.empty.title'),
              subtitle: l10n.t('sadaqaHistory.empty.subtitle'),
              actionLabel: l10n.t('sadaqaHistory.refresh'),
              onAction: () => cubit.loadHistory(),
            );
          }

          return RefreshIndicator(
            onRefresh: () => cubit.loadHistory(isRefresh: true),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: state.items.length,
              separatorBuilder: (_, _index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final item = state.items[index];
                return _HistoryTile(item: item, l10n: l10n, theme: theme);
              },
            ),
          );
        },
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.item,
    required this.l10n,
    required this.theme,
  });

  final SadaqaHistoryItem item;
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            offset: const Offset(0, 6),
            color: theme.shadowColor.withValues(alpha: 0.05),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title.isEmpty
                          ? l10n.t('sadaqaHistory.unknownCause')
                          : item.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _CompanyLabel(item: item, l10n: l10n, theme: theme),
                    const SizedBox(height: 6),
                    Text(
                      _formatDate(item.createdAt),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              // Статус скрываем по запросу
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hours = date.hour.toString().padLeft(2, '0');
    final minutes = date.minute.toString().padLeft(2, '0');
    return '$day.$month.${date.year}, $hours:$minutes';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.l10n});

  final SadaqaHistoryStatus status;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, color) = switch (status) {
      SadaqaHistoryStatus.success => (
          l10n.t('sadaqaHistory.status.success'),
          AppColors.success
        ),
      SadaqaHistoryStatus.failed => (
          l10n.t('sadaqaHistory.status.failed'),
          AppColors.badgeDanger
        ),
      _ => (
          l10n.t('sadaqaHistory.status.pending'),
          theme.colorScheme.primary
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _CompanyLabel extends StatelessWidget {
  const _CompanyLabel({
    required this.item,
    required this.l10n,
    required this.theme,
  });

  final SadaqaHistoryItem item;
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final hasCompany = item.companyName?.isNotEmpty == true;
    final text = hasCompany
        ? item.companyName!
        : l10n.t('sadaqaHistory.company.unknown');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.handshake_outlined,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            '${l10n.t('sadaqaHistory.company')}: $text',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryMessage extends StatelessWidget {
  const _HistoryMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onAction,
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
