import 'dart:io';

import 'package:safa_app/features/travel/data/datasources/tour_remote_data_source.dart';
import 'package:safa_app/features/travel/domain/entities/tour.dart';
import 'package:safa_app/features/travel/domain/entities/tour_category.dart';
import 'package:safa_app/features/travel/domain/entities/tour_guide.dart';
import 'package:safa_app/features/travel/domain/repositories/tour_repository.dart';

class TourRepositoryImpl implements TourRepository {
  TourRepositoryImpl({TourRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? TourRemoteDataSource();

  final TourRemoteDataSource _remoteDataSource;

  @override
  Future<List<Tour>> getTours() async {
    final response = await _remoteDataSource.getTours();
    return response
        .map((data) => Tour.fromJson(data as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Tour> createTour(Tour tour) async {
    final response = await _remoteDataSource.createTour(tour.toJson());
    return Tour.fromJson(response);
  }

  @override
  Future<Tour> updateTour(int tourId, Tour tour) async {
    final response = await _remoteDataSource.updateTour(tourId, tour.toJson());
    return Tour.fromJson(response);
  }

  @override
  Future<List<TourCategory>> getCategories() async {
    final response = await _remoteDataSource.getCategories();
    return response
        .map((data) => TourCategory.fromJson(data as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<TourGuide>> getGuides() async {
    final response = await _remoteDataSource.getGuides();
    return response
        .map((data) => TourGuide.fromJson(data as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<String> uploadImage(File file) async {
    final formData = await _remoteDataSource.buildImagePayload(file);
    final response = await _remoteDataSource.uploadImage(formData);
    return response['file_path'] as String? ?? response['url'] as String? ?? '';
  }
}
