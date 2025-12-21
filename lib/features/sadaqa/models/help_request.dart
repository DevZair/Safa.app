import 'package:flutter/foundation.dart';

enum HelpRequestStatus {
  newRequest(1),
  inProgress(0),
  archived(2);

  const HelpRequestStatus(this.value);

  final int value;

  static HelpRequestStatus fromValue(Object? raw) {
    final intValue = _parseInt(raw) ?? newRequest.value;
    switch (intValue) {
      case 0:
        return HelpRequestStatus.inProgress;
      case 2:
        return HelpRequestStatus.archived;
      default:
        return HelpRequestStatus.newRequest;
    }
  }
}

@immutable
class HelpRequest {
  const HelpRequest({
    required this.id,
    required this.name,
    required this.surname,
    required this.phoneNumber,
    required this.status,
    this.address,
    this.helpReason,
    this.helpCategoryId,
    this.helpCategoryTitle,
    this.materialStatusId,
    this.materialStatusTitle,
    this.companyName,
    this.money,
    this.createdAt,
    this.childrenCount,
    this.age,
    this.iin,
    this.receivedOtherHelp,
    this.city,
    this.otherCategory,
  });

  final String id;
  final String name;
  final String surname;
  final String phoneNumber;
  final HelpRequestStatus status;
  final String? address;
  final String? helpReason;
  final int? helpCategoryId;
  final String? helpCategoryTitle;
  final int? materialStatusId;
  final String? materialStatusTitle;
  final String? companyName;
  final double? money;
  final DateTime? createdAt;
  final int? childrenCount;
  final int? age;
  final String? iin;
  final bool? receivedOtherHelp;
  final String? city;
  final String? otherCategory;

  String get fullName {
    final parts = [name, surname].where((part) => part.trim().isNotEmpty);
    return parts.isNotEmpty ? parts.join(' ').trim() : '';
  }

  HelpRequest copyWith({
    HelpRequestStatus? status,
    int? helpCategoryId,
    String? helpCategoryTitle,
    int? materialStatusId,
    String? materialStatusTitle,
  }) {
    return HelpRequest(
      id: id,
      name: name,
      surname: surname,
      phoneNumber: phoneNumber,
      status: status ?? this.status,
      helpCategoryId: helpCategoryId ?? this.helpCategoryId,
      helpCategoryTitle: helpCategoryTitle ?? this.helpCategoryTitle,
      materialStatusId: materialStatusId ?? this.materialStatusId,
      materialStatusTitle: materialStatusTitle ?? this.materialStatusTitle,
      address: address,
      helpReason: helpReason,
      companyName: companyName,
      money: money,
      createdAt: createdAt,
      childrenCount: childrenCount,
      age: age,
      iin: iin,
      receivedOtherHelp: receivedOtherHelp,
      city: city,
      otherCategory: otherCategory,
    );
  }

  factory HelpRequest.fromJson(Map<String, Object?> json) {
    final rawId = json['id'] ?? json['hr_id'];
    final rawHelpCategory = json['help_category'];
    int? helpCategoryId;
    String? helpCategoryTitle;
    if (rawHelpCategory is Map<String, Object?>) {
      helpCategoryId = _parseInt(rawHelpCategory['id']);
      final title = rawHelpCategory['title'];
      if (title is String && title.trim().isNotEmpty) {
        helpCategoryTitle = title;
      }
    }
    helpCategoryId ??= _parseInt(json['help_category_id']);
    helpCategoryTitle ??= _stringOrNull(
      json['help_category_title'] ?? json['category'],
    );

    final rawMaterialStatus = json['materials_status'] ?? json['material'];
    int? materialStatusId;
    String? materialStatusTitle;
    if (rawMaterialStatus is Map<String, Object?>) {
      materialStatusId = _parseInt(rawMaterialStatus['id']);
      final title = rawMaterialStatus['title'];
      if (title is String && title.trim().isNotEmpty) {
        materialStatusTitle = title;
      }
    }
    materialStatusId ??= _parseInt(json['materials_status_id']);
    materialStatusTitle ??= _stringOrNull(json['materials_status_title']);

    final createdAtString = _stringOrNull(
      json['created_at'] ?? json['createdAt'],
    );
    final createdAt =
        createdAtString != null ? DateTime.tryParse(createdAtString) : null;

    final status = HelpRequestStatus.fromValue(json['status'] ?? json['active']);

    return HelpRequest(
      id: rawId != null ? '$rawId' : '',
      name: _stringOrEmpty(json['name']),
      surname: _stringOrEmpty(json['surname'] ?? json['last_name']),
      phoneNumber: _stringOrEmpty(json['phone_number'] ?? json['phone']),
      address: _stringOrNull(json['address']),
      helpReason: _stringOrNull(json['help_reason'] ?? json['why_need_help']),
      helpCategoryId: helpCategoryId,
      helpCategoryTitle: helpCategoryTitle,
      materialStatusId: materialStatusId,
      materialStatusTitle: materialStatusTitle,
      companyName: _stringOrNull(json['company_name']),
      money: _parseDouble(json['money'] ?? json['requested_money']),
      createdAt: createdAt,
      childrenCount: _parseInt(json['child_num']),
      age: _parseInt(json['age']),
      iin: _stringOrNull(json['iin']),
      receivedOtherHelp: _parseBool(json['received_other_help']),
      city: _stringOrNull(json['city']),
      otherCategory: _stringOrNull(json['other_category']),
      status: status,
    );
  }
}

String _stringOrEmpty(Object? value) {
  if (value == null) return '';
  return '$value'.trim();
}

String? _stringOrNull(Object? value) {
  if (value == null) return null;
  final text = '$value'.trim();
  return text.isEmpty ? null : text;
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

bool? _parseBool(Object? value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.toLowerCase().trim();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
  }
  return null;
}
