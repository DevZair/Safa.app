class Tour {
  final int id;
  final int tourCompanyId;
  final int tourCategoryId;
  final int tourGuidId;
  final String image;
  final double price;
  final String departureDate;
  final String returnDate;
  final int duration;
  final bool isNew;
  final int maxPeople;
  final String location;
  final int status;

  Tour({
    required this.id,
    required this.tourCompanyId,
    required this.tourCategoryId,
    required this.tourGuidId,
    required this.image,
    required this.price,
    required this.departureDate,
    required this.returnDate,
    required this.duration,
    required this.isNew,
    required this.maxPeople,
    required this.location,
    required this.status,
  });

  factory Tour.fromJson(Map<String, dynamic> json) {
    return Tour(
      id: json['id'] as int,
      tourCompanyId: json['tour_company_id'] as int,
      tourCategoryId: json['tour_category_id'] as int,
      tourGuidId: json['tour_guid_id'] as int,
      image: json['image'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      departureDate: json['departure_date'] as String,
      returnDate: json['return_date'] as String,
      duration: json['duration'] as int,
      isNew: json['is_new'] as bool? ?? false,
      maxPeople: json['max_people'] as int,
      location: json['location'] as String? ?? '',
      status: json['status'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tour_company_id': tourCompanyId,
      'tour_category_id': tourCategoryId,
      'tour_guid_id': tourGuidId,
      'image': image,
      'price': price,
      'departure_date': departureDate,
      'return_date': returnDate,
      'duration': duration,
      'is_new': isNew,
      'max_people': maxPeople,
      'location': location,
      'status': status,
    };
  }
}

