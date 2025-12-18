import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safa_app/features/sadaqa_history/data/sadaqa_history_repository.dart';
import 'package:safa_app/features/sadaqa_history/models/sadaqa_history_item.dart';

class SadaqaHistoryState {
  final List<SadaqaHistoryItem> items;
  final bool isLoading;
  final bool isRefreshing;
  final String? errorMessage;

  const SadaqaHistoryState({
    required this.items,
    required this.isLoading,
    required this.isRefreshing,
    required this.errorMessage,
  });

  factory SadaqaHistoryState.initial() {
    return const SadaqaHistoryState(
      items: [],
      isLoading: true,
      isRefreshing: false,
      errorMessage: null,
    );
  }

  SadaqaHistoryState copyWith({
    List<SadaqaHistoryItem>? items,
    bool? isLoading,
    bool? isRefreshing,
    String? errorMessage,
    bool resetError = false,
  }) {
    return SadaqaHistoryState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: resetError ? null : errorMessage ?? this.errorMessage,
    );
  }

  int get successCount =>
      items.where((item) => item.status == SadaqaHistoryStatus.success).length;

  int get pendingCount =>
      items.where((item) => item.status == SadaqaHistoryStatus.pending).length;
}

class SadaqaHistoryCubit extends Cubit<SadaqaHistoryState> {
  SadaqaHistoryCubit({SadaqaHistoryRepository? repository})
    : _repository = repository ?? SadaqaHistoryRepository(),
      super(SadaqaHistoryState.initial()) {
    loadHistory();
  }

  final SadaqaHistoryRepository _repository;

  Future<void> loadHistory({bool isRefresh = false}) async {
    emit(
      state.copyWith(
        isLoading: !isRefresh,
        isRefreshing: isRefresh,
        resetError: true,
      ),
    );

    try {
      final items = await _repository.fetchHistory();
      emit(
        state.copyWith(
          items: items,
          isLoading: false,
          isRefreshing: false,
          errorMessage: null,
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          items: const [],
          isLoading: false,
          isRefreshing: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
