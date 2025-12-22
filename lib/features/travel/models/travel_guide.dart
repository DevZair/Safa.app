class TravelGuide {
  final String id;
  final String firstName;
  final String lastName;
  final String about;
  final double rating;

  const TravelGuide({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.about,
    required this.rating,
  });

  String get fullName {
    final parts = [firstName.trim(), lastName.trim()].where((part) => part.isNotEmpty);
    final joined = parts.join(' ').trim();
    return joined.isNotEmpty ? joined : 'Гид';
  }

  factory TravelGuide.fromJson(Map<String, Object?> json) {
    final ratingRaw = json['rating'] ?? json['avg_rating'];
    final rating = ratingRaw is num
        ? ratingRaw.toDouble()
        : double.tryParse('$ratingRaw') ?? 0.0;
    return TravelGuide(
      id: '${json['id'] ?? ''}',
      firstName: '${json['name'] ?? json['first_name'] ?? ''}',
      lastName: '${json['surname'] ?? json['last_name'] ?? ''}',
      about: '${json['about_self'] ?? json['about'] ?? ''}',
      rating: rating,
    );
  }
}
