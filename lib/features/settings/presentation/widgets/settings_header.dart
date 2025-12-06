import 'package:flutter/material.dart';
import 'package:safa_app/widgets/gradient_header.dart';

class SettingsHeader extends StatelessWidget {
  const SettingsHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.height = 280,
    this.topColor,
    this.bottomColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final double height;
  final Color? topColor;
  final Color? bottomColor;

  @override
  Widget build(BuildContext context) {
    return GradientHeader(
      icon: icon,
      title: title,
      subtitle: subtitle,
      height: height,
      topColor: topColor ?? const Color(0xFF2EC8A6),
      bottomColor: bottomColor ?? const Color(0xFF1F9CCF),
    );
  }
}
