import 'package:dio/dio.dart';
import 'package:safa_app/features/sadaqa/domain/entities/reference_item.dart';
import 'package:safa_app/features/sadaqa/domain/entities/request_help_payload.dart';

abstract class RequestHelpRepository {
  Future<int?> send(RequestHelpPayload payload);
  Future<void> uploadFile({
    required int helpRequestId,
    required MultipartFile file,
  });
  Future<List<ReferenceItem>> fetchMaterialStatuses({int? companyId});
  Future<List<CategoryItem>> fetchCategories({int? companyId});
  Future<List<ReferenceItem>> fetchCompanies();
}
