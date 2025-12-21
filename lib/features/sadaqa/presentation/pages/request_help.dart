import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:safa_app/features/sadaqa/data/request_help_repository.dart';

class RequestHelpPage extends StatefulWidget {
  const RequestHelpPage({super.key});

  @override
  State<RequestHelpPage> createState() => _RequestHelpPageState();
}

class _RequestHelpPageState extends State<RequestHelpPage> {
  final _repository = RequestHelpRepository();

  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _iinController = TextEditingController();
  final _childrenController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _amountController = TextEditingController();
  final _storyController = TextEditingController();
  final _otherCategoryController = TextEditingController();
  late final List<TextEditingController> _trackedControllers;
  String? _selectedMaterialStatus;
  final List<ReferenceItem> _materialStatuses = [];
  final List<CategoryItem> _categories = [];
  final List<ReferenceItem> _companies = [];
  PlatformFile? _selectedFile;
  bool _isPickingFile = false;
  bool _isLoadingCategories = true;
  bool _isLoadingCompanies = true;
  int? _selectedCategoryId;
  int? _selectedCompanyId;
  bool _isOtherCategory = false;
  int _storyLength = 0;
  bool _isSubmitting = false;
  String? _submitError;
  bool _isLoadingRefs = true;

  @override
  void initState() {
    super.initState();
    _trackedControllers = [
      _firstNameController,
      _lastNameController,
      _ageController,
      _iinController,
      _childrenController,
      _phoneController,
      _emailController,
      _cityController,
      _addressController,
      _amountController,
      _otherCategoryController,
    ];
    for (final controller in _trackedControllers) {
      controller.addListener(_handleFieldChanged);
    }
    _storyController.addListener(_handleStoryChanged);
    _loadMaterialStatuses();
    _loadCategories();
    _loadCompanies();
  }

  @override
  void dispose() {
    _storyController.removeListener(_handleStoryChanged);
    for (final controller in _trackedControllers) {
      controller.removeListener(_handleFieldChanged);
    }
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _iinController.dispose();
    _childrenController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _amountController.dispose();
    _otherCategoryController.dispose();
    _storyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final form = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionCard(
            title: 'Личные данные',
            subtitle:
                'Ваша контактная информация поможет нам подтвердить заявку.',
            child: Column(
              children: [
                _ResponsiveFieldsRow(
                  children: [
                    _LabeledField(
                      label: 'Имя *',
                      child: _RequestTextField(
                        controller: _firstNameController,
                        hintText: 'Введите имя',
                        validator: _requiredValidator,
                      ),
                    ),
                    _LabeledField(
                      label: 'Фамилия *',
                      child: _RequestTextField(
                        controller: _lastNameController,
                        hintText: 'Введите фамилию',
                        validator: _requiredValidator,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _ResponsiveFieldsRow(
                  children: [
                    _LabeledField(
                      label: 'Телефон *',
                      child: _RequestTextField(
                        controller: _phoneController,
                        hintText: '+7 700 123 45 67',
                        keyboardType: TextInputType.phone,
                        validator: _requiredValidator,
                        prefixIcon: Icons.phone_outlined,
                      ),
                    ),
                    _LabeledField(
                      label: 'Электронная почта',
                      child: _RequestTextField(
                        controller: _emailController,
                        hintText: 'you@example.com',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          if (text.isEmpty) return null;
                          final emailRegex = RegExp(
                            r'^[\w\.-]+@[\w\.-]+\.[A-Za-z]{2,}$',
                          );
                          if (!emailRegex.hasMatch(text)) {
                            return 'Введите корректный email';
                          }
                          return null;
                        },
                        prefixIcon: Icons.email_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _ResponsiveFieldsRow(
                  children: [
                    _LabeledField(
                      label: 'Возраст (опционально)',
                      child: _RequestTextField(
                        controller: _ageController,
                        hintText: 'Например, 32',
                        keyboardType: TextInputType.number,
                        validator: _requiredNumberValidator,
                      ),
                    ),
                    _LabeledField(
                      label: 'ИИН (опционально)',
                      child: _RequestTextField(
                        controller: _iinController,
                        hintText: 'ИИН (12 цифр)',
                        keyboardType: TextInputType.number,
                        validator: _requiredValidator,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _ResponsiveFieldsRow(
                  children: [
                    _LabeledField(
                      label: 'Дети в семье (опционально)',
                      child: _RequestTextField(
                        controller: _childrenController,
                        hintText: 'Например, 2',
                        keyboardType: TextInputType.number,
                        validator: _requiredNumberValidator,
                      ),
                    ),
                    _LabeledField(
                      label: 'Материальное положение',
                      child: _MaterialStatusDropdown(
                        isLoading: _isLoadingRefs,
                        statuses: _materialStatuses,
                        value: _selectedMaterialStatus,
                        onChanged: (value) {
                          setState(() => _selectedMaterialStatus = value);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _SectionCard(
            title: 'Местоположение',
            subtitle:
                'Эта информация помогает волонтёрам лучше координировать помощь.',
            child: Column(
              children: [
                _LabeledField(
                  label: 'Город / регион *',
                  child: _RequestTextField(
                    controller: _cityController,
                    hintText: 'Астана, Казахстан',
                    validator: _requiredValidator,
                    prefixIcon: Icons.location_on_outlined,
                  ),
                ),
                const SizedBox(height: 16),
                _LabeledField(
                  label: 'Полный адрес *',
                  child: _RequestTextField(
                    controller: _addressController,
                    hintText: 'Улица, дом, квартира',
                    validator: _requiredValidator,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _SectionCard(
            title: 'Детали запроса',
            subtitle:
                'Опишите ситуацию, чтобы доноры могли понять, чем помочь.',
            child: Column(
              children: [
                _LabeledField(
                  label: 'Категория помощи *',
                  child: _CategoryDropdown(
                    categories: _categories,
                    isLoading: _isLoadingCategories,
                    value: _selectedCategoryId,
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                        final selected = _categories.firstWhere(
                          (item) => item.id == value,
                          orElse: () => const CategoryItem(
                            id: 0,
                            title: '',
                            isOther: false,
                          ),
                        );
                        _isOtherCategory = selected.isOther && value != null;
                      });
                    },
                  ),
                ),
                if (_isOtherCategory) ...[
                  const SizedBox(height: 12),
                  _LabeledField(
                    label: 'Другая категория *',
                    child: _RequestTextField(
                      controller: _otherCategoryController,
                      hintText: 'Опишите категорию',
                      validator: _requiredValidator,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                _LabeledField(
                  label: 'Фонд / компания *',
                  child: _CompanyDropdown(
                    companies: _companies,
                    isLoading: _isLoadingCompanies,
                    value: _selectedCompanyId,
                    onChanged: (value) {
                      setState(() => _selectedCompanyId = value);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _LabeledField(
                  label: 'Необходимая сумма (ТГ)',
                  child: _RequestTextField(
                    controller: _amountController,
                    hintText: '0',
                    keyboardType: TextInputType.number,
                    validator: _optionalNumberValidator,
                    prefixIcon: null,
                  ),
                ),
                const SizedBox(height: 16),
                _LabeledField(
                  label: 'Ваша история *',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RequestTextField(
                        controller: _storyController,
                        hintText: 'Опишите вашу историю как можно подробнее.',
                        maxLines: 6,
                        maxLength: 600,
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$_storyLength / 600 символов',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF8E9BB3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _LabeledField(
                  label: 'Загрузите фото (необязательно)',
                  child: _UploadTile(
                    onTap: _pickFile,
                    onRemove: _selectedFile == null ? null : _clearFile,
                    fileName: _selectedFile?.name,
                    fileSize: _selectedFile?.size,
                    isLoading: _isPickingFile,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _SubmitButton(onPressed: () => _submit(), isLoading: _isSubmitting),
          const SizedBox(height: 18),
          const _FooterNote(),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 24,
        foregroundColor: const Color(0xFF1A2B4F),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Запросить помощь',
              style: theme.textTheme.titleLarge?.copyWith(
                color: const Color(0xFF172B4D),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Расскажите нам больше о вашей ситуации',
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF6B7A90),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_submitError != null) ...[
                        _SubmitError(message: _submitError!),
                        const SizedBox(height: 16),
                      ],
                      const _HeroCard(),
                      const SizedBox(height: 16),
                      const SizedBox(height: 24),
                      form,
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

  void _handleFieldChanged() {
    if (mounted) setState(() {});
  }

  void _handleStoryChanged() {
    setState(() {
      _storyLength = _storyController.text.length;
    });
  }

  Future<void> _loadMaterialStatuses() async {
    try {
      final items = await _repository.fetchMaterialStatuses();
      _materialStatuses
        ..clear()
        ..addAll(items);
      _selectedMaterialStatus = _materialStatuses.isNotEmpty
          ? '${_materialStatuses.first.id}'
          : null;
    } catch (_) {
      _materialStatuses.clear();
      _selectedMaterialStatus = null;
    } finally {
      if (mounted) {
        setState(() => _isLoadingRefs = false);
      }
    }
  }

  Future<void> _loadCategories() async {
    try {
      final items = await _repository.fetchCategories();
      _categories
        ..clear()
        ..addAll(items);
      _selectedCategoryId = null;
      _isOtherCategory = false;
    } catch (_) {
      _categories.clear();
      _selectedCategoryId = null;
      _isOtherCategory = false;
    } finally {
      if (mounted) {
        setState(() => _isLoadingCategories = false);
      }
    }
  }

  Future<void> _loadCompanies() async {
    try {
      final items = await _repository.fetchCompanies();
      _companies
        ..clear()
        ..addAll(items);
      _selectedCompanyId = null;
    } catch (_) {
      _companies.clear();
      _selectedCompanyId = null;
    } finally {
      if (mounted) {
        setState(() => _isLoadingCompanies = false);
      }
    }
  }

  Future<void> _pickFile() async {
    if (_isPickingFile) return;
    setState(() {
      _isPickingFile = true;
      _submitError = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        withData: true,
        type: FileType.custom,
        allowedExtensions: const ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        const maxSizeBytes = 5 * 1024 * 1024;
        if (file.size > maxSizeBytes) {
          setState(() {
            _submitError = 'Файл больше 5 МБ. Выберите меньший файл.';
            _selectedFile = null;
          });
        } else {
          setState(() => _selectedFile = file);
        }
      }
    } catch (error) {
      setState(() {
        _submitError = 'Не удалось выбрать файл: $error';
        _selectedFile = null;
      });
    } finally {
      if (mounted) {
        setState(() => _isPickingFile = false);
      }
    }
  }

  void _clearFile() {
    setState(() {
      _selectedFile = null;
    });
  }

  Future<MultipartFile?> _buildMultipartFile() async {
    final file = _selectedFile;
    if (file == null) return null;
    if (file.bytes != null) {
      return MultipartFile.fromBytes(file.bytes!, filename: file.name);
    }
    if (file.path != null && file.path!.isNotEmpty) {
      return MultipartFile.fromFile(file.path!, filename: file.name);
    }
    return null;
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    if (_categories.isEmpty) {
      setState(() {
        _submitError = 'Категории не загружены. Попробуйте позже.';
      });
      return;
    }
    if (_selectedCategoryId == null) {
      setState(() {
        _submitError = 'Пожалуйста, выберите категорию помощи.';
      });
      return;
    }
    if (_isOtherCategory && _otherCategoryController.text.trim().isEmpty) {
      setState(() {
        _submitError = 'Укажите название другой категории.';
      });
      return;
    }
    if (_selectedMaterialStatus == null || _selectedMaterialStatus!.isEmpty) {
      setState(() {
        _submitError = 'Выберите материальный статус.';
      });
      return;
    }
    if (_companies.isNotEmpty && _selectedCompanyId == null) {
      setState(() {
        _submitError = 'Пожалуйста, выберите фонд/компанию.';
      });
      return;
    }
    final phoneText = _phoneController.text.trim();
    final sanitizedPhone = phoneText.replaceAll(' ', '');
    final phoneRegex = RegExp(r'^[0-9+\-]+$');
    if (!phoneRegex.hasMatch(sanitizedPhone)) {
      setState(() {
        _submitError =
            'Телефон может содержать только цифры, а также символы + или -.';
      });
      return;
    }
    final ageValue = int.tryParse(_ageController.text.trim());
    if (ageValue == null) {
      setState(() {
        _submitError = 'Введите возраст.';
      });
      return;
    }
    final childrenValue = int.tryParse(_childrenController.text.trim());
    if (childrenValue == null) {
      setState(() {
        _submitError = 'Укажите количество детей.';
      });
      return;
    }
    final iinText = _iinController.text.trim();
    if (iinText.isEmpty) {
      setState(() {
        _submitError = 'Введите ИИН.';
      });
      return;
    }
    final iinDigits = iinText.replaceAll(RegExp(r'\D'), '');
    if (iinDigits.length != 12) {
      setState(() {
        _submitError = 'ИИН должен содержать ровно 12 цифр.';
      });
      return;
    }
    final amountText = _amountController.text.trim();
    if (amountText.isNotEmpty && num.tryParse(amountText) == null) {
      setState(() {
        _submitError = 'Укажите сумму числом.';
      });
      return;
    }

    final addressCombined = _cityController.text.trim().isEmpty
        ? _addressController.text.trim()
        : '${_cityController.text.trim()}, ${_addressController.text.trim()}';
    final amountValue = num.tryParse(amountText);

    if (!mounted) return;

    final selectedCompany = _companies
        .firstWhere(
          (item) => item.id == _selectedCompanyId,
          orElse: () => const ReferenceItem(id: 0, title: ''),
        )
        .title;
    final uploadFile = await _buildMultipartFile();
    if (!mounted) return;

    final payload = RequestHelpPayload(
      name: _firstNameController.text.trim(),
      surname: _lastNameController.text.trim(),
      phoneNumber: sanitizedPhone,
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      address: addressCombined,
      whyNeedHelp: _storyController.text.trim(),
      otherCategory: _isOtherCategory
          ? _otherCategoryController.text.trim()
          : null,
      age: ageValue,
      childInFam: childrenValue,
      iin: iinDigits,
      companyName: selectedCompany.isEmpty ? null : selectedCompany,
      materialStatus: int.tryParse(_selectedMaterialStatus ?? ''),
      receivedOtherHelp: false,
      money: amountValue,
      status: null,
      helpCategory: _selectedCategoryId!,
    );

    FocusScope.of(context).unfocus();
    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      final requestId = await _repository.send(payload);
      if (requestId != null && uploadFile != null) {
        await _repository.uploadFile(
          helpRequestId: requestId,
          file: uploadFile,
        );
      }
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _submitError = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ваш запрос отправлен на проверку.')),
      );
      _resetFormFields();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _submitError = error.toString();
      });
    }
  }

  void _resetFormFields() {
    _formKey.currentState?.reset();
    _storyController.clear();
    _amountController.clear();
    _addressController.clear();
    _cityController.clear();
    _emailController.clear();
    _phoneController.clear();
    _lastNameController.clear();
    _firstNameController.clear();
    _ageController.clear();
    _childrenController.clear();
    _iinController.clear();
    _otherCategoryController.clear();

    setState(() {
      _selectedFile = null;
      _storyLength = 0;
      _isOtherCategory = false;
      _selectedCategoryId = null;
      _selectedMaterialStatus = null;
      _selectedCompanyId = null;
      _submitError = null;
    });
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF2EC8A6), Color(0xFF5BC8FF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(41, 158, 135, 0.25),
            offset: Offset(0, 16),
            blurRadius: 36,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.favorite_border,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Каждая история важна',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Опишите вашу ситуацию ясно, чтобы получить помощь быстрее.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadTile extends StatelessWidget {
  const _UploadTile({
    required this.onTap,
    this.onRemove,
    this.fileName,
    this.fileSize,
    this.isLoading = false,
  });
  final VoidCallback onTap;
  final VoidCallback? onRemove;
  final String? fileName;
  final int? fileSize;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final hasFile = (fileName ?? '').isNotEmpty;
    final subtitle = hasFile && fileSize != null
        ? _formatFileSize(fileSize!)
        : 'PNG, JPG до 5 МБ';

    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasFile ? const Color(0xFF2EC8A6) : const Color(0xFFE0E6F1),
            width: hasFile ? 1.6 : 1.2,
          ),
          color: hasFile ? const Color(0xFFE6F8F3) : const Color(0xFFF4F7FC),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: hasFile ? const Color(0xFF2EC8A6) : Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                hasFile
                    ? Icons.insert_drive_file_outlined
                    : Icons.cloud_upload_outlined,
                color: hasFile ? Colors.white : const Color(0xFF2EC8A6),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasFile ? (fileName ?? '') : 'Прикрепите фото',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A2B4F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF6B7A90),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else if (hasFile && onRemove != null)
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.close, color: Color(0xFF2EC8A6)),
              )
            else
              const Icon(Icons.chevron_right, color: Color(0xFF2EC8A6)),
          ],
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.onPressed, required this.isLoading});
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF1EBE92),
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        shadowColor: const Color.fromRGBO(30, 190, 146, 0.4),
        elevation: 6,
      ),
      child: isLoading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              'Отправить запрос',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
    );
  }
}

class _FooterNote extends StatelessWidget {
  const _FooterNote();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      'Мы рассмотрим заявку в течение 24–48 часов и уведомим вас после проверки.',
      textAlign: TextAlign.center,
      style: theme.textTheme.bodySmall?.copyWith(
        color: const Color(0xFF7D8AA5),
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

String? _requiredValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Обязательное поле';
  }
  return null;
}

String? _requiredNumberValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Обязательное поле';
  }
  if (num.tryParse(value.trim()) == null) {
    return 'Введите число';
  }
  return null;
}

String? _optionalNumberValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  if (num.tryParse(value.trim()) == null) {
    return 'Введите число';
  }
  return null;
}

String _formatFileSize(int bytes) {
  const kb = 1024;
  const mb = kb * 1024;
  if (bytes >= mb) {
    return '${(bytes / mb).toStringAsFixed(2)} МБ';
  }
  return '${(bytes / kb).toStringAsFixed(0)} КБ';
}

class _SubmitError extends StatelessWidget {
  const _SubmitError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE8E8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE57373)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFD32F2F)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFFD32F2F), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(26, 43, 79, 0.08),
            offset: Offset(0, 12),
            blurRadius: 24,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: const Color(0xFF1A2B4F),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF6B7A90),
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A2B4F),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _RequestTextField extends StatelessWidget {
  const _RequestTextField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.prefixIcon,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final int maxLines;
  final int? maxLength;
  final FormFieldValidator<String>? validator;
  final IconData? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: const Color(0xFFF4F7FC),
        counterText: '',
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: const Color(0xFF1A2B4F))
            : null,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE0E6F1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF2EC8A6), width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE57373)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE57373)),
        ),
      ),
    );
  }
}

class _MaterialStatusDropdown extends StatelessWidget {
  const _MaterialStatusDropdown({
    required this.statuses,
    required this.value,
    required this.onChanged,
    required this.isLoading,
  });

  final List<ReferenceItem> statuses;
  final String? value;
  final ValueChanged<String?> onChanged;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F7FC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE0E6F1)),
        ),
        child: Row(
          children: const [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Загружаем статусы из бэкенда...'),
          ],
        ),
      );
    }

    if (statuses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF5E8),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFF5D7A8)),
        ),
        child: const Text(
          'Нет данных о материальном статусе из бэкенда. '
          'Вы можете отправить запрос без этого поля.',
          style: TextStyle(color: Color(0xFF9A6B1B), fontSize: 13),
        ),
      );
    }

    return DropdownButtonFormField<String>(
      initialValue: value?.isEmpty == true ? null : value,
      items: statuses
          .map(
            (item) => DropdownMenuItem<String>(
              value: '${item.id}',
              child: Text(item.title),
            ),
          )
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Выберите статус',
        filled: true,
        fillColor: const Color(0xFFF4F7FC),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE0E6F1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF2EC8A6), width: 1.6),
        ),
      ),
      icon: const Icon(
        Icons.keyboard_arrow_down_outlined,
        color: Color(0xFF1A2B4F),
      ),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(18),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  const _CategoryDropdown({
    required this.categories,
    required this.isLoading,
    required this.value,
    required this.onChanged,
  });

  final List<CategoryItem> categories;
  final bool isLoading;
  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F7FC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE0E6F1)),
        ),
        child: Row(
          children: const [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Загружаем категории...'),
          ],
        ),
      );
    }

    if (categories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF5E8),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFF5D7A8)),
        ),
        child: const Text(
          'Нет категорий из бэкенда. '
          'Попробуйте обновить позже.',
          style: TextStyle(color: Color(0xFF9A6B1B), fontSize: 13),
        ),
      );
    }

    return DropdownButtonFormField<int>(
      initialValue: value,
      validator: (val) => val == null ? 'Выберите категорию' : null,
      items: categories
          .map(
            (item) =>
                DropdownMenuItem<int>(value: item.id, child: Text(item.title)),
          )
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Выберите категорию',
        filled: true,
        fillColor: const Color(0xFFF4F7FC),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE0E6F1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF2EC8A6), width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE57373)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE57373)),
        ),
      ),
      icon: const Icon(
        Icons.keyboard_arrow_down_outlined,
        color: Color(0xFF1A2B4F),
      ),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(18),
    );
  }
}

class _CompanyDropdown extends StatelessWidget {
  const _CompanyDropdown({
    required this.companies,
    required this.isLoading,
    required this.value,
    required this.onChanged,
  });

  final List<ReferenceItem> companies;
  final bool isLoading;
  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F7FC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE0E6F1)),
        ),
        child: Row(
          children: const [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Загружаем фонды...'),
          ],
        ),
      );
    }

    if (companies.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF5E8),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFF5D7A8)),
        ),
        child: const Text(
          'Нет компаний из бэкенда. '
          'Вы можете продолжить без выбора.',
          style: TextStyle(color: Color(0xFF9A6B1B), fontSize: 13),
        ),
      );
    }

    return DropdownButtonFormField<int>(
      initialValue: value,
      validator: (val) =>
          companies.isEmpty ? null : (val == null ? 'Выберите фонд' : null),
      items: companies
          .map(
            (item) =>
                DropdownMenuItem<int>(value: item.id, child: Text(item.title)),
          )
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Выберите фонд или компанию',
        filled: true,
        fillColor: const Color(0xFFF4F7FC),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE0E6F1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF2EC8A6), width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE57373)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE57373)),
        ),
      ),
      icon: const Icon(
        Icons.keyboard_arrow_down_outlined,
        color: Color(0xFF1A2B4F),
      ),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(18),
    );
  }
}

class _ResponsiveFieldsRow extends StatelessWidget {
  const _ResponsiveFieldsRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    const spacing = 16.0;
    const breakpoint = 600.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= breakpoint) {
          return Row(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                Expanded(child: children[i]),
                if (i != children.length - 1) SizedBox(width: spacing),
              ],
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i != 0) SizedBox(height: spacing),
              children[i],
            ],
          ],
        );
      },
    );
  }
}
