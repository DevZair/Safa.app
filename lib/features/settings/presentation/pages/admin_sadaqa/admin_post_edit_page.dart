import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safa_app/core/utils/error_messages.dart';
import 'package:safa_app/features/sadaqa/domain/entities/sadaqa_post.dart';
import 'package:safa_app/features/sadaqa/domain/repositories/sadaqa_repository.dart';
import 'package:safa_app/features/sadaqa/domain/utils/media_resolver.dart';

class AdminPostEditPage extends StatefulWidget {
  const AdminPostEditPage({
    super.key,
    required this.post,
    required this.repository,
  });

  final SadaqaPost post;
  final SadaqaRepository repository;

  @override
  State<AdminPostEditPage> createState() => _AdminPostEditPageState();
}

class _AdminPostEditPageState extends State<AdminPostEditPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _imageController;
  bool _isSaving = false;
  bool _isUploading = false;
  String? _uploadError;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post.title);
    _contentController = TextEditingController(text: widget.post.content);
    _imageController = TextEditingController(text: widget.post.image);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = resolveMediaUrl(_imageController.text.trim());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактировать пост'),
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
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Заголовок'),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Контент'),
              minLines: 4,
              maxLines: 10,
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onSave() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final image = _imageController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните заголовок и контент')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final updated = await widget.repository.updatePost(
        postId: widget.post.id,
        title: title,
        content: content,
        image: image.isNotEmpty ? image : null,
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
