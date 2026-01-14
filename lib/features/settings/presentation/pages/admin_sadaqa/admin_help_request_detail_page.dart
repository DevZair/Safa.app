import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safa_app/core/utils/error_messages.dart';
import 'package:safa_app/core/localization/app_localizations.dart';
import 'package:safa_app/features/sadaqa/domain/entities/help_request.dart';
import 'package:safa_app/features/sadaqa/domain/repositories/sadaqa_repository.dart';
import 'package:safa_app/features/settings/presentation/widgets/help_request_status.dart';

class AdminHelpRequestDetailPage extends StatefulWidget {
  const AdminHelpRequestDetailPage({
    super.key,
    required this.request,
    required this.repository,
    this.companyName,
  });

  final HelpRequest request;
  final SadaqaRepository repository;
  final String? companyName;

  @override
  State<AdminHelpRequestDetailPage> createState() =>
      _AdminHelpRequestDetailPageState();
}

class _AdminHelpRequestDetailPageState
    extends State<AdminHelpRequestDetailPage> {
  late HelpRequest _request;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _request = widget.request;
  }

  Future<void> _changeStatus(HelpRequestStatus status) async {
    if (_request.id.isEmpty) return;
    final l10n = context.l10n;
    setState(() => _isUpdating = true);
    try {
      final updated = await widget.repository.updateHelpRequestStatus(
        id: _request.id,
        status: status,
      );
      if (!mounted) return;
      setState(() {
        _request = (updated ?? _request.copyWith(status: status)).copyWith(
          helpCategoryTitle:
              updated?.helpCategoryTitle ?? _request.helpCategoryTitle,
          materialStatusTitle:
              updated?.materialStatusTitle ?? _request.materialStatusTitle,
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('admin.helpRequests.statusUpdated'))),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${l10n.t('admin.helpRequests.error')}: ${friendlyError(error)}',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  void _popWithData() {
    Navigator.of(context).pop(_request);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final backendTitle = _request.helpCategoryTitle?.trim();
    final pageTitle = _safeL10n(
      l10n,
      'admin.helpRequests.detailTitle',
      backendTitle?.isNotEmpty == true
          ? backendTitle!
          : (_request.fullName.isNotEmpty ? _request.fullName : 'Заявка'),
    );
    final changeStatusLabel = _safeL10n(
      l10n,
      'admin.helpRequests.changeStatus',
      'Изменить статус',
    );
    return WillPopScope(
      onWillPop: () async {
        _popWithData();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _popWithData,
          ),
          title: Text(
            pageTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            _StatusMenu(
              current: _request.status,
              onSelected: _changeStatus,
              isUpdating: _isUpdating,
            ),
          ],
          bottom: widget.companyName?.isNotEmpty == true
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(30),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: Text(
                      widget.companyName!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              : null,
        ),
        body: ListView(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                HelpRequestStatusChip(status: _request.status, l10n: l10n),
                TextButton.icon(
                  onPressed: _isUpdating
                      ? null
                      : () async {
                          final next = await _pickStatus(context, l10n);
                          if (next != null) _changeStatus(next);
                        },
                  icon: const Icon(Icons.swap_horiz),
                  label: Text(changeStatusLabel),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            _InfoSection(
              title: 'Контакты',
              children: [
                _InfoRow(
                  label: 'Имя',
                  value: _request.fullName.isNotEmpty
                      ? _request.fullName
                      : l10n.t('admin.helpRequests.unnamed'),
                ),
                _InfoRow(
                  label: 'Телефон',
                  value: _request.phoneNumber.isNotEmpty
                      ? _request.phoneNumber
                      : l10n.t('admin.helpRequests.notProvided'),
                ),
                if (_request.city != null && _request.city!.isNotEmpty)
                  _InfoRow(label: 'Город', value: _request.city!),
              ],
            ),
            SizedBox(height: 14.h),
            _InfoSection(
              title: 'Детали заявки',
              children: [
                _InfoRow(
                  label: 'Категория',
                  value:
                      _request.helpCategoryTitle ??
                      l10n.t('admin.helpRequests.notProvided'),
                ),
                _InfoRow(
                  label: 'Статус',
                  value: '',
                  valueWidget: HelpRequestStatusChip(
                    status: _request.status,
                    l10n: l10n,
                    dense: true,
                  ),
                ),
                _InfoRow(
                  label: 'Материальное положение',
                  value:
                      _request.materialStatusTitle ??
                      l10n.t('admin.helpRequests.notProvided'),
                ),
                if (_request.money != null)
                  _InfoRow(
                    label: 'Сумма',
                    value: '${_request.money!.toStringAsFixed(0)} ₸',
                  ),
                if (_request.companyName != null &&
                    _request.companyName!.isNotEmpty)
                  _InfoRow(label: 'Фонд', value: _request.companyName!),
                if (_request.childrenCount != null)
                  _InfoRow(
                    label: 'Дети в семье',
                    value: '${_request.childrenCount}',
                  ),
                if (_request.age != null)
                  _InfoRow(label: 'Возраст', value: '${_request.age}'),
                if (_request.iin != null && _request.iin!.isNotEmpty)
                  _InfoRow(label: 'ИИН', value: _request.iin!),
                if (_request.otherCategory != null &&
                    _request.otherCategory!.isNotEmpty)
                  _InfoRow(
                    label: 'Другая категория',
                    value: _request.otherCategory!,
                  ),
                if (_request.createdAt != null)
                  _InfoRow(
                    label: 'Создано',
                    value:
                        '${_request.createdAt!.year}-${_request.createdAt!.month.toString().padLeft(2, '0')}-${_request.createdAt!.day.toString().padLeft(2, '0')}',
                  ),
                if (_request.receivedOtherHelp != null)
                  _InfoRow(
                    label: 'Получал другую помощь',
                    value: _request.receivedOtherHelp! ? 'Да' : 'Нет',
                  ),
              ],
            ),
            if (_request.address != null && _request.address!.isNotEmpty) ...[
              SizedBox(height: 14.h),
              _InfoSection(
                title: 'Адрес',
                children: [_InfoRow(label: '', value: _request.address!)],
              ),
            ],
            if (_request.helpReason != null &&
                _request.helpReason!.trim().isNotEmpty) ...[
              SizedBox(height: 14.h),
              _InfoSection(
                title: 'Причина обращения',
                children: [_InfoRow(label: '', value: _request.helpReason!)],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<HelpRequestStatus?> _pickStatus(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    return showModalBottomSheet<HelpRequestStatus>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: HelpRequestStatus.values.map((status) {
              return ListTile(
                onTap: () => Navigator.of(context).pop(status),
                leading: status == _request.status
                    ? const Icon(Icons.check_circle, color: Color(0xFF1E88E5))
                    : const Icon(Icons.circle_outlined),
                title: Text(helpRequestStatusLabel(l10n, status)),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

String _safeL10n(AppLocalizations l10n, String key, String fallback) {
  final value = l10n.t(key);
  if (value == key || value.trim().isEmpty) return fallback;
  return value;
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 10.h),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.valueWidget});

  final String label;
  final String value;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty)
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withValues(
                    alpha: 0.7,
                  ),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Expanded(
            flex: 3,
            child:
                valueWidget ??
                Text(
                  value.isNotEmpty ? value : '—',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

class _StatusMenu extends StatelessWidget {
  const _StatusMenu({
    required this.current,
    required this.onSelected,
    required this.isUpdating,
  });

  final HelpRequestStatus current;
  final ValueChanged<HelpRequestStatus> onSelected;
  final bool isUpdating;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<HelpRequestStatus>(
      enabled: !isUpdating,
      tooltip: '',
      onSelected: onSelected,
      itemBuilder: (context) {
        return HelpRequestStatus.values
            .map((status) {
              return PopupMenuItem<HelpRequestStatus>(
                value: status,
                child: Row(
                  children: [
                    if (status == current)
                      Icon(Icons.check, size: 18.sp)
                    else
                      SizedBox(width: 18.w),
                    SizedBox(width: 6.w),
                    Text(
                      helpRequestStatusLabel(context.l10n, status),
                      style: TextStyle(
                        fontWeight: status == current
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            })
            .toList(growable: false);
      },
      child: isUpdating
          ? SizedBox(
              width: 22.r,
              height: 22.r,
              child: CircularProgressIndicator(strokeWidth: 2.w),
            )
          : Padding(padding: EdgeInsets.all(4.r), child: Icon(Icons.more_vert)),
    );
  }
}
