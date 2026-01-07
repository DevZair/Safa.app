import 'package:safa_app/features/settings/domain/entities/admin_auth_tokens.dart';

abstract class AdminAuthRepository {
  Future<AdminAuthTokens> login({
    required String login,
    required String password,
  });
}
