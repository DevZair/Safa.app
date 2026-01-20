import 'package:safa_app/core/localization/app_localizations.dart';
import 'package:safa_app/core/settings/app_settings_cubit.dart';
import 'package:safa_app/core/settings/app_settings_state.dart';
import 'package:safa_app/core/styles/app_colors.dart';
import 'package:safa_app/core/service/db_service.dart';
import 'package:safa_app/core/utils/error_messages.dart';
import 'package:safa_app/features/settings/data/repositories/admin_auth_repository_impl.dart';
import 'package:safa_app/features/settings/domain/repositories/admin_auth_repository.dart';
import 'package:safa_app/features/settings/domain/entities/admin_login_result.dart';
import 'package:safa_app/features/settings/presentation/pages/admin_sadaqa/admin_panel_page.dart';
import 'package:safa_app/features/settings/presentation/pages/admin_tour/admin_panel_page.dart';
import 'package:safa_app/features/settings/presentation/pages/super_admin/super_admin_panel_page.dart';
import 'package:safa_app/features/settings/presentation/widgets/admin_sheet.dart';
import 'package:safa_app/features/settings/presentation/widgets/settings_header.dart';
import 'package:safa_app/features/settings/presentation/widgets/settings_section.dart';
import 'package:safa_app/features/settings/presentation/widgets/settings_tile.dart';
import 'package:safa_app/features/settings/presentation/widgets/settings_user_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  late final TextEditingController _adminLoginController;
  late final TextEditingController _adminPasswordController;
  final AdminAuthRepository _adminRepository = AdminAuthRepositoryImpl();
  bool _isAdminSubmitting = false;
  AdminLoginResult? _lastLoginResult;

  static const _languageFlags = {'ru': '🇷🇺', 'kk': '🇰🇿', 'uz': '🇺🇿'};

  @override
  void initState() {
    super.initState();
    _adminLoginController = TextEditingController();
    _adminPasswordController = TextEditingController();
    _syncAdminFields(context.read<AppSettingsCubit>().state);
  }

  @override
  void dispose() {
    _adminLoginController.dispose();
    _adminPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocConsumer<AppSettingsCubit, AppSettingsState>(
        listenWhen: (previous, current) =>
            previous.adminLogin != current.adminLogin ||
            previous.adminPassword != current.adminPassword,
        listener: (context, settingsState) {
          _syncAdminFields(settingsState);
        },
        builder: (context, settingsState) {
          final l10n = context.l10n;
          final currentLanguageLabel = l10n.t(
            'settings.language.option.${settingsState.locale.languageCode}',
          );
          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 32.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SettingsHeader(
                      icon: Icons.settings_outlined,
                      title: l10n.t('settings.header.title'),
                      subtitle: l10n.t('settings.header.subtitle'),
                    ),
                    Positioned(
                      left: 24.w,
                      right: 24.w,
                      bottom: -(48.h),
                      child: SettingsUserCard(
                        name: l10n.t('settings.user.name'),
                        email: l10n.t('settings.user.email'),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 72.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SettingsSection(
                        title: l10n.t('settings.section.preferences'),
                        children: [
                          SettingsSwitchTile(
                            icon: Icons.notifications_active_outlined,
                            iconColor: const Color(0xFF22B573),
                            title: l10n.t('settings.notifications.title'),
                            subtitle: l10n.t('settings.notifications.subtitle'),
                            value: _notificationsEnabled,
                            onChanged: (value) {
                              setState(() => _notificationsEnabled = value);
                            },
                          ),
                          SettingsTile(
                            icon: Icons.language_outlined,
                            iconColor: const Color(0xFF3BA7F2),
                            title: l10n.t('settings.language.title'),
                            subtitle: l10n.t('settings.language.subtitle'),
                            onTap: () =>
                                _showLanguagePicker(settingsState, l10n),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  currentLanguageLabel,
                                  style:
                                      Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ) ??
                                      const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                SizedBox(width: 8.w),
                                const Icon(
                                  Icons.chevron_right,
                                  color: AppColors.iconColor,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 28.h),
                      SettingsSection(
                        title: l10n.t('settings.section.admin'),
                        children: [
                          SettingsTile(
                            icon: Icons.admin_panel_settings_outlined,
                            iconColor: const Color(0xFFF25F5C),
                            title: l10n.t('settings.section.admin'),
                            subtitle: l10n.t('settings.admin.subtitle'),
                            onTap: () => _handleAdminEntry(l10n),
                          ),
                        ],
                      ),
                      SizedBox(height: 28.h),
                      SettingsSection(
                        title: l10n.t('settings.section.account'),
                        children: [
                          SettingsTile(
                            icon: Icons.lock_outline,
                            iconColor: const Color(0xFF2FC58C),
                            title: l10n.t('settings.account.privacy.title'),
                            subtitle: l10n.t(
                              'settings.account.privacy.subtitle',
                            ),
                            onTap: () async {
                              final Uri url = Uri.parse(
                                "https://safa-app.netlify.app",
                              );

                              final bool supported = await canLaunchUrl(url);
                              if (!supported) {
                                return;
                              }

                              await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showLanguagePicker(
    AppSettingsState settingsState,
    AppLocalizations l10n,
  ) async {
    final locales = AppLocalizations.supportedLocales;
    Locale tempLocale = settingsState.locale;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        final surface = theme.colorScheme.surface;
        final highlight = theme.colorScheme.primary;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
            ),
            padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 32.h),
            child: StatefulBuilder(
              builder: (context, setModalState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 42.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.2,
                          ),
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 18.h),
                    Text(
                      l10n.t('settings.language.title'),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    for (final locale in locales) ...[
                      _LanguageOptionTile(
                        label: l10n.t(
                          'settings.language.option.${locale.languageCode}',
                        ),
                        flag: _languageFlags[locale.languageCode] ?? '🌐',
                        selected:
                            tempLocale.languageCode == locale.languageCode,
                        onTap: () {
                          setModalState(() => tempLocale = locale);
                        },
                      ),
                      SizedBox(height: 12.h),
                    ],
                    SizedBox(height: 4.h),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: highlight,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                      ),
                      onPressed: () {
                        context.read<AppSettingsCubit>().changeLocale(
                          tempLocale,
                        );
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        l10n.t('settings.language.save'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _syncAdminFields(AppSettingsState settingsState) {
    if (_adminLoginController.text != settingsState.adminLogin) {
      _adminLoginController.text = settingsState.adminLogin;
    }
    if (_adminPasswordController.text != settingsState.adminPassword) {
      _adminPasswordController.text = settingsState.adminPassword;
    }
  }

  Future<void> _handleAdminEntry(AppLocalizations l10n) async {
    final hasTokens =
        DBService.accessToken.isNotEmpty ||
        DBService.tourAccessToken.isNotEmpty ||
        DBService.superAdminAccessToken.isNotEmpty;
    if (hasTokens) {
      final relogin = await _askReloginOrContinue();
      if (relogin == true) {
        DBService.accessToken = '';
        DBService.refreshToken = '';
        DBService.tourAccessToken = '';
        DBService.tourRefreshToken = '';
        _clearSuperAdminTokens();
        await _openAdminSheet(l10n);
      } else {
        await _openAdminArea(
          _adminLoginController.text.trim().isNotEmpty
              ? _adminLoginController.text.trim()
              : null,
        );
      }
      return;
    }
    await _openAdminSheet(l10n);
  }

  Future<bool?> _askReloginOrContinue() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Админка'),
          content: const Text(
            'Вы уже вошли. Продолжить с текущими данными или войти заново?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Продолжить'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Войти заново'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openAdminSheet(AppLocalizations l10n) async {
    final loginSnapshot = _adminLoginController.text.trim();
    final success = await showAdminSheet(
      context: context,
      l10n: l10n,
      loginController: _adminLoginController,
      passwordController: _adminPasswordController,
      onLoginChanged: (value) =>
          context.read<AppSettingsCubit>().updateAdminLogin(value),
      onPasswordChanged: (value) =>
          context.read<AppSettingsCubit>().updateAdminPassword(value),
      onSubmit: _handleAdminSubmit,
    );
    if (success && mounted) {
      await _openAdminArea(loginSnapshot.isNotEmpty ? loginSnapshot : null);
    }
  }

  Future<bool> _handleAdminSubmit() async {
    if (_isAdminSubmitting) return false;
    final login = _adminLoginController.text.trim();
    final password = _adminPasswordController.text.trim();
    if (login.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Введите логин и пароль')));
      return false;
    }
    setState(() => _isAdminSubmitting = true);
    try {
      final result = await _adminRepository.login(
        login: login,
        password: password,
      );
      _lastLoginResult = result;
      if (!mounted) return true;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Успешный вход')));
      return result.hasAnySuccess;
    } catch (error) {
      if (!mounted) return false;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(friendlyError(error))));
      return false;
    } finally {
      if (mounted) {
        setState(() => _isAdminSubmitting = false);
      }
    }
  }

  void _clearSuperAdminTokens() {
    DBService.superAdminAccessToken = '';
    DBService.superAdminRefreshToken = '';
  }

  Future<void> _openAdminArea(String? companyName) async {
    final result = _lastLoginResult;
    final hasSadaqa =
        result?.sadaqaSuccess == true || DBService.accessToken.isNotEmpty;
    final hasTour =
        result?.tourSuccess == true || DBService.tourAccessToken.isNotEmpty;
    final hasSuperAdmin =
        result?.superAdminSuccess == true ||
        DBService.superAdminAccessToken.isNotEmpty;

    if (!hasSadaqa && !hasTour && !hasSuperAdmin) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Сначала выполните вход')));
      return;
    }

    if (hasSuperAdmin && (hasSadaqa || hasTour)) {
      await _chooseAdminDestination(companyName);
      return;
    }

    if (hasSuperAdmin) {
      await _openSuperAdminPanel();
      return;
    }

    if (hasSadaqa) {
      await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (_) => AdminPanelPage(companyName: companyName),
        ),
      );
      return;
    }

    await Navigator.of(
      context,
      rootNavigator: true,
    ).push(MaterialPageRoute(builder: (_) => const TourAdminPanelPage()));
  }

  Future<void> _chooseAdminDestination(String? companyName) async {
    final l10n = context.l10n;
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
            left: 16.w,
            right: 16.w,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24.r),
            ),
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.t('settings.section.admin'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 12.h),
                ListTile(
                  leading: const Icon(Icons.stars_outlined),
                  title: Text(l10n.t('settings.superAdmin.title')),
                  subtitle: Text(l10n.t('settings.superAdmin.subtitle')),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _openSuperAdminPanel();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings_outlined),
                  title: Text(l10n.t('settings.admin.company.title')),
                  subtitle: Text(l10n.t('settings.admin.company.subtitle')),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _openCompanyAdmin(companyName);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openCompanyAdmin(String? companyName) async {
    final result = _lastLoginResult;
    final hasSadaqa =
        result?.sadaqaSuccess == true || DBService.accessToken.isNotEmpty;

    if (hasSadaqa) {
      await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (_) => AdminPanelPage(companyName: companyName),
        ),
      );
      return;
    }

    await Navigator.of(
      context,
      rootNavigator: true,
    ).push(MaterialPageRoute(builder: (_) => const TourAdminPanelPage()));
  }

  Future<void> _openSuperAdminPanel() async {
    await Navigator.of(
      context,
      rootNavigator: true,
    ).push(MaterialPageRoute(builder: (_) => const SuperAdminPanelPage()));
  }
}

class _LanguageOptionTile extends StatelessWidget {
  const _LanguageOptionTile({
    required this.label,
    required this.flag,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String flag;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withValues(alpha: 0.2);
    final background = selected
        ? theme.colorScheme.primary.withValues(alpha: 0.12)
        : theme.colorScheme.surface;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: borderColor, width: 2.w),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 18.r,
                    offset: Offset(0, 10.h),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Text(flag, style: TextStyle(fontSize: 24.sp)),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check_circle, color: theme.colorScheme.primary)
            else
              Icon(
                Icons.circle_outlined,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
          ],
        ),
      ),
    );
  }
}
