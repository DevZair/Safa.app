import 'package:safa_app/core/constants/api_constants.dart';
import 'package:safa_app/core/service/api_service.dart';
import 'package:safa_app/features/sadaqa_history/models/sadaqa_history_item.dart';

class SadaqaHistoryRepository {
  Future<List<SadaqaHistoryItem>> fetchHistory() async {
    final data = await ApiService.request<Object?>(
      ApiConstants.sadaqaHistory,
      method: Method.get,
    );

    final list = _unwrapList(data);

    return list.map(SadaqaHistoryItem.fromJson).toList();
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
