import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safa_app/core/localization/app_localizations.dart';
import 'package:safa_app/core/service/db_service.dart';
import 'package:safa_app/features/settings/presentation/pages/super_admin/languages_page.dart';
import 'package:safa_app/features/settings/presentation/pages/super_admin/sadaqa_companies_page.dart';
import 'package:safa_app/features/settings/presentation/pages/super_admin/tour_companies_page.dart';

class SuperAdminPanelPage extends StatelessWidget {
  const SuperAdminPanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final sections = [
      _Section(
        color: const Color(0xFF3BA7F2),
        icon: Icons.flight_takeoff_outlined,
        title: l10n.t('settings.superAdmin.tourCard.title'),
        subtitle: l10n.t('settings.superAdmin.tourCard.subtitle'),
        builder: (_) => const TourCompaniesPage(),
      ),
      _Section(
        color: const Color(0xFF22B573),
        icon: Icons.volunteer_activism_outlined,
        title: l10n.t('settings.superAdmin.sadaqaCard.title'),
        subtitle: l10n.t('settings.superAdmin.sadaqaCard.subtitle'),
        builder: (_) => const SadaqaCompaniesPage(),
      ),
      _Section(
        color: const Color(0xFFF59E0B),
        icon: Icons.language_outlined,
        title: l10n.t('settings.superAdmin.languageCard.title'),
        subtitle: l10n.t('settings.superAdmin.languageCard.subtitle'),
        builder: (_) => const LanguagesPage(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('settings.superAdmin.title')),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            tooltip: l10n.t('settings.superAdmin.logout'),
            onPressed: () {
              DBService.superAdminAccessToken = '';
              DBService.superAdminRefreshToken = '';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.t('settings.superAdmin.logoutSuccess')),
                ),
              );
              Navigator.of(context).maybePop();
            },
            icon: const Icon(Icons.logout),
            color: const Color(0xFFE53935),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
          child: Column(
            children: [
              _buildInfoBanner(l10n, theme),
              SizedBox(height: 16.h),
              ...sections
                  .map(
                    (s) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _SectionCard(section: s),
                    ),
                  )
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBanner(AppLocalizations l10n, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5B8DEF), Color(0xFF7B6AF5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B8DEF).withValues(alpha: 0.28),
            blurRadius: 18.r,
            offset: Offset(0, 12.h),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.workspace_premium_outlined,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.t('settings.superAdmin.subtitle'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  l10n.t('settings.superAdmin.banner'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.86),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section {
  _Section({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.builder,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final WidgetBuilder builder;
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section});

  final _Section section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: section.color.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        onTap: () {
          Navigator.of(
            context,
            rootNavigator: true,
          ).push(MaterialPageRoute(builder: section.builder));
        },
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: section.color.withValues(alpha: 0.25),
                      blurRadius: 12.r,
                      offset: Offset(0, 8.h),
                    ),
                  ],
                ),
                child: Icon(section.icon, color: section.color),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      section.subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
