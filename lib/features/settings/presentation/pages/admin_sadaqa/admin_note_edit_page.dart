import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safa_app/core/utils/error_messages.dart';
import 'package:safa_app/features/sadaqa/domain/entities/sadaqa_post.dart';
import 'package:safa_app/features/sadaqa/domain/repositories/sadaqa_repository.dart';
import 'package:safa_app/features/sadaqa/domain/utils/media_resolver.dart';

class AdminNoteEditPage extends StatefulWidget {
  const AdminNoteEditPage({
    super.key,
    required this.note,
    required this.repository,
  });

  final SadaqaPost note;
  final SadaqaRepository repository;

  @override
  State<AdminNoteEditPage> createState() => _AdminNoteEditPageState();
}

class _AdminNoteEditPageState extends State<AdminNoteEditPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _imageController;
  late int _status;
  String? _noteType;
  final _addressController = TextEditingController();
  final _goalController = TextEditingController();
  final _collectedController = TextEditingController();
  bool _isSaving = false;
  bool _isUploading = false;
  String? _uploadError;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _imageController = TextEditingController(text: widget.note.image);
    _status = widget.note.status;
    _noteType = widget.note.noteType;
    _addressController.text = widget.note.address ?? '';
    _goalController.text = widget.note.goalMoney != null
        ? '${widget.note.goalMoney}'
        : '';
    _collectedController.text = widget.note.collectedMoney != null
        ? '${widget.note.collectedMoney}'
        : '';
  }

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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактировать заметку'),
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
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.r),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(18.r),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x12000000),
                        blurRadius: 22.r,
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
                      SizedBox(height: 18.h),
                      Text(
                        'Детали заметки',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      _buildInputField(
                        label: 'Заголовок',
                        hint: 'Название заметки',
                        controller: _titleController,
                      ),
                      SizedBox(height: 12.h),
                      _buildInputField(
                        label: 'Контент',
                        hint: 'Подробности, которые нужно сохранить',
                        controller: _contentController,
                        minLines: 4,
                        maxLines: 10,
                      ),
                      SizedBox(height: 12.h),
                      _StatusSelector(
                        value: _status,
                        onChanged: (value) => setState(() => _status = value),
                      ),
                      SizedBox(height: 12.h),
                      _NoteTypeSelector(
                        value: _noteType,
                        onChanged: (value) => setState(() => _noteType = value),
                      ),
                      SizedBox(height: 12.h),
                      _buildInputField(
                        label: 'Адрес',
                        hint: 'Адрес/местоположение',
                        controller: _addressController,
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInputField(
                              label: 'Цель (goal_money)',
                              hint: 'Напр. 100000',
                              controller: _goalController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildInputField(
                              label: 'Собрано (collected_money)',
                              hint: 'Напр. 40000',
                              controller: _collectedController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
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
                          elevation: 0,
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
                            : const Text('Сохранить'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
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
      final updated = await widget.repository.updateNote(
        noteId: widget.note.id,
        title: title,
        content: content,
        image: image.isNotEmpty ? image : null,
        status: _status,
        noteType: _noteType,
        address: address.isNotEmpty ? address : null,
        goalMoney: goal,
        collectedMoney: collected,
      );
      if (!mounted) return;
      Navigator.of(context).pop(updated);
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

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int minLines = 1,
    int maxLines = 1,
    IconData? icon,
    TextInputType? keyboardType,
  }) {
    final theme = Theme.of(context);
    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(
        color: theme.colorScheme.outline.withValues(alpha: 0.14),
        width: 1.w,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
          ),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          minLines: minLines,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.55,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 14.h,
            ),
            prefixIcon: icon == null
                ? null
                : Icon(
                    icon,
                    color: theme.colorScheme.primary.withValues(alpha: 0.7),
                  ),
            border: baseBorder,
            enabledBorder: baseBorder,
            focusedBorder: baseBorder.copyWith(
              borderSide: BorderSide(
                color: theme.colorScheme.primary.withValues(alpha: 0.8),
                width: 1.6.w,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusSelector extends StatelessWidget {
  const _StatusSelector({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  static const _options = [
    _StatusOption(value: 0, label: 'Активный'),
    _StatusOption(value: 1, label: 'Неактивный'),
    _StatusOption(value: 2, label: 'Архив'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Статус',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: _options.map((option) {
            final selected = option.value == value;
            return ChoiceChip(
              label: Text(option.label),
              selected: selected,
              onSelected: (_) => onChanged(option.value),
              selectedColor: theme.colorScheme.primary.withValues(alpha: 0.15),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _StatusOption {
  const _StatusOption({required this.value, required this.label});
  final int value;
  final String label;
}

class _NoteTypeSelector extends StatelessWidget {
  const _NoteTypeSelector({required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String> onChanged;

  static const _options = ['Обычный', 'Средний', 'Срочный'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Тип заметки',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: _options.map((option) {
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
