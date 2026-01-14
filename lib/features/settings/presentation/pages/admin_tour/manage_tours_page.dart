import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:safa_app/core/utils/error_messages.dart';
import 'package:safa_app/core/constants/api_constants.dart';
import 'package:safa_app/features/settings/presentation/pages/admin_tour/create_edit_tour_page.dart';
import 'package:safa_app/features/travel/data/repositories/tour_repository_impl.dart';
import 'package:safa_app/features/travel/domain/entities/tour.dart';
import 'package:safa_app/features/travel/domain/repositories/tour_repository.dart';

class ManageToursPage extends StatefulWidget {
  const ManageToursPage({super.key});

  @override
  State<ManageToursPage> createState() => _ManageToursPageState();
}

class _ManageToursPageState extends State<ManageToursPage> {
  final TourRepository _tourRepository = TourRepositoryImpl();
  late Future<List<Tour>> _toursFuture;

  @override
  void initState() {
    super.initState();
    _toursFuture = _tourRepository.getTours();
  }

  void _refreshTours() {
    setState(() {
      _toursFuture = _tourRepository.getTours();
    });
  }

  Future<void> _navigateToCreateEditPage({Tour? tour}) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => CreateEditTourPage(tour: tour)),
    );

    if (result == true) {
      _refreshTours();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Tours')),
      body: FutureBuilder<List<Tour>>(
        future: _toursFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Не удалось загрузить туры'),
                  SizedBox(height: 8.h),
                  Text(
                    friendlyError(snapshot.error),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ElevatedButton(
                    onPressed: _refreshTours,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tours found.'));
          }

          final tours = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(16.r),
            itemCount: tours.length,
            itemBuilder: (context, index) {
              final tour = tours[index];
              return _TourCard(
                tour: tour,
                onTap: () => _navigateToCreateEditPage(tour: tour),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateEditPage,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _TourCard extends StatelessWidget {
  final Tour tour;
  final VoidCallback onTap;

  const _TourCard({required this.tour, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'en_US', // Or use a locale that fits your currency needs
      symbol: '\$', // Or any other currency symbol
      decimalDigits: 0,
    );

    final imageUrl = tour.image.startsWith('http')
        ? tour.image
        : '${ApiConstants.baseUrl}${tour.image}';

    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 180.h,
              width: double.infinity,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.grey,
                      size: 48.sp,
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tour.location,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        Icons.price_change,
                        color: theme.primaryColor,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        currencyFormatter.format(tour.price),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.timer_outlined,
                        color: Colors.grey[600],
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '${tour.duration} days',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  const Divider(),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDateInfo(
                        context,
                        icon: Icons.flight_takeoff,
                        label: 'Departure',
                        date: tour.departureDate,
                      ),
                      _buildDateInfo(
                        context,
                        icon: Icons.flight_land,
                        label: 'Return',
                        date: tour.returnDate,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateInfo(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String date,
  }) {
    final theme = Theme.of(context);
    DateTime? parsedDate;
    try {
      parsedDate = DateTime.parse(date);
    } catch (e) {
      // Ignore parsing errors
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
        SizedBox(height: 4.h),
        Row(
          children: [
            Icon(icon, size: 18.sp, color: Colors.grey[700]),
            SizedBox(width: 6.w),
            Text(
              parsedDate != null
                  ? DateFormat.yMMMd().format(parsedDate)
                  : 'N/A',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
