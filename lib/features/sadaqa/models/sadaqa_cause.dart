import 'package:safa_app/features/sadaqa/utils/media_resolver.dart';

class SadaqaCause {
  final String id;
  final String imagePath;
  final String title;
  final String subtitle;
  final String? companyId;
  final String? companyName;
  final String? companyLogo;
  final List<String> gallery;
  final int amount;
  final double raised;
  final double goal;
  final int donors;
  final String description;
  final String? noteType;
  final bool isPrivate;

  const SadaqaCause({
    required this.id,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    this.companyId,
    this.companyName,
    this.companyLogo,
    this.gallery = const [],
    required this.amount,
    required this.raised,
    required this.goal,
    required this.donors,
    required this.description,
    this.noteType,
    this.isPrivate = false,
  });

  factory SadaqaCause.fromJson(Map<String, Object?> json) {
    final gallery = _parseGallery(json);
    final imagePath = gallery.isNotEmpty
        ? gallery.first
        : 'assets/images/font1.jpeg';
    final company = json['company'] as Map<String, Object?>?;
    final companyName = _parseCompanyName(json)?.trim();
    final companyId = _firstNonEmpty([
      '${json['company_id'] ?? ''}',
      '${company?['id'] ?? ''}',
    ]);

    final description = _firstNonEmpty([
      '${json['description'] ?? ''}',
      '${json['why_need_help'] ?? ''}',
      '${json['subtitle'] ?? ''}',
      '${json['content'] ?? ''}',
      '${json['help_reason'] ?? ''}',
    ]);

    return SadaqaCause(
      id: _firstNonEmpty([
        '${json['id'] ?? ''}',
        '${json['uuid'] ?? ''}',
        '${json['slug'] ?? ''}',
      ]),
      imagePath: imagePath,
      title: _firstNonEmpty([
        '${json['title'] ?? ''}',
        '${json['name'] ?? ''}',
        '${json['why_need_help'] ?? ''}',
        '${json['short_title'] ?? ''}',
      ]),
      subtitle: _firstNonEmpty([
        '${json['subtitle'] ?? ''}',
        '${json['short_description'] ?? ''}',
        '${json['category'] ?? ''}',
        '${json['address'] ?? ''}',
        '${json['content'] ?? ''}',
      ]),
      companyId: companyId.isNotEmpty ? companyId : null,
      companyName: companyName,
      companyLogo: _parseCompanyLogo(json),
      gallery: gallery,
      amount:
          _parseInt(json['recommended_amount']) ??
          _parseInt(json['suggested_amount']) ??
          _parseInt(json['amount']) ??
          _parseInt(json['money']) ??
          0,
      raised:
          _parseDouble(json['raised']) ??
          _parseDouble(json['collected']) ??
          _parseDouble(json['collected_money']) ??
          _parseDouble(json['paid']) ??
          0,
      goal:
          _parseDouble(json['goal']) ??
          _parseDouble(json['target']) ??
          _parseDouble(json['goal_money']) ??
          _parseDouble(json['need']) ??
          _parseDouble(json['money']) ??
          0,
      donors:
          _parseInt(json['donors']) ??
          _parseInt(json['supporters']) ??
          _parseInt(json['donors_count']) ??
          _parseInt(json['count_donors']) ??
          0,
      description: description,
      noteType: '${json['note_type'] ?? ''}',
      isPrivate: _isPrivate(json),
    );
  }

  SadaqaCause copyWith({
    String? id,
    String? imagePath,
    String? title,
    String? subtitle,
    String? companyId,
    String? companyName,
    String? companyLogo,
    List<String>? gallery,
    int? amount,
    double? raised,
    double? goal,
    int? donors,
    String? description,
    String? noteType,
    bool? isPrivate,
  }) {
    return SadaqaCause(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      companyLogo: companyLogo ?? this.companyLogo,
      gallery: gallery ?? this.gallery,
      amount: amount ?? this.amount,
      raised: raised ?? this.raised,
      goal: goal ?? this.goal,
      donors: donors ?? this.donors,
      description: description ?? this.description,
      noteType: noteType ?? this.noteType,
      isPrivate: isPrivate ?? this.isPrivate,
    );
  }
}

String _firstNonEmpty(List<String> values) {
  return values.firstWhere(
    (value) => value.trim().isNotEmpty,
    orElse: () => '',
  );
}

int? _parseInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value');
}

double? _parseDouble(Object? value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse('$value');
}

bool _isPrivate(Map<String, Object?> json) {
  final value =
      json['private'] ??
      json['is_private'] ??
      json['isPrivate'] ??
      json['visibility'];
  if (value is bool) return value;

  final normalized = '${value ?? ''}'.toLowerCase();
  return normalized == 'true' ||
      normalized == '1' ||
      normalized == 'private' ||
      normalized == 'admin';
}

String? _parseCompanyName(Map<String, Object?> json) {
  final company = json['company'] as Map<String, Object?>?;
  final name =
      json['company_name'] ??
      company?['name'] ??
      company?['title'] ??
      company?['company'];
  if (name is String && name.trim().isNotEmpty) return name.trim();
  return null;
}

String? _parseCompanyLogo(Map<String, Object?> json) {
  final company = json['company'] as Map<String, Object?>?;
  final logo = json['company_logo'] ?? company?['logo'] ?? company?['image'];
  if (logo is String && logo.trim().isNotEmpty) return logo.trim();
  return null;
}

List<String> _parseGallery(Map<String, Object?> json) {
  final images = <String>{};

  for (final key in ['gallery', 'photos', 'images', 'files']) {
    final fromKey = json[key];
    images.addAll(_coerceStringList(fromKey));
  }

  final cover = _extractImageUrl(
    json['cover'] ?? json['image'] ?? json['thumbnail'] ?? json['photo'],
  );
  if (cover != null) images.add(cover);

  return images.where((value) => value.trim().isNotEmpty).toList();
}

Iterable<String> _coerceStringList(Object? value) sync* {
  if (value is List) {
    for (final item in value) {
      final url = _extractImageUrl(item);
      if (url != null) yield url;
    }
  } else if (value is String && value.trim().isNotEmpty) {
    yield resolveMediaUrl(value);
  }
}

String? _extractImageUrl(Object? value) {
  if (value is String && value.trim().isNotEmpty) {
    return resolveMediaUrl(value);
  }

  if (value is Map<String, Object?>) {
    final url = value['url'] ?? value['image'] ?? value['path'];
    if (url is String && url.trim().isNotEmpty) return resolveMediaUrl(url);
  }
  return null;
}
