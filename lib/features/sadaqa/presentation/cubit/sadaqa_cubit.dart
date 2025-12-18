import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safa_app/features/sadaqa/data/sadaqa_repository.dart';
import 'package:safa_app/features/sadaqa/models/sadaqa_cause.dart';

enum SadaqaTab { all, favorites }

class SadaqaState {
  final SadaqaTab activeTab;
  final List<SadaqaCause> causes;
  final Set<String> favoriteCauseIds;
  final bool isLoading;
  final String? errorMessage;

  const SadaqaState({
    required this.activeTab,
    required this.causes,
    required this.favoriteCauseIds,
    required this.isLoading,
    required this.errorMessage,
  });

  factory SadaqaState.initial() => const SadaqaState(
    activeTab: SadaqaTab.all,
    causes: [],
    favoriteCauseIds: <String>{},
    isLoading: true,
    errorMessage: null,
  );

  int get favoritesCount => favoriteCauseIds.length;

  List<SadaqaCause> get visibleCauses => activeTab == SadaqaTab.all
      ? causes
      : causes.where((cause) => favoriteCauseIds.contains(cause.id)).toList();

  bool isFavorite(String id) => favoriteCauseIds.contains(id);

  SadaqaState copyWith({
    SadaqaTab? activeTab,
    List<SadaqaCause>? causes,
    Set<String>? favoriteCauseIds,
    bool? isLoading,
    String? errorMessage,
    bool resetError = false,
  }) {
    return SadaqaState(
      activeTab: activeTab ?? this.activeTab,
      causes: causes ?? this.causes,
      favoriteCauseIds: favoriteCauseIds ?? this.favoriteCauseIds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: resetError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class SadaqaCubit extends Cubit<SadaqaState> {
  SadaqaCubit({SadaqaRepository? repository})
    : _repository = repository ?? SadaqaRepository(),
      super(SadaqaState.initial()) {
    loadCauses();
  }

  final SadaqaRepository _repository;

  Future<void> loadCauses() async {
    emit(state.copyWith(isLoading: true, resetError: true));
    try {
      final fetched = await _repository.fetchCauses();
      final publicCauses = _filterPublic(fetched);

      final nextCauses = publicCauses;

      final favorites = state.favoriteCauseIds
          .where((id) => nextCauses.any((cause) => cause.id == id))
          .toSet();

      emit(
        state.copyWith(
          causes: nextCauses,
          favoriteCauseIds: favorites,
          isLoading: false,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          causes: const [],
          isLoading: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void selectTab(SadaqaTab tab) {
    if (tab == state.activeTab) return;
    emit(state.copyWith(activeTab: tab));
  }

  void toggleFavorite(String causeId) {
    if (!state.causes.any((cause) => cause.id == causeId)) return;

    final updated = Set<String>.from(state.favoriteCauseIds);
    if (!updated.add(causeId)) {
      updated.remove(causeId);
    }
    emit(state.copyWith(favoriteCauseIds: updated));
  }

  List<SadaqaCause> _filterPublic(List<SadaqaCause> causes) {
    final seen = <String>{};
    return causes.where((cause) {
      if (cause.isPrivate) return false;
      if (cause.id.isEmpty) return false;
      if (!seen.add(cause.id)) return false;
      return true;
    }).toList();
  }
}
