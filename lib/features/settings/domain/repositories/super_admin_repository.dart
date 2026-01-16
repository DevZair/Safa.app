import 'package:safa_app/features/settings/domain/entities/admin_auth_tokens.dart';
import 'package:safa_app/features/sadaqa/domain/entities/sadaqa_company.dart';
import 'package:safa_app/features/travel/domain/entities/travel_company.dart';

abstract class SuperAdminRepository {
  Future<AdminAuthTokens> login({
    required String login,
    required String password,
  });

  Future<void> createTourCompany({
    required String companyName,
    required String logo,
    required double rating,
    required String username,
    required String password,
  });

  Future<void> createSadaqaCompany({
    required String title,
    required String whyCollecting,
    required String image,
    required String payment,
    required String login,
    required String password,
  });

  Future<void> createLanguage({required String code, required String title});

  Future<List<TravelCompany>> fetchTourCompanies();
  Future<List<SadaqaCompany>> fetchSadaqaCompanies();
  Future<List<LanguageItem>> fetchLanguages();
  Future<String> uploadImage(String path);
}

class LanguageItem {
  const LanguageItem({
    required this.id,
    required this.code,
    required this.title,
  });

  final int id;
  final String code;
  final String title;
}
