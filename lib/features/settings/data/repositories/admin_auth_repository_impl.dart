import 'package:safa_app/core/constants/api_constants.dart';
import 'package:safa_app/core/service/api_service.dart';
import 'package:safa_app/core/service/db_service.dart';
import 'package:safa_app/features/settings/domain/entities/admin_auth_tokens.dart';
import 'package:safa_app/features/settings/domain/repositories/admin_auth_repository.dart';

class AdminAuthRepositoryImpl implements AdminAuthRepository {
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
