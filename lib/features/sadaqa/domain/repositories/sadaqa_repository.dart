import 'package:safa_app/features/sadaqa/domain/entities/help_request.dart';
import 'package:safa_app/features/sadaqa/domain/entities/reference_item.dart';
import 'package:safa_app/features/sadaqa/domain/entities/sadaqa_cause.dart';
import 'package:safa_app/features/sadaqa/domain/entities/sadaqa_company.dart';
import 'package:safa_app/features/sadaqa/domain/entities/sadaqa_post.dart';

abstract class SadaqaRepository {
  Future<List<SadaqaCause>> fetchCauses();
  Future<List<SadaqaCompany>> fetchCompanies();
  Future<SadaqaCompany?> fetchCompanyDetail(String companyId);

  Future<List<SadaqaPost>> fetchPosts({String? companyId});
  Future<List<SadaqaPost>> fetchNotes({String? companyId});
  Future<SadaqaPost?> fetchActiveNote({String? companyId});
  List<SadaqaPost>? readCachedPosts({String? companyId});
  SadaqaPost? readCachedActiveNote({String? companyId});

  Future<List<SadaqaPost>> fetchAdminPosts();
  Future<List<SadaqaPost>> fetchAdminNotes();

  Future<List<HelpRequest>> fetchHelpRequests();
  Future<HelpRequest?> updateHelpRequestStatus({
    required String id,
    required HelpRequestStatus status,
  });

  Future<List<ReferenceItem>> fetchPrivateMaterialStatusList();
  Future<List<ReferenceItem>> fetchPrivateHelpCategoryList();
  Future<ReferenceItem?> createMaterialStatus(String title, {bool isActive = true});
  Future<bool> deleteMaterialStatus(int id);
  Future<ReferenceItem?> updateMaterialStatus({
    required int id,
    required String title,
    bool isActive = true,
  });
  Future<ReferenceItem?> createHelpCategory(String title, {bool isOther = false});
  Future<bool> deleteHelpCategory(int id);
  Future<ReferenceItem?> updateHelpCategory({
    required int id,
    required String title,
    bool isOther = false,
  });

  Future<SadaqaCompany> updateCompanyProfile({
    String? title,
    String? image,
    String? logo,
    String? cover,
    String? payment,
    String? whyCollecting,
  });

  Future<SadaqaPost> createPost({
    String? title,
    String? content,
    String? image,
  });
  Future<SadaqaPost> updatePost({
    required String postId,
    String? title,
    String? content,
    String? image,
  });
  Future<void> deletePost(String postId);

  Future<SadaqaPost> createNote({
    String? title,
    String? content,
    String? image,
    String? noteType,
    String? address,
    double? goalMoney,
    double? collectedMoney,
    int? status,
  });
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
  });
  Future<void> deleteNote(String noteId);

  Future<String> uploadImage(String path);
}
