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

  static String get _resolvedBaseUrl {
    final stored = DBService.baseUrl;
    final base = stored.isNotEmpty ? stored : ApiConstants.baseUrl;
    if (base.startsWith('http')) return base;
    return 'https://$base';
  }

  static final Dio _dio = Dio()
    ..options = BaseOptions(
      baseUrl: _resolvedBaseUrl,
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
    bool followRedirects = false,
  }) async {
    final rawToken = DBService.accessToken.isNotEmpty
        ? DBService.accessToken
        : ApiConstants.apiToken;

    final isMultipart = formData != null;
    final newHeaders = <String, Object?>{
      'lang': DBService.languageCode,
    };

    if (rawToken.isNotEmpty) {
      newHeaders['Authorization'] = 'Bearer $rawToken';
    }

    if (headers != null) newHeaders.addAll(headers);

    final requestData = formData ?? data;

    try {
      final response = await _dio.request<Object?>(
        path,
        data: requestData,
        queryParameters: queryParams,
        options: Options(
          method: method.name,
          headers: newHeaders,
          contentType: isMultipart
              ? Headers.multipartFormDataContentType
              : Headers.jsonContentType,
          followRedirects: followRedirects,
        ),
      );

      // Manually handle redirects to keep headers/method/payload consistent.
      if (followRedirects &&
          response.statusCode != null &&
          response.statusCode! >= 300 &&
          response.statusCode! < 400) {
        final location = response.headers.value('location');
        if (location != null && location.isNotEmpty) {
          return await request<T>(
            location,
            method: method,
            data: data,
            headers: headers,
            queryParams: queryParams,
            formData: formData,
            followRedirects: true,
          );
        }
      }

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
