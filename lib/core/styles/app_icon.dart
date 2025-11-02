import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

const Map<String, String> appIcons = {
  'sadaqa': 'assets/icons/server.svg',
  'travel': 'assets/icons/airplane-outline.svg',
  'settings': 'assets/icons/cog.svg',
  'user': 'assets/icons/person.svg',
  'navigation': 'assets/icons/navigate.svg',
};

class AppIcon extends StatelessWidget {
  const AppIcon(
    this.icon, {
    super.key,
    this.size = 22,
    this.color,
    this.isString = false,
  });

  final String icon;
  final Color? color;
  final double size;
  final bool isString;

  @override
  Widget build(BuildContext context) {
    final colorFilter = color != null
        ? ColorFilter.mode(color!, BlendMode.srcIn)
        : null;

    return isString
        ? SvgPicture.string(
            icon,
            width: size,
            height: size,
            colorFilter: colorFilter,
          )
        : SvgPicture.asset(
            icon,
            width: size,
            height: size,
            colorFilter: colorFilter,
          );
  }
}
