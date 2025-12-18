import 'package:safa_app/core/constants/api_constants.dart';
import 'package:safa_app/core/service/api_service.dart';
import 'package:safa_app/features/sadaqa/models/sadaqa_cause.dart';

class SadaqaRepository {
  Future<List<SadaqaCause>> fetchCauses() async {
    final paths = <String>{
      ApiConstants.sadaqaCauses,
      '/api/sadaqa/public/posts/',
      '/api/sadaqa/donation/',
      '/sadaqa/donations/',
      '/sadaqa/donation/',
    };

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
    }

    return [];
  }
}
