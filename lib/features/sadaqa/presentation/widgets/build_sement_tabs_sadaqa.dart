import 'package:flutter/material.dart';
import 'package:safa_app/core/styles/app_colors.dart';

Widget buildSegmentedTabs({
  required int selectedTabIndex,
  required int favoritesCount,
  required ValueChanged<int> onTabSelected,
}) {
  void handleTap(int index) {
    if (selectedTabIndex != index) {
      onTabSelected(index);
    }
  }

  return Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: const Color(0xFFF4F6FA),
      borderRadius: BorderRadius.circular(32),
      border: Border.all(color: Colors.white, width: 1.5),
      boxShadow: const [
        BoxShadow(
          color: Color.fromRGBO(22, 94, 76, 0.06),
          blurRadius: 18,
          offset: Offset(0, 10),
        ),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => handleTap(0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: selectedTabIndex == 0
                    ? Colors.white
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(28),
                boxShadow: selectedTabIndex == 0
                    ? const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.08),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  'Все сборы',
                  style: TextStyle(
                    color: selectedTabIndex == 0
                        ? AppColors.primary
                        : const Color(0xFF4A5568),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => handleTap(1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: selectedTabIndex == 1
                    ? Colors.white
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(28),
                boxShadow: selectedTabIndex == 1
                    ? const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.08),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    selectedTabIndex == 1 ? Icons.star : Icons.star_border,
                    size: 18,
                    color: selectedTabIndex == 1
                        ? AppColors.primary
                        : const Color(0xFF4A5568),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Избранное ($favoritesCount)',
                    style: TextStyle(
                      color: selectedTabIndex == 1
                          ? AppColors.primary
                          : const Color(0xFF4A5568),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
