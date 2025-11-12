import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safa_app/core/localization/app_localizations.dart';
import 'package:safa_app/core/settings/app_settings_cubit.dart';
import 'package:safa_app/core/settings/app_settings_state.dart';
import 'package:safa_app/core/styles/app_colors.dart';
import 'package:safa_app/features/settings/presentation/widgets/settings_header.dart';
import 'package:safa_app/features/settings/presentation/widgets/settings_section.dart';
import 'package:safa_app/features/settings/presentation/widgets/settings_tile.dart';
import 'package:safa_app/features/settings/presentation/widgets/settings_user_card.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocBuilder<AppSettingsCubit, AppSettingsState>(
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
                                context
                                    .read<AppSettingsCubit>()
                                    .toggleDarkMode(value);
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
                              subtitle:
                                  l10n.t('settings.notifications.subtitle'),
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
                                    style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
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
                          title: l10n.t('settings.section.account'),
                          children: [
                            SettingsTile(
                              icon: Icons.person_outline,
                              iconColor: const Color(0xFF22C0A0),
                              title:
                                  l10n.t('settings.account.profile.title'),
                              subtitle: l10n
                                  .t('settings.account.profile.subtitle'),
                              onTap: () {},
                            ),
                            SettingsTile(
                              icon: Icons.history,
                              iconColor: const Color(0xFF6D8BFF),
                              title:
                                  l10n.t('settings.account.history.title'),
                              subtitle:
                                  l10n.t('settings.account.history.subtitle'),
                              onTap: () {},
                            ),
                            SettingsTile(
                              icon: Icons.lock_outline,
                              iconColor: const Color(0xFF2FC58C),
                              title:
                                  l10n.t('settings.account.privacy.title'),
                              subtitle:
                                  l10n.t('settings.account.privacy.subtitle'),
                              onTap: () {},
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
      ),
    );
  }

  Future<void> _showLanguagePicker(
    AppSettingsState settingsState,
    AppLocalizations l10n,
  ) async {
    final locales = AppLocalizations.supportedLocales;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final locale in locales)
                ListTile(
                  title: Text(
                    l10n.t(
                      'settings.language.option.${locale.languageCode}',
                    ),
                  ),
                  trailing: settingsState.locale.languageCode ==
                          locale.languageCode
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    context.read<AppSettingsCubit>().changeLocale(locale);
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        );
      },
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
