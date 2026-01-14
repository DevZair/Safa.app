import 'package:safa_app/features/travel/data/datasources/travel_remote_data_source.dart';
import 'package:safa_app/features/travel/domain/entities/travel_category.dart';
import 'package:safa_app/features/travel/domain/entities/travel_company.dart';
import 'package:safa_app/features/travel/domain/entities/travel_guide.dart';
import 'package:safa_app/features/travel/domain/entities/travel_package.dart';
import 'package:safa_app/features/travel/domain/repositories/travel_repository.dart';

class TravelRepositoryImpl implements TravelRepository {
  TravelRepositoryImpl({TravelRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? TravelRemoteDataSource();

  final TravelRemoteDataSource _remoteDataSource;

  @override
  Future<List<TravelCompany>> fetchCompanies() async {
    final list = await _remoteDataSource.fetchCompanies();
    return list
        .map(TravelCompany.fromJson)
        .where((company) => company.id.isNotEmpty)
        .toList();
  }

  @override
  Future<List<TravelPackage>> fetchPackages() async {
    final list = await _remoteDataSource.fetchPackages();
    return list.map(TravelPackage.fromJson).toList();
  }

  @override
  Future<List<TravelGuide>> fetchGuides() async {
    final list = await _remoteDataSource.fetchGuides();
    return list
        .map(TravelGuide.fromJson)
        .where((guide) => guide.id.isNotEmpty)
        .toList();
  }

  @override
  Future<List<TravelCategory>> fetchCategories() async {
    final list = await _remoteDataSource.fetchCategories();
    return list
        .map(TravelCategory.fromJson)
        .where((category) => category.id.isNotEmpty)
        .toList();
  }

  @override
  Future<int> fetchActiveToursCount() async {
    final data = await _remoteDataSource.fetchActiveToursCountRaw();
    return _parseActiveToursCount(data);
  }

  @override
  Future<void> createBooking(Map<String, Object?> payload) {
    return _remoteDataSource.createBooking(payload);
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
