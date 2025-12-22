class TravelCompany {
  final String id;
  final String name;
  final double rating;
  final int tours;
  final String thumbnail;

  const TravelCompany({
    required this.id,
    required this.name,
    required this.rating,
    required this.tours,
    required this.thumbnail,
  });

  factory TravelCompany.fromJson(Map<String, Object?> json) {
    final rating = json['rating'] ?? json['rating_avg'] ?? 0;
    final tours = json['tours'] ??
        json['tours_count'] ??
        json['tour_count'] ??
        json['tourCount'] ??
        0;
    final name = '${json['name'] ?? json['comp_name'] ?? json['company_name'] ?? ''}';
    final thumbnail =
        '${json['thumbnail'] ?? json['image'] ?? json['logo'] ?? ''}';
    return TravelCompany(
      id: '${json['id'] ?? ''}',
      name: name,
      rating: rating is num
          ? rating.toDouble()
          : double.tryParse('$rating') ?? 0,
      tours: tours is num ? tours.toInt() : int.tryParse('$tours') ?? 0,
      thumbnail: thumbnail,
    );
  }
}
