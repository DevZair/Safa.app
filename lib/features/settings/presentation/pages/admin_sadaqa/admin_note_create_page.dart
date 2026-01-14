import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safa_app/core/utils/error_messages.dart';
import 'package:safa_app/features/sadaqa/domain/repositories/sadaqa_repository.dart';
import 'package:safa_app/features/sadaqa/domain/utils/media_resolver.dart';

class AdminNoteCreatePage extends StatefulWidget {
  const AdminNoteCreatePage({super.key, required this.repository});

  final SadaqaRepository repository;

  @override
  State<AdminNoteCreatePage> createState() => _AdminNoteCreatePageState();
}

class _AdminNoteCreatePageState extends State<AdminNoteCreatePage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _imageController = TextEditingController();
  String? _noteType;
  final _addressController = TextEditingController();
  final _goalController = TextEditingController();
  final _collectedController = TextEditingController();

  bool _isSaving = false;
  bool _isUploading = false;
  String? _uploadError;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _imageController.dispose();
    _addressController.dispose();
    _goalController.dispose();
    _collectedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = resolveMediaUrl(_imageController.text.trim());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создать заметку'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _onSave,
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
                blurRadius: 20.r,
                offset: Offset(0, 10.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ImagePreview(
                imageUrl: imageUrl,
                isUploading: _isUploading,
                uploadError: _uploadError,
                onPick: _pickAndUploadImage,
              ),
              SizedBox(height: 16.h),
              _NoteTypeSelector(
                value: _noteType,
                onChanged: (value) => setState(() => _noteType = value),
              ),
              SizedBox(height: 12.h),
              _StyledField(
                controller: _titleController,
                label: 'Заголовок',
                hint: 'Введите заголовок',
              ),
              SizedBox(height: 12.h),
              _StyledField(
                controller: _contentController,
                label: 'Контент',
                hint: 'Добавьте описание',
                minLines: 4,
                maxLines: 10,
              ),
              SizedBox(height: 12.h),
              _StyledField(
                controller: _addressController,
                label: 'Адрес',
                hint: 'Адрес/местоположение',
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: _StyledField(
                      controller: _goalController,
                      label: 'Цель (goal_money)',
                      hint: 'Напр. 100000',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _StyledField(
                      controller: _collectedController,
                      label: 'Собрано (collected_money)',
                      hint: 'Напр. 40000',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: _isSaving ? null : _onSave,
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
                    : const Text('Создать'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onSave() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final image = _imageController.text.trim();
    final address = _addressController.text.trim();
    final goal = _goalController.text.trim().isEmpty
        ? null
        : double.tryParse(_goalController.text.trim());
    final collected = _collectedController.text.trim().isEmpty
        ? null
        : double.tryParse(_collectedController.text.trim());

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните заголовок и контент')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final created = await widget.repository.createNote(
        title: title,
        content: content,
        image: image.isNotEmpty ? image : null,
        noteType: _noteType,
        address: address.isNotEmpty ? address : null,
        goalMoney: goal,
        collectedMoney: collected,
      );
      if (!mounted) return;
      Navigator.of(context).pop(created);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(friendlyError(error))));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickAndUploadImage() async {
    if (_isUploading) return;
    setState(() {
      _isUploading = true;
      _uploadError = null;
    });
    try {
      const allowed = ['jpg', 'jpeg', 'png', 'webp'];
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowed,
        withData: false,
      );
      if (result == null || result.files.isEmpty) {
        setState(() => _isUploading = false);
        return;
      }
      final path = result.files.first.path;
      if (path == null) {
        setState(() {
          _isUploading = false;
          _uploadError = 'Не удалось получить путь файла';
        });
        return;
      }
      final ext = path.split('.').last.toLowerCase();
      if (!allowed.contains(ext)) {
        setState(() {
          _isUploading = false;
          _uploadError = 'Поддерживаются только JPG, PNG, WEBP';
        });
        return;
      }
      final uploadedUrl = await widget.repository.uploadImage(path);
      if (!mounted) return;
      setState(() {
        _imageController.text = uploadedUrl;
        _isUploading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isUploading = false;
        _uploadError = '$error';
      });
    }
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({
    required this.imageUrl,
    required this.isUploading,
    required this.onPick,
    this.uploadError,
  });

  final String imageUrl;
  final bool isUploading;
  final VoidCallback onPick;
  final String? uploadError;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: double.infinity,
      height: 220.h,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            padding: EdgeInsets.all(12.r),
            child: Icon(Icons.image_outlined, color: Colors.grey, size: 36.sp),
          ),
          SizedBox(height: 10.h),
          const Text('Добавить изображение'),
        ],
      ),
    );

    final content = imageUrl.isEmpty
        ? placeholder
        : ClipRRect(
            borderRadius: BorderRadius.circular(18.r),
            child: Image.network(
              imageUrl,
              height: 220.h,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => placeholder,
            ),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: isUploading ? null : onPick,
          child: Stack(
            children: [
              content,
              Positioned(
                right: 12.w,
                bottom: 12.h,
                child: ElevatedButton.icon(
                  onPressed: isUploading ? null : onPick,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.7),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  icon: isUploading
                      ? SizedBox(
                          width: 16.r,
                          height: 16.r,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.w,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Icon(Icons.upload, size: 18.sp, color: Colors.white),
                  label: Text(
                    isUploading ? 'Загрузка...' : 'Загрузить',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (uploadError != null) ...[
          SizedBox(height: 6.h),
          Text(
            uploadError!,
            style: TextStyle(color: Colors.red, fontSize: 12.sp),
          ),
        ],
      ],
    );
  }
}

class _NoteTypeSelector extends StatelessWidget {
  const _NoteTypeSelector({required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const options = ['Обычный', 'Средний', 'Срочный'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Тип заметки',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: options.map((option) {
            final selected = value == option;
            return ChoiceChip(
              label: Text(option),
              selected: selected,
              onSelected: (_) => onChanged(option),
              selectedColor: theme.colorScheme.primary.withValues(alpha: 0.15),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _StyledField extends StatelessWidget {
  const _StyledField({
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }
}
