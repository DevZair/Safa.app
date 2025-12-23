import 'package:flutter/material.dart';
import 'package:safa_app/core/localization/app_localizations.dart';
import 'package:safa_app/features/sadaqa/data/sadaqa_repository.dart';
import 'package:safa_app/features/sadaqa/data/request_help_repository.dart';
import 'package:safa_app/features/sadaqa/models/help_request.dart';
import 'package:safa_app/features/settings/presentation/pages/admin_sadaqa/admin_help_request_detail_page.dart';
import 'package:safa_app/features/settings/presentation/widgets/help_request_status.dart';

class AdminHelpRequestsPage extends StatefulWidget {
  const AdminHelpRequestsPage({super.key, this.companyName});

  final String? companyName;

  @override
  State<AdminHelpRequestsPage> createState() => _AdminHelpRequestsPageState();
}

class _AdminHelpRequestsPageState extends State<AdminHelpRequestsPage>
    with SingleTickerProviderStateMixin {
  final _repository = SadaqaRepository();
  bool _isLoading = true;
  String? _error;
  String? _updatingId;
  List<HelpRequest> _requests = const [];
  List<ReferenceItem> _materialStatuses = const [];
  List<ReferenceItem> _categories = const [];
  bool _isLoadingRefs = true;
  String? _refsError;
  late final TabController _tabController;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() => _tabIndex = _tabController.index);
    });
    _loadRequests();
    _loadRefs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final requests = await _repository.fetchHelpRequests();
      if (!mounted) return;
      setState(() => _requests = requests);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadRefs() async {
    setState(() {
      _isLoadingRefs = true;
      _refsError = null;
    });
    try {
      final results = await Future.wait([
        _repository.fetchPrivateMaterialStatusList(),
        _repository.fetchPrivateHelpCategoryList(),
      ]);
      if (!mounted) return;
      setState(() {
        _materialStatuses = results[0];
        _categories = results[1];
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _refsError = error.toString());
    } finally {
      if (mounted) setState(() => _isLoadingRefs = false);
    }
  }

  Future<void> _changeStatus(
    HelpRequest request,
    HelpRequestStatus status,
  ) async {
    if (request.id.isEmpty) return;
    setState(() => _updatingId = request.id);
    final l10n = context.l10n;
    try {
      final updated = await _repository.updateHelpRequestStatus(
        id: request.id,
        status: status,
      );
      if (!mounted) return;
      final next = (updated ?? request.copyWith(status: status)).copyWith(
        helpCategoryTitle:
            updated?.helpCategoryTitle ?? request.helpCategoryTitle,
        materialStatusTitle:
            updated?.materialStatusTitle ?? request.materialStatusTitle,
      );
      setState(() {
        _requests = _requests
            .map((item) => item.id == request.id ? next : item)
            .toList(growable: false);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('admin.helpRequests.statusUpdated'))),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.t('admin.helpRequests.error')}: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _updatingId = null);
      }
    }
  }

  Future<void> _openDetail(HelpRequest request) async {
    final updated =
        await Navigator.of(context, rootNavigator: true).push<HelpRequest>(
      MaterialPageRoute(
        builder: (_) => AdminHelpRequestDetailPage(
          request: request,
          repository: _repository,
          companyName: widget.companyName,
        ),
      ),
    );

    if (updated != null && mounted) {
      setState(() {
        _requests = _requests
            .map((item) => item.id == updated.id ? updated : item)
            .toList(growable: false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final tabTitles = [
      _safeL10n(l10n, 'admin.helpRequests.title', 'Заявки'),
      _safeL10n(
        l10n,
        'admin.helpRequests.materialStatus',
        'Материальное положение',
      ),
      _safeL10n(l10n, 'admin.helpRequests.category', 'Категория'),
    ];
    final pageTitle = tabTitles[_tabIndex.clamp(0, tabTitles.length - 1)];
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          centerTitle: true,
          title: Text(
            pageTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(
              widget.companyName?.isNotEmpty == true ? 72 : 48,
            ),
            child: Column(
              children: [
                if (widget.companyName?.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      widget.companyName!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: tabTitles[0]),
                    Tab(text: tabTitles[1]),
                    Tab(text: tabTitles[2]),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            RefreshIndicator(
              onRefresh: _loadRequests,
              child: _buildBody(l10n, theme),
            ),
            _LookupTab(
              title: 'Материальное положение',
              isLoading: _isLoadingRefs,
              error: _refsError,
              items: _materialStatuses,
              onRefresh: _loadRefs,
              onAdd: () => _promptMaterialStatus(
                context: context,
                title: 'Добавить материальное положение',
                onSubmit: (value, isActive) =>
                    _createMaterialStatus(value, isActive: isActive),
              ),
              onEdit: (item) => _promptMaterialStatus(
                context: context,
                title: 'Редактировать материальное положение',
                initial: item.title,
                initialStatus: item.isActive,
                onSubmit: (value, isActive) =>
                    _updateMaterialStatus(item.id, value, isActive: isActive),
              ),
              onDelete: (_) {},
              showStatusToggle: true,
              onToggleStatus: (item, active) => _updateMaterialStatus(
                item.id,
                item.title,
                isActive: active,
              ),
            ),
            _LookupTab(
              title: 'Категория',
              isLoading: _isLoadingRefs,
              error: _refsError,
              items: _categories,
              onRefresh: _loadRefs,
              onAdd: () => _promptCreateLookup(
                context: context,
                title: 'Добавить категорию',
                onSubmit: (value) => _createHelpCategory(value),
              ),
              onEdit: (item) => _promptCreateLookup(
                context: context,
                title: 'Редактировать категорию',
                initial: item.title,
                onSubmit: (value) => _updateHelpCategory(item.id, value),
              ),
              onDelete: (item) => _confirmDelete(
                context: context,
                title: 'Удалить "${item.title}"?',
                onConfirm: () => _deleteHelpCategory(item.id),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createMaterialStatus(String title, {bool isActive = true}) async {
    final created =
        await _repository.createMaterialStatus(title, isActive: isActive);
    if (created == null) throw Exception('Не удалось создать статус');
    setState(() {
      _materialStatuses = [..._materialStatuses, created]..sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
    });
  }

  Future<void> _updateMaterialStatus(
    int id,
    String title, {
    bool isActive = true,
  }) async {
    final updated = await _repository.updateMaterialStatus(
      id: id,
      title: title,
      isActive: isActive,
    );
    if (updated == null) throw Exception('Не удалось обновить статус');
    setState(() {
      _materialStatuses = _materialStatuses
          .map((e) => e.id == id ? updated : e)
          .toList(growable: false);
    });
  }

  Future<void> _createHelpCategory(String title) async {
    final created = await _repository.createHelpCategory(title);
    if (created == null) throw Exception('Не удалось создать категорию');
    setState(() {
      _categories = [..._categories, created]..sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
    });
  }

  Future<void> _updateHelpCategory(int id, String title) async {
    final updated = await _repository.updateHelpCategory(id: id, title: title);
    if (updated == null) throw Exception('Не удалось обновить категорию');
    setState(() {
      _categories = _categories
          .map((e) => e.id == id ? updated : e)
          .toList(growable: false);
    });
  }

  Future<void> _deleteHelpCategory(int id) async {
    final ok = await _repository.deleteHelpCategory(id);
    if (!ok) throw Exception('Не удалось удалить категорию');
    setState(() {
      _categories =
          _categories.where((e) => e.id != id).toList(growable: false);
    });
  }

  Future<void> _promptCreateLookup({
    required BuildContext context,
    required String title,
    String? initial,
    required Future<void> Function(String value) onSubmit,
  }) async {
    final controller = TextEditingController(text: initial ?? '');
    final theme = Theme.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Введите название'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isEmpty) return;
                Navigator.of(context).pop(text);
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );

    if (result == null || result.trim().isEmpty) return;

    try {
      await onSubmit(result.trim());
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Сохранено'),
          backgroundColor: theme.colorScheme.primary,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Ошибка: $error'),
          backgroundColor: theme.colorScheme.error,
        ),
      );
    }
  }

  Future<void> _confirmDelete({
    required BuildContext context,
    required String title,
    required Future<void> Function() onConfirm,
  }) async {
    final theme = Theme.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await onConfirm();
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: const Text('Удалено')),
      );
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Ошибка: $error'),
          backgroundColor: theme.colorScheme.error,
        ),
      );
    }
  }

  Future<void> _promptMaterialStatus({
    required BuildContext context,
    required String title,
    String? initial,
    bool initialStatus = true,
    required Future<void> Function(String value, bool isActive) onSubmit,
  }) async {
    final controller = TextEditingController(text: initial ?? '');
    final theme = Theme.of(context);
    final messenger = ScaffoldMessenger.of(context);
    var isActive = initialStatus;

    final result = await showDialog<Map<String, Object?>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(title),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration:
                        const InputDecoration(hintText: 'Введите название'),
                    autofocus: true,
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Статус (показывать)'),
                    value: isActive,
                    onChanged: (value) => setState(() => isActive = value),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Отмена'),
                ),
                FilledButton(
                  onPressed: () {
                    final text = controller.text.trim();
                    if (text.isEmpty) return;
                    Navigator.of(context).pop({
                      'text': text,
                      'isActive': isActive,
                    });
                  },
                  child: const Text('Сохранить'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null) return;
    final text = result['text']?.toString().trim() ?? '';
    final active =
        result['isActive'] is bool ? result['isActive'] as bool : true;
    if (text.isEmpty) return;
    try {
      await onSubmit(text, active);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Сохранено'),
          backgroundColor: theme.colorScheme.primary,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Ошибка: $error'),
          backgroundColor: theme.colorScheme.error,
        ),
      );
    }
  }

  Widget _buildBody(AppLocalizations l10n, ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.t('admin.helpRequests.error'),
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.red.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadRequests,
                child: Text(l10n.t('sadaqa.actions.retry')),
              ),
            ],
          ),
        ),
      );
    }

    if (_requests.isEmpty) {
      return Center(
        child: Text(
          l10n.t('admin.helpRequests.empty'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: _requests.length,
      itemBuilder: (context, index) {
        final request = _requests[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _HelpRequestCard(
            request: request,
            l10n: l10n,
            isUpdating: _updatingId == request.id,
            onTap: () => _openDetail(request),
            onChangeStatus: (status) => _changeStatus(request, status),
          ),
        );
      },
    );
  }
}

class _LookupTab extends StatelessWidget {
  const _LookupTab({
    required this.title,
    required this.isLoading,
    required this.error,
    required this.items,
    required this.onRefresh,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    this.showStatusToggle = false,
    this.onToggleStatus,
  });

  final String title;
  final bool isLoading;
  final String? error;
  final List<ReferenceItem> items;
  final Future<void> Function() onRefresh;
  final VoidCallback onAdd;
  final ValueChanged<ReferenceItem> onEdit;
  final ValueChanged<ReferenceItem> onDelete;
  final bool showStatusToggle;
  final void Function(ReferenceItem, bool)? onToggleStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ошибка загрузки',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.red.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: onRefresh,
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Добавить'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Text(
              'Пусто. Добавьте первый элемент.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(
                      alpha: 0.7,
                    ),
              ),
            ),
          ...items.map(
            (item) => Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(item.title),
                subtitle: Text('ID: ${item.id}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showStatusToggle && onToggleStatus != null)
                      Switch(
                        value: item.isActive,
                        onChanged: (value) =>
                            onToggleStatus?.call(item, value),
                      ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => onEdit(item),
                    ),
                    if (!showStatusToggle)
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => onDelete(item),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpRequestCard extends StatelessWidget {
  const _HelpRequestCard({
    required this.request,
    required this.l10n,
    required this.onTap,
    required this.onChangeStatus,
    required this.isUpdating,
  });

  final HelpRequest request;
  final AppLocalizations l10n;
  final VoidCallback onTap;
  final ValueChanged<HelpRequestStatus> onChangeStatus;
  final bool isUpdating;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = request.fullName.isNotEmpty
        ? request.fullName
        : l10n.t('admin.helpRequests.unnamed');
    final reason = request.helpReason ?? l10n.t('admin.helpRequests.noReason');
    final category = request.helpCategoryTitle ?? l10n.t('sadaqa.header.title');
    final createdAt = request.createdAt;
    final dateText = createdAt != null
        ? '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}'
        : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final badgeMaxWidth = maxWidth * 0.6;

        return Material(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          elevation: 1.5,
          shadowColor: Colors.black.withValues(alpha: 0.04),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(16),
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
                              name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              request.phoneNumber.isNotEmpty
                                  ? request.phoneNumber
                                  : l10n.t('admin.helpRequests.notProvided'),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color:
                                    theme.textTheme.bodySmall?.color?.withValues(
                                          alpha: 0.75,
                                        ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          HelpRequestStatusChip(
                            status: request.status,
                            l10n: l10n,
                          ),
                          const SizedBox(height: 6),
                          _StatusMenu(
                            current: request.status,
                            onSelected: onChangeStatus,
                            isUpdating: isUpdating,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    reason,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withValues(
                            alpha: 0.82,
                          ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MetaBadge(
                        icon: Icons.category_outlined,
                        label: category,
                        maxWidth: badgeMaxWidth,
                      ),
                      if (dateText != null)
                        _MetaBadge(
                          icon: Icons.calendar_today_outlined,
                          label: dateText,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MetaBadge extends StatelessWidget {
  const _MetaBadge({required this.icon, required this.label, this.maxWidth});

  final IconData icon;
  final String label;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    if (maxWidth != null) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth!),
        child: content,
      );
    }
    return content;
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
        return HelpRequestStatus.values.map((status) {
          return PopupMenuItem<HelpRequestStatus>(
            value: status,
            child: Row(
              children: [
                if (status == current)
                  const Icon(Icons.check, size: 18)
                else
                  const SizedBox(width: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    helpRequestStatusLabel(context.l10n, status),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight:
                          status == current ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(growable: false);
      },
      child: isUpdating
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.more_vert),
            ),
    );
  }
}

String _safeL10n(AppLocalizations l10n, String key, String fallback) {
  final value = l10n.t(key);
  if (value == key || value.trim().isEmpty) return fallback;
  return value;
}
