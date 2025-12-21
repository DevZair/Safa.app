import 'package:go_router/go_router.dart';
import 'package:safa_app/core/localization/app_localizations.dart';
import 'package:safa_app/core/navigation/app_router.dart';
import 'package:safa_app/core/settings/app_settings_cubit.dart';
import 'package:safa_app/core/settings/app_settings_state.dart';
import 'package:safa_app/core/styles/app_colors.dart';
import 'package:safa_app/features/settings/data/admin_auth_repository.dart';
import 'package:safa_app/features/settings/presentation/widgets/settings_header.dart';
import 'package:safa_app/features/settings/presentation/widgets/settings_section.dart';
import 'package:safa_app/features/settings/presentation/widgets/settings_tile.dart';
import 'package:safa_app/features/settings/presentation/widgets/settings_user_card.dart';
import 'package:safa_app/features/settings/presentation/widgets/admin_sheet.dart';
import 'package:safa_app/features/settings/presentation/pages/admin/admin_panel_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  final _adminRepository = AdminAuthRepository();
  bool _isAdminSubmitting = false;

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
            padding: const EdgeInsets.only(bottom: 32),
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
                      left: 24,
                      right: 24,
                      bottom: -48,
                      child: SettingsUserCard(
                        name: l10n.t('settings.user.name'),
                        email: l10n.t('settings.user.email'),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 72),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SettingsSection(
                        title: l10n.t('settings.section.appearance'),
                        children: [
                          SettingsSwitchTile(
                            icon: Icons.dark_mode_outlined,
                            iconColor: const Color(0xFF4C6EF5),
                            title: l10n.t('settings.theme.title'),
                            subtitle: l10n.t('settings.theme.subtitle'),
                            value: settingsState.isDarkMode,
                            onChanged: (value) {
                              context.read<AppSettingsCubit>().toggleDarkMode(
                                value,
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
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
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.chevron_right,
                                  color: AppColors.iconColor,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      SettingsSection(
                        title: l10n.t('settings.section.admin'),
                        children: [
                          SettingsTile(
                            icon: Icons.admin_panel_settings_outlined,
                            iconColor: const Color(0xFFF25F5C),
                            title: l10n.t('settings.section.admin'),
                            subtitle: l10n.t('settings.admin.subtitle'),
                            onTap: () => _openAdminSheet(l10n),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      SettingsSection(
                        title: l10n.t('settings.section.account'),
                        children: [
                          SettingsTile(
                            icon: Icons.person_outline,
                            iconColor: const Color(0xFF22C0A0),
                            title: l10n.t('settings.account.profile.title'),
                            subtitle: l10n.t(
                              'settings.account.profile.subtitle',
                            ),
                            onTap: () {},
                          ),
                          SettingsTile(
                            icon: Icons.history,
                            iconColor: const Color(0xFF6D8BFF),
                            title: l10n.t('settings.account.history.title'),
                            subtitle: l10n.t(
                              'settings.account.history.subtitle',
                            ),
                            onTap: () {
                              context.pushNamed(AppRoute.settingsHistory.name);
                            },
                          ),
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
                      const SizedBox(height: 28),
                      SettingsSection(
                        title: l10n.t('settings.section.support'),
                        children: [
                          SettingsTile(
                            icon: Icons.help_outline,
                            iconColor: const Color(0xFF50A6B8),
                            title: l10n.t('settings.support.title'),
                            subtitle: l10n.t('settings.support.subtitle'),
                            onTap: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      _LogoutCard(
                        label: l10n.t('settings.logout'),
                        onPressed: () {},
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
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: StatefulBuilder(
              builder: (context, setModalState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.2,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      l10n.t('settings.language.title'),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 24),
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
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 4),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: highlight,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
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
      _clearAdminInputs();
      await _openAdminPanel(l10n, loginSnapshot.isNotEmpty ? loginSnapshot : null);
    }
  }

  Future<bool> _handleAdminSubmit() async {
    if (_isAdminSubmitting) return false;
    final login = _adminLoginController.text.trim();
    final password = _adminPasswordController.text.trim();
    if (login.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите логин и пароль')),
      );
      return false;
    }
    setState(() => _isAdminSubmitting = true);
    try {
      await _adminRepository.login(login: login, password: password);
      if (!mounted) return true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Успешный вход')),
      );
      
      return true;
    } catch (error) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка входа: $error')),
      );
      return false;
    } finally {
      if (mounted) {
        setState(() => _isAdminSubmitting = false);
      }
    }
  }

  void _clearAdminInputs() {
    _adminLoginController.clear();
    _adminPasswordController.clear();
    context.read<AppSettingsCubit>()
      ..updateAdminLogin('')
      ..updateAdminPassword('');
  }

  Future<void> _openAdminPanel(AppLocalizations l10n, String? companyName) {
    return Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => AdminPanelPage(
          companyName: companyName,
        ),
      ),
    );
  }
}

class _LogoutCard extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const _LogoutCard({required this.onPressed, required this.label});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(26),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout, color: Color(0xFFE53935)),
              const SizedBox(width: 10),
              Text(
                label,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFE53935),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
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
