class SadaqaCompany {
  const SadaqaCompany({
    required this.id,
    required this.title,
    this.logo,
    this.cover,
  });

  final String id;
  final String title;
  final String? logo;
  final String? cover;

  factory SadaqaCompany.fromJson(Map<String, Object?> json) {
    final rawId = json['id'];
    final id = rawId == null ? '' : '$rawId';
    final title = '${json['title'] ?? ''}'.trim();
    final logo = _pickFirstString(json, ['logo', 'image', 'cover']);
    final cover = _pickFirstString(json, ['cover', 'image', 'thumbnail']);
    return SadaqaCompany(
      id: id,
      title: title.isNotEmpty ? title : 'Без названия',
      logo: logo,
      cover: cover,
    );
  }
}

String? _pickFirstString(Map<String, Object?> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) return value.trim();
  }
  return null;
}
