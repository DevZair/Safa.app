import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:safa_app/core/localization/app_localizations.dart';
import 'package:safa_app/core/styles/app_colors.dart';
import 'package:safa_app/core/styles/app_icon.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  List<NavigationDestination> _buildDestinations(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final mutedIcon =
        theme.colorScheme.onSurface.withValues(alpha: 0.6);
    return [
      NavigationDestination(
        icon: Icon(Icons.favorite_outline, color: mutedIcon),
        selectedIcon: const Icon(Icons.favorite, color: AppColors.primary),
        label: l10n.t('nav.sadaqa'),
      ),
      NavigationDestination(
        icon: AppIcon(appIcons['travel']!, color: mutedIcon),
        selectedIcon: AppIcon(appIcons['travel']!, color: AppColors.primary),
        label: l10n.t('nav.travel'),
      ),
      NavigationDestination(
        icon: AppIcon(appIcons['settings']!, color: mutedIcon),
        selectedIcon: AppIcon(appIcons['settings']!, color: AppColors.primary),
        label: l10n.t('nav.settings'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
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
            backgroundColor: Theme.of(context).colorScheme.surface,
            indicatorColor: AppColors.primary.withAlpha(31),
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _onDestinationSelected,
            destinations: _buildDestinations(context),
          ),
        ),
      ),
    );
  }
}
