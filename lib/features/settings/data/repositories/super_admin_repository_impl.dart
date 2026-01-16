import 'package:dio/dio.dart';
import 'package:safa_app/core/constants/api_constants.dart';
import 'package:safa_app/core/service/api_service.dart';
import 'package:safa_app/core/service/db_service.dart';
import 'package:safa_app/features/sadaqa/domain/entities/sadaqa_company.dart';
import 'package:safa_app/features/settings/domain/entities/admin_auth_tokens.dart';
import 'package:safa_app/features/settings/domain/repositories/super_admin_repository.dart';
import 'package:safa_app/features/travel/domain/entities/travel_company.dart';

class SuperAdminRepositoryImpl implements SuperAdminRepository {
  @override
  Future<AdminAuthTokens> login({
    required String login,
    required String password,
  }) async {
    _clearTokens();
    final response = await ApiService.request<Map<String, Object?>>(
      ApiConstants.superAdminLogin,
      method: Method.post,
      data: {'login': login, 'password': password},
      includeAuthHeader: false,
    );

    final tokens = _mapTokens(response);
    _storeTokens(tokens);
    return tokens;
  }

  @override
  Future<void> createTourCompany({
    required String companyName,
    required String logo,
    required double rating,
    required String username,
    required String password,
  }) async {
    await ApiService.request<Object?>(
      ApiConstants.superAdminCreateTourCompany,
      method: Method.post,
      data: {
        'logo': logo,
        'comp_name': companyName,
        'rating': rating,
        'username': username,
        'password': password,
      },
      followRedirects: true,
    );
  }

  @override
  Future<void> createSadaqaCompany({
    required String title,
    required String whyCollecting,
    required String image,
    required String payment,
    required String login,
    required String password,
  }) async {
    await ApiService.request<Object?>(
      ApiConstants.superAdminCreateSadaqaCompany,
      method: Method.post,
      data: {
        'title': title,
        'why_collecting': whyCollecting,
        'image': image,
        'payment': payment,
        'login': login,
        'password': password,
      },
      followRedirects: true,
    );
  }

  @override
  Future<void> createLanguage({
    required String code,
    required String title,
  }) async {
    await ApiService.request<Object?>(
      ApiConstants.superAdminCreateLanguage,
      method: Method.post,
      data: {'code': code, 'title': title},
      followRedirects: true,
    );
  }

  @override
  Future<List<TravelCompany>> fetchTourCompanies() async {
    final response = await ApiService.request<List<dynamic>>(
      ApiConstants.travelCompanies,
      method: Method.get,
    );
    return response
        .whereType<Map<String, Object?>>()
        .map(TravelCompany.fromJson)
        .toList();
  }

  @override
  Future<List<SadaqaCompany>> fetchSadaqaCompanies() async {
    final response = await ApiService.request<List<dynamic>>(
      ApiConstants.sadaqaCompanies,
      method: Method.get,
    );
    return response
        .whereType<Map<String, Object?>>()
        .map(SadaqaCompany.fromJson)
        .toList();
  }

  @override
  Future<List<LanguageItem>> fetchLanguages() async {
    final response = await ApiService.request<List<dynamic>>(
      '/api/sadaqa/public/languages/',
      method: Method.get,
    );
    return response
        .whereType<Map<String, Object?>>()
        .map(
          (json) => LanguageItem(
            id: (json['id'] as num?)?.toInt() ?? 0,
            code: '${json['code'] ?? ''}',
            title: '${json['title'] ?? ''}',
          ),
        )
        .where((lang) => lang.code.isNotEmpty)
        .toList();
  }

  @override
  Future<String> uploadImage(String path) async {
    final fileName = path.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(path, filename: fileName),
    });

    final headers = DBService.superAdminAccessToken.isNotEmpty
        ? {'Authorization': 'Bearer ${DBService.superAdminAccessToken}'}
        : null;

    final response = await ApiService.request<Map<String, Object?>>(
      ApiConstants.uploadFile,
      method: Method.post,
      formData: formData,
      headers: headers,
      followRedirects: true,
    );

    final url = response['url'] ?? response['path'] ?? response['file'];
    final normalized = '$url'.trim();
    if (normalized.isEmpty) throw Exception('Не удалось загрузить файл');
    return normalized;
  }

  AdminAuthTokens _mapTokens(Map<String, Object?> json) {
    final access = '${json['access_token'] ?? ''}'.trim();
    final refresh = '${json['refresh_token'] ?? ''}'.trim();
    final type = '${json['token_type'] ?? 'bearer'}'.trim();

    if (access.isEmpty) {
      throw Exception('Не удалось получить токен супер админа');
    }

    return AdminAuthTokens(
      accessToken: access,
      refreshToken: refresh.isNotEmpty ? refresh : null,
      tokenType: type,
    );
  }

  void _storeTokens(AdminAuthTokens tokens) {
    DBService.superAdminAccessToken = tokens.accessToken;
    if (tokens.refreshToken?.isNotEmpty == true) {
      DBService.superAdminRefreshToken = tokens.refreshToken!;
    }
  }

  void _clearTokens() {
    DBService.superAdminAccessToken = '';
    DBService.superAdminRefreshToken = '';
  }
}
