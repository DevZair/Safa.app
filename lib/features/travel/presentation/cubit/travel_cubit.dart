import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safa_app/core/styles/app_colors.dart';
import 'package:safa_app/features/travel/data/travel_repository.dart';
import 'package:safa_app/features/travel/models/travel_company.dart';
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

class TravelCategory {
  final String id;
  final String label;
  final IconData icon;

  const TravelCategory({
    required this.id,
    required this.label,
    required this.icon,
  });
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
      favoritePackageIds: favoritePackageIds ?? this.favoritePackageIds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: resetError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  factory TravelState.initial() {
    return TravelState(
      heroTitle: 'Путешествия',
      heroSubtitle: 'Откройте для себя уникальные путешествия',
      metrics: const [
        TravelMetric(
          id: 'active',
          value: '156+',
          label: 'Активные туры',
          icon: Icons.flight_class_rounded,
        ),
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
      ],
      categories: const [
        TravelCategory(
          id: 'all',
          label: 'Все туры',
          icon: Icons.flight_takeoff_rounded,
        ),
        TravelCategory(id: 'umrah', label: 'Умра', icon: Icons.mosque_rounded),
        TravelCategory(id: 'hajj', label: 'Хадж', icon: Icons.mosque_sharp),
      ],
      selectedCategoryId: 'all',
      activeTab: TravelTab.all,
      companies: const [],
      packages: _defaultPackages,
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
      final companies = await _repository.fetchCompanies();

      final favorites = state.favoritePackageIds
          .where((id) => state.packages.any((pkg) => pkg.id == id))
          .toSet();

      emit(
        state.copyWith(
          companies: companies,
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

const _defaultPackages = <TravelPackage>[
  TravelPackage(
    id: 'umrah-economy',
    companyId: 'al-haramain',
    categoryId: 'umrah',
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
    startDateLabel: '15.12.2024',
    durationLabel: '10 дней',
    tags: [
      TravelBadgeData('Новинка', AppColors.badgeNew),
      TravelBadgeData(
        'Умра',
        AppColors.badgeLightBackground,
        AppColors.headingDeep,
      ),
    ],
  ),
  TravelPackage(
    id: 'umrah-comfort',
    companyId: 'al-haramain',
    categoryId: 'umrah',
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
    startDateLabel: '20.02.2025',
    durationLabel: '12 дней',
    tags: [
      TravelBadgeData(
        'Популярно',
        AppColors.badgeLightBackground,
        AppColors.headingDeep,
      ),
      TravelBadgeData(
        'Умра',
        AppColors.badgeLightBackground,
        AppColors.headingDeep,
      ),
    ],
  ),
  TravelPackage(
    id: 'hajj-premium',
    companyId: 'noor-travel',
    categoryId: 'hajj',
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
    startDateLabel: '10.06.2025',
    durationLabel: '15 дней',
    tags: [
      TravelBadgeData('Новинка', AppColors.badgeNew),
      TravelBadgeData(
        'Хадж',
        AppColors.surfaceLight,
        AppColors.favoriteInactive,
      ),
    ],
  ),
  TravelPackage(
    id: 'hajj-standard',
    companyId: 'safa-marwa',
    categoryId: 'hajj',
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
    startDateLabel: '05.06.2025',
    durationLabel: '12 дней',
    tags: [
      TravelBadgeData('Раннее бронирование', AppColors.badgeNew),
      TravelBadgeData(
        'Хадж',
        AppColors.surfaceLight,
        AppColors.favoriteInactive,
      ),
    ],
  ),
];
