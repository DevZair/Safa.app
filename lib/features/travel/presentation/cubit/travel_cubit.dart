import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safa_app/core/styles/app_colors.dart';
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

class TravelCompany {
  final String name;
  final double rating;
  final int tours;
  final String thumbnail;

  const TravelCompany({
    required this.name,
    required this.rating,
    required this.tours,
    required this.thumbnail,
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
      companies: const [
        TravelCompany(
          name: 'Al-Haramain Tours',
          rating: 4.9,
          tours: 156,
          thumbnail: 'assets/images/travel_card2.jpg',
        ),
        TravelCompany(
          name: 'Noor Travel Group',
          rating: 4.8,
          tours: 243,
          thumbnail: 'assets/images/travel_card1.jpg',
        ),
        TravelCompany(
          name: 'Safa & Marwa Tours',
          rating: 4.7,
          tours: 187,
          thumbnail: 'assets/images/travel_card2.jpg',
        ),
      ],
      packages: _defaultPackages,
      favoritePackageIds: <String>{},
    );
  }
}

class TravelCubit extends Cubit<TravelState> {
  TravelCubit() : super(TravelState.initial());

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
    title: 'Умра 2024 – Эконом',
    location: 'Makkah & Madinah',
    imagePath: 'assets/images/travel_card1.jpg',
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
    id: 'hajj-premium',
    title: 'Хадж 2025 – Премиум',
    location: 'Saudi Arabia',
    imagePath: 'assets/images/travel_card2.jpg',
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
];
