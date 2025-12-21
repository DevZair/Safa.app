import 'package:dio/dio.dart';
import 'package:safa_app/core/constants/api_constants.dart';
import 'package:safa_app/core/service/api_service.dart';

class ReferenceItem {
  final int id;
  final String title;

  const ReferenceItem({required this.id, required this.title});

  factory ReferenceItem.fromJson(Map<String, Object?> json) {
    return ReferenceItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: '${json['title'] ?? ''}',
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

class RequestHelpPayload {
  final String name;
  final String surname;
  final String phoneNumber;
  final String address;
  final String whyNeedHelp;
  final int helpCategory;
  final String? email;
  final String? otherCategory;
  final String? companyName;
  final int? age;
  final int? childInFam;
  final String? iin;
  final int? materialStatus;
  final int? status;
  final num? money;
  final bool receivedOtherHelp;

  const RequestHelpPayload({
    required this.name,
    required this.surname,
    required this.phoneNumber,
    required this.address,
    required this.whyNeedHelp,
    required this.helpCategory,
    this.receivedOtherHelp = false,
    this.email,
    this.otherCategory,
    this.companyName,
    this.age,
    this.childInFam,
    this.iin,
    this.materialStatus,
    this.money,
    this.status,
  });

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'name': name,
      'surname': surname,
      'age': age ?? 0,
      'email': email,
      'phone_number': phoneNumber,
      'other_category': otherCategory,
      'child_num': childInFam ?? 0,
      'address': address,
      'iin': iin ?? '',
      'help_reason': whyNeedHelp,
      'received_other_help': receivedOtherHelp,
      'company_name': companyName,
      'status': status,
      'materials_status_id': materialStatus ?? 0,
      'help_category_id': helpCategory,
      'money': money,
    };
  }
}

class RequestHelpRepository {
  Future<int?> send(RequestHelpPayload payload) async {
    final response = await ApiService.request<Map<String, Object?>>(
      ApiConstants.requestHelp,
      method: Method.post,
      data: payload.toJson(),
    );

    if (response case {'id': final Object? id}) {
      return (id as num?)?.toInt();
    }
    return null;
  }

  Future<void> uploadFile({
    required int helpRequestId,
    required MultipartFile file,
  }) async {
    final basePath = '${ApiConstants.requestHelpFileUpload}$helpRequestId';
    final paths = <String>{basePath, '$basePath/'};
    final formBodies = <FormData>[
      FormData.fromMap({'file': file}),
      FormData.fromMap({'files': [file]}),
    ];

    Object? lastError;
    for (final path in paths) {
      for (final formData in formBodies) {
        try {
          await ApiService.request<Map<String, Object?>>(
            path,
            method: Method.post,
            formData: formData,
          );
          return;
        } catch (error) {
          lastError = error;
          if (error is DioException) {
            final status = error.response?.statusCode ?? 0;
            // Retry on validation/server issues with alternate payloads/paths.
            if (status == 422 || status >= 500) {
              continue;
            }
          }
          rethrow;
        }
      }
    }

    if (lastError != null) throw lastError;
  }

  Future<List<ReferenceItem>> fetchMaterialStatuses() async {
    final paths = <String>{
      ApiConstants.sadaqaMaterialStatuses,
      '/api/sadaqa/material_status/',
      '/sadaqa/materials_status/',
      '/sadaqa/material_status/',
    };

    List<Object?> data = const [];
    Object? lastError;

    for (final path in paths) {
      try {
        final response = await ApiService.request<List<Object?>>(
          path,
          method: Method.get,
        );
        data = response;
        lastError = null;
        break;
      } catch (error) {
        lastError = error;
        continue;
      }
    }

    if (data.isEmpty && lastError != null) throw lastError;

    return data
        .whereType<Map<String, Object?>>()
        .map(ReferenceItem.fromJson)
        .where((item) => item.id != 0 && item.title.isNotEmpty)
        .toList();
  }

  Future<List<CategoryItem>> fetchCategories() async {
    final data = await ApiService.request<List<Object?>>(
      ApiConstants.sadaqaCategories,
      method: Method.get,
    );

    return data
        .whereType<Map<String, Object?>>()
        .map(CategoryItem.fromJson)
        .where((item) => item.id != 0 && item.title.isNotEmpty)
        .toList();
  }

  Future<List<ReferenceItem>> fetchCompanies() async {
    final data = await ApiService.request<List<Object?>>(
      ApiConstants.sadaqaCompanies,
      method: Method.get,
    );

    return data
        .whereType<Map<String, Object?>>()
        .map(ReferenceItem.fromJson)
        .where((item) => item.id != 0 && item.title.isNotEmpty)
        .toList();
  }
}
