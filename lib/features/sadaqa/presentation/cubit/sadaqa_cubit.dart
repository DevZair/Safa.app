import 'package:flutter_bloc/flutter_bloc.dart';

enum SadaqaTab { all, favorites }

class SadaqaCause {
  final String id;
  final String imagePath;
  final String title;
  final String subtitle;
  final String? companyName;
  final String? companyLogo;
  final List<String> gallery;
  final int amount;
  final double raised;
  final double goal;
  final int donors;
  final String description;

  const SadaqaCause({
    required this.id,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    this.companyName,
    this.companyLogo,
    this.gallery = const [],
    required this.amount,
    required this.raised,
    required this.goal,
    required this.donors,
    required this.description,
  });
}

class SadaqaState {
  final SadaqaTab activeTab;
  final List<SadaqaCause> causes;
  final Set<String> favoriteCauseIds;

  const SadaqaState({
    required this.activeTab,
    required this.causes,
    required this.favoriteCauseIds,
  });

  factory SadaqaState.initial() => SadaqaState(
        activeTab: SadaqaTab.all,
        causes: _defaultCauses,
        favoriteCauseIds: <String>{},
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
  }) {
    return SadaqaState(
      activeTab: activeTab ?? this.activeTab,
      causes: causes ?? this.causes,
      favoriteCauseIds: favoriteCauseIds ?? this.favoriteCauseIds,
    );
  }
}

class SadaqaCubit extends Cubit<SadaqaState> {
  SadaqaCubit() : super(SadaqaState.initial());

  void selectTab(SadaqaTab tab) {
    if (tab == state.activeTab) return;
    emit(state.copyWith(activeTab: tab));
  }

  void toggleFavorite(String causeId) {
    final updated = Set<String>.from(state.favoriteCauseIds);
    if (!updated.add(causeId)) {
      updated.remove(causeId);
    }
    emit(state.copyWith(favoriteCauseIds: updated));
  }
}

const _defaultCauses = <SadaqaCause>[
  SadaqaCause(
    id: 'gaza_children',
    imagePath: 'assets/images/font1.jpeg',
    title: 'Набор деньги для детей Газа',
    subtitle: 'Соберите деньги для детей в Газе',
    companyName: 'Мерім',
    companyLogo: 'assets/images/meirim_logo.png',
    gallery: [
      'assets/images/font1.jpeg',
      'assets/images/font2.jpg',
    ],
    amount: 5000,
    raised: 32450,
    goal: 50000,
    donors: 1247,
    description:
        'Помогите обеспечить детей полноценным питанием и медицинской помощью.',
  ),
  SadaqaCause(
    id: 'orphanage',
    imagePath: 'assets/images/font2.jpg',
    title: 'Детский дом – поддержка',
    subtitle: 'Обеспечьте детей необходимым',
    companyName: 'Береке',
    companyLogo: 'assets/images/font2.jpg',
    gallery: [
      'assets/images/font2.jpg',
      'assets/images/font1.jpeg',
    ],
    amount: 12000,
    raised: 16500,
    goal: 30000,
    donors: 876,
    description:
        'Собираем средства на одежду, книги и бытовые нужды для детей в приюте.',
  ),
  SadaqaCause(
    id: 'education',
    imagePath: 'assets/images/font1.jpeg',
    title: 'Образование для сирот',
    subtitle: 'Подарите возможность учиться',
    companyName: 'Rahmet',
    companyLogo: 'assets/images/font1.jpeg',
    gallery: [
      'assets/images/font1.jpeg',
    ],
    amount: 8000,
    raised: 9400,
    goal: 20000,
    donors: 512,
    description:
        'Каждый вклад помогает оплатить школьные принадлежности и обучение.',
  ),
];
