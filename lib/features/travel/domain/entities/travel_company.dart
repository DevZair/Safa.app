class TravelCompany {
  final String id;
  final String name;
  final double rating;
  final List<String> activeTourIds;
  final String thumbnail;

  const TravelCompany({
    required this.id,
    required this.name,
    required this.rating,
    required this.activeTourIds,
    required this.thumbnail,
  });

  int get tours => activeTourIds.length;

  factory TravelCompany.fromJson(Map<String, Object?> json) {
    final rating = json['rating'] ?? json['rating_avg'] ?? 0;
    final name =
        '${json['name'] ?? json['comp_name'] ?? json['company_name'] ?? ''}';
    final thumbnail =
        '${json['thumbnail'] ?? json['image'] ?? json['logo'] ?? ''}';
    final ids = _extractActiveTourIds(json['active_tours_id']);
    return TravelCompany(
      id: '${json['id'] ?? ''}',
      name: name,
      rating: rating is num ? rating.toDouble() : double.tryParse('$rating') ?? 0,
      activeTourIds: ids,
      thumbnail: thumbnail,
    );
  }

  static List<String> _extractActiveTourIds(Object? raw) {
    if (raw is List) {
      return raw
          .map((e) => '$e'.trim())
          .where((value) => value.isNotEmpty)
          .toSet()
          .toList();
    }
    if (raw is String) {
      if (raw.trim().isEmpty) return [];
      return raw
          .split(',')
          .map((e) => e.trim())
          .where((value) => value.isNotEmpty)
          .toSet()
          .toList();
    }
    return [];
  }
}
