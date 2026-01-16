import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safa_app/core/localization/app_localizations.dart';
import 'package:safa_app/core/utils/error_messages.dart';
import 'package:safa_app/features/settings/data/repositories/super_admin_repository_impl.dart';
import 'package:safa_app/features/settings/domain/repositories/super_admin_repository.dart';
import 'package:safa_app/features/settings/presentation/pages/super_admin/language_create_page.dart';

class LanguagesPage extends StatefulWidget {
  const LanguagesPage({super.key});

  @override
  State<LanguagesPage> createState() => _LanguagesPageState();
}

class _LanguagesPageState extends State<LanguagesPage> {
  final SuperAdminRepository _repository = SuperAdminRepositoryImpl();
  bool _loading = true;
  List<LanguageItem> _languages = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('settings.superAdmin.languageCard.title')),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 80.h),
                  itemBuilder: (context, index) {
                    final lang = _languages[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(
                          0xFFF59E0B,
                        ).withValues(alpha: 0.12),
                        child: const Icon(
                          Icons.language_outlined,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                      title: Text(lang.title),
                      subtitle: Text(lang.code),
                    );
                  },
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemCount: _languages.length,
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreate,
        label: Text(l10n.t('settings.superAdmin.actions.createLanguage')),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await _repository.fetchLanguages();
      if (!mounted) return;
      setState(() => _languages = list);
    } catch (e) {
      if (!mounted) return;
      _showMessage(friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _openCreate() async {
    final created = await Navigator.of(context, rootNavigator: true).push<bool>(
      MaterialPageRoute(
        builder: (_) => LanguageCreatePage(repository: _repository),
      ),
    );
    if (created == true) {
      await _load();
    }
  }
}
