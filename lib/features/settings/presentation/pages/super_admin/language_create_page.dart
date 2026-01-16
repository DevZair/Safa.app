import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safa_app/core/localization/app_localizations.dart';
import 'package:safa_app/core/utils/error_messages.dart';
import 'package:safa_app/features/settings/domain/repositories/super_admin_repository.dart';

class LanguageCreatePage extends StatefulWidget {
  const LanguageCreatePage({super.key, required this.repository});

  final SuperAdminRepository repository;

  @override
  State<LanguageCreatePage> createState() => _LanguageCreatePageState();
}

class _LanguageCreatePageState extends State<LanguageCreatePage> {
  final _codeCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    _titleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('settings.superAdmin.actions.createLanguage')),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: const Icon(
                        Icons.language_outlined,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        l10n.t('settings.superAdmin.languageCard.subtitle'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              _field(
                _codeCtrl,
                l10n.t('settings.superAdmin.fields.code'),
                hint: 'ru, kk, uz',
              ),
              _field(
                _titleCtrl,
                l10n.t('settings.superAdmin.fields.languageTitle'),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(l10n.t('settings.superAdmin.submit')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    String? hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final code = _codeCtrl.text.trim();
    final title = _titleCtrl.text.trim();
    if (code.isEmpty || title.isEmpty) {
      _show(l10n.t('settings.superAdmin.validation.language'));
      return;
    }
    setState(() => _submitting = true);
    try {
      await widget.repository.createLanguage(code: code, title: title);
      if (!mounted) return;
      _show(l10n.t('settings.superAdmin.success.language'));
      Navigator.of(context).pop(true);
    } catch (e) {
      _show(friendlyError(e));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
