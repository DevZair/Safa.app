class ReferenceItem {
  final int id;
  final String title;
  final bool isActive;

  const ReferenceItem({
    required this.id,
    required this.title,
    this.isActive = true,
  });

  factory ReferenceItem.fromJson(Map<String, Object?> json) {
    return ReferenceItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: '${json['title'] ?? ''}',
      isActive: _parseMaterialStatusActive(
            json['status'] ?? json['active'] ?? json['is_active'],
          ) ??
          true,
    );
  }

  ReferenceItem copyWith({int? id, String? title, bool? isActive}) {
    return ReferenceItem(
      id: id ?? this.id,
      title: title ?? this.title,
      isActive: isActive ?? this.isActive,
    );
  }
}

class CategoryItem {
  final int id;
  final String title;
  final bool isOther;

  const CategoryItem({
    required this.id,
    required this.title,
    this.isOther = false,
  });

  factory CategoryItem.fromJson(Map<String, Object?> json) {
    return CategoryItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: '${json['title'] ?? ''}',
      isOther: json['is_other'] == true,
    );
  }
}

bool? _parseMaterialStatusActive(Object? value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value == 0;
  if (value is String) {
    final normalized = value.toLowerCase().trim();
    final asInt = int.tryParse(normalized);
    if (asInt != null) return asInt == 0;
    if (normalized == 'true') return true;
    if (normalized == 'false') return false;
  }
  return null;
}
