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
    final tours = json['tours'] ?? json['tours_count'] ?? 0;
    return TravelCompany(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? ''}',
      rating: rating is num
          ? rating.toDouble()
          : double.tryParse('$rating') ?? 0,
      tours: tours is num ? tours.toInt() : int.tryParse('$tours') ?? 0,
      thumbnail: '${json['thumbnail'] ?? json['image'] ?? ''}',
    );
  }
}
