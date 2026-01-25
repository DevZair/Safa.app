// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
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
    ..httpClientAdapter = _buildHttpAdapter()
    ..interceptors.add(CustomInterceptor());

  static HttpClientAdapter _buildHttpAdapter() {
    final adapter = IOHttpClientAdapter();
    adapter.onHttpClientCreate = (client) {
      final allowedHost = Uri.tryParse(_resolvedBaseUrl)?.host;
      client.badCertificateCallback = (cert, host, port) {
        // Allow self-signed/invalid cert for our API host to prevent TLS handshake issues
        // on emulators and some Android/iOS devices.
        if (allowedHost != null && allowedHost.isNotEmpty) {
          return host == allowedHost;
        }
        return true;
      };
      return client;
    };
    return adapter;
  }

  static FutureOr<T> request<T>(
    String path, {
    Method method = Method.post,
    Object? data,
    Map<String, Object?>? headers,
    Map<String, Object?>? queryParams,
    FormData? formData,
    bool followRedirects = false,
    bool includeAuthHeader = true,
  }) async {
    final resolvedToken = _tokenForPath(path);
    final rawToken = resolvedToken.isNotEmpty
        ? resolvedToken
        : ApiConstants.apiToken;

    final isMultipart = formData != null;
    final newHeaders = <String, Object?>{'lang': DBService.languageCode};

    if (includeAuthHeader && rawToken.isNotEmpty) {
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
          maxRedirects: followRedirects ? 5 : 0,
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

      // Check for error status codes (>= 300) or null status code
      if (response.statusCode == null || response.statusCode! >= 300) {
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
      // Try to refresh token if we got 401 and have a refresh token
      if (error.response?.statusCode == 401 && includeAuthHeader) {
        final refreshed = await _tryRefreshToken(path);
        if (refreshed) {
          // Retry the original request with new token
          return await request<T>(
            path,
            method: method,
            data: data,
            headers: headers,
            queryParams: queryParams,
            formData: formData,
            followRedirects: followRedirects,
            includeAuthHeader: includeAuthHeader,
          );
        }
      }

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

  static String _tokenForPath(String path) {
    final normalized = path.toLowerCase();
    // Never attach existing tokens to login endpoints to avoid 401.
    if (normalized.contains('/company/login') ||
        normalized.contains('/auth/admin/login') ||
        normalized.contains('/refresh')) {
      return '';
    }

    if (normalized.contains('/auth/admin/')) {
      return DBService.superAdminAccessToken;
    }

    final isTourPath = normalized.contains('/tour/');

    if (isTourPath && DBService.tourAccessToken.isNotEmpty) {
      return DBService.tourAccessToken;
    }

    if (DBService.accessToken.isNotEmpty) {
      return DBService.accessToken;
    }

    return '';
  }

  static Future<bool> _tryRefreshToken(String path) async {
    final normalized = path.toLowerCase();

    // Determine which token to refresh based on path
    String refreshToken;
    String refreshEndpoint;

    if (normalized.contains('/auth/admin/')) {
      refreshToken = DBService.superAdminRefreshToken;
      refreshEndpoint = ApiConstants.superAdminRefresh;
    } else if (normalized.contains('/tour/')) {
      refreshToken = DBService.tourRefreshToken;
      refreshEndpoint = ApiConstants.tourAdminRefresh;
    } else if (normalized.contains('/sadaqa/')) {
      refreshToken = DBService.refreshToken;
      refreshEndpoint = ApiConstants.sadaqaAdminRefresh;
    } else {
      return false;
    }

    if (refreshToken.isEmpty) {
      return false;
    }

    // Try different formats for refresh token request
    final formatsToTry = [
      {'refresh': refreshToken}, // Common FastAPI/Django format
      {'refresh_token': refreshToken}, // Alternative format
    ];

    for (final dataFormat in formatsToTry) {
      try {
        final response = await _dio.request<Object?>(
          refreshEndpoint,
          data: dataFormat,
          options: Options(
            method: 'POST',
            headers: {
              'lang': DBService.languageCode,
              'content-type': Headers.jsonContentType,
            },
          ),
        );

        if (response.statusCode != null &&
            response.statusCode! >= 200 &&
            response.statusCode! < 300) {
          final data = response.data;
          if (data is Map<String, Object?>) {
            final access = '${data['access_token'] ?? ''}'.trim();
            final refresh = '${data['refresh_token'] ?? ''}'.trim();

            if (access.isNotEmpty) {
              // Update tokens based on path
              if (normalized.contains('/auth/admin/')) {
                DBService.superAdminAccessToken = access;
                if (refresh.isNotEmpty) {
                  DBService.superAdminRefreshToken = refresh;
                }
              } else if (normalized.contains('/tour/')) {
                DBService.tourAccessToken = access;
                if (refresh.isNotEmpty) {
                  DBService.tourRefreshToken = refresh;
                }
              } else if (normalized.contains('/sadaqa/')) {
                DBService.accessToken = access;
                if (refresh.isNotEmpty) {
                  DBService.refreshToken = refresh;
                }
              }
              return true;
            }
          }
        }
      } catch (e) {
        // Try next format
        continue;
      }
    }

    return false;
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
