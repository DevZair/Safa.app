import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safa_app/core/utils/error_messages.dart';
import 'package:safa_app/features/travel/domain/entities/travel_guide.dart';
import 'package:safa_app/features/travel/domain/repositories/tour_repository.dart';

class GuideFormPage extends StatefulWidget {
  const GuideFormPage({super.key, required this.repository, this.initial});

  final TourRepository repository;
  final TravelGuide? initial;

  @override
  State<GuideFormPage> createState() => _GuideFormPageState();
}

class _GuideFormPageState extends State<GuideFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _aboutController = TextEditingController();
  final _ratingController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _firstNameController.text = initial.firstName;
      _lastNameController.text = initial.lastName;
      _aboutController.text = initial.about;
      if (initial.rating != 0) {
        _ratingController.text = initial.rating.toStringAsFixed(1);
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _aboutController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final ratingText = _ratingController.text.trim();
      final rating =
          ratingText.isEmpty ? null : double.tryParse(ratingText) ?? 0.0;
      final isEdit = widget.initial != null;
      final result = isEdit
          ? await widget.repository.updateGuide(
              guideId: widget.initial!.numericId ??
                  int.tryParse(widget.initial!.id) ??
                  0,
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              about: _aboutController.text.trim(),
              rating: rating,
            )
          : await widget.repository.createGuide(
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              about: _aboutController.text.trim(),
              rating: rating,
            );
      if (!mounted) return;
      Navigator.of(context).pop<TravelGuide>(result);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyError(error))),
      );
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Изменить гида' : 'Новый гид'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.r),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(
                  controller: _firstNameController,
                  label: 'Имя',
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Введите имя' : null,
                ),
                SizedBox(height: 14.h),
                _buildTextField(
                  controller: _lastNameController,
                  label: 'Фамилия',
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Введите фамилию' : null,
                ),
                SizedBox(height: 14.h),
                _buildTextField(
                  controller: _aboutController,
                  label: 'Описание',
                  maxLines: 3,
                ),
                SizedBox(height: 14.h),
                _buildTextField(
                  controller: _ratingController,
                  label: 'Рейтинг (0-5)',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    final parsed = double.tryParse(value.trim());
                    if (parsed == null) return 'Введите число';
                    if (parsed < 0 || parsed > 5) return 'Диапазон 0-5';
                    return null;
                  },
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: _isSubmitting
                        ? SizedBox(
                            width: 18.r,
                            height: 18.r,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.w,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.onPrimary,
                              ),
                            ),
                          )
                        : Text(isEdit ? 'Сохранить изменения' : 'Сохранить'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
    );
  }
}
