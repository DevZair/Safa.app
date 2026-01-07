import 'package:dio/dio.dart';
import 'package:safa_app/core/constants/api_constants.dart';
import 'package:safa_app/core/service/api_service.dart';
import 'package:safa_app/features/sadaqa/domain/entities/reference_item.dart';
import 'package:safa_app/features/sadaqa/domain/entities/request_help_payload.dart';
import 'package:safa_app/features/sadaqa/domain/repositories/request_help_repository.dart';

class RequestHelpRepositoryImpl implements RequestHelpRepository {
  @override
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

  @override
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

  @override
  Future<List<ReferenceItem>> fetchMaterialStatuses({int? companyId}) async {
    final paths = <String>{
      ApiConstants.sadaqaMaterialStatuses,
      '/api/sadaqa/material_status/',
      '/sadaqa/materials_status/',
      '/sadaqa/material_status/',
    };

    final query = companyId == null ? null : {'company_id': companyId};

    List<Object?> data = const [];
    Object? lastError;

    for (final path in paths) {
      try {
        final response = await ApiService.request<List<Object?>>(
          path,
          method: Method.get,
          queryParams: query,
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
        .where((item) => item.id != 0 && item.title.isNotEmpty && item.isActive)
        .toList();
  }

  @override
  Future<List<CategoryItem>> fetchCategories({int? companyId}) async {
    final paths = <String>{
      ApiConstants.sadaqaCategories,
      '/api/sadaqa/public/categories/',
      '/sadaqa/public/categories/',
    };
    final normalized = <String>{};
    for (final path in paths) {
      normalized.add(path);
      if (!path.endsWith('/')) normalized.add('$path/');
    }

    final query = companyId == null ? null : {'company_id': companyId};

    List<Object?> data = const [];
    Object? lastError;

    for (final path in normalized) {
      try {
        final response = await ApiService.request<List<Object?>>(
          path,
          method: Method.get,
          queryParams: query,
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
        .map(CategoryItem.fromJson)
        .where((item) => item.id != 0 && item.title.isNotEmpty)
        .toList();
  }

  @override
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
