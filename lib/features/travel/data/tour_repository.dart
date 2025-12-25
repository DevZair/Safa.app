import 'dart:io';

import 'package:dio/dio.dart';
import 'package:safa_app/core/constants/api_constants.dart';
import 'package:safa_app/core/service/api_service.dart';
import 'package:safa_app/features/travel/models/tour.dart';
import 'package:safa_app/features/travel/models/tour_category.dart';
import 'package:safa_app/features/travel/models/tour_guide.dart';

class TourRepository {
  Future<List<Tour>> getTours() async {
    final response = await ApiService.request<List<dynamic>>(
      ApiConstants.tourPrivateTours,
      method: Method.get,
    );
    return response.map((data) => Tour.fromJson(data as Map<String, dynamic>)).toList();
  }

  Future<Tour> createTour(Tour tour) async {
    final response = await ApiService.request<Map<String, dynamic>>(
      ApiConstants.tourPrivateTours,
      method: Method.post,
      data: tour.toJson(),
    );
    return Tour.fromJson(response);
  }

  Future<Tour> updateTour(int tourId, Tour tour) async {
    final response = await ApiService.request<Map<String, dynamic>>(
      '${ApiConstants.tourPrivateTours}$tourId/',
      method: Method.put,
      data: tour.toJson(),
    );
    return Tour.fromJson(response);
  }

  Future<List<TourCategory>> getCategories() async {
    final response = await ApiService.request<List<dynamic>>(
      ApiConstants.tourPrivateCategories,
      method: Method.get,
    );
    return response.map((data) => TourCategory.fromJson(data as Map<String, dynamic>)).toList();
  }

  Future<List<TourGuide>> getGuides() async {
    final response = await ApiService.request<List<dynamic>>(
      ApiConstants.tourPrivateGuides,
      method: Method.get,
    );
    return response.map((data) => TourGuide.fromJson(data as Map<String, dynamic>)).toList();
  }

  Future<String> uploadImage(File file) async {
    final fileName = file.path.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });

    final response = await ApiService.request<Map<String, dynamic>>(
      ApiConstants.uploadFile,
      method: Method.post,
      formData: formData,
    );

    // Assuming the API returns a JSON with a 'file_path' or 'url' key
    return response['file_path'] as String? ?? response['url'] as String? ?? '';
  }
}
