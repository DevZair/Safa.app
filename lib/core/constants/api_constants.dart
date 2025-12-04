final class ApiConstants {
  const ApiConstants._();

  // TODO: replace with the FastAPI base URL when it is available.
  static const String baseUrl = 'http://localhost:8000';

  static const String travelCompanies = '/api/travel/companies';
  static const String travelPackages = '/api/travel/packages';

  static const String requestHelp = '/api/sadaqa/help_request/';
  static const String sadaqaCategories = '/api/sadaqa/help_category/';
  static const String sadaqaMaterialStatuses = '/api/sadaqa/materials_status/';
}
