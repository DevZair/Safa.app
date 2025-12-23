import 'package:safa_app/core/constants/api_constants.dart';
import 'package:safa_app/core/service/api_service.dart';
import 'package:safa_app/features/travel/models/travel_company.dart';
import 'package:safa_app/features/travel/models/travel_category.dart';
import 'package:safa_app/features/travel/models/travel_guide.dart';
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

  Future<List<TravelGuide>> fetchGuides() async {
    final data = await ApiService.request<Object?>(
      ApiConstants.travelGuides,
      method: Method.get,
    );

    final list = _unwrapList(data);

    return list
        .map(TravelGuide.fromJson)
        .where((guide) => guide.id.isNotEmpty)
        .toList();
  }

  Future<List<TravelCategory>> fetchCategories() async {
    final data = await ApiService.request<Object?>(
      ApiConstants.travelCategories,
      method: Method.get,
    );

    final list = _unwrapList(data);

    return list
        .map(TravelCategory.fromJson)
        .where((category) => category.id.isNotEmpty)
        .toList();
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

  Future<int> fetchActiveToursCount() async {
    final data = await ApiService.request<Object?>(
      ApiConstants.travelActiveToursCount,
      method: Method.get,
    );

    return _parseActiveToursCount(data);
  }

  static int _parseActiveToursCount(Object? raw) {
    return _extractActiveToursCount(raw) ?? 0;
  }

  static int? _extractActiveToursCount(Object? raw) {
    final direct = _asInt(raw);
    if (direct != null) return direct;

    if (raw is Map<String, Object?>) {
      for (final key in [
        'active_tours_count',
        'activeToursCount',
        'count',
        'value',
        'data',
        'active',
      ]) {
        if (!raw.containsKey(key)) continue;
        final nested = raw[key];
        final parsed = _extractActiveToursCount(nested);
        if (parsed != null) return parsed;
      }
    }

    return null;
  }

  static int? _asInt(Object? value) {
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }
}
