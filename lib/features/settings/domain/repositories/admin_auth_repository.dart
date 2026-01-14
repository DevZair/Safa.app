import 'package:safa_app/features/settings/domain/entities/admin_login_result.dart';

abstract class AdminAuthRepository {
  Future<AdminLoginResult> login({
    required String login,
    required String password,
  });
}
