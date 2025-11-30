import 'package:safa_app/core/constants/api_constants.dart';
import 'package:safa_app/core/service/api_service.dart';

class RequestHelpPayload {
  final String firstName;
  final String lastName;
  final String phone;
  final String? email;
  final String city;
  final String address;
  final String category;
  final String amount;
  final String story;

  const RequestHelpPayload({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.city,
    required this.address,
    required this.category,
    required this.amount,
    required this.story,
    this.email,
  });

  Map<String, Object?> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'email': email,
      'city': city,
      'address': address,
      'category': category,
      'amount': amount,
      'story': story,
    };
  }
}

class RequestHelpRepository {
  Future<void> send(RequestHelpPayload payload) async {
    await ApiService.request<Map<String, Object?>>(
      ApiConstants.requestHelp,
      method: Method.post,
      data: payload.toJson(),
    );
  }
}
