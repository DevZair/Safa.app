import 'dart:io';

import 'package:safa_app/features/travel/data/datasources/tour_remote_data_source.dart';
import 'package:safa_app/features/travel/domain/entities/tour.dart';
import 'package:safa_app/features/travel/domain/entities/tour_category.dart';
import 'package:safa_app/features/travel/domain/entities/tour_guide.dart';
import 'package:safa_app/features/travel/domain/entities/tour_booking.dart';
import 'package:safa_app/features/travel/domain/entities/travel_guide.dart';
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
  Future<TourCategory> createCategory({required String title}) async {
    final response = await _remoteDataSource.createCategory({'title': title});
    return TourCategory.fromJson(response);
  }

  @override
  Future<TourCategory> updateCategory({
    required int categoryId,
    required String title,
  }) async {
    final response = await _remoteDataSource.updateCategory(categoryId, {
      'title': title,
    });
    return TourCategory.fromJson(response);
  }

  @override
  Future<List<TourGuide>> getGuides() async {
    final response = await _remoteDataSource.getGuides();
    return response
        .map((data) => TourGuide.fromJson(data as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<TourBooking>> getBookings() async {
    final response = await _remoteDataSource.getBookings();
    return response
        .map((data) => TourBooking.fromJson(data as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<TravelGuide>> getGuidesDetailed() async {
    final response = await _remoteDataSource.getGuidesDetailed();
    return response
        .map((data) => TravelGuide.fromJson(data as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<TravelGuide> createGuide({
    required String firstName,
    required String lastName,
    required String about,
    double? rating,
  }) async {
    final payload = {
      'name': firstName,
      'surname': lastName,
      'about_self': about,
      if (rating != null) 'rating': rating,
    };
    final response = await _remoteDataSource.createGuide(payload);
    return TravelGuide.fromJson(response);
  }

  @override
  Future<TravelGuide> updateGuide({
    required int guideId,
    required String firstName,
    required String lastName,
    required String about,
    double? rating,
  }) async {
    final payload = {
      'name': firstName,
      'surname': lastName,
      'about_self': about,
      if (rating != null) 'rating': rating,
    };
    final response = await _remoteDataSource.updateGuide(guideId, payload);
    return TravelGuide.fromJson(response);
  }

  @override
  Future<String> uploadImage(File file) async {
    final formData = await _remoteDataSource.buildImagePayload(file);
    final response = await _remoteDataSource.uploadImage(formData);
    return response['path'] as String? ??
        response['file_path'] as String? ??
        response['url'] as String? ??
        '';
  }
}
