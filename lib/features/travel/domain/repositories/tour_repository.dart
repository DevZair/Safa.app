import 'dart:io';

import 'package:safa_app/features/travel/domain/entities/tour.dart';
import 'package:safa_app/features/travel/domain/entities/tour_category.dart';
import 'package:safa_app/features/travel/domain/entities/tour_guide.dart';
import 'package:safa_app/features/travel/domain/entities/tour_booking.dart';
import 'package:safa_app/features/travel/domain/entities/travel_guide.dart';

abstract class TourRepository {
  Future<List<Tour>> getTours();
  Future<Tour> createTour(Tour tour);
  Future<Tour> updateTour(int tourId, Tour tour);
  Future<List<TourCategory>> getCategories();
  Future<List<TourGuide>> getGuides();
  Future<List<TravelGuide>> getGuidesDetailed();
  Future<List<TourBooking>> getBookings();
  Future<TourCategory> createCategory({required String title});
  Future<TourCategory> updateCategory({
    required int categoryId,
    required String title,
  });
  Future<TravelGuide> createGuide({
    required String firstName,
    required String lastName,
    required String about,
    double? rating,
  });
  Future<TravelGuide> updateGuide({
    required int guideId,
    required String firstName,
    required String lastName,
    required String about,
    double? rating,
  });
  Future<String> uploadImage(File file);
}
