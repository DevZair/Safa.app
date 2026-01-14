class AdminLoginResult {
  const AdminLoginResult({
    required this.sadaqaSuccess,
    required this.tourSuccess,
  });

  final bool sadaqaSuccess;
  final bool tourSuccess;

  bool get hasAnySuccess => sadaqaSuccess || tourSuccess;
}
