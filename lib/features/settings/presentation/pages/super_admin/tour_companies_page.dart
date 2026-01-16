import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safa_app/core/localization/app_localizations.dart';
import 'package:safa_app/core/utils/error_messages.dart';
import 'package:safa_app/features/settings/data/repositories/super_admin_repository_impl.dart';
import 'package:safa_app/features/settings/domain/repositories/super_admin_repository.dart';
import 'package:safa_app/features/travel/domain/entities/travel_company.dart';
import 'package:safa_app/features/settings/presentation/pages/super_admin/tour_company_create_page.dart';

class TourCompaniesPage extends StatefulWidget {
  const TourCompaniesPage({super.key});

  @override
  State<TourCompaniesPage> createState() => _TourCompaniesPageState();
}

class _TourCompaniesPageState extends State<TourCompaniesPage> {
  final SuperAdminRepository _repository = SuperAdminRepositoryImpl();
  bool _loading = true;
  List<TravelCompany> _companies = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('settings.superAdmin.tourCard.title'))),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 80.h),
                  itemBuilder: (context, index) {
                    final company = _companies[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(
                          0xFF3BA7F2,
                        ).withValues(alpha: 0.12),
                        child: const Icon(
                          Icons.flight_takeoff_outlined,
                          color: Color(0xFF3BA7F2),
                        ),
                      ),
                      title: Text(company.name),
                      subtitle: Text(
                        '${l10n.t('settings.superAdmin.fields.rating')}: ${company.rating.toStringAsFixed(1)}',
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemCount: _companies.length,
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreate(),
        label: Text(l10n.t('settings.superAdmin.actions.createTour')),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await _repository.fetchTourCompanies();
      if (!mounted) return;
      setState(() => _companies = list);
    } catch (e) {
      if (!mounted) return;
      _showMessage(friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openCreate() async {
    final created = await Navigator.of(context, rootNavigator: true).push<bool>(
      MaterialPageRoute(
        builder: (_) => TourCompanyCreatePage(repository: _repository),
      ),
    );
    if (created == true) {
      await _load();
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
