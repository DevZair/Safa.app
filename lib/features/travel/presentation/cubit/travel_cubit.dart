import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safa_app/core/styles/app_colors.dart';
import 'package:safa_app/features/travel/data/travel_repository.dart';
import 'package:safa_app/features/travel/models/travel_category.dart';
import 'package:safa_app/features/travel/models/travel_company.dart';
import 'package:safa_app/features/travel/models/travel_guide.dart';
import 'package:safa_app/features/travel/presentation/widgets/travel_package_card.dart';

enum TravelTab { all, saved }

class TravelMetric {
  final String id;
  final String value;
  final String label;
  final IconData icon;

  const TravelMetric({
    required this.id,
    required this.value,
    required this.label,
    required this.icon,
  });
}

const List<TravelMetric> _kStaticTravelMetrics = [
  TravelMetric(
    id: 'travelers',
    value: '12K+',
    label: 'Счастливые путешественники',
    icon: Icons.person_outline_rounded,
  ),
  TravelMetric(
    id: 'destinations',
    value: '45+',
    label: 'Направления',
    icon: Icons.place_outlined,
  ),
];

List<TravelMetric> _buildTravelMetrics({int? activeToursCount}) {
  return [
    TravelMetric(
      id: 'active',
      value: _formatActiveToursValue(activeToursCount),
      label: 'Активные туры',
      icon: Icons.flight_class_rounded,
    ),
    ..._kStaticTravelMetrics,
  ];
}

String _formatActiveToursValue(int? count) {
  if (count == null) return '--';
  if (count <= 0) return '0';
  return count.toString();
}

class TravelState {
  final String heroTitle;
  final String heroSubtitle;
  final List<TravelMetric> metrics;
  final List<TravelCategory> categories;
  final String selectedCategoryId;
  final TravelTab activeTab;
  final List<TravelCompany> companies;
  final List<TravelPackage> packages;
  final List<TravelGuide> guides;
  final Set<String> favoritePackageIds;
  final bool isLoading;
  final String? errorMessage;

  const TravelState({
    required this.heroTitle,
    required this.heroSubtitle,
    required this.metrics,
    required this.categories,
    required this.selectedCategoryId,
    required this.activeTab,
    required this.companies,
    required this.packages,
    required this.guides,
    required this.favoritePackageIds,
    required this.isLoading,
    required this.errorMessage,
  });

  TravelState copyWith({
    String? heroTitle,
    String? heroSubtitle,
    List<TravelMetric>? metrics,
    List<TravelCategory>? categories,
    String? selectedCategoryId,
    TravelTab? activeTab,
    List<TravelCompany>? companies,
    List<TravelPackage>? packages,
    List<TravelGuide>? guides,
    Set<String>? favoritePackageIds,
    bool? isLoading,
    String? errorMessage,
    bool resetError = false,
  }) {
    return TravelState(
      heroTitle: heroTitle ?? this.heroTitle,
      heroSubtitle: heroSubtitle ?? this.heroSubtitle,
      metrics: metrics ?? this.metrics,
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      activeTab: activeTab ?? this.activeTab,
      companies: companies ?? this.companies,
      packages: packages ?? this.packages,
      guides: guides ?? this.guides,
      favoritePackageIds: favoritePackageIds ?? this.favoritePackageIds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: resetError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  factory TravelState.initial() {
    return TravelState(
      heroTitle: 'Путешествия',
      heroSubtitle: 'Откройте для себя уникальные путешествия',
      metrics: _buildTravelMetrics(),
      categories: List<TravelCategory>.from(TravelCategory.coreCategories),
      selectedCategoryId: TravelCategory.all.id,
      activeTab: TravelTab.all,
      companies: const [],
      packages: _defaultPackages,
      guides: const [],
      favoritePackageIds: <String>{},
      isLoading: true,
      errorMessage: null,
    );
  }
}

class TravelCubit extends Cubit<TravelState> {
  TravelCubit({TravelRepository? repository})
      : _repository = repository ?? TravelRepository(),
        super(TravelState.initial()) {
    loadTravelData();
  }

  final TravelRepository _repository;

  Future<void> loadTravelData() async {
    emit(state.copyWith(isLoading: true, resetError: true));
    try {
      final activeToursCountFuture = _loadActiveToursCount();
      final companies = await _repository.fetchCompanies();
      final packages = await _repository.fetchPackages();
      final guides = await _repository.fetchGuides();
      final apiCategories = await _repository.fetchCategories();
      final categoryResult = _mergeCategories(apiCategories);
      final mergedCategories = categoryResult.categories;
      final selectedCategoryId = mergedCategories
              .any((category) => category.id == state.selectedCategoryId)
          ? state.selectedCategoryId
          : TravelCategory.all.id;
      final packagesWithGuides = _applyGuideInfo(packages, guides);
      final packagesWithCategoryLabels = _applyCategoryData(
        packagesWithGuides,
        categoryResult.normalizedByRawId,
      );
      final favorites = state.favoritePackageIds
          .where((id) => packagesWithCategoryLabels.any((pkg) => pkg.id == id))
          .toSet();
      final apiActiveToursCount = await activeToursCountFuture;
      final companyActiveToursCount = companies
          .fold<int>(0, (sum, company) => sum + company.activeTourIds.length);
      final activeToursCount = apiActiveToursCount ?? companyActiveToursCount;

      emit(
        state.copyWith(
          metrics: _buildTravelMetrics(activeToursCount: activeToursCount),
          companies: companies,
          packages: packagesWithCategoryLabels,
          categories: mergedCategories,
          selectedCategoryId: selectedCategoryId,
          guides: guides,
          favoritePackageIds: favorites,
          isLoading: false,
          errorMessage: null,
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<int?> _loadActiveToursCount() async {
    try {
      return await _repository.fetchActiveToursCount();
    } on Object catch (error) {
      debugPrint('Failed to load active tours count: $error');
      return null;
    }
  }

  void selectCategory(String categoryId) {
    if (categoryId == state.selectedCategoryId) return;
    emit(state.copyWith(selectedCategoryId: categoryId));
  }

  void selectTab(TravelTab tab) {
    if (tab == state.activeTab) return;
    emit(state.copyWith(activeTab: tab));
  }

  void toggleFavorite(String packageId) {
    final updated = Set<String>.from(state.favoritePackageIds);
    if (updated.contains(packageId)) {
      updated.remove(packageId);
    } else {
      updated.add(packageId);
    }
    emit(state.copyWith(favoritePackageIds: updated));
  }

}

class _CategoryMergeResult {
  final List<TravelCategory> categories;
  final Map<String, TravelCategory> normalizedByRawId;

  const _CategoryMergeResult({
    required this.categories,
    required this.normalizedByRawId,
  });
}

_CategoryMergeResult _mergeCategories(List<TravelCategory> fetched) {
  final addedIds = <String>{};
  final categories = <TravelCategory>[];
  final normalizedByRawId = <String, TravelCategory>{};

  void addCategory(TravelCategory category) {
    final id = category.id.trim().toLowerCase();
    if (id.isEmpty || id == TravelCategory.all.id) return;
    if (addedIds.contains(id)) return;
    addedIds.add(id);
    categories.add(category);
  }

  for (final category in fetched) {
    final normalized = _normalizeCategory(category);
    final rawKey = category.id.trim().toLowerCase();
    if (rawKey.isNotEmpty && !_isTestCategory(normalized)) {
      normalizedByRawId[rawKey] = normalized;
    }
    if (_isTestCategory(normalized)) continue;
    addCategory(normalized);
  }

  addCategory(TravelCategory.umrah);
  addCategory(TravelCategory.hajj);

  return _CategoryMergeResult(
    categories: [
      TravelCategory.all,
      ...categories,
    ],
    normalizedByRawId: normalizedByRawId,
  );
}

bool _isTestCategory(TravelCategory category) {
  final normalizedId = category.id.trim().toLowerCase();
  final normalizedLabel = category.label.trim().toLowerCase();
  for (final candidate in ['test', 'тест']) {
    if (normalizedId.contains(candidate) ||
        normalizedLabel.contains(candidate)) {
      return true;
    }
  }
  return false;
}

List<TravelPackage> _applyGuideInfo(
  List<TravelPackage> packages,
  List<TravelGuide> guides,
) {
  if (guides.isEmpty) return packages;
  final guideById = <String, TravelGuide>{};
  for (final guide in guides) {
    final key = guide.id.trim().toLowerCase();
    if (key.isEmpty) continue;
    guideById[key] = guide;
  }

  return packages.map((package) {
    final key = package.guideId.trim().toLowerCase();
    final guide = guideById[key];
    if (guide == null) return package;
    final updatedRating = guide.rating > 0 ? guide.rating : package.guideRating;
    return package.copyWith(
      guideName: guide.fullName,
      guideRating: updatedRating,
    );
  }).toList();
}

List<TravelPackage> _applyCategoryData(
  List<TravelPackage> packages,
  Map<String, TravelCategory> normalizedByRawId,
) {
  if (normalizedByRawId.isEmpty) return packages;
  return packages.map((package) {
    final rawKey = package.categoryId.trim().toLowerCase();
    final normalized = normalizedByRawId[rawKey];
    if (normalized == null) return package;
    return package.copyWith(
      categoryId: normalized.id,
      categoryLabel: normalized.label,
    );
  }).toList();
}

TravelCategory _normalizeCategory(TravelCategory category) {
  final id = category.id.trim().toLowerCase();
  final label = category.label.trim().toLowerCase();

  if (id.contains('haj') || label.contains('haj') || label.contains('хадж')) {
    return TravelCategory.hajj;
  }
  if (id.contains('umrah') || label.contains('umrah') || label.contains('умра')) {
    return TravelCategory.umrah;
  }
  return category;
}

const _defaultPackages = <TravelPackage>[
  TravelPackage(
    id: 'umrah-economy',
    companyId: 'al-haramain',
    categoryId: 'umrah',
    categoryLabel: 'Умра',
    guideId: 'guide-umrah-1',
    title: 'Умра 2024 – Эконом',
    location: 'Makkah & Madinah',
    imagePath: 'assets/images/travel_card1.jpg',
    gallery: [
      'assets/images/travel_card1.jpg',
      'assets/images/travel_card2.jpg',
    ],
    guideName: 'Abdruhman Qori',
    guideRating: 4.9,
    priceUsd: 2500,
    availabilityLabel: 'Оставшиеся места: 8',
    isNew: true,
    startDateLabel: '15.12.2024',
    durationLabel: '10 дней',
    returnDateLabel: '25.12.2024',
    maxPeople: 100,
  ),
  TravelPackage(
    id: 'umrah-comfort',
    companyId: 'al-haramain',
    categoryId: 'umrah',
    categoryLabel: 'Умра',
    guideId: 'guide-umrah-2',
    title: 'Умра 2025 – Комфорт',
    location: 'Makkah & Madinah',
    imagePath: 'assets/images/travel_card1.jpg',
    gallery: [
      'assets/images/travel_card1.jpg',
      'assets/images/travel_card2.jpg',
    ],
    guideName: 'Sheikh Ahmed Al-Mansouri',
    guideRating: 4.8,
    priceUsd: 3100,
    availabilityLabel: 'Оставшиеся места: 12',
    isNew: false,
    startDateLabel: '20.02.2025',
    durationLabel: '12 дней',
    returnDateLabel: '02.03.2025',
    maxPeople: 120,
  ),
  TravelPackage(
    id: 'hajj-premium',
    companyId: 'noor-travel',
    categoryId: 'hajj',
    categoryLabel: 'Хадж',
    guideId: 'guide-hajj-1',
    title: 'Хадж 2025 – Премиум',
    location: 'Saudi Arabia',
    imagePath: 'assets/images/travel_card2.jpg',
    gallery: [
      'assets/images/travel_card2.jpg',
      'assets/images/travel_card1.jpg',
    ],
    guideName: 'Islam Qori',
    guideRating: 4.8,
    priceUsd: 5500,
    availabilityLabel: 'Оставшиеся места: 5',
    isNew: true,
    startDateLabel: '10.06.2025',
    durationLabel: '15 дней',
    returnDateLabel: '25.06.2025',
    maxPeople: 80,
  ),
  TravelPackage(
    id: 'hajj-standard',
    companyId: 'safa-marwa',
    categoryId: 'hajj',
    categoryLabel: 'Хадж',
    guideId: 'guide-hajj-2',
    title: 'Хадж 2025 – Стандарт',
    location: 'Saudi Arabia',
    imagePath: 'assets/images/travel_card2.jpg',
    gallery: [
      'assets/images/travel_card2.jpg',
      'assets/images/travel_card1.jpg',
    ],
    guideName: 'Abdulloh Qori',
    guideRating: 4.6,
    priceUsd: 4200,
    availabilityLabel: 'Оставшиеся места: 14',
    isNew: false,
    startDateLabel: '05.06.2025',
    durationLabel: '12 дней',
    returnDateLabel: '17.06.2025',
    maxPeople: 90,
  ),
];
