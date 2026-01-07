import 'dart:io';

import 'package:safa_app/features/travel/domain/entities/tour.dart';
import 'package:safa_app/features/travel/domain/entities/tour_category.dart';
import 'package:safa_app/features/travel/domain/entities/tour_guide.dart';

abstract class TourRepository {
  Future<List<Tour>> getTours();
  Future<Tour> createTour(Tour tour);
  Future<Tour> updateTour(int tourId, Tour tour);
  Future<List<TourCategory>> getCategories();
  Future<List<TourGuide>> getGuides();
  Future<String> uploadImage(File file);
}
