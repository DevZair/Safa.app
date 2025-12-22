import 'package:flutter/material.dart';

class TravelCategory {
  final String id;
  final String label;
  final IconData icon;

  const TravelCategory({
    required this.id,
    required this.label,
    required this.icon,
  });

  static const TravelCategory all = TravelCategory(
    id: 'all',
    label: 'Все туры',
    icon: Icons.flight_takeoff_rounded,
  );

  static const TravelCategory umrah = TravelCategory(
    id: 'umrah',
    label: 'Умра',
    icon: Icons.mosque_rounded,
  );

  static const TravelCategory hajj = TravelCategory(
    id: 'hajj',
    label: 'Хадж',
    icon: Icons.mosque_sharp,
  );


  static const List<TravelCategory> coreCategories = [
    all,
    umrah,
    hajj,
  ];

  factory TravelCategory.fromJson(Map<String, Object?> json) {
    final id = _extractId(json);
    final label = _extractLabel(json, id);
    return TravelCategory(
      id: id,
      label: label,
      icon: _resolveIcon(id),
    );
  }

  static String _extractId(Map<String, Object?> json) {
    final rawId = json['slug'] ??
        json['code'] ??
        json['value'] ??
        json['id'] ??
        '';
    return '$rawId'.trim();
  }

  static String _extractLabel(Map<String, Object?> json, String fallbackId) {
    final rawLabel = json['name'] ??
        json['label'] ??
        json['title'] ??
        json['category'] ??
        '';
    if (rawLabel is String && rawLabel.trim().isNotEmpty) {
      return rawLabel.trim();
    }
    if (fallbackId.isNotEmpty) {
      return _formatLabelFromId(fallbackId);
    }
    return 'Категория';
  }

  static String _formatLabelFromId(String id) {
    final cleaned = id.replaceAll(RegExp(r'[-_]'), ' ').trim();
    if (cleaned.isEmpty) return 'Категория';
    final parts = cleaned.split(' ');
    final capitalized = parts
        .where((part) => part.isNotEmpty)
        .map((part) =>
            '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}')
        .join(' ');
    return capitalized.isEmpty ? 'Категория' : capitalized;
  }

  static IconData _resolveIcon(String id) {
    switch (id) {
      case 'umrah':
        return Icons.mosque_rounded;
      case 'hajj':
        return Icons.mosque_sharp;
      default:
        return Icons.travel_explore_rounded;
    }
  }
}
