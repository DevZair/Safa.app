import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safa_app/core/utils/error_messages.dart';
import 'package:safa_app/features/sadaqa/data/repositories/sadaqa_repository_impl.dart';
import 'package:safa_app/features/sadaqa/domain/entities/sadaqa_cause.dart';
import 'package:safa_app/features/sadaqa/domain/entities/sadaqa_company.dart';
import 'package:safa_app/features/sadaqa/domain/repositories/sadaqa_repository.dart';

enum SadaqaTab { all, favorites }

class SadaqaState {
  final SadaqaTab activeTab;
  final List<SadaqaCause> causes;
  final List<SadaqaCompany> companies;
  final Set<String> favoriteCauseIds;
  final bool isLoading;
  final String? errorMessage;

  const SadaqaState({
    required this.activeTab,
    required this.causes,
    required this.companies,
    required this.favoriteCauseIds,
    required this.isLoading,
    required this.errorMessage,
  });

  factory SadaqaState.initial() => const SadaqaState(
    activeTab: SadaqaTab.all,
    causes: [],
    companies: [],
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
    List<SadaqaCompany>? companies,
    Set<String>? favoriteCauseIds,
    bool? isLoading,
    String? errorMessage,
    bool resetError = false,
  }) {
    return SadaqaState(
      activeTab: activeTab ?? this.activeTab,
      causes: causes ?? this.causes,
      companies: companies ?? this.companies,
      favoriteCauseIds: favoriteCauseIds ?? this.favoriteCauseIds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: resetError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class SadaqaCubit extends Cubit<SadaqaState> {
  SadaqaCubit({SadaqaRepository? repository})
    : _repository = repository ?? SadaqaRepositoryImpl(),
      super(SadaqaState.initial()) {
    loadCauses();
  }

  final SadaqaRepository _repository;

  Future<void> loadCauses() async {
    emit(state.copyWith(isLoading: true, resetError: true));
    try {
      List<SadaqaCompany> companies = const [];
      String? companyError;
      try {
        companies = await _repository.fetchCompanies();
        if (companies.isEmpty) {
          companyError = 'Company not found';
        }
      } catch (error) {
        final message = error.toString();
        final normalized = message.toLowerCase();
        if (normalized.contains('company') &&
            normalized.contains('not found')) {
          companyError = 'Company not found';
        } else {
          companies = const [];
        }
      }

      if (companyError != null) {
        emit(
          state.copyWith(
            causes: const [],
            companies: const [],
            isLoading: false,
            errorMessage: companyError,
          ),
        );
        return;
      }
      final fetched = await _repository.fetchCauses();
      final enrichedCauses = _applyCompanyData(fetched, companies);
      final publicCauses = _filterPublic(enrichedCauses);

      final nextCauses = publicCauses;

      final favorites = state.favoriteCauseIds
          .where((id) => nextCauses.any((cause) => cause.id == id))
          .toSet();

      emit(
        state.copyWith(
          causes: nextCauses,
          companies: companies,
          favoriteCauseIds: favorites,
          isLoading: false,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          causes: const [],
          companies: const [],
          isLoading: false,
          errorMessage: friendlyError(error),
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

  List<SadaqaCause> _applyCompanyData(
    List<SadaqaCause> causes,
    List<SadaqaCompany> companies,
  ) {
    if (companies.isEmpty) return causes;
    final map = {for (final c in companies) c.id: c};
    return causes.map((cause) {
      final companyId = cause.companyId;
      final company = companyId != null ? map[companyId] : null;
      if (company == null) return cause;

      return cause.copyWith(
        companyName: (cause.companyName?.trim().isNotEmpty ?? false)
            ? cause.companyName
            : company.title,
        companyLogo: (cause.companyLogo?.trim().isNotEmpty ?? false)
            ? cause.companyLogo
            : company.logo ?? company.cover ?? cause.companyLogo,
      );
    }).toList();
  }
}
