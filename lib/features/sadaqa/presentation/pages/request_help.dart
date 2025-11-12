// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class RequestHelpPage extends StatefulWidget {
  const RequestHelpPage({super.key});

  @override
  State<RequestHelpPage> createState() => _RequestHelpPageState();
}

class _RequestHelpPageState extends State<RequestHelpPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _amountController = TextEditingController();
  final _storyController = TextEditingController();

  final List<String> _categories = const [
    'Медицинская помощь',
    'Образование',
    'Чрезвычайная помощь',
    'Продовольственная помощь',
    'Жильё',
  ];

  String? _selectedCategory;
  int _storyLength = 0;

  @override
  void initState() {
    super.initState();
    _storyController.addListener(_handleStoryChanged);
  }

  @override
  void dispose() {
    _storyController.removeListener(_handleStoryChanged);
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _amountController.dispose();
    _storyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _HeroCard(),
                      const SizedBox(height: 28),
                      Form(
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
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          prefixIcon: Icons.email_outlined,
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
                                    child: _RequestDropdown(
                                      value: _selectedCategory,
                                      hintText: 'Выберите категорию',
                                      items: _categories,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedCategory = value;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _LabeledField(
                                    label: 'Необходимая сумма (ТГ) *',
                                    child: _RequestTextField(
                                      controller: _amountController,
                                      hintText: '0',
                                      keyboardType: TextInputType.number,
                                      validator: _requiredValidator,
                                      prefixIcon: Icons.attach_money,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _LabeledField(
                                    label: 'Ваша история *',
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _RequestTextField(
                                          controller: _storyController,
                                          hintText:
                                              'Опишите вашу историю как можно подробнее.',
                                          maxLines: 6,
                                          maxLength: 600,
                                          validator: _requiredValidator,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '$_storyLength / 600 символов',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: const Color(0xFF8E9BB3),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _LabeledField(
                                    label: 'Загрузите фото (необязательно)',
                                    child: _UploadTile(onTap: () {}),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),
                            _SubmitButton(onPressed: _submit),
                            const SizedBox(height: 18),
                            const _FooterNote(),
                          ],
                        ),
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

  void _handleStoryChanged() {
    setState(() {
      _storyLength = _storyController.text.length;
    });
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ваш запрос отправлен на проверку.')),
    );
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
  const _UploadTile({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF2EC8A6), width: 1.4),
          color: const Color(0xFFE6F8F3),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.cloud_upload_outlined,
                color: Color(0xFF2EC8A6),
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Прикрепите фото',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A2B4F),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'PNG, JPG до 5 МБ',
                    style: TextStyle(color: Color(0xFF6B7A90), fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF2EC8A6)),
          ],
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF1EBE92),
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        shadowColor: const Color.fromRGBO(30, 190, 146, 0.4),
        elevation: 6,
      ),
      child: const Text(
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

class _RequestDropdown extends StatelessWidget {
  const _RequestDropdown({
    required this.items,
    required this.onChanged,
    required this.hintText,
    this.value,
  });

  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String hintText;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map(
            (item) => DropdownMenuItem<String>(value: item, child: Text(item)),
          )
          .toList(),
      onChanged: onChanged,
      validator: _requiredValidator,
      decoration: InputDecoration(
        hintText: hintText,
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
