import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safa_app/core/utils/error_messages.dart';
import 'package:safa_app/features/settings/presentation/pages/admin_tour/category_form_page.dart';
import 'package:safa_app/features/travel/data/repositories/tour_repository_impl.dart';
import 'package:safa_app/features/travel/domain/entities/tour_category.dart';
import 'package:safa_app/features/travel/domain/repositories/tour_repository.dart';

class ManageCategoriesPage extends StatefulWidget {
  const ManageCategoriesPage({super.key});

  @override
  State<ManageCategoriesPage> createState() => _ManageCategoriesPageState();
}

class _ManageCategoriesPageState extends State<ManageCategoriesPage> {
  final TourRepository _repository = TourRepositoryImpl();
  late Future<List<TourCategory>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _repository.getCategories();
  }

  void _refresh() {
    setState(() => _categoriesFuture = _repository.getCategories());
  }

  Future<void> _openForm({TourCategory? initial}) async {
    final result = await Navigator.of(context).push<TourCategory?>(
      MaterialPageRoute(
        builder: (_) =>
            CategoryFormPage(repository: _repository, initial: initial),
      ),
    );
    if (result != null) {
      _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            initial == null ? 'Категория добавлена' : 'Категория обновлена',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Категории')),
      body: FutureBuilder<List<TourCategory>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Не удалось загрузить категории'),
                  SizedBox(height: 6.h),
                  Text(
                    _friendlyError(snapshot.error),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
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

          final categories = snapshot.data ?? const [];
          if (categories.isEmpty) {
            return Center(
              child: Text(
                'Категории пока не добавлены',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _CategoryCard(
                  category: category,
                  onEdit: () => _openForm(initial: category),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, this.onEdit});

  final TourCategory category;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.cardColor,
      elevation: 1,
      borderRadius: BorderRadius.circular(14.r),
      child: ListTile(
        title: Text(
          category.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text('ID: ${category.id}'),
        trailing: IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: onEdit,
          tooltip: 'Изменить',
        ),
      ),
    );
  }
}

String _friendlyError(Object? error) {
  if (error == null) return 'Попробуйте позже';
  if (error is SocketException) return 'Нет подключения к интернету';
  final text = error.toString();
  if (text.contains('SocketException')) return 'Нет подключения к интернету';
  return friendlyError(error);
}
