import 'dart:io';

import 'package:dio/dio.dart';
import 'package:safa_app/core/constants/api_constants.dart';
import 'package:safa_app/core/service/api_service.dart';
import 'package:safa_app/core/service/db_service.dart';

class TourRemoteDataSource {
  Future<List<dynamic>> getTours() async {
    return ApiService.request<List<dynamic>>(
      ApiConstants.tourPrivateTours,
      method: Method.get,
    );
  }

  Future<Map<String, dynamic>> createTour(Map<String, dynamic> payload) async {
    return ApiService.request<Map<String, dynamic>>(
      ApiConstants.tourPrivateTours,
      method: Method.post,
      data: payload,
      followRedirects: true,
    );
  }

  Future<Map<String, dynamic>> updateTour(
    int tourId,
    Map<String, dynamic> payload,
  ) async {
    return ApiService.request<Map<String, dynamic>>(
      '${ApiConstants.tourPrivateTours}$tourId',
      method: Method.put,
      data: payload,
      followRedirects: true,
    );
  }

  Future<List<dynamic>> getCategories() async {
    return ApiService.request<List<dynamic>>(
      ApiConstants.tourPrivateCategories,
      method: Method.get,
    );
  }

  Future<Map<String, dynamic>> createCategory(
    Map<String, dynamic> payload,
  ) async {
    return ApiService.request<Map<String, dynamic>>(
      ApiConstants.tourPrivateCategories,
      method: Method.post,
      data: payload,
      followRedirects: true,
    );
  }

  Future<Map<String, dynamic>> updateCategory(
    int categoryId,
    Map<String, dynamic> payload,
  ) async {
    return ApiService.request<Map<String, dynamic>>(
      '${ApiConstants.tourPrivateCategories}$categoryId',
      method: Method.put,
      data: payload,
      followRedirects: true,
    );
  }

  Future<List<dynamic>> getGuides() async {
    return ApiService.request<List<dynamic>>(
      ApiConstants.tourPrivateGuides,
      method: Method.get,
    );
  }

  Future<List<dynamic>> getGuidesDetailed() async {
    return ApiService.request<List<dynamic>>(
      ApiConstants.tourPrivateGuides,
      method: Method.get,
    );
  }

  Future<List<dynamic>> getBookings() async {
    return ApiService.request<List<dynamic>>(
      ApiConstants.tourPrivateBookings,
      method: Method.get,
      followRedirects: true,
    );
  }

  Future<Map<String, dynamic>> createGuide(Map<String, dynamic> payload) async {
    return ApiService.request<Map<String, dynamic>>(
      ApiConstants.tourPrivateGuides,
      method: Method.post,
      data: payload,
      followRedirects: true,
    );
  }

  Future<Map<String, dynamic>> updateGuide(
    int guideId,
    Map<String, dynamic> payload,
  ) async {
    return ApiService.request<Map<String, dynamic>>(
      '${ApiConstants.tourPrivateGuides}$guideId',
      method: Method.put,
      data: payload,
      followRedirects: true,
    );
  }

  Future<Map<String, dynamic>> uploadImage(FormData formData) async {
    return ApiService.request<Map<String, dynamic>>(
      ApiConstants.uploadFile,
      method: Method.post,
      formData: formData,
      headers: DBService.tourAccessToken.isNotEmpty
          ? {'Authorization': 'Bearer ${DBService.tourAccessToken}'}
          : null,
    );
  }

  Future<FormData> buildImagePayload(File file) async {
    final fileName = file.path.split('/').last;
    return FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });
  }
}
