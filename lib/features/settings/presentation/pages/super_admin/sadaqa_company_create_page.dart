import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safa_app/core/localization/app_localizations.dart';
import 'package:safa_app/core/utils/error_messages.dart';
import 'package:safa_app/features/settings/domain/repositories/super_admin_repository.dart';

class SadaqaCompanyCreatePage extends StatefulWidget {
  const SadaqaCompanyCreatePage({super.key, required this.repository});

  final SuperAdminRepository repository;

  @override
  State<SadaqaCompanyCreatePage> createState() =>
      _SadaqaCompanyCreatePageState();
}

class _SadaqaCompanyCreatePageState extends State<SadaqaCompanyCreatePage> {
  final _titleCtrl = TextEditingController();
  final _whyCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  final _paymentCtrl = TextEditingController();
  final _loginCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _whyCtrl.dispose();
    _imageCtrl.dispose();
    _paymentCtrl.dispose();
    _loginCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('settings.superAdmin.actions.createSadaqa')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _info(context),
              SizedBox(height: 16.h),
              _field(_titleCtrl, l10n.t('settings.superAdmin.fields.title')),
              _field(
                _whyCtrl,
                l10n.t('settings.superAdmin.fields.why'),
                maxLines: 3,
              ),
              _field(
                _imageCtrl,
                l10n.t('settings.superAdmin.fields.image'),
                hint: 'https://...',
              ),
              _uploadButton(),
              _field(
                _paymentCtrl,
                l10n.t('settings.superAdmin.fields.payment'),
              ),
              _field(_loginCtrl, l10n.t('settings.superAdmin.fields.login')),
              _field(
                _passwordCtrl,
                l10n.t('settings.superAdmin.fields.password'),
                obscure: true,
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

  Widget _info(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFF22B573).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: const Icon(
              Icons.volunteer_activism_outlined,
              color: Color(0xFF22B573),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              l10n.t('settings.superAdmin.sadaqaCard.subtitle'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        obscureText: obscure,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
      ),
    );
  }

  Widget _uploadButton() {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _imageCtrl.text.isEmpty ? 'Файл не выбран' : _imageCtrl.text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 12.w),
          ElevatedButton.icon(
            onPressed: _submitting ? null : _handleFilePick,
            icon: const Icon(Icons.cloud_upload_outlined),
            label: const Text('Upload'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleFilePick() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: false,
    );
    if (result == null || result.files.single.path == null) return;
    final path = result.files.single.path!;
    setState(() => _submitting = true);
    try {
      final url = await widget.repository.uploadImage(path);
      _imageCtrl.text = url;
      _show('Загружено');
    } catch (e) {
      _show(friendlyError(e));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final title = _titleCtrl.text.trim();
    final why = _whyCtrl.text.trim();
    final image = _imageCtrl.text.trim();
    final payment = _paymentCtrl.text.trim();
    final login = _loginCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (title.isEmpty ||
        why.isEmpty ||
        image.isEmpty ||
        payment.isEmpty ||
        login.isEmpty ||
        password.isEmpty) {
      _show(l10n.t('settings.superAdmin.validation.sadaqa'));
      return;
    }

    setState(() => _submitting = true);
    try {
      await widget.repository.createSadaqaCompany(
        title: title,
        whyCollecting: why,
        image: image,
        payment: payment,
        login: login,
        password: password,
      );
      if (!mounted) return;
      _show(l10n.t('settings.superAdmin.success.sadaqa'));
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
