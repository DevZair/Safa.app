import 'package:safa_app/core/constants/api_constants.dart';

class TravelPackage {
  final String id;
  final String companyId;
  final String categoryId;
  final String categoryLabel;
  final String guideId;
  final String title;
  final String location;
  final String imagePath;
  final List<String> gallery;
  final String guideName;
  final double guideRating;
  final int priceUsd;
  final String availabilityLabel;
  final bool isNew;
  final String startDateLabel;
  final String returnDateLabel;
  final String durationLabel;
  final int maxPeople;

  const TravelPackage({
    required this.id,
    required this.companyId,
    required this.categoryId,
    required this.categoryLabel,
    required this.guideId,
    required this.title,
    required this.location,
    required this.imagePath,
    required this.gallery,
    required this.guideName,
    required this.guideRating,
    required this.priceUsd,
    required this.availabilityLabel,
    required this.isNew,
    required this.startDateLabel,
    required this.returnDateLabel,
    required this.durationLabel,
    required this.maxPeople,
  });

  factory TravelPackage.fromJson(Map<String, Object?> json) {
    final price = json['price_usd'] ?? json['price'] ?? 0;
    final guideRatingRaw = json['guide_rating'] ?? json['guideRating'];
    final guideRating = guideRatingRaw is num
        ? guideRatingRaw.toDouble()
        : double.tryParse('$guideRatingRaw') ?? 0;
    final images = <String>[];
    final rawImages = json['images'] ?? json['gallery'] ?? json['pictures'];
    if (rawImages is List) {
      images.addAll(
        rawImages
            .map((e) => _resolveImagePath(e))
            .where((path) => path.isNotEmpty)
            .toList(),
      );
    } else if (rawImages is String) {
      final resolved = _resolveImagePath(rawImages);
      if (resolved.isNotEmpty) images.add(resolved);
    }

    final imagePath = _resolveImagePath(
      json['image'] ??
          json['imagePath'] ??
          json['cover'] ??
          json['thumbnail'] ??
          json['photo'] ??
          '',
    );
    final availabilityLabel = _stringify(
      json['availability_label'] ??
          json['availability'] ??
          (json['max_people'] != null ? 'До ${json['max_people']} чел.' : null),
    );
    final startDateLabel = _formatDate(
      json['departure_date'] ??
          json['start_date'] ??
          json['start_date_label'] ??
          '',
    );
    final returnDateLabel = _formatDate(
      json['return_date'] ?? json['end_date'] ?? json['returnDate'] ?? '',
    );
    final durationLabel = _formatDuration(
      json['duration'] ?? json['duration_label'],
    );
    final maxPeople = _intify(json['max_people'] ?? json['max_people_limit']);

    final categoryIdCandidate = _stringify(
      json['category_id'] ??
          json['categoryId'] ??
          json['tour_category_id'] ??
          json['tour_category'],
    );
    final guideIdCandidate = _stringify(
      json['guide_id'] ??
          json['guideId'] ??
          json['tour_guid_id'] ??
          json['tour_guide_id'] ??
          json['guide'],
    );

    return TravelPackage(
      id: _stringify(json['id']),
      companyId: _stringify(
        json['company_id'] ??
            json['companyId'] ??
            json['tour_company_id'] ??
            json['tour_company'],
      ),
      categoryId: categoryIdCandidate.isNotEmpty ? categoryIdCandidate : 'all',
      categoryLabel: _stringify(
        json['category_label'] ??
            json['category_title'] ??
            json['category'] ??
            '',
      ),
      title: _stringify(
        json['title'] ??
            json['name'] ??
            json['tour_title'] ??
            json['tour_name'] ??
            json['package_name'],
      ),
      location: _stringify(
        json['location'] ?? json['tour_location'] ?? json['place'] ?? '',
      ),
      imagePath: imagePath,
      gallery: images,
      guideName: _stringify(
        json['guide_name'] ??
            json['guideName'] ??
            json['guide'] ??
            json['guide_name_en'],
      ),
      guideId: guideIdCandidate,
      guideRating: guideRating,
      priceUsd: price is num ? price.toInt() : int.tryParse('$price') ?? 0,
      availabilityLabel: availabilityLabel,
      isNew: _boolify(json['is_new'] ?? json['isNew']),
      startDateLabel: startDateLabel,
      returnDateLabel: returnDateLabel,
      durationLabel: durationLabel,
      maxPeople: maxPeople,
    );
  }

  String get dateRangeLabel {
    if (startDateLabel.isNotEmpty && returnDateLabel.isNotEmpty) {
      return '$startDateLabel – $returnDateLabel';
    }
    if (startDateLabel.isNotEmpty) return startDateLabel;
    return returnDateLabel;
  }

  String get groupSizeLabel {
    if (maxPeople > 0) {
      return 'до $maxPeople человек';
    }
    return '';
  }

  String get priceLabel {
    if (priceUsd <= 0) return 'Цена по запросу';
    return 'от ${_formatPrice(priceUsd)} ₸';
  }

  String get priceSubtitle {
    if (priceUsd <= 0) return '';
    return 'за человека';
  }

  TravelPackage copyWith({
    String? guideName,
    double? guideRating,
    String? guideId,
    String? categoryId,
    String? categoryLabel,
    bool? isNew,
    String? availabilityLabel,
    String? returnDateLabel,
    String? durationLabel,
    int? maxPeople,
  }) {
    return TravelPackage(
      id: id,
      companyId: companyId,
      categoryId: categoryId ?? this.categoryId,
      categoryLabel: categoryLabel ?? this.categoryLabel,
      guideId: guideId ?? this.guideId,
      title: title,
      location: location,
      imagePath: imagePath,
      gallery: gallery,
      guideName: guideName ?? this.guideName,
      guideRating: guideRating ?? this.guideRating,
      priceUsd: priceUsd,
      availabilityLabel: availabilityLabel ?? this.availabilityLabel,
      isNew: isNew ?? this.isNew,
      startDateLabel: startDateLabel,
      returnDateLabel: returnDateLabel ?? this.returnDateLabel,
      durationLabel: durationLabel ?? this.durationLabel,
      maxPeople: maxPeople ?? this.maxPeople,
    );
  }

  static String _stringify(Object? value) {
    if (value == null) return '';
    if (value is String) return value.trim();
    return value.toString();
  }

  static int _intify(Object? value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    final parsed = int.tryParse('$value'.trim());
    return parsed ?? 0;
  }

  static bool _boolify(Object? value) {
    if (value == null) return false;
    if (value is bool) return value;
    final lowered = '$value'.trim().toLowerCase();
    return lowered == '1' ||
        lowered == 'true' ||
        lowered == 'yes' ||
        lowered == 'y';
  }

  static String _resolveImagePath(Object? raw) {
    final value = _stringify(raw);
    if (value.isEmpty) return '';
    if (value.startsWith('http')) return value;
    if (value.startsWith('/')) return '${ApiConstants.baseUrl}$value';
    return value;
  }

  static String _formatDate(Object? raw) {
    final value = _stringify(raw);
    if (value.isEmpty) return '';
    final parsed = DateTime.tryParse(value);
    if (parsed != null) {
      return '${parsed.day.toString().padLeft(2, "0")}.${parsed.month.toString().padLeft(2, "0")}.${parsed.year}';
    }
    return value;
  }

  static String _formatDuration(Object? raw) {
    final value = _stringify(raw);
    if (value.isEmpty) return '';
    final numeric = num.tryParse(value);
    if (numeric != null) {
      final intValue = numeric.toInt();
      return '$intValue ${intValue == 1 ? 'день' : 'дней'}';
    }
    return value;
  }

  static String _formatPrice(int value) {
    final formatter = value.toString();
    final parts = <String>[];
    for (int i = formatter.length; i > 0; i -= 3) {
      final start = i - 3 < 0 ? 0 : i - 3;
      parts.add(formatter.substring(start, i));
    }
    return parts.reversed.join(' ');
  }
}
