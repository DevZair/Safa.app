import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:safa_app/core/constants/api_constants.dart';
import 'package:safa_app/core/service/api_service.dart';
import 'package:safa_app/core/service/db_service.dart';
import 'package:safa_app/features/sadaqa/models/sadaqa_company.dart';
import 'package:safa_app/features/sadaqa/models/sadaqa_cause.dart';
import 'package:safa_app/features/sadaqa/models/sadaqa_post.dart';
import 'package:safa_app/features/sadaqa/utils/media_resolver.dart';

class SadaqaRepository {
  static const _postsCacheKey = 'cache_sadaqa_posts';
  static const _notesCacheKey = 'cache_sadaqa_notes';

  Future<List<SadaqaCause>> fetchCauses() async {
    final basePaths = <String>{
      ApiConstants.sadaqaCauses,
      '/api/sadaqa/public/notes',
      '/api/sadaqa/public/posts',
      '/api/sadaqa/donation',
      
      '/sadaqa/donations',
      '/sadaqa/donation',
    };

    final paths = <String>{};
    for (final path in basePaths) {
      paths.add(path);
      if (!path.endsWith('/')) paths.add('$path/');
    }

    Object? data;
    Object? lastError;

    for (final path in paths) {
      try {
        data = await ApiService.request<Object?>(path, method: Method.get);
        lastError = null;
        break;
      } catch (error) {
        lastError = error;
        continue;
      }
    }

    if (data == null && lastError != null) {
      throw lastError;
    }

    final list = _unwrapList(data);

    return list
        .map(SadaqaCause.fromJson)
        .where((item) => item.id.isNotEmpty)
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
      // Treat a single object as a one-item list when API returns a map.
      if (data['id'] != null || data['title'] != null) {
        return [data];
      }
    }

    return [];
  }

  Future<List<SadaqaCompany>> fetchCompanies() async {
    final basePaths = <String>{
      ApiConstants.sadaqaCompanies,
      '/api/sadaqa/public/company',
      '/sadaqa/public/company',
    };

    final paths = <String>{};
    for (final path in basePaths) {
      paths.add(path);
      if (!path.endsWith('/')) paths.add('$path/');
    }

    Object? data;
    Object? lastError;

    for (final path in paths) {
      try {
        data = await ApiService.request<Object?>(path, method: Method.get);
        lastError = null;
        break;
      } catch (error) {
        lastError = error;
        continue;
      }
    }

    if (data == null && lastError != null) throw lastError;

    final list = _unwrapList(data);

    return list
        .map(SadaqaCompany.fromJson)
        .where((company) => company.id.isNotEmpty)
        .toList();
  }

  Future<List<SadaqaPost>> fetchPosts({String? companyId}) async {
    final cacheKey = _cacheKey(_postsCacheKey, companyId);
    final cached = _readCachedPosts(cacheKey);

    try {
    final basePaths = <String>{
      '/api/sadaqa/public/posts',
      '/api/sadaqa/public/posts/',
      '/sadaqa/public/posts',
      '/sadaqa/public/posts/',
    };

    Object? data;
    Object? lastError;

    for (final path in basePaths) {
      try {
        data = await ApiService.request<Object?>(path, method: Method.get);
        lastError = null;
        break;
      } catch (error) {
        lastError = error;
        continue;
      }
    }

    if (data == null && lastError != null) throw lastError;

    final list = _unwrapList(data);
    final posts = list
        .map(SadaqaPost.fromJson)
        .where((post) => post.id.isNotEmpty)
        .toList();
    _writeCachedPosts(cacheKey, posts);

    if (companyId == null || companyId.isEmpty) return posts;
    return posts
        .where((post) => post.companyId != null && post.companyId == companyId)
        .toList();
    } catch (error) {
      if (cached != null) return cached;
      rethrow;
    }
  }

  Future<List<SadaqaPost>> fetchAdminPosts() async {
    final basePaths = <String>{
      ApiConstants.sadaqaAdminPosts,
      '${ApiConstants.sadaqaAdminPosts}/',
    };

    Object? data;
    Object? lastError;

    for (final path in basePaths) {
      try {
        data = await ApiService.request<Object?>(
          path,
          method: Method.get,
          followRedirects: true,
        );
        lastError = null;
        break;
      } catch (error) {
        lastError = error;
        continue;
      }
    }

    if (data == null && lastError != null) throw lastError;

    final list = _unwrapList(data);
    return list
        .map(SadaqaPost.fromJson)
        .where((post) => post.id.isNotEmpty)
        .toList();
  }

  Future<List<SadaqaPost>> fetchAdminNotes() async {
    final basePaths = <String>{
      ApiConstants.sadaqaAdminNotes,
      '${ApiConstants.sadaqaAdminNotes}/',
    };

    Object? data;
    Object? lastError;

    for (final path in basePaths) {
      try {
        data = await ApiService.request<Object?>(
          path,
          method: Method.get,
          followRedirects: true,
        );
        lastError = null;
        break;
      } catch (error) {
        lastError = error;
        continue;
      }
    }

    if (data == null && lastError != null) throw lastError;

    final list = _unwrapList(data);
    return list
        .map(SadaqaPost.fromJson)
        .where((post) => post.id.isNotEmpty)
        .toList();
  }

  Future<List<SadaqaPost>> fetchNotes({String? companyId}) async {
    final cacheKey = _cacheKey(_notesCacheKey, companyId);
    final cached = _readCachedPosts(cacheKey);

    try {
    final basePaths = <String>{
      '/api/sadaqa/public/notes/active',
      '/api/sadaqa/public/notes/active/',
      '/api/sadaqa/public/notes',
      '/api/sadaqa/public/notes/',
      '/sadaqa/public/notes',
      '/sadaqa/public/notes/',
    };

    Object? data;
    Object? lastError;

    for (final path in basePaths) {
      try {
        final query = <String, Object?>{};
        if (companyId != null && companyId.isNotEmpty) {
          query['company_id'] = companyId;
        }
        data = await ApiService.request<Object?>(
          path,
          method: Method.get,
          queryParams: query.isEmpty ? null : query,
          followRedirects: true,
        );
        lastError = null;
        break;
      } catch (error) {
        lastError = error;
        continue;
      }
    }

    if (data == null && lastError != null) throw lastError;

    final list = _unwrapList(data);
    final notes = list
        .map(SadaqaPost.fromJson)
        .where((post) => post.id.isNotEmpty)
        .toList();
    _writeCachedPosts(cacheKey, notes);

    if (companyId == null || companyId.isEmpty) return notes;
    return notes
        .where((note) => note.companyId != null && note.companyId == companyId)
        .toList();
    } catch (error) {
      if (cached != null) return cached;
      rethrow;
    }
  }

  Future<SadaqaPost?> fetchActiveNote({String? companyId}) async {
    final basePaths = <String>{
      '/api/sadaqa/public/notes/active',
      '/api/sadaqa/public/notes/active/',
    };

    Object? lastError;
    for (final path in basePaths) {
      try {
        final query = <String, Object?>{};
        if (companyId != null && companyId.isNotEmpty) {
          query['company_id'] = companyId;
        }

        final data = await ApiService.request<Object?>(
          path,
          method: Method.get,
          queryParams: query.isEmpty ? null : query,
          followRedirects: true,
        );

        if (data is Map<String, Object?>) {
          return SadaqaPost.fromJson(data);
        }
        if (data is List && data.isNotEmpty) {
          final first =
              data.firstWhere((e) => e is Map<String, Object?>, orElse: () => {});
          if (first is Map<String, Object?>) {
            return SadaqaPost.fromJson(first);
          }
        }
      } catch (error) {
        lastError = error;
        continue;
      }
    }

    if (lastError != null) throw lastError;
    return null;
  }

  String _cacheKey(String base, String? companyId) {
    if (companyId == null || companyId.isEmpty) return base;
    return '$base:$companyId';
  }

  List<SadaqaPost>? _readCachedPosts(String key) {
    final raw = $storage.getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, Object?>>()
            .map(SadaqaPost.fromJson)
            .toList();
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  void _writeCachedPosts(String key, List<SadaqaPost> posts) {
    final jsonList = posts.map((e) => e.toJson()).toList();
    $storage.setString(key, jsonEncode(jsonList));
  }

  Future<SadaqaCompany> updateCompanyProfile({
    String? title,
    String? image,
    String? logo,
    String? cover,
    String? payment,
    String? whyCollecting,
  }) async {
    final resolvedImage = (image ?? cover ?? logo);
    final payload = <String, Object?>{
      if (title != null) 'title': title,
      if (resolvedImage != null) 'image': resolvedImage,
      if (payment != null) 'payment': payment,
      if (whyCollecting != null) 'why_collecting': whyCollecting,
    };

    final pathsToTry = <String>{
      '/api/sadaqa/private/company/me',
      '/api/sadaqa/private/company/me/',
      '/api/sadaqa/private/company',
      '/api/sadaqa/private/company/',
    };
    final methodsToTry = <Method>[Method.put, Method.patch];

    Object? lastError;
    for (final method in methodsToTry) {
      for (final path in pathsToTry) {
        try {
          final response = await _requestWithRedirect<Map<String, Object?>>(
            path: path,
            method: method,
            data: payload,
          );
          final data = response['data'];
          if (data is Map<String, Object?>) {
            return SadaqaCompany.fromJson(data);
          }
          return SadaqaCompany.fromJson(response);
        } catch (error) {
          lastError = error;
          continue;
        }
      }
    }

    if (lastError != null) throw lastError;

    return SadaqaCompany.fromJson({
      'id': '',
      'title': title ?? '',
      'logo': logo ?? '',
      'cover': cover ?? '',
    });
  }

  Future<SadaqaPost> updatePost({
    required String postId,
    String? title,
    String? content,
    String? image,
  }) async {
    final basePath =
        '${ApiConstants.sadaqaAdminPosts}${postId.startsWith('/') ? '' : '/'}$postId';

    final payload = <String, Object?>{
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (image != null) 'image': image,
    };

    final pathsToTry = <String>{
      basePath,
      if (!basePath.endsWith('/')) '$basePath/',
    };
    final methodsToTry = <Method>[Method.patch, Method.put];

    Object? lastError;
    for (final method in methodsToTry) {
      for (final path in pathsToTry) {
        try {
          final response = await _requestWithRedirect<Map<String, Object?>>(
            path: path,
            method: method,
            data: payload,
          );
          final parsed = _parsePostFromResponse(response, fallbackId: postId);
          return parsed;
        } catch (error) {
          lastError = error;
          continue;
        }
      }
    }

    if (lastError != null) {
      throw lastError;
    }

    // Fallback to constructing with provided data
    return SadaqaPost.fromJson({
      'id': postId,
      'title': title ?? '',
      'content': content ?? '',
      'image': image ?? '',
    });
  }

  Future<SadaqaPost> createPost({
    String? title,
    String? content,
    String? image,
  }) async {
    const languageIds = {
      'ru': 1,
      'kk': 2,
      'uz': 3,
      'en': 4,
    };
    final languageId = languageIds[DBService.languageCode] ?? 0;

    final payload = <String, Object?>{
      'language_id': languageId,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (image != null) 'image': image,
    };

    final paths = <String>{
      ApiConstants.sadaqaAdminPosts,
      '${ApiConstants.sadaqaAdminPosts}/',
    };

    Object? lastError;
    for (final path in paths) {
      try {
        final response = await _requestWithRedirect<Map<String, Object?>>(
          path: path,
          method: Method.post,
          data: payload,
        );
        return _parsePostFromResponse(response, fallbackId: '');
      } catch (error) {
        lastError = error;
        continue;
      }
    }

    if (lastError != null) throw lastError;

    return SadaqaPost.fromJson({
      'id': '',
      'title': title ?? '',
      'content': content ?? '',
      'image': image ?? '',
    });
  }

  SadaqaPost _parsePostFromResponse(
    Map<String, Object?> response, {
    required String fallbackId,
  }) {
    final data = response['data'];
    if (data is Map<String, Object?>) {
      return SadaqaPost.fromJson(data);
    }
    if (response.isNotEmpty) {
      return SadaqaPost.fromJson(response);
    }
    return SadaqaPost.fromJson({
      'id': fallbackId,
      'title': '${response['title'] ?? ''}',
      'content': '${response['content'] ?? ''}',
      'image': '${response['image'] ?? ''}',
    });
  }

  Future<String> uploadImage(String path) async {
    final fileName = path.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(path, filename: fileName),
    });

    final response = await ApiService.request<Map<String, Object?>>(
      ApiConstants.uploadFile,
      method: Method.post,
      formData: formData,
      followRedirects: true,
    );

    final url = response['url'] ?? response['path'] ?? response['file'];
    if (url is String && url.isNotEmpty) {
      return resolveMediaUrl(url);
    }
    throw Exception('Не удалось загрузить файл');
  }

  Future<void> deletePost(String postId) async {
    final basePath =
        '${ApiConstants.sadaqaAdminPosts}${postId.startsWith('/') ? '' : '/'}$postId';
    final paths = <String>{
      basePath,
      if (!basePath.endsWith('/')) '$basePath/',
    };
    Object? lastError;
    for (final path in paths) {
      try {
        await _requestWithRedirect<Object?>(
          path: path,
          method: Method.delete,
        );
        lastError = null;
        break;
      } catch (error) {
        lastError = error;
        continue;
      }
    }
    if (lastError != null) throw lastError;
  }

  Future<void> deleteNote(String noteId) async {
    final basePath =
        '${ApiConstants.sadaqaAdminNotes}${noteId.startsWith('/') ? '' : '/'}$noteId';
    final paths = <String>{
      basePath,
      if (!basePath.endsWith('/')) '$basePath/',
    };
    Object? lastError;
    for (final path in paths) {
      try {
        await _requestWithRedirect<Object?>(
          path: path,
          method: Method.delete,
        );
        lastError = null;
        break;
      } catch (error) {
        lastError = error;
        continue;
      }
    }
    if (lastError != null) throw lastError;
  }

  Future<SadaqaPost> updateNote({
    required String noteId,
    String? title,
    String? content,
    String? image,
    int? status,
    String? noteType,
    String? address,
    double? goalMoney,
    double? collectedMoney,
  }) async {
    final pathsToTry = <String>{
      '${ApiConstants.sadaqaAdminNotes}/$noteId',
      '${ApiConstants.sadaqaAdminNotes}/$noteId/',
    };
    final payload = <String, Object?>{
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (image != null) 'image': image,
      if (status != null) 'status': status,
      if (noteType != null) 'note_type': noteType,
      if (address != null) 'address': address,
      if (goalMoney != null) 'goal_money': goalMoney,
      if (collectedMoney != null) 'collected_money': collectedMoney,
    };
    Object? lastError;
    for (final path in pathsToTry) {
      try {
        final response = await _requestWithRedirect<Map<String, Object?>>(
          path: path,
          method: Method.put,
          data: payload,
        );
        return _parsePostFromResponse(response, fallbackId: noteId);
      } catch (error) {
        lastError = error;
        continue;
      }
    }
    if (lastError != null) throw lastError;
    return SadaqaPost.fromJson({
      'id': noteId,
      'title': title ?? '',
      'content': content ?? '',
      'image': image ?? '',
    });
  }

  Future<SadaqaPost> createNote({
    String? title,
    String? content,
    String? image,
    String? noteType,
    String? address,
    double? goalMoney,
    double? collectedMoney,
    int? status,
  }) async {
    const languageIds = {
      'ru': 1,
      'kk': 2,
      'uz': 3,
      'en': 4,
    };
    final languageId = languageIds[DBService.languageCode] ?? 0;

    final payload = <String, Object?>{
      'language_id': languageId,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (image != null) 'image': image,
      if (noteType != null) 'note_type': noteType,
      if (address != null) 'address': address,
      if (goalMoney != null) 'goal_money': goalMoney,
      if (collectedMoney != null) 'collected_money': collectedMoney,
      if (status != null) 'status': status,
    };

    final paths = <String>{
      ApiConstants.sadaqaAdminNotes,
      '${ApiConstants.sadaqaAdminNotes}/',
    };

    Object? lastError;
    for (final path in paths) {
      try {
        final response = await _requestWithRedirect<Map<String, Object?>>(
          path: path,
          method: Method.post,
          data: payload,
        );
        return _parsePostFromResponse(response, fallbackId: '');
      } catch (error) {
        lastError = error;
        continue;
      }
    }

    if (lastError != null) throw lastError;

    return SadaqaPost.fromJson({
      'id': '',
      'title': title ?? '',
      'content': content ?? '',
      'image': image ?? '',
    });
  }

  Future<T> _requestWithRedirect<T>({
    required String path,
    required Method method,
    Object? data,
    FormData? formData,
  }) async {
    try {
      return await ApiService.request<T>(
        path,
        method: method,
        data: data,
        formData: formData,
        followRedirects: true,
      );
    } on DioException catch (error) {
      final location = error.response?.headers.value('location');
      if (location != null && location.isNotEmpty) {
        return await ApiService.request<T>(
          location,
          method: method,
          data: data,
          formData: formData,
          followRedirects: true,
        );
      }
      rethrow;
    }
  }
}
