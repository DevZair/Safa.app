import 'package:flutter/material.dart';
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
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF4F6FB);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  const SettingsHeader(
                    icon: Icons.settings_outlined,
                    title: 'Настройки',
                    subtitle: 'Настройте приложение по своему удобству',
                  ),
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: -48,
                    child: SettingsUserCard(
                      name: 'Гость',
                      email: 'guest@safa.app',
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
                      title: 'Внешний вид',
                      children: [
                        SettingsSwitchTile(
                          icon: Icons.dark_mode_outlined,
                          iconColor: const Color(0xFF4C6EF5),
                          title: 'Темный режим',
                          subtitle: 'Переключиться на темную тему',
                          value: _isDarkMode,
                          onChanged: (value) {
                            setState(() => _isDarkMode = value);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    SettingsSection(
                      title: 'Предпочтения',
                      children: [
                        SettingsSwitchTile(
                          icon: Icons.notifications_active_outlined,
                          iconColor: const Color(0xFF22B573),
                          title: 'Уведомления',
                          subtitle: 'Включить push-уведомления',
                          value: _notificationsEnabled,
                          onChanged: (value) {
                            setState(() => _notificationsEnabled = value);
                          },
                        ),
                        SettingsTile(
                          icon: Icons.language_outlined,
                          iconColor: const Color(0xFF3BA7F2),
                          title: 'Язык',
                          subtitle: 'Изменить язык приложения',
                          onTap: () {},
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'English',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade800,
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
                      title: 'Учетная запись',
                      children: [
                        SettingsTile(
                          icon: Icons.person_outline,
                          iconColor: const Color(0xFF22C0A0),
                          title: 'Профиль',
                          subtitle: 'Редактировать профиль',
                          onTap: () {},
                        ),
                        SettingsTile(
                          icon: Icons.history,
                          iconColor: const Color(0xFF6D8BFF),
                          title: 'История садакы',
                          subtitle: 'Просмотреть ваши прошлые садакы',
                          onTap: () {},
                        ),
                        SettingsTile(
                          icon: Icons.lock_outline,
                          iconColor: const Color(0xFF2FC58C),
                          title: 'Конфиденциальность и безопасность',
                          subtitle: 'Управление настройками конфиденциальности',
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    SettingsSection(
                      title: 'Support',
                      children: [
                        SettingsTile(
                          icon: Icons.help_outline,
                          iconColor: const Color(0xFF50A6B8),
                          title: 'Помощь и поддержка',
                          subtitle: 'Получить помощь с приложением',
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    _LogoutCard(onPressed: () {}),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutCard extends StatelessWidget {
  final VoidCallback onPressed;

  const _LogoutCard({required this.onPressed});

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
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout, color: Color(0xFFE53935)),
              const SizedBox(width: 10),
              Text(
                'Выйти',
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
