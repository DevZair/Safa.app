class AdminAuthTokens {
  const AdminAuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
  });

  final String accessToken;
  final String? refreshToken;
  final String tokenType;
}
