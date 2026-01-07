import 'package:flutter/material.dart';
import 'package:safa_app/core/localization/app_localizations.dart';
import 'package:safa_app/features/sadaqa/data/repositories/sadaqa_repository_impl.dart';
import 'package:safa_app/features/sadaqa/domain/entities/sadaqa_post.dart';
import 'package:safa_app/features/sadaqa/domain/repositories/sadaqa_repository.dart';
import 'package:safa_app/features/sadaqa/domain/utils/media_resolver.dart';
import 'package:safa_app/features/settings/presentation/pages/admin_sadaqa/admin_note_edit_page.dart';
import 'package:safa_app/features/settings/presentation/pages/admin_sadaqa/admin_note_create_page.dart';

class AdminNotesPage extends StatefulWidget {
  const AdminNotesPage({super.key, this.companyName});

  final String? companyName;

  @override
  State<AdminNotesPage> createState() => _AdminNotesPageState();
}

class _AdminNotesPageState extends State<AdminNotesPage> {
  final SadaqaRepository _repository = SadaqaRepositoryImpl();
  bool _isLoading = true;
  String? _error;
  List<SadaqaPost> _notes = const [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final notes = await _repository.fetchAdminNotes();
      setState(() => _notes = notes);
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          title: Text(
            l10n.t('settings.admin.menu.notes'),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(
              (widget.companyName?.isNotEmpty == true ? 32 : 0) + 48,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.companyName?.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
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
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor:
                      theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  indicatorColor: theme.colorScheme.primary,
                  tabs: const [
                    Tab(text: 'Активные'),
                    Tab(text: 'Архив'),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _loadNotes,
          child: TabBarView(
            children: [
              _buildBody(
                theme,
                l10n,
                _notes.where((n) => n.status != 2).toList(),
                isArchive: false,
              ),
              _buildBody(
                theme,
                l10n,
                _notes.where((n) => n.status == 2).toList(),
                isArchive: true,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _onCreateNote,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildBody(
    ThemeData theme,
    AppLocalizations l10n,
    List<SadaqaPost> notes, {
    required bool isArchive,
  }) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Не удалось загрузить', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: Colors.red.withValues(alpha: 0.8)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadNotes,
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }
    if (notes.isEmpty) {
      return Center(
        child: Text(
          isArchive ? 'Архив пуст' : 'Нет заметок',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _NoteCard(
            note: note,
            onEdit: _onEditNote,
            onDelete: _onDeleteNote,
          ),
        );
      },
    );
  }

  Future<void> _onEditNote(SadaqaPost note) async {
    final updated =
        await Navigator.of(context, rootNavigator: true).push<SadaqaPost>(
      MaterialPageRoute(
        builder: (_) => AdminNoteEditPage(
          note: note,
          repository: _repository,
        ),
      ),
    );
    if (updated != null && mounted) {
      setState(() {
        _notes = _notes
            .map((n) => n.id == updated.id ? updated : n)
            .toList(growable: false);
      });
    }
  }

  Future<void> _onCreateNote() async {
    final created =
        await Navigator.of(context, rootNavigator: true).push<SadaqaPost>(
      MaterialPageRoute(
        builder: (_) => AdminNoteCreatePage(repository: _repository),
      ),
    );
    if (created != null && mounted) {
      setState(() {
        _notes = [created, ..._notes];
      });
    }
  }

  Future<void> _onDeleteNote(SadaqaPost note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Удалить заметку?'),
          content: Text('Вы уверены, что хотите удалить "${note.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _repository.deleteNote(note.id);
      if (!mounted) return;
      setState(() {
        _notes = _notes.where((n) => n.id != note.id).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заметка удалена')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка удаления: $error')),
      );
    }
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.note,
    required this.onEdit,
    required this.onDelete,
  });

  final SadaqaPost note;
  final ValueChanged<SadaqaPost> onEdit;
  final ValueChanged<SadaqaPost> onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = note.title.isNotEmpty ? note.title : 'Без названия';
    final subtitle = note.content;
    final image = resolveMediaUrl(note.image);
    final hasGoal = note.goal != null && note.goal! > 0;
    final progress = hasGoal
        ? ((note.collected ?? 0).toDouble() / note.goal!)
            .clamp(0.0, 1.0)
            .toDouble()
        : 0.0;

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: image.isNotEmpty
                      ? Image.network(
                          image,
                          width: 76,
                          height: 76,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _placeholder(),
                        )
                      : _placeholder(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                      if (hasGoal) ...[
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: progress,
                          minHeight: 6.0,
                          borderRadius: BorderRadius.circular(10),
                          backgroundColor:
                              theme.colorScheme.primary.withValues(alpha: 0.12),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(progress * 100).toStringAsFixed(1)}% собрано',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => onEdit(note),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Редактировать'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    onPressed: () => onDelete(note),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Удалить'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.image_outlined, color: Colors.grey),
    );
  }
}
