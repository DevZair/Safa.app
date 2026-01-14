import 'package:safa_app/core/styles/app_colors.dart';
import 'package:safa_app/features/travel/data/repositories/tour_repository_impl.dart';
import 'package:safa_app/features/travel/domain/repositories/tour_repository.dart';
import 'package:safa_app/features/travel/domain/entities/tour_category.dart';
import 'package:safa_app/features/travel/domain/entities/tour_guide.dart';
import 'package:safa_app/features/travel/domain/entities/tour.dart';
import 'package:safa_app/core/constants/api_constants.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:safa_app/core/utils/error_messages.dart';

class CreateEditTourPage extends StatefulWidget {
  final Tour? tour;

  const CreateEditTourPage({super.key, this.tour});

  @override
  State<CreateEditTourPage> createState() => _CreateEditTourPageState();
}

class _CreateEditTourPageState extends State<CreateEditTourPage> {
  final _formKey = GlobalKey<FormState>();
  final TourRepository _tourRepository = TourRepositoryImpl();

  // Futures for dropdown data
  late Future<List<TourCategory>> _categoriesFuture;
  late Future<List<TourGuide>> _guidesFuture;

  // Form state
  int? _selectedCategoryId;
  int? _selectedGuideId;
  int? _selectedStatus;
  File? _selectedImage;
  String? _existingImageUrl;

  // Controllers
  late final TextEditingController _locationController;
  late final TextEditingController _priceController;
  late final TextEditingController _departureDateController;
  late final TextEditingController _returnDateController;
  late final TextEditingController _durationController;
  late final TextEditingController _maxPeopleController;
  late bool _isNew;

  bool get _isEditMode => widget.tour != null;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _statusOptions = [
    {'value': 0, 'label': 'Inactive'},
    {'value': 1, 'label': 'Active'},
    {'value': 2, 'label': 'Completed'},
  ];

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _tourRepository.getCategories();
    _guidesFuture = _tourRepository.getGuides();

    final tour = widget.tour;
    _locationController = TextEditingController(text: tour?.location ?? '');
    _priceController = TextEditingController(
      text: tour?.price.toString() ?? '',
    );
    _departureDateController = TextEditingController(
      text: tour?.departureDate.split('T').first ?? '',
    );
    _returnDateController = TextEditingController(
      text: tour?.returnDate.split('T').first ?? '',
    );
    _durationController = TextEditingController(
      text: tour?.duration.toString() ?? '',
    );
    _maxPeopleController = TextEditingController(
      text: tour?.maxPeople.toString() ?? '',
    );
    _isNew = tour?.isNew ?? true;

    _selectedCategoryId = tour?.tourCategoryId;
    _selectedGuideId = tour?.tourGuidId;
    _selectedStatus = tour?.status ?? 1; // Default to Active
    _existingImageUrl = tour?.image;
  }

  @override
  void dispose() {
    _locationController.dispose();
    _priceController.dispose();
    _departureDateController.dispose();
    _returnDateController.dispose();
    _durationController.dispose();
    _maxPeopleController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _selectedImage = File(result.files.single.path!);
      });
    }
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (selectedDate != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(selectedDate);
    }
  }

  Future<void> _saveTour() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Выберите категорию')));
      return;
    }
    if (_selectedGuideId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Выберите гида')));
      return;
    }
    if (_departureDateController.text.isEmpty ||
        _returnDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Укажите даты вылета и возврата')),
      );
      return;
    }
    setState(() => _isLoading = true);

    try {
      String imageUrl = _existingImageUrl ?? '';
      if (_selectedImage != null) {
        imageUrl = await _tourRepository.uploadImage(_selectedImage!);
      }

      if (imageUrl.isEmpty) {
        throw Exception('Image could not be uploaded or found.');
      }

      final tourData = Tour(
        id: widget.tour?.id ?? 0,
        location: _locationController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        tourCompanyId: widget.tour?.tourCompanyId ?? 0, // Not edited in form
        tourCategoryId: _selectedCategoryId!,
        tourGuidId: _selectedGuideId!,
        image: imageUrl,
        departureDate: _departureDateController.text,
        returnDate: _returnDateController.text,
        duration: int.tryParse(_durationController.text) ?? 0,
        isNew: _isNew,
        maxPeople: int.tryParse(_maxPeopleController.text) ?? 0,
        status: _selectedStatus!,
      );

      if (_isEditMode) {
        await _tourRepository.updateTour(widget.tour!.id, tourData);
      } else {
        await _tourRepository.createTour(tourData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tour saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(friendlyError(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? 'Edit Tour' : 'Create Tour')),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([_categoriesFuture, _guidesFuture]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Не удалось загрузить данные'),
                  SizedBox(height: 8.h),
                  Text(
                    friendlyError(snapshot.error),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No data available.'));
          }

          final categories = snapshot.data![0] as List<TourCategory>;
          final guides = snapshot.data![1] as List<TourGuide>;

          return _buildForm(categories, guides);
        },
      ),
    );
  }

  Widget _buildForm(List<TourCategory> categories, List<TourGuide> guides) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Image Picker
            _buildImagePicker(),
            SizedBox(height: 16.h),
            // General Info
            _buildTextField(_locationController, 'Location'),
            _buildTextField(
              _priceController,
              'Price',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            // Dropdowns
            _buildDropdown(
              'Category',
              _selectedCategoryId,
              categories
                  .map(
                    (c) => DropdownMenuItem(value: c.id, child: Text(c.title)),
                  )
                  .toList(),
              (value) => setState(() => _selectedCategoryId = value),
            ),
            _buildDropdown(
              'Guide',
              _selectedGuideId,
              guides
                  .map(
                    (g) =>
                        DropdownMenuItem(value: g.id, child: Text(g.fullName)),
                  )
                  .toList(),
              (value) => setState(() => _selectedGuideId = value),
            ),
            _buildDropdown<int>(
              'Status',
              _selectedStatus,
              _statusOptions.map((s) {
                return DropdownMenuItem<int>(
                  value: s['value'] as int,
                  child: Text(s['label'] as String),
                );
              }).toList(),
              (value) => setState(() => _selectedStatus = value),
            ),
            // Dates
            _buildDateField(_departureDateController, 'Departure Date'),
            _buildDateField(_returnDateController, 'Return Date'),
            // Details
            _buildTextField(
              _durationController,
              'Duration (days)',
              keyboardType: TextInputType.number,
            ),
            _buildTextField(
              _maxPeopleController,
              'Max People',
              keyboardType: TextInputType.number,
            ),
            SwitchListTile(
              title: const Text('Is New?'),
              value: _isNew,
              onChanged: (bool value) => setState(() => _isNew = value),
              contentPadding: EdgeInsets.symmetric(vertical: 8.h),
            ),
            SizedBox(height: 32.h),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                onPressed: _saveTour,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  backgroundColor: AppColors.primary,
                ),
                child: const Text(
                  'Save Tour',
                  style: TextStyle(color: AppColors.badgeLightBackground),
                ),
              ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        Container(
          height: 200.h,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1.w),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: _selectedImage != null
              ? Image.file(_selectedImage!, fit: BoxFit.cover)
              : (_existingImageUrl != null && _existingImageUrl!.isNotEmpty
                    ? Image.network(
                        _existingImageUrl!.startsWith('http')
                            ? _existingImageUrl!
                            : ApiConstants.baseUrl + _existingImageUrl!,
                        fit: BoxFit.cover,
                      )
                    : const Center(child: Text('No Image Selected'))),
        ),
        SizedBox(height: 8.h),
        OutlinedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.camera_alt),
          label: const Text('Select Image'),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty)
            return 'Please enter a value for $label';
          return null;
        },
      ),
    );
  }

  Widget _buildDateField(TextEditingController controller, String label) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        readOnly: true,
        onTap: () => _pickDate(controller),
        validator: (value) {
          if (value == null || value.isEmpty)
            return 'Please select a date for $label';
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown<T>(
    String label,
    T? value,
    List<DropdownMenuItem<T>> items,
    void Function(T?)? onChanged,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: DropdownButtonFormField<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null) return 'Please select a value for $label';
          return null;
        },
      ),
    );
  }
}
