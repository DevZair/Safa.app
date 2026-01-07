import 'package:safa_app/features/travel/domain/entities/travel_category.dart';
import 'package:safa_app/features/travel/domain/entities/travel_company.dart';
import 'package:safa_app/features/travel/domain/entities/travel_guide.dart';
import 'package:safa_app/features/travel/domain/entities/travel_package.dart';

abstract class TravelRepository {
  Future<List<TravelCompany>> fetchCompanies();
  Future<List<TravelPackage>> fetchPackages();
  Future<List<TravelGuide>> fetchGuides();
  Future<List<TravelCategory>> fetchCategories();
  Future<int> fetchActiveToursCount();
}
