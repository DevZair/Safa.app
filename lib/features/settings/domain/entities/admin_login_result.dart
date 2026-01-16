class AdminLoginResult {
  const AdminLoginResult({
    required this.sadaqaSuccess,
    required this.tourSuccess,
    required this.superAdminSuccess,
  });

  final bool sadaqaSuccess;
  final bool tourSuccess;
  final bool superAdminSuccess;

  bool get hasAnySuccess => sadaqaSuccess || tourSuccess || superAdminSuccess;
}
