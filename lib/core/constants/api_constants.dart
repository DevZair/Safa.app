final class ApiConstants {
  const ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://safa-production.up.railway.app',
  );
  static const String apiToken = String.fromEnvironment(
    'API_TOKEN',
    defaultValue: '',
  );

  static const String travelCompanies = '/api/tour/public/companies/';
  static const String travelPackages = '/api/tour/public/tours/';
  static const String travelCategories = '/api/tour/public/categories/';
  static const String travelGuides = '/api/tour/public/guides/';
  static const String travelActiveToursCount =
      '/api/tour/public/companies/active-tours-count';
  static const String tourPrivateTours = '/api/tour/private/tours/';
  static const String tourPrivateCategories = '/api/tour/private/categories/';
  static const String tourPrivateGuides = '/api/tour/private/guides/';
  static const String sadaqaCauses = '/api/sadaqa/public/notes/';
  static const String sadaqaAdminLogin = '/api/sadaqa/private/company/login';
  static const String sadaqaAdminPosts = '/api/sadaqa/private/posts';
  static const String sadaqaAdminNotes = '/api/sadaqa/private/notes';
  static const String uploadFile = '/api/upload/';
  static const String requestHelp = '/api/sadaqa/public/help-requests/';
  static const String requestHelpFileUpload =
      '/api/sadaqa/public/help-request-files/';
  static const String sadaqaHelpRequests = '/api/sadaqa/private/help-requests/';
  static const String sadaqaCategories = '/api/sadaqa/public/categories/';
  static const String sadaqaCompanies = '/api/sadaqa/public/company/';
  static const String sadaqaMaterialStatuses =
      '/api/sadaqa/public/materials-status/';
  static const String sadaqaPrivateMaterialStatuses =
      '/api/sadaqa/private/materials-status/';
  static const String sadaqaPrivateHelpCategories =
      '/api/sadaqa/private/help-categories/';
}
