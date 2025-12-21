import 'package:safa_app/core/constants/api_constants.dart';
import 'package:safa_app/core/service/api_service.dart';
import 'package:safa_app/core/service/db_service.dart';

class AdminAuthTokens {
  AdminAuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
  });

  final String accessToken;
  final String? refreshToken;
  final String tokenType;
}

class AdminAuthRepository {
  Future<AdminAuthTokens> login({
    required String login,
    required String password,
  }) async {
    final response = await ApiService.request<Map<String, Object?>>(
      ApiConstants.sadaqaAdminLogin,
      method: Method.post,
      data: {'login': login, 'password': password},
    );

    final access = '${response['access_token'] ?? ''}'.trim();
    final refresh = '${response['refresh_token'] ?? ''}'.trim();
    final type = '${response['token_type'] ?? 'bearer'}'.trim();

    if (access.isEmpty) {
      throw Exception('Не удалось получить токен');
    }

    DBService.accessToken = access;
    if (refresh.isNotEmpty) {
      DBService.refreshToken = refresh;
    }

    return AdminAuthTokens(
      accessToken: access,
      refreshToken: refresh.isNotEmpty ? refresh : null,
      tokenType: type,
    );
  }
}
