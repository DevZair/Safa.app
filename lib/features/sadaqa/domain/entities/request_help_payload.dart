class RequestHelpPayload {
  final String name;
  final String surname;
  final String phoneNumber;
  final String address;
  final String whyNeedHelp;
  final int helpCategory;
  final String? otherCategory;
  final String? companyName;
  final int? companyId;
  final int? age;
  final int? childInFam;
  final String? iin;
  final int? materialStatus;
  final int? status;
  final num? money;
  final bool receivedOtherHelp;

  const RequestHelpPayload({
    required this.name,
    required this.surname,
    required this.phoneNumber,
    required this.address,
    required this.whyNeedHelp,
    required this.helpCategory,
    this.receivedOtherHelp = false,
    this.otherCategory,
    this.companyName,
    this.companyId,
    this.age,
    this.childInFam,
    this.iin,
    this.materialStatus,
    this.money,
    this.status,
  });

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'name': name,
      'surname': surname,
      'age': age ?? 0,
      'phone_number': phoneNumber,
      'other_category': otherCategory,
      'child_num': childInFam ?? 0,
      'address': address,
      'iin': iin ?? '',
      'help_reason': whyNeedHelp,
      'received_other_help': receivedOtherHelp,
      'company_name': companyName,
      'company_id': companyId,
      'status': status,
      'materials_status_id': materialStatus ?? 0,
      'help_category_id': helpCategory,
      'money': money,
    };
  }
}
