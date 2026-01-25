import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:safa_app/core/constants/api_constants.dart';
import 'package:safa_app/core/service/api_service.dart';
import 'package:safa_app/core/service/db_service.dart';
import 'package:safa_app/features/sadaqa/domain/entities/sadaqa_company.dart';
import 'package:safa_app/features/sadaqa/domain/entities/sadaqa_cause.dart';
import 'package:safa_app/features/sadaqa/domain/entities/help_request.dart';
import 'package:safa_app/features/sadaqa/domain/entities/sadaqa_post.dart';
import 'package:safa_app/features/sadaqa/domain/entities/reference_item.dart';
import 'package:safa_app/features/sadaqa/domain/repositories/sadaqa_repository.dart';
import 'package:safa_app/features/sadaqa/domain/utils/media_resolver.dart';

class SadaqaRepositoryImpl implements SadaqaRepository {
  static const _postsCacheKey = 'cache_sadaqa_posts';
  static const _notesCacheKey = 'cache_sadaqa_notes';
  static const _activeNoteCacheKey = 'cache_sadaqa_active_note';

  @override
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

  SadaqaPost? _extractActiveNote(Object? data) {
    if (data is Map<String, Object?>) {
      return SadaqaPost.fromJson(data);
    }
    if (data is List && data.isNotEmpty) {
      final first =
          data.firstWhere((e) => e is Map<String, Object?>, orElse: () => null);
      if (first is Map<String, Object?>) {
        return SadaqaPost.fromJson(first);
      }
    }
    return null;
  }

  @override
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

  @override
  Future<SadaqaCompany?> fetchCompanyDetail(String companyId) async {
    if (companyId.isEmpty) return null;

    final basePaths = <String>{
      '${ApiConstants.sadaqaCompanies}$companyId',
      '${ApiConstants.sadaqaCompanies}$companyId/',
      '/api/sadaqa/public/company/$companyId',
      '/api/sadaqa/public/company/$companyId/',
      '/sadaqa/public/company/$companyId',
      '/sadaqa/public/company/$companyId/',
    };

    Object? lastError;

    for (final path in basePaths) {
      try {
        final response = await ApiService.request<Object?>(
          path,
          method: Method.get,
          followRedirects: true,
        );

        if (response is Map<String, Object?>) {
          final data = response['data'];
          if (data is Map<String, Object?>) {
            return SadaqaCompany.fromJson(data);
          }
          return SadaqaCompany.fromJson(response);
        }
      } catch (error) {
        lastError = error;
        continue;
      }
    }

    if (lastError != null) {
      debugPrint('Failed to load company detail: $lastError');
    }

    return null;
  }

  @override
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

  @override
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

  @override
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

  @override
  Future<List<HelpRequest>> fetchHelpRequests() async {
    final basePaths = <String>{
      ApiConstants.sadaqaHelpRequests,
      '${ApiConstants.sadaqaHelpRequests}/',
      '${ApiConstants.sadaqaHelpRequests}my',
      '${ApiConstants.sadaqaHelpRequests}my/',
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
    final requests = list
        .map(HelpRequest.fromJson)
        .where((item) => item.id.isNotEmpty)
        .toList();

    if (requests.isEmpty) return requests;

    Map<int, String> categoryTitles = const {};
    Map<int, String> materialStatusTitles = const {};

    try {
    final lookups = await Future.wait<List<ReferenceItem>>([
      _fetchPrivateHelpCategories(),
      _fetchPrivateMaterialStatuses(),
    ]);
    final categories = lookups[0];
    final materials = lookups[1];
    categoryTitles = {for (final item in categories) item.id: item.title};
    materialStatusTitles = {for (final item in materials) item.id: item.title};
    } catch (error) {
      debugPrint('Failed to enrich help requests: $error');
    }

    if (categoryTitles.isEmpty && materialStatusTitles.isEmpty) {
      return requests;
    }

    return requests.map((item) {
      final categoryTitle = item.helpCategoryTitle ??
          (item.helpCategoryId != null
              ? categoryTitles[item.helpCategoryId!]
              : null);
      final materialTitle = item.materialStatusTitle ??
          (item.materialStatusId != null
              ? materialStatusTitles[item.materialStatusId!]
              : null);

      if (categoryTitle == item.helpCategoryTitle &&
          materialTitle == item.materialStatusTitle) {
        return item;
      }

      return item.copyWith(
        helpCategoryTitle: categoryTitle,
        materialStatusTitle: materialTitle,
      );
    }).toList(growable: false);
  }

  @override
  Future<HelpRequest?> updateHelpRequestStatus({
    required String id,
    required HelpRequestStatus status,
  }) async {
    final basePaths = <String>{
      '${ApiConstants.sadaqaHelpRequests}$id',
      '${ApiConstants.sadaqaHelpRequests}$id/',
    };

    Object? lastError;

    for (final path in basePaths) {
      try {
        final response = await ApiService.request<Object?>(
          path,
          method: Method.put,
          data: {'status': status.value},
          queryParams: {'help_request_id': id},
          followRedirects: true,
        );

        if (response is Map<String, Object?>) {
          final data = response['data'];
          if (data is Map<String, Object?>) {
            return HelpRequest.fromJson(data);
          }
          return HelpRequest.fromJson(response);
        }

        return null;
      } catch (error) {
        lastError = error;
        continue;
      }
    }

    if (lastError != null) throw lastError;
    return null;
  }

  @override
  Future<List<ReferenceItem>> fetchPrivateMaterialStatusList() async {
    return _fetchPrivateMaterialStatuses();
  }

  @override
  Future<List<ReferenceItem>> fetchPrivateHelpCategoryList() async {
    return _fetchPrivateHelpCategories();
  }

  @override
  Future<ReferenceItem?> createMaterialStatus(String title,
      {bool isActive = true}) async {
    final created = await _createLookup(
      basePath: ApiConstants.sadaqaPrivateMaterialStatuses,
      title: title,
      extra: {
        'language_id': _languageId(),
        'status': isActive ? 0 : 1,
        'is_active': isActive ? 0 : 1,
        'active': isActive ? 0 : 1,
      },
    );
    if (created != null) {
      _cacheMaterialStatus(created.id, isActive);
    }
    return created;
  }

  @override
  Future<bool> deleteMaterialStatus(int id) async {
    final deleted = await _deleteLookup(
      basePath: ApiConstants.sadaqaPrivateMaterialStatuses,
      id: id,
    );
    if (deleted) {
      _removeMaterialStatusFromCache(id);
    }
    return deleted;
  }

  @override
  Future<ReferenceItem?> updateMaterialStatus({
    required int id,
    required String title,
    bool isActive = true,
  }) async {
    final updated = await _updateLookup(
      basePath: ApiConstants.sadaqaPrivateMaterialStatuses,
      id: id,
      title: title,
      extra: {
        'language_id': _languageId(),
        'status': isActive ? 0 : 1,
        'is_active': isActive ? 0 : 1,
        'active': isActive ? 0 : 1,
      },
    );
    if (updated != null) {
      _cacheMaterialStatus(updated.id, isActive);
    }
    return updated;
  }

  @override
  Future<ReferenceItem?> createHelpCategory(
    String title, {
    bool isOther = false,
  }) async {
    return _createLookup(
      basePath: ApiConstants.sadaqaPrivateHelpCategories,
      title: title,
      extra: {
        'language_id': _languageId(),
        'is_other': isOther,
      },
    );
  }

  @override
  Future<bool> deleteHelpCategory(int id) async {
    return _deleteLookup(
      basePath: ApiConstants.sadaqaPrivateHelpCategories,
      id: id,
    );
  }

  @override
  Future<ReferenceItem?> updateHelpCategory({
    required int id,
    required String title,
    bool isOther = false,
  }) async {
    return _updateLookup(
      basePath: ApiConstants.sadaqaPrivateHelpCategories,
      id: id,
      title: title,
      extra: {
        'language_id': _languageId(),
        'is_other': isOther,
      },
    );
  }

  Future<List<ReferenceItem>> _fetchPrivateMaterialStatuses() async {
    final paths = <String>{
      ApiConstants.sadaqaPrivateMaterialStatuses,
      '${ApiConstants.sadaqaPrivateMaterialStatuses}my',
      '/api/sadaqa/private/materials_status/',
      '/api/sadaqa/private/materials_status/my',
    };

    final normalized = <String>{};
    for (final path in paths) {
      normalized.add(path);
      if (!path.endsWith('/')) normalized.add('$path/');
    }

    List<Map<String, Object?>> data = const [];
    Object? lastError;

    for (final path in normalized) {
      try {
        final response = await ApiService.request<Object?>(
          path,
          method: Method.get,
          followRedirects: true,
        );
        data = _unwrapList(response);
        lastError = null;
        break;
      } catch (error) {
        lastError = error;
        continue;
      }
    }

    if (data.isEmpty && lastError != null) {
      debugPrint('Failed to load material statuses: $lastError');
    }

    final cachedStates = _readCachedMaterialStatuses();

    final list = <ReferenceItem>[];
    for (final item in data) {
      final id = _asInt(item['id']);
      final title = _asString(item['title'] ?? item['name']);
      final rawStatus = _parseMaterialStatusActive(
        item['status'] ?? item['is_active'] ?? item['active'],
      );
      final status = rawStatus ?? cachedStates[id] ?? true;
      if (id != null && id > 0 && title != null && title.isNotEmpty) {
        list.add(ReferenceItem(id: id, title: title, isActive: status));
        _cacheMaterialStatus(id, status);
      }
    }
    return list;
  }

  Future<List<ReferenceItem>> _fetchPrivateHelpCategories() async {
    final paths = <String>{
      ApiConstants.sadaqaPrivateHelpCategories,
      '${ApiConstants.sadaqaPrivateHelpCategories}my',
      '/api/sadaqa/private/help_categories/',
      '/api/sadaqa/private/help_categories/my',
    };

    final normalized = <String>{};
    for (final path in paths) {
      normalized.add(path);
      if (!path.endsWith('/')) normalized.add('$path/');
    }

    List<Map<String, Object?>> data = const [];
    Object? lastError;

    for (final path in normalized) {
      try {
        final response = await ApiService.request<Object?>(
          path,
          method: Method.get,
          followRedirects: true,
        );
        data = _unwrapList(response);
        lastError = null;
        break;
      } catch (error) {
        lastError = error;
        continue;
      }
    }

    if (data.isEmpty && lastError != null) {
      debugPrint('Failed to load help categories: $lastError');
    }

    final list = <ReferenceItem>[];
    for (final item in data) {
      final id = _asInt(item['id']);
      final title = _asString(item['title'] ?? item['name']);
      final status =
          _asBool(item['status'] ?? item['is_active'] ?? item['active']) ??
              true;
      if (id != null && id > 0 && title != null && title.isNotEmpty) {
        list.add(
          ReferenceItem(
            id: id,
            title: title,
            isActive: status,
          ),
        );
      }
    }
    return list;
  }

  Future<ReferenceItem?> _createLookup({
    required String basePath,
    required String title,
    Map<String, Object?> extra = const {},
  }) async {
    final paths = <String>{
      basePath,
      '$basePath/',
      basePath.replaceAll('_', '-'),
      '${basePath.replaceAll('_', '-')}/',
    };

    final payload = {'title': title, ...extra};

    for (final path in paths) {
      try {
        final response = await ApiService.request<Object?>(
          path,
          method: Method.post,
          data: payload,
          followRedirects: true,
        );

        if (response is Map<String, Object?>) {
          final data = response['data'];
          final body = data is Map<String, Object?> ? data : response;
          final id = _asInt(body['id']);
          final resolvedTitle = _asString(body['title']) ?? title;
          final resolvedStatus = _resolveLookupStatus(
            basePath: basePath,
            body: body,
            extra: extra,
          );
          if (id != null) {
            return ReferenceItem(
              id: id,
              title: resolvedTitle,
              isActive: resolvedStatus ?? true,
            );
          }
        }
      } catch (error) {
        debugPrint('Failed to create lookup $basePath: $error');
        continue;
      }
    }
    return null;
  }

  Future<ReferenceItem?> _updateLookup({
    required String basePath,
    required int id,
    required String title,
    Map<String, Object?> extra = const {},
  }) async {
    final normalizedBase = <String>{basePath, basePath.replaceAll('_', '-')};
    final paths = <String>{};
    for (final base in normalizedBase) {
      paths.add('$base$id');
      paths.add('$base$id/');
    }

    final payload = {'title': title, ...extra};

    for (final path in paths) {
      try {
        final response = await ApiService.request<Object?>(
          path,
          method: Method.put,
          data: payload,
          followRedirects: true,
        );

        if (response is Map<String, Object?>) {
          final data = response['data'];
          final body = data is Map<String, Object?> ? data : response;
          final resolvedId = _asInt(body['id']) ?? id;
          final resolvedTitle = _asString(body['title']) ?? title;
          final resolvedStatus = _resolveLookupStatus(
            basePath: basePath,
            body: body,
            extra: extra,
          );
          return ReferenceItem(
            id: resolvedId,
            title: resolvedTitle,
            isActive: resolvedStatus ?? true,
          );
        }
      } catch (error) {
        debugPrint('Failed to update lookup $basePath/$id: $error');
        continue;
      }
    }
    return null;
  }

  Future<bool> _deleteLookup({
    required String basePath,
    required int id,
  }) async {
    final normalizedBase = <String>{basePath, basePath.replaceAll('_', '-')};
    final paths = <String>{};
    for (final base in normalizedBase) {
      paths.add('$base$id');
      paths.add('$base$id/');
    }

    for (final path in paths) {
      try {
        await ApiService.request<String?>(
          path,
          method: Method.delete,
          followRedirects: true,
        );
        return true;
      } catch (error) {
        debugPrint('Failed to delete lookup $path: $error');
        continue;
      }
    }
    return false;
  }

  @override
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

  @override
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

        final note = _extractActiveNote(data);
        if (note != null) {
          _writeCachedActiveNote(companyId, note);
          return note;
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

  @override
  List<SadaqaPost>? readCachedPosts({String? companyId}) {
    final cacheKey = _cacheKey(_postsCacheKey, companyId);
    return _readCachedPosts(cacheKey);
  }

  @override
  SadaqaPost? readCachedActiveNote({String? companyId}) {
    final cacheKey = _cacheKey(_activeNoteCacheKey, companyId);
    final cached = _readCachedPosts(cacheKey);
    if (cached == null || cached.isEmpty) return null;
    return cached.first;
  }

  void _writeCachedActiveNote(String? companyId, SadaqaPost note) {
    final cacheKey = _cacheKey(_activeNoteCacheKey, companyId);
    _writeCachedPosts(cacheKey, [note]);
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

  bool? _resolveLookupStatus({
    required String basePath,
    required Map<String, Object?> body,
    required Map<String, Object?> extra,
  }) {
    final raw = body['status'] ??
        body['is_active'] ??
        body['active'] ??
        extra['status'] ??
        extra['is_active'] ??
        extra['active'];
    if (basePath.contains('materials-status')) {
      return _parseMaterialStatusActive(raw);
    }
    return _asBool(raw);
  }

  bool? _parseMaterialStatusActive(Object? value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value == 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      final asInt = int.tryParse(normalized);
      if (asInt != null) return asInt == 0;
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
    }
    return null;
  }

  Map<int, bool> _readCachedMaterialStatuses() {
    final raw = $storage.getString(StorageKeys.materialStatusCache.name);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded.map(
          (key, value) => MapEntry(int.parse(key), value == true),
        );
      }
    } catch (_) {
      return {};
    }
    return {};
  }

  void _cacheMaterialStatus(int id, bool isActive) {
    if (id <= 0) return;
    final current = _readCachedMaterialStatuses();
    current[id] = isActive;
    $storage.setString(
      StorageKeys.materialStatusCache.name,
      jsonEncode(current.map((key, value) => MapEntry(key.toString(), value))),
    );
  }

  void _removeMaterialStatusFromCache(int id) {
    if (id <= 0) return;
    final current = _readCachedMaterialStatuses();
    if (!current.containsKey(id)) return;
    current.remove(id);
    $storage.setString(
      StorageKeys.materialStatusCache.name,
      jsonEncode(current.map((key, value) => MapEntry(key.toString(), value))),
    );
  }

  int? _asInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value');
  }

  String? _asString(Object? value) {
    if (value == null) return null;
    final text = '$value'.trim();
    return text.isEmpty ? null : text;
  }

  bool? _asBool(Object? value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.toLowerCase().trim();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    return null;
  }

  int _languageId() {
    // API currently expects explicit language_id; default to RU=1 unless specified.
    return 1;
  }

  @override
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

  @override
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

  @override
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

  @override
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

    final url = _normalizeUploadUrl(
      response['url'] ?? response['path'] ?? response['file'],
    );
    if (url.isNotEmpty) return url;
    throw Exception('Не удалось загрузить файл');
  }

  /// Always return an HTTPS URL on the current API host, even if backend
  /// responds with an absolute URL from another tunnel or an http link.
  String _normalizeUploadUrl(Object? value) {
    final raw = '${value ?? ''}'.trim();
    if (raw.isEmpty) return '';

    final normalizedBase =
        ApiConstants.baseUrl.startsWith('http')
            ? ApiConstants.baseUrl
            : 'https://${ApiConstants.baseUrl}';
    final baseUri = Uri.tryParse(normalizedBase);
    if (baseUri == null || baseUri.host.isEmpty) {
      return resolveMediaUrl(raw);
    }

    final parsed = Uri.tryParse(raw);
    final path = switch (parsed) {
      Uri(:final String path) when path.isNotEmpty => path,
      _ => raw,
    };
    final sanitizedPath = path.startsWith('/') ? path : '/$path';
    final query = parsed?.hasQuery == true ? '?${parsed!.query}' : '';
    return '${baseUri.scheme}://${baseUri.authority}$sanitizedPath$query';
  }

  @override
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

  @override
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

  @override
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

  @override
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
