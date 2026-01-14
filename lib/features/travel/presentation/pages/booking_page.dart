import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:safa_app/core/styles/app_colors.dart';
import 'package:safa_app/core/utils/error_messages.dart';
import 'package:safa_app/features/travel/data/repositories/travel_repository_impl.dart';
import 'package:safa_app/features/travel/domain/entities/travel_package.dart';
import 'package:safa_app/features/travel/domain/repositories/travel_repository.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key, required this.package});

  final TravelPackage package;

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();
  final TravelRepository _repository = TravelRepositoryImpl();

  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _patronymicController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passportController = TextEditingController();
  final _personNumberController = TextEditingController(text: '1');
  final _dobController = TextEditingController();

  DateTime? _dob;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _patronymicController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passportController.dispose();
    _personNumberController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final initial = _dob ?? DateTime(1990, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dob = picked;
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dob == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Выберите дату рождения')));
      return;
    }

    final tourId = int.tryParse(widget.package.id);
    if (tourId == null || tourId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось определить тур')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final payload = {
        'person_number': int.tryParse(_personNumberController.text) ?? 1,
        'name': _nameController.text.trim(),
        'surname': _surnameController.text.trim(),
        'patronymic': _patronymicController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'passport_number': _passportController.text.trim(),
        'date_of_birth': _dob!.toIso8601String(),
        'tour_id': tourId,
      };

      await _repository.createBooking(payload);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Заявка отправлена'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(friendlyError(error)),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Бронирование тура')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.package.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
              _buildTextField(
                controller: _personNumberController,
                label: 'Количество человек',
                keyboardType: TextInputType.number,
              ),
              _buildTextField(controller: _nameController, label: 'Имя'),
              _buildTextField(controller: _surnameController, label: 'Фамилия'),
              _buildTextField(
                controller: _patronymicController,
                label: 'Отчество',
                isOptional: true,
              ),
              _buildTextField(
                controller: _phoneController,
                label: 'Телефон',
                keyboardType: TextInputType.phone,
              ),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              _buildTextField(
                controller: _passportController,
                label: 'Паспорт',
              ),
              _buildDateField(),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          height: 18.r,
                          width: 18.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.badgeLightBackground,
                            ),
                          ),
                        )
                      : const Text(
                          'Отправить заявку',
                          style: TextStyle(
                            color: AppColors.badgeLightBackground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    bool isOptional = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
        ),
        validator: (value) {
          if (isOptional) return null;
          if (value == null || value.trim().isEmpty) {
            return 'Заполните поле';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDateField() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: TextFormField(
        controller: _dobController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Дата рождения',
          suffixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
        ),
        onTap: _pickDate,
        validator: (_) {
          if (_dob == null) return 'Укажите дату рождения';
          return null;
        },
      ),
    );
  }
}
