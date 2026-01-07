import 'dart:io';

import 'package:dio/dio.dart';
import 'package:safa_app/core/constants/api_constants.dart';
import 'package:safa_app/core/service/api_service.dart';

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
    );
  }

  Future<Map<String, dynamic>> updateTour(
    int tourId,
    Map<String, dynamic> payload,
  ) async {
    return ApiService.request<Map<String, dynamic>>(
      '${ApiConstants.tourPrivateTours}$tourId/',
      method: Method.put,
      data: payload,
    );
  }

  Future<List<dynamic>> getCategories() async {
    return ApiService.request<List<dynamic>>(
      ApiConstants.tourPrivateCategories,
      method: Method.get,
    );
  }

  Future<List<dynamic>> getGuides() async {
    return ApiService.request<List<dynamic>>(
      ApiConstants.tourPrivateGuides,
      method: Method.get,
    );
  }

  Future<Map<String, dynamic>> uploadImage(FormData formData) async {
    return ApiService.request<Map<String, dynamic>>(
      ApiConstants.uploadFile,
      method: Method.post,
      formData: formData,
    );
  }

  Future<FormData> buildImagePayload(File file) async {
    final fileName = file.path.split('/').last;
    return FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });
  }
}
