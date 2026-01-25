
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safa_app/core/localization/app_localizations.dart';
import 'package:safa_app/core/utils/error_messages.dart';
import 'package:safa_app/features/settings/domain/repositories/super_admin_repository.dart';

class TourCompanyCreatePage extends StatefulWidget {
  const TourCompanyCreatePage({super.key, required this.repository});

  final SuperAdminRepository repository;

  @override
  State<TourCompanyCreatePage> createState() => _TourCompanyCreatePageState();
}

class _TourCompanyCreatePageState extends State<TourCompanyCreatePage> {
  final _nameCtrl = TextEditingController();
  final _logoCtrl = TextEditingController();
  final _ratingCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _logoCtrl.dispose();
    _ratingCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('settings.superAdmin.actions.createTour')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _info(theme, l10n),
              SizedBox(height: 16.h),
              _field(
                _nameCtrl,
                l10n.t('settings.superAdmin.fields.companyName'),
              ),
              _field(
                _logoCtrl,
                l10n.t('settings.superAdmin.fields.logo'),
                hint: 'https://...',
              ),
              _uploadButton(l10n),
              _field(
                _ratingCtrl,
                l10n.t('settings.superAdmin.fields.rating'),
                hint: '0 - 5',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              _field(
                _usernameCtrl,
                l10n.t('settings.superAdmin.fields.username'),
              ),
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
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
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

  Widget _info(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFF3BA7F2).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: const Icon(
              Icons.flight_takeoff_outlined,
              color: Color(0xFF3BA7F2),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              l10n.t('settings.superAdmin.tourCard.subtitle'),
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
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
      ),
    );
  }

  Widget _uploadButton(AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _logoCtrl.text.isEmpty
                  ? l10n.t('settings.superAdmin.fields.logo')
                  : _logoCtrl.text,
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
      _logoCtrl.text = url;
      _show('Загружено');
    } catch (e) {
      _show(friendlyError(e));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final name = _nameCtrl.text.trim();
    final logo = _logoCtrl.text.trim();
    final rating = double.tryParse(
      _ratingCtrl.text.replaceAll(',', '.').trim(),
    );
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (name.isEmpty ||
        logo.isEmpty ||
        username.isEmpty ||
        password.isEmpty ||
        rating == null ||
        rating < 0 ||
        rating > 5) {
      _show(l10n.t('settings.superAdmin.validation.tour'));
      return;
    }

    setState(() => _submitting = true);
    try {
      await widget.repository.createTourCompany(
        companyName: name,
        logo: logo,
        rating: rating,
        username: username,
        password: password,
      );
      if (!mounted) return;
      _show(l10n.t('settings.superAdmin.success.tour'));
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
