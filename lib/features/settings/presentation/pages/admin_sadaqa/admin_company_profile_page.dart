import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:safa_app/features/sadaqa/data/repositories/sadaqa_repository_impl.dart';
import 'package:safa_app/features/sadaqa/domain/entities/sadaqa_company.dart';
import 'package:safa_app/features/sadaqa/domain/repositories/sadaqa_repository.dart';
import 'package:safa_app/features/sadaqa/domain/utils/media_resolver.dart';

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
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Сохранить'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 18,
                offset: Offset(0, 10),
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Обновите название, логотип и обложку компании. '
                      'Эти данные будут использоваться в карточках и админке.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.7),
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _LabeledField(
                controller: _nameController,
                label: 'Название компании',
                hint: 'Введите название компании',
              ),
              const SizedBox(height: 12),
              _ImageField(
                label: 'Логотип',
                controller: _logoController,
                imageUrl: logoUrl,
                isUploading: _isUploadingLogo,
                onUpload: () => _pickImage(isLogo: true),
              ),
              const SizedBox(height: 12),
              _ImageField(
                label: 'Обложка',
                controller: _coverController,
                imageUrl: coverUrl,
                isUploading: _isUploadingCover,
                onUpload: () => _pickImage(isLogo: false),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
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
        SnackBar(content: Text('Не удалось загрузить файл: $error')),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $error')),
      );
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: _decoration(hint),
        ),
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _ImagePreview(imageUrl: imageUrl),
            const SizedBox(width: 12),
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
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
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
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14),
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
          radius: 36,
          backgroundColor: const Color(0xFFE8EEF5),
          backgroundImage: hasImage ? NetworkImage(imageUrl!) : null,
          child: !hasImage
              ? Text(
                  initials,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Color(0xFF3B82F6),
                  ),
                )
              : null,
        ),
        if (isUploading)
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2),
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
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF8D6BFF)),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 12,
    ),
  );
}
