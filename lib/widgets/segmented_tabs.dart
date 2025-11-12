import 'package:flutter/material.dart';
import 'package:safa_app/core/styles/app_colors.dart';

class SegmentedTabConfig {
  final String label;
  final IconData? icon;
  final IconData? activeIcon;

  const SegmentedTabConfig({required this.label, this.icon, this.activeIcon});
}

Widget buildSegmentedTabs({
  required BuildContext context,
  required List<SegmentedTabConfig> tabs,
  required int selectedIndex,
  required ValueChanged<int> onTabSelected,
}) {
  void handleTap(int index) {
    if (index != selectedIndex) onTabSelected(index);
  }

  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final trackColor =
      isDark ? AppColors.darkMutedSurface : AppColors.surfaceMuted;
  final borderColor = isDark
      ? AppColors.darkStroke.withValues(alpha: 0.6)
      : AppColors.white;
  final inactiveColor = isDark
      ? AppColors.darkTextPrimary.withValues(alpha: 0.5)
      : AppColors.tabInactive;
  final activeTextColor = isDark ? AppColors.darkTextPrimary : AppColors.primary;
  final activeBg = isDark ? AppColors.darkElevated : AppColors.white;
  final shadowColor = isDark
      ? Colors.black.withValues(alpha: 0.35)
      : AppColors.black.withValues(alpha: 0.08);

  return Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: trackColor,
      borderRadius: BorderRadius.circular(32),
      border: Border.all(color: borderColor, width: 1.5),
    ),
    child: Row(
      children: [
        for (var i = 0; i < tabs.length; i++) ...[
          Expanded(
            child: GestureDetector(
              onTap: () => handleTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 0),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: selectedIndex == i ? activeBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: selectedIndex == i
                      ? [
                          BoxShadow(
                            color: shadowColor,
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (tabs[i].icon != null) ...[
                      Icon(
                        selectedIndex == i
                            ? (tabs[i].activeIcon ?? tabs[i].icon)
                            : tabs[i].icon,
                        size: 18,
                        color: selectedIndex == i
                            ? activeTextColor
                            : inactiveColor,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Flexible(
                      child: Text(
                        tabs[i].label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color:
                              selectedIndex == i ? activeTextColor : inactiveColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (i != tabs.length - 1) const SizedBox(width: 8),
        ],
      ],
    ),
  );
}
