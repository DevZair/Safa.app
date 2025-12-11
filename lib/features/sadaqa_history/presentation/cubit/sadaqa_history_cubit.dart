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
      final hydratedItems = items.isNotEmpty ? items : _mockItems();
      emit(
        state.copyWith(
          items: hydratedItems,
          isLoading: false,
          isRefreshing: false,
          errorMessage: null,
        ),
      );
    } on Object catch (error) {
      final fallback = _mockItems();
      emit(
        state.copyWith(
          items: fallback,
          isLoading: false,
          isRefreshing: false,
          errorMessage: fallback.isEmpty ? error.toString() : null,
        ),
      );
    }
  }

  List<SadaqaHistoryItem> _mockItems() {
    final now = DateTime.now();
    return [
      SadaqaHistoryItem(
        id: 1,
        title: 'Поддержка семьи из Астаны',
        amount: 15000,
        currency: 'KZT',
        createdAt: now.subtract(const Duration(days: 1, hours: 3)),
        status: SadaqaHistoryStatus.success,
        paymentMethod: 'Kaspi',
        receiptId: 'KZ-2024-0015',
        companyName: 'Мерім',
      ),
      SadaqaHistoryItem(
        id: 2,
        title: 'Лекарства для нуждающихся',
        amount: 8000,
        currency: 'KZT',
        createdAt: now.subtract(const Duration(days: 3, hours: 5)),
        status: SadaqaHistoryStatus.pending,
        paymentMethod: 'Card',
        receiptId: 'KZ-2024-0008',
        companyName: 'Береке',
      ),
      SadaqaHistoryItem(
        id: 3,
        title: 'Помощь детскому дому',
        amount: 12000,
        currency: 'KZT',
        createdAt: now.subtract(const Duration(days: 7, hours: 2)),
        status: SadaqaHistoryStatus.failed,
        paymentMethod: 'Apple Pay',
        receiptId: 'KZ-2024-0003',
        companyName: 'Rahmet',
      ),
    ];
  }
}
