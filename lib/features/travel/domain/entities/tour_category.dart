class TourCategory {
  final int id;
  final String title;

  TourCategory({
    required this.id,
    required this.title,
  });

  factory TourCategory.fromJson(Map<String, dynamic> json) {
    return TourCategory(
      id: json['id'] as int,
      title: json['title'] as String,
    );
  }
}
