import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safa_app/core/localization/app_localizations.dart';
import 'package:safa_app/core/utils/error_messages.dart';
import 'package:safa_app/features/sadaqa/data/repositories/sadaqa_repository_impl.dart';
import 'package:safa_app/features/sadaqa/domain/entities/sadaqa_post.dart';
import 'package:safa_app/features/sadaqa/domain/repositories/sadaqa_repository.dart';
import 'package:safa_app/features/sadaqa/domain/utils/media_resolver.dart';
import 'package:safa_app/features/settings/presentation/pages/admin_sadaqa/admin_post_create_page.dart';
import 'package:safa_app/features/settings/presentation/pages/admin_sadaqa/admin_post_edit_page.dart';

class AdminPostsPage extends StatefulWidget {
  const AdminPostsPage({super.key, this.companyName});

  final String? companyName;

  @override
  State<AdminPostsPage> createState() => _AdminPostsPageState();
}

class _AdminPostsPageState extends State<AdminPostsPage> {
  final SadaqaRepository _repository = SadaqaRepositoryImpl();
  bool _isLoading = true;
  String? _error;
  List<SadaqaPost> _posts = const [];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final posts = await _repository.fetchAdminPosts();
      setState(() => _posts = posts);
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.t('settings.admin.menu.posts'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: widget.companyName?.isNotEmpty == true
            ? PreferredSize(
                preferredSize: Size.fromHeight(32.h),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: Text(
                    widget.companyName!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            : null,
      ),
      body: RefreshIndicator(onRefresh: _loadPosts, child: _buildBody(theme)),
      floatingActionButton: FloatingActionButton(
        onPressed: _onCreatePost,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Не удалось загрузить', style: theme.textTheme.titleMedium),
            SizedBox(height: 8.h),
            Text(
              _error!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.red.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            ElevatedButton(
              onPressed: _loadPosts,
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }
    if (_posts.isEmpty) {
      return Center(
        child: Text(
          'Нет постов',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: _PostCard(
            post: post,
            onEdit: _onEditPost,
            onDelete: _onDeletePost,
          ),
        );
      },
    );
  }

  Future<void> _onEditPost(SadaqaPost post) async {
    final updated = await Navigator.of(context, rootNavigator: true)
        .push<SadaqaPost>(
          MaterialPageRoute(
            builder: (_) =>
                AdminPostEditPage(post: post, repository: _repository),
          ),
        );
    if (updated != null && mounted) {
      setState(() {
        _posts = _posts
            .map((p) => p.id == updated.id ? updated : p)
            .toList(growable: false);
      });
    }
  }

  Future<void> _onDeletePost(SadaqaPost post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Удалить пост?'),
          content: Text('Вы уверены, что хотите удалить "${post.title}"?'),
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
      await _repository.deletePost(post.id);
      if (!mounted) return;
      setState(() {
        _posts = _posts.where((p) => p.id != post.id).toList();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Пост удалён')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(friendlyError(error))));
    }
  }

  Future<void> _onCreatePost() async {
    final created = await Navigator.of(context, rootNavigator: true)
        .push<SadaqaPost>(
          MaterialPageRoute(
            builder: (_) => AdminPostCreatePage(repository: _repository),
          ),
        );
    if (created != null && mounted) {
      setState(() {
        _posts = [created, ..._posts];
      });
    }
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({
    required this.post,
    required this.onEdit,
    required this.onDelete,
  });

  final SadaqaPost post;
  final ValueChanged<SadaqaPost> onEdit;
  final ValueChanged<SadaqaPost> onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final image = resolveMediaUrl(post.image);
    final dateText = post.createdAt != null
        ? '${post.createdAt!.year}-${post.createdAt!.month.toString().padLeft(2, '0')}-${post.createdAt!.day.toString().padLeft(2, '0')}'
        : '';

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(20.r),
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (image.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.network(
                  image,
                  width: double.infinity,
                  height: 180.h,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _placeholderImage(),
                ),
              )
            else
              _placeholderImage(),
            SizedBox(height: 10.h),
            Text(
              post.title.isNotEmpty ? post.title : 'Без названия',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              post.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
              ),
            ),
            SizedBox(height: 8.h),
            if (dateText.isNotEmpty)
              Text(
                dateText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => onEdit(post),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Редактировать'),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red, width: 1.w),
                    ),
                    onPressed: () => onDelete(post),
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

  Widget _placeholderImage() {
    return Container(
      width: double.infinity,
      height: 180.h,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: const Icon(Icons.image_outlined, color: Colors.grey),
    );
  }
}
