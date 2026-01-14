class TourBooking {
  final int id;
  final int tourId;
  final String name;
  final String surname;
  final String? patronymic;
  final int personNumber;
  final String phone;
  final String email;
  final String passportNumber;
  final DateTime dateOfBirth;
  final DateTime bookingDate;
  final String? secretCode;

  TourBooking({
    required this.id,
    required this.tourId,
    required this.name,
    required this.surname,
    required this.patronymic,
    required this.personNumber,
    required this.phone,
    required this.email,
    required this.passportNumber,
    required this.dateOfBirth,
    required this.bookingDate,
    required this.secretCode,
  });

  factory TourBooking.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(Object? value) {
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return TourBooking(
      id: (json['id'] as num?)?.toInt() ?? 0,
      tourId: (json['tour_id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      surname: json['surname'] as String? ?? '',
      patronymic: json['patronymic'] as String?,
      personNumber: (json['person_number'] as num?)?.toInt() ?? 1,
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      passportNumber: json['passport_number'] as String? ?? '',
      dateOfBirth: parseDate(json['date_of_birth']),
      bookingDate: parseDate(json['booking_date']),
      secretCode: json['secret_code'] as String?,
    );
  }
}
