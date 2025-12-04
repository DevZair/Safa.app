import 'package:dio/dio.dart';
import 'package:safa_app/core/constants/api_constants.dart';
import 'package:safa_app/core/service/api_service.dart';

class ReferenceItem {
  final int id;
  final String title;

  const ReferenceItem({required this.id, required this.title});

  factory ReferenceItem.fromJson(Map<String, Object?> json) {
    return ReferenceItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: '${json['title'] ?? ''}',
    );
  }
}

class RequestHelpPayload {
  final String name;
  final String surname;
  final String phoneNumber;
  final String address;
  final String whyNeedHelp;
  final int helpCategory;
  final String? email;
  final String? otherCategory;
  final int? age;
  final int? childInFam;
  final String? iin;
  final String? materialStatus;
  final int? status;
  final num? money;
  final Object? file;

  const RequestHelpPayload({
    required this.name,
    required this.surname,
    required this.phoneNumber,
    required this.address,
    required this.whyNeedHelp,
    required this.helpCategory,
    this.email,
    this.otherCategory,
    this.age,
    this.childInFam,
    this.iin,
    this.materialStatus,
    this.money,
    this.status,
    this.file,
  });

  FormData toFormData() {
    final formMap = <String, Object?>{
      'name': name,
      'surname': surname,
      'age': age,
      'email': email,
      'phone_number': phoneNumber,
      'other_category': otherCategory,
      'child_in_fam': childInFam,
      'address': address,
      'iin': iin,
      'why_need_help': whyNeedHelp,
      if (status != null) 'status': status,
      'material_status': materialStatus ?? '',
      'help_category': helpCategory,
    };

    if (money != null) {
      formMap['money'] = money;
    }
    if (file != null) {
      formMap['file'] = file;
    }

    return FormData.fromMap(formMap);
  }
}

class RequestHelpRepository {
  Future<void> send(RequestHelpPayload payload) async {
    await ApiService.request<Map<String, Object?>>(
      ApiConstants.requestHelp,
      method: Method.post,
      formData: payload.toFormData(),
    );
  }

  Future<List<ReferenceItem>> fetchMaterialStatuses() async {
    final data = await ApiService.request<List<Object?>>(
      ApiConstants.sadaqaMaterialStatuses,
      method: Method.get,
    );
    return data
        .whereType<Map<String, Object?>>()
        .map(ReferenceItem.fromJson)
        .where((item) => item.id != 0 && item.title.isNotEmpty)
        .toList();
  }
}
