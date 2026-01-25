import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safa_app/core/localization/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:safa_app/core/utils/error_messages.dart';
import 'package:safa_app/features/travel/data/repositories/tour_repository_impl.dart';
import 'package:safa_app/features/travel/domain/entities/tour_booking.dart';
import 'package:safa_app/features/travel/domain/entities/tour.dart';
import 'package:safa_app/features/travel/domain/repositories/tour_repository.dart';

class TourRequestsPage extends StatefulWidget {
  const TourRequestsPage({super.key});

  @override
  State<TourRequestsPage> createState() => _TourRequestsPageState();
}

class _TourRequestsPageState extends State<TourRequestsPage> {
  final TourRepository _repository = TourRepositoryImpl();
  late Future<List<TourBooking>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _bookingsFuture = _repository.getBookings();
  }

  void _refresh() {
    setState(() {
      _bookingsFuture = _repository.getBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('tourAdminPanel.menu.requests')),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: FutureBuilder<List<TourBooking>>(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Не удалось загрузить заявки'),
                  SizedBox(height: 8.h),
                  Text(
                    friendlyError(snapshot.error),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12.h),
                  ElevatedButton(
                    onPressed: _refresh,
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }
          final bookings = snapshot.data ?? [];
          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Заявок пока нет'),
                  SizedBox(height: 12.h),
                  ElevatedButton(
                    onPressed: _refresh,
                    child: const Text('Обновить'),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView.separated(
              padding: EdgeInsets.all(16.r),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return _BookingTile(booking: booking);
              },
              separatorBuilder: (context, index) => SizedBox(height: 8.h),
            ),
          );
        },
      ),
    );
  }
}

class _BookingTile extends StatelessWidget {
  const _BookingTile({required this.booking});

  final TourBooking booking;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateLabel = DateFormat(
      'dd MMM yyyy, HH:mm',
    ).format(booking.bookingDate);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: ListTile(
        title: Text('${booking.surname} ${booking.name}'),
        subtitle: Text(
          'Тур ID: ${booking.tourId}\nТел: ${booking.phone}\n$dateLabel',
        ),
        isThreeLine: true,
        trailing: Icon(Icons.chevron_right, size: 20.sp),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BookingDetailPage(booking: booking),
            ),
          );
        },
      ),
    );
  }
}

class BookingDetailPage extends StatefulWidget {
  const BookingDetailPage({required this.booking, super.key});

  final TourBooking booking;

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  final TourRepository _repository = TourRepositoryImpl();
  late Future<Tour?> _tourFuture;

  @override
  void initState() {
    super.initState();
    _tourFuture = _loadTour();
  }

  Future<Tour?> _loadTour() async {
    try {
      final tours = await _repository.getTours();
      return tours.firstWhere(
        (t) => t.id == widget.booking.tourId,
        orElse: () => tours.isNotEmpty ? tours.first : null as Tour,
      );
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Детали заявки')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Section(
              title: 'Информация о заявке',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(
                    label: 'Имя',
                    value: '${booking.surname} ${booking.name}',
                  ),
                  if (booking.patronymic?.isNotEmpty == true)
                    _InfoRow(label: 'Отчество', value: booking.patronymic!),
                  _InfoRow(label: 'Телефон', value: booking.phone),
                  _InfoRow(label: 'Email', value: booking.email),
                  _InfoRow(label: 'Паспорт', value: booking.passportNumber),
                  _InfoRow(
                    label: 'Кол-во человек',
                    value: booking.personNumber.toString(),
                  ),
                  _InfoRow(
                    label: 'Дата рождения',
                    value: DateFormat('dd.MM.yyyy').format(booking.dateOfBirth),
                  ),
                  _InfoRow(
                    label: 'Дата заявки',
                    value: DateFormat(
                      'dd.MM.yyyy HH:mm',
                    ).format(booking.bookingDate),
                  ),
                  _InfoRow(
                    label: 'Секретный код',
                    value: booking.secretCode ?? '-',
                  ),
                  _InfoRow(label: 'ID тура', value: booking.tourId.toString()),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            _Section(
              title: 'Тур',
              child: FutureBuilder<Tour?>(
                future: _tourFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    return Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        friendlyError(snapshot.error),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.red,
                        ),
                      ),
                    );
                  }
                  final tour = snapshot.data;
                  if (tour == null) {
                    return const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text('Тур не найден'),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoRow(label: 'Локация', value: tour.location),
                      _InfoRow(label: 'Цена', value: tour.price.toString()),
                      _InfoRow(label: 'Статус', value: tour.status.toString()),
                      _InfoRow(
                        label: 'Длительность',
                        value: '${tour.duration} дн.',
                      ),
                      _InfoRow(
                        label: 'Вылет',
                        value: tour.departureDate.split('T').first,
                      ),
                      _InfoRow(
                        label: 'Возврат',
                        value: tour.returnDate.split('T').first,
                      ),
                      _InfoRow(
                        label: 'Макс. людей',
                        value: tour.maxPeople.toString(),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
