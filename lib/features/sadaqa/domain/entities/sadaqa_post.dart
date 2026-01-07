import 'package:safa_app/features/sadaqa/domain/utils/media_resolver.dart';

class SadaqaPost {
  const SadaqaPost({
    required this.id,
    required this.companyId,
    required this.title,
    required this.content,
    required this.image,
    this.createdAt,
    this.likes = 0,
    this.comments = 0,
    this.goal,
    this.collected,
    this.status = 0,
    this.noteType,
    this.address,
    this.goalMoney,
    this.collectedMoney,
  });

  final String id;
  final String? companyId;
  final String title;
  final String content;
  final String image;
  final DateTime? createdAt;
  final int likes;
  final int comments;
  final double? goal;
  final double? collected;
  final String? noteType;
  final String? address;
  final double? goalMoney;
  final double? collectedMoney;
  final int status;

  factory SadaqaPost.fromJson(Map<String, Object?> json) {
    final rawId = json['id'];
    final id = rawId == null ? '' : '$rawId';
    final companyId = '${json['company_id'] ?? ''}'.trim();
    final createdAtString = json['created_at'] ?? json['createdAt'];
    DateTime? createdAt;
    if (createdAtString is String && createdAtString.isNotEmpty) {
      createdAt = DateTime.tryParse(createdAtString);
    }
    final likes = _parseInt(json['likes']) ?? 0;
    final comments = _parseInt(json['comments']) ?? 0;
    final goal = _parseDouble(json['goal_money']) ??
        _parseDouble(json['goal']) ??
        _parseDouble(json['need']);
    final collected = _parseDouble(json['collected_money']) ??
        _parseDouble(json['collected']) ??
        _parseDouble(json['paid']);
    final noteType =
        json['note_type'] is String ? (json['note_type'] as String) : null;
    final address =
        json['address'] is String ? (json['address'] as String) : null;
    final goalMoney = _parseDouble(json['goal_money']);
    final collectedMoney = _parseDouble(json['collected_money']);
    final rawImage = json['image'] is String ? (json['image'] as String) : '';
    final resolvedImage = resolveMediaUrl(rawImage);
    final image =
        resolvedImage.isNotEmpty ? resolvedImage : 'assets/images/font1.jpeg';
    final status = _parseInt(json['status']) ?? 0;
    return SadaqaPost(
      id: id,
      companyId: companyId.isNotEmpty ? companyId : null,
      title: '${json['title'] ?? ''}',
      content: '${json['content'] ?? ''}',
      image: image,
      createdAt: createdAt,
      likes: likes,
      comments: comments,
      goal: goal,
      collected: collected,
      status: status,
      noteType: noteType,
      address: address,
      goalMoney: goalMoney,
      collectedMoney: collectedMoney,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'title': title,
      'content': content,
      'image': image,
      'created_at': createdAt?.toIso8601String(),
      'likes': likes,
      'comments': comments,
      'goal': goal,
      'goal_money': goalMoney ?? goal,
      'collected': collected,
      'collected_money': collectedMoney ?? collected,
      'status': status,
      'note_type': noteType,
      'address': address,
    };
  }
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
