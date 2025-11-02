import 'package:flutter/material.dart';
import 'package:safa_app/core/styles/app_colors.dart';
import 'package:safa_app/core/styles/app_icon.dart';
import 'package:safa_app/features/sadaqa/presentation/pages/sadaqa_page.dart';
import 'package:safa_app/features/settings/presentation/pages/settings_page.dart';
import 'package:safa_app/features/travel/presentation/pages/travel_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  static const _pages = [SadaqaPage(), TravelPage(), SettingsPage()];

  static final _destinations = [
    const NavigationDestination(
      icon: Icon(Icons.favorite_outline),
      selectedIcon: Icon(Icons.favorite, color: AppColors.primary),
      label: 'Sadaqa',
    ),
    NavigationDestination(
      icon: AppIcon(appIcons['travel']!, color: Colors.grey),
      selectedIcon: AppIcon(appIcons['travel']!, color: AppColors.primary),
      label: 'Travel',
    ),
    NavigationDestination(
      icon: AppIcon(appIcons['settings']!, color: Colors.grey),
      selectedIcon: AppIcon(appIcons['settings']!, color: AppColors.primary),
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _selectedIndex, children: _pages),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: Color(0xFFE0E0E0), width: 1),
          ),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            labelTextStyle: WidgetStateProperty.all(
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          child: NavigationBar(
            backgroundColor: Colors.white,
            indicatorColor: AppColors.primary.withAlpha(31),
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) =>
                setState(() => _selectedIndex = index),
            destinations: _destinations,
          ),
        ),
      ),
    );
  }
}
