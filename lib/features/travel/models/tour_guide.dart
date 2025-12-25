class TourGuide {
  final int id;
  final String fullName;

  TourGuide({
    required this.id,
    required this.fullName,
  });

  factory TourGuide.fromJson(Map<String, dynamic> json) {
    final name = json['full_name'] ?? json['name'] ?? json['username'] ?? 'Unnamed Guide';
    final id = json['id'];
    return TourGuide(
      id: id is int ? id : int.tryParse(id.toString()) ?? 0,
      fullName: name as String,
    );
  }
}
