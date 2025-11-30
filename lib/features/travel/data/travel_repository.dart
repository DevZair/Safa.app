import 'package:safa_app/core/constants/api_constants.dart';
import 'package:safa_app/core/service/api_service.dart';
import 'package:safa_app/features/travel/models/travel_company.dart';
import 'package:safa_app/features/travel/presentation/widgets/travel_package_card.dart';

class TravelRepository {
  Future<List<TravelCompany>> fetchCompanies() async {
    final data = await ApiService.request<Object?>(
      ApiConstants.travelCompanies,
      method: Method.get,
    );

    final list = _unwrapList(data);

    return list.map(TravelCompany.fromJson).toList();
  }

  Future<List<TravelPackage>> fetchPackages() async {
    final data = await ApiService.request<Object?>(
      ApiConstants.travelPackages,
      method: Method.get,
    );

    final list = _unwrapList(data);

    return list.map(TravelPackage.fromJson).toList();
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
