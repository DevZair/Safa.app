import 'package:safa_app/core/constants/api_constants.dart';
import 'package:safa_app/core/service/api_service.dart';

class TravelRemoteDataSource {
  Future<List<Map<String, Object?>>> fetchCompanies() async {
    final data = await ApiService.request<Object?>(
      ApiConstants.travelCompanies,
      method: Method.get,
    );
    return _unwrapList(data);
  }

  Future<List<Map<String, Object?>>> fetchPackages() async {
    final data = await ApiService.request<Object?>(
      ApiConstants.travelPackages,
      method: Method.get,
    );
    return _unwrapList(data);
  }

  Future<List<Map<String, Object?>>> fetchGuides() async {
    final data = await ApiService.request<Object?>(
      ApiConstants.travelGuides,
      method: Method.get,
    );
    return _unwrapList(data);
  }

  Future<List<Map<String, Object?>>> fetchCategories() async {
    final data = await ApiService.request<Object?>(
      ApiConstants.travelCategories,
      method: Method.get,
    );
    return _unwrapList(data);
  }

  Future<Object?> fetchActiveToursCountRaw() async {
    return ApiService.request<Object?>(
      ApiConstants.travelActiveToursCount,
      method: Method.get,
    );
  }

  List<Map<String, Object?>> _unwrapList(Object? data) {
    if (data is List) {
      return data.whereType<Map<String, Object?>>().toList();
    }

    if (data is Map<String, Object?>) {
      final inner = data['data'];
      if (inner is List) {
        return inner.whereType<Map<String, Object?>>().toList();
      }
    }

    return [];
  }
}
