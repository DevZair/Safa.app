import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safa_app/features/sadaqa/data/repositories/sadaqa_repository_impl.dart';
import 'package:safa_app/features/sadaqa/domain/entities/sadaqa_company.dart';
import 'package:safa_app/features/sadaqa/domain/repositories/sadaqa_repository.dart';
import 'package:safa_app/features/sadaqa/domain/utils/media_resolver.dart';
import 'package:safa_app/core/utils/error_messages.dart';

class AdminCompanyProfilePage extends StatefulWidget {
  const AdminCompanyProfilePage({super.key, this.companyName});

  final String? companyName;

  @override
  State<AdminCompanyProfilePage> createState() =>
      _AdminCompanyProfilePageState();
}

class _AdminCompanyProfilePageState extends State<AdminCompanyProfilePage> {
  final SadaqaRepository _repository = SadaqaRepositoryImpl();
  final _nameController = TextEditingController();
  final _logoController = TextEditingController();
  final _coverController = TextEditingController();

  bool _isSaving = false;
  bool _isUploadingLogo = false;
  bool _isUploadingCover = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.companyName ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _logoController.dispose();
    _coverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logoUrl = resolveMediaUrl(_logoController.text.trim());
    final coverUrl = resolveMediaUrl(_coverController.text.trim());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль компании'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? SizedBox(
                    width: 16.r,
                    height: 16.r,
                    child: CircularProgressIndicator(strokeWidth: 2.w),
                  )
                : const Text('Сохранить'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 18.r,
                offset: Offset(0, 10.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _LogoPreview(
                    imageUrl: logoUrl,
                    isUploading: _isUploadingLogo,
                    fallback: _nameController.text.trim(),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Обновите название, логотип и обложку компании. '
                      'Эти данные будут использоваться в карточках и админке.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              _LabeledField(
                controller: _nameController,
                label: 'Название компании',
                hint: 'Введите название компании',
              ),
              SizedBox(height: 12.h),
              _ImageField(
                label: 'Логотип',
                controller: _logoController,
                imageUrl: logoUrl,
                isUploading: _isUploadingLogo,
                onUpload: () => _pickImage(isLogo: true),
              ),
              SizedBox(height: 12.h),
              _ImageField(
                label: 'Обложка',
                controller: _coverController,
                imageUrl: coverUrl,
                isUploading: _isUploadingCover,
                onUpload: () => _pickImage(isLogo: false),
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: _isSaving
                    ? SizedBox(
                        width: 18.r,
                        height: 18.r,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.w,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text('Сохранить изменения'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage({required bool isLogo}) async {
    if (isLogo ? _isUploadingLogo : _isUploadingCover) return;
    setState(() {
      if (isLogo) {
        _isUploadingLogo = true;
      } else {
        _isUploadingCover = true;
      }
    });

    try {
      const allowed = ['jpg', 'jpeg', 'png', 'webp'];
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowed,
        withData: false,
      );
      if (result == null || result.files.isEmpty) {
        return;
      }
      final path = result.files.first.path;
      if (path == null) return;

      final url = await _repository.uploadImage(path);
      if (!mounted) return;
      setState(() {
        final controller = isLogo ? _logoController : _coverController;
        controller.text = url;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Не удалось загрузить файл: ${friendlyError(error)}'),
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        if (isLogo) {
          _isUploadingLogo = false;
        } else {
          _isUploadingCover = false;
        }
      });
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Укажите название компании')),
      );
      return;
    }
    final logo = _logoController.text.trim();
    final cover = _coverController.text.trim();
    final image = cover.isNotEmpty ? cover : (logo.isNotEmpty ? logo : null);

    setState(() => _isSaving = true);
    try {
      final company = await _repository.updateCompanyProfile(
        title: name,
        image: image,
        logo: logo.isNotEmpty ? logo : null,
        cover: cover.isNotEmpty ? cover : null,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Данные компании обновлены')),
      );
      Navigator.of(context).pop<SadaqaCompany>(company);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(friendlyError(error))));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.controller,
    required this.label,
    required this.hint,
  });

  final TextEditingController controller;
  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        TextField(controller: controller, decoration: _decoration(hint)),
      ],
    );
  }
}

class _ImageField extends StatelessWidget {
  const _ImageField({
    required this.label,
    required this.controller,
    required this.imageUrl,
    required this.onUpload,
    required this.isUploading,
  });

  final String label;
  final TextEditingController controller;
  final String? imageUrl;
  final VoidCallback onUpload;
  final bool isUploading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            _ImagePreview(imageUrl: imageUrl),
            SizedBox(width: 12.w),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: _decoration('Вставьте ссылку или загрузите файл')
                    .copyWith(
                      suffixIcon: IconButton(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onPressed: isUploading ? null : onUpload,
                        icon: isUploading
                            ? SizedBox(
                                width: 16.r,
                                height: 16.r,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.w,
                                ),
                              )
                            : const Icon(Icons.file_upload_outlined),
                      ),
                    ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    return Container(
      width: 72.r,
      height: 72.r,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        image: hasImage
            ? DecorationImage(
                image: NetworkImage(imageUrl!),
                fit: BoxFit.cover,
                onError: (_, __) {},
              )
            : null,
      ),
      child: hasImage
          ? null
          : const Icon(Icons.photo_outlined, color: Color(0xFF9CA3AF)),
    );
  }
}

class _LogoPreview extends StatelessWidget {
  const _LogoPreview({
    required this.imageUrl,
    required this.isUploading,
    required this.fallback,
  });

  final String? imageUrl;
  final bool isUploading;
  final String fallback;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    final trimmed = fallback.trim();
    final initials = trimmed.isNotEmpty ? trimmed[0].toUpperCase() : '?';

    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 36.r,
          backgroundColor: const Color(0xFFE8EEF5),
          backgroundImage: hasImage ? NetworkImage(imageUrl!) : null,
          child: !hasImage
              ? Text(
                  initials,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18.sp,
                    color: Color(0xFF3B82F6),
                  ),
                )
              : null,
        ),
        if (isUploading)
          SizedBox(
            width: 28.r,
            height: 28.r,
            child: CircularProgressIndicator(strokeWidth: 2.w),
          ),
      ],
    );
  }
}

InputDecoration _decoration(String hint) {
  return InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: const Color(0xFFF3F4F6),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: const BorderSide(color: Color(0xFF8D6BFF)),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
  );
}
