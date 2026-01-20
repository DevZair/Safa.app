import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    final mutedIcon = theme.colorScheme.onSurface.withValues(alpha: 0.6);
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
    final theme = Theme.of(context);
    final isIOS = theme.platform == TargetPlatform.iOS;
    final barHeight = isIOS ? 65.h : 70.h;
    final radius = 40.r;
    final bottomOffset = isIOS ? 12.h : 26.h;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.only(
          left: 22.w,
          right: 22.w,
          bottom: bottomOffset,
          top: isIOS ? 4.h : 16.h,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: Colors.white.withValues(alpha: isIOS ? 0.4 : 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 20.r,
                offset: Offset(0, 12.h),
              ),
            ],
            backgroundBlendMode: BlendMode.screen,
          ),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          child: SizedBox(
            height: barHeight,
            child: _AnimatedNavBar(
              items: _buildDestinations(context),
              currentIndex: navigationShell.currentIndex,
              onTap: _onDestinationSelected,
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedNavBar extends StatelessWidget {
  const _AnimatedNavBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<NavigationDestination> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final highlightColor = Colors.white.withValues(alpha: 0.18);
    final iconColor = theme.colorScheme.onSurface;

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = constraints.maxWidth / items.length;
        return Stack(
          alignment: Alignment.centerLeft,
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              left: itemWidth * currentIndex + itemWidth * 0.12,
              top: 10,
              child: Container(
                width: itemWidth * 0.76,
                height: constraints.maxHeight - 20,
                decoration: BoxDecoration(
                  color: highlightColor,
                  borderRadius: BorderRadius.circular(18.r),
                ),
              ),
            ),
            Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: _NavItem(
                      destination: items[i],
                      selected: i == currentIndex,
                      iconColor: iconColor,
                      onTap: () => onTap(i),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.iconColor,
    required this.onTap,
  });

  final NavigationDestination destination;
  final bool selected;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 220),
              scale: selected ? 1.15 : 1.0,
              curve: Curves.easeOut,
              child: IconTheme(
                data: IconThemeData(
                  color: selected
                      ? AppColors.primary
                      : iconColor.withValues(alpha: 0.7),
                  size: 24.sp,
                ),
                child: selected
                    ? destination.selectedIcon ?? destination.icon
                    : destination.icon,
              ),
            ),
            SizedBox(height: 6.h),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              style:
                  theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? AppColors.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ) ??
                  TextStyle(
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? AppColors.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
              child: Text(destination.label),
            ),
          ],
        ),
      ),
    );
  }
}
