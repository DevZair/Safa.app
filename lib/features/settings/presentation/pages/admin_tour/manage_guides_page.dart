import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';

import 'package:safa_app/features/travel/data/repositories/tour_repository_impl.dart';
import 'package:safa_app/features/travel/domain/entities/travel_guide.dart';
import 'package:safa_app/features/travel/domain/repositories/tour_repository.dart';
import 'package:safa_app/features/settings/presentation/pages/admin_tour/guide_form_page.dart';

class ManageGuidesPage extends StatefulWidget {
  const ManageGuidesPage({super.key});

  @override
  State<ManageGuidesPage> createState() => _ManageGuidesPageState();
}

class _ManageGuidesPageState extends State<ManageGuidesPage> {
  final TourRepository _repository = TourRepositoryImpl();
  late Future<List<TravelGuide>> _guidesFuture;

  @override
  void initState() {
    super.initState();
    _guidesFuture = _repository.getGuidesDetailed();
  }

  void _refresh() {
    setState(() => _guidesFuture = _repository.getGuidesDetailed());
  }

  Future<void> _openCreateGuide() async {
    final created = await Navigator.of(context).push<TravelGuide?>(
      MaterialPageRoute(
        builder: (_) => GuideFormPage(repository: _repository),
      ),
    );
    if (created != null) {
      _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Гид успешно добавлен')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Гиды')),
      body: FutureBuilder<List<TravelGuide>>(
        future: _guidesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Не удалось загрузить гидов',
                    style: theme.textTheme.titleMedium,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    _friendlyError(snapshot.error),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12.h),
                  ElevatedButton(
                    onPressed: _refresh,
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }
          final guides = snapshot.data ?? const [];
          if (guides.isEmpty) {
            return Center(
              child: Text(
                'Гиды пока не добавлены',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
            itemCount: guides.length,
            itemBuilder: (context, index) {
              final guide = guides[index];
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _GuideCard(
                  guide: guide,
                  onEdit: () async {
                    final updated = await Navigator.of(context)
                        .push<TravelGuide?>(
                      MaterialPageRoute(
                        builder: (_) => GuideFormPage(
                          repository: _repository,
                          initial: guide,
                        ),
                      ),
                    );
                    if (updated != null) {
                      _refresh();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Гид обновлён')),
                        );
                      }
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateGuide,
        child: const Icon(Icons.add),
      ),
    );
  }
}

String _friendlyError(Object? error) {
  if (error == null) return 'Попробуйте позже';
  if (error is SocketException) return 'Нет подключения к интернету';
  final text = error.toString();
  if (text.contains('SocketException')) return 'Нет подключения к интернету';
  if (text.contains('401') || text.contains('403')) {
    return 'Нет доступа. Проверьте авторизацию.';
  }
  return 'Попробуйте позже. Детали: $text';
}

class _GuideCard extends StatelessWidget {
  const _GuideCard({required this.guide, this.onEdit});

  final TravelGuide guide;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(16.r),
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22.r,
              backgroundColor: theme.colorScheme.primary.withValues(
                alpha: 0.12,
              ),
              child: Icon(Icons.person, color: theme.colorScheme.primary),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    guide.fullName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (guide.about.isNotEmpty) ...[
                    SizedBox(height: 6.h),
                    Text(
                      guide.about,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withValues(
                          alpha: 0.75,
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        Icons.star_rate_rounded,
                        color: Colors.amber,
                        size: 18.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        guide.rating.toStringAsFixed(1),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (guide.numericId != null) ...[
                        SizedBox(width: 12.w),
                        Text(
                          'ID: ${guide.numericId}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (onEdit != null) ...[
              SizedBox(width: 8.w),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: onEdit,
                tooltip: 'Изменить',
              ),
            ],
          ],
        ),
      ),
    );
  }
}
