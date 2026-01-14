import 'package:safa_app/core/constants/api_constants.dart';
import 'package:safa_app/core/service/api_service.dart';
import 'package:safa_app/core/service/db_service.dart';
import 'package:safa_app/features/settings/domain/entities/admin_auth_tokens.dart';
import 'package:safa_app/features/settings/domain/entities/admin_login_result.dart';
import 'package:safa_app/features/settings/domain/repositories/admin_auth_repository.dart';

class AdminAuthRepositoryImpl implements AdminAuthRepository {
  Future<AdminLoginResult> login({
    required String login,
    required String password,
  }) async {
    _clearSadaqaTokens();
    _clearTourTokens();

    AdminAuthTokens? sadaqaTokens;
    AdminAuthTokens? tourTokens;
    final errors = <String>[];

    try {
      sadaqaTokens = await _loginAndExtract(
        path: ApiConstants.sadaqaAdminLogin,
        login: login,
        password: password,
      );
      _storeSadaqaTokens(sadaqaTokens);
    } catch (error) {
      _clearSadaqaTokens();
      errors.add('sadaqa: ${Error.safeToString(error)}');
    }

    try {
      tourTokens = await _loginAndExtract(
        path: ApiConstants.tourAdminLogin,
        login: login,
        password: password,
      );
      _storeTourTokens(tourTokens);
    } catch (error) {
      _clearTourTokens();
      errors.add('tour: ${Error.safeToString(error)}');
    }

    if (sadaqaTokens == null && tourTokens == null) {
      throw Exception(
        errors.isNotEmpty
            ? errors.join(' | ')
            : 'Login failed for both services',
      );
    }

    return AdminLoginResult(
      sadaqaSuccess: sadaqaTokens != null,
      tourSuccess: tourTokens != null,
    );
  }

  Future<AdminAuthTokens> _loginAndExtract({
    required String path,
    required String login,
    required String password,
  }) async {
    final isTourLogin = path == ApiConstants.tourAdminLogin;
    final response = await ApiService.request<Map<String, Object?>>(
      path,
      method: Method.post,
      data: isTourLogin ? null : {'login': login, 'password': password},
      queryParams: isTourLogin
          ? {'username': login, 'password': password}
          : null,
      includeAuthHeader: false,
    );

    final access = '${response['access_token'] ?? ''}'.trim();
    final refresh = '${response['refresh_token'] ?? ''}'.trim();
    final type = '${response['token_type'] ?? 'bearer'}'.trim();

    if (access.isEmpty) {
      throw Exception('Не удалось получить токен');
    }

    return AdminAuthTokens(
      accessToken: access,
      refreshToken: refresh.isNotEmpty ? refresh : null,
      tokenType: type,
    );
  }

  void _storeSadaqaTokens(AdminAuthTokens tokens) {
    DBService.accessToken = tokens.accessToken;
    if (tokens.refreshToken?.isNotEmpty == true) {
      DBService.refreshToken = tokens.refreshToken!;
    }
  }

  void _storeTourTokens(AdminAuthTokens tokens) {
    DBService.tourAccessToken = tokens.accessToken;
    if (tokens.refreshToken?.isNotEmpty == true) {
      DBService.tourRefreshToken = tokens.refreshToken!;
    }
  }

  void _clearTourTokens() {
    DBService.tourAccessToken = '';
    DBService.tourRefreshToken = '';
  }

  void _clearSadaqaTokens() {
    DBService.accessToken = '';
    DBService.refreshToken = '';
  }
}
