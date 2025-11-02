// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:safa_app/core/constants/api_constants.dart';

import '../utils/custom_intercepter.dart';
import 'db_service.dart';

enum Method { get, post, put, patch, delete }

@immutable
class ApiService {
  const ApiService._();

  static final Dio _dio = Dio()
    ..options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      followRedirects: false,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      maxRedirects: 5,
    )
    ..interceptors.add(CustomInterceptor());

  static FutureOr<T> request<T>(
    String path, {
    Method method = Method.post,
    Object? data,
    Map<String, Object?>? headers,
    Map<String, Object?>? queryParams,
    FormData? formData,
  }) async {
    final newHeaders = <String, Object?>{
      'content-Type': formData != null
          ? 'multipart/form-data'
          : 'application/json',
      'X-Api-Token': DBService.token,
      'lang': DBService.languageCode,
    };

    if (headers != null) newHeaders.addAll(headers);

    try {
      final response = await _dio.request<Object?>(
        path,
        data: data ?? formData,
        queryParameters: queryParams,
        options: Options(method: method.name, headers: newHeaders),
      );

      if (response.statusCode == null || response.statusCode! > 204) {
        final convert = const JsonEncoder().cast<Object?, String?>().convert(
          response.data ?? {},
        );

        final json = const JsonDecoder()
            .cast<String, Map<String, Object?>>()
            .convert(convert ?? '{}');

        if (json case {
          'status': final String? status,
          'description': final String? description,
          'data': final String? data,
        }) {
          throw Error.throwWithStackTrace(
            const JsonEncoder().cast<Map<String, Object?>, String>().convert({
              'description': description,
              'status': status,
              'data': data,
              'message': "Can't send request",
              'isError': true,
            }),
            StackTrace.current,
          );
        } else {
          throwError();
        }
      }

      return const JsonDecoder().cast<String, T>().convert(
        jsonEncode(response.data ?? {}),
      );
    } on DioException catch (error, stackTrace) {
      final convert = const JsonEncoder().cast<Object?, String?>().convert(
        error.response?.data ?? {},
      );
      final json = const JsonDecoder()
          .cast<String, Map<String, Object?>>()
          .convert(convert ?? '{}');

      if (json case {
        'status': final String? status,
        'description': final String? description,
        'data': final String? data,
      }) {
        throw Error.throwWithStackTrace(
          const JsonEncoder().cast<Map<String, Object?>, String>().convert({
            'description': description,
            'status': status,
            'data': data,
            'message': "Can't send request",
            'isError': true,
          }),
          stackTrace,
        );
      } else {
        throwError();
      }
    } on Object catch (error, stackTrace) {
      Error.safeToString(error);
      stackTrace.toString();
      rethrow;
    }
  }

  static Never throwError() => throw Error.throwWithStackTrace(
    const JsonEncoder().cast<Map<String, Object?>, String>().convert({
      'description': 'Server Error',
      'status': 'Server Error',
      'data': 'Server Error',
      'message': "Can't send request",
      'isError': true,
    }),
    StackTrace.current,
  );
}

