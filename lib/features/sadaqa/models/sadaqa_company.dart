class SadaqaCompany {
  const SadaqaCompany({
    required this.id,
    required this.title,
    this.logo,
    this.cover,
    this.payment,
    this.whyCollecting,
    this.postCount,
  });

  final String id;
  final String title;
  final String? logo;
  final String? cover;
  final String? payment;
  final String? whyCollecting;
  final int? postCount;

  factory SadaqaCompany.fromJson(Map<String, Object?> json) {
    final rawId = json['id'];
    final id = rawId == null ? '' : '$rawId';
    final title = '${json['title'] ?? ''}'.trim();
    final logo = _pickFirstString(json, ['logo', 'image', 'cover']);
    final cover = _pickFirstString(json, ['cover', 'image', 'thumbnail']);
    final payment = _pickFirstString(json, ['payment', 'payment_link']);
    final whyCollecting = _pickFirstString(
      json,
      ['why_collecting', 'description', 'subtitle'],
    );
    final postCount = json['post_count'] is int ? json['post_count'] as int : null;

    return SadaqaCompany(
      id: id,
      title: title.isNotEmpty ? title : 'Без названия',
      logo: logo,
      cover: cover,
      payment: payment,
      whyCollecting: whyCollecting,
      postCount: postCount,
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
