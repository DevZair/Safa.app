import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safa_app/core/localization/app_localizations.dart';
import 'package:safa_app/features/settings/presentation/pages/admin_tour/manage_categories_page.dart';
import 'package:safa_app/features/settings/presentation/pages/admin_tour/manage_tours_page.dart';
import 'package:safa_app/features/settings/presentation/pages/admin_tour/manage_guides_page.dart';
import 'package:safa_app/features/settings/presentation/pages/admin_tour/tour_requests_page.dart';

class TourAdminPanelPage extends StatefulWidget {
  const TourAdminPanelPage({super.key, this.companyName});

  final String? companyName;

  @override
  State<TourAdminPanelPage> createState() => _TourAdminPanelPageState();
}

class _TourAdminPanelPageState extends State<TourAdminPanelPage> {
  String? _companyName;

  @override
  void initState() {
    super.initState();
    _companyName = widget.companyName;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final items = [
      _AdminItem(
        icon: Icons.article_outlined,
        color: const Color(0xFF3B82F6),
        title: l10n.t('tourAdminPanel.menu.requests'),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const TourRequestsPage()),
          );
        },
      ),
      _AdminItem(
        icon: Icons.tour_outlined,
        color: const Color(0xFF3BA7F2),
        title: l10n.t('tourAdminPanel.menu.tours'),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ManageToursPage()),
          );
        },
      ),
      _AdminItem(
        icon: Icons.people_outline,
        color: const Color(0xFF8D6BFF),
        title: l10n.t('tourAdminPanel.menu.guides'),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ManageGuidesPage()),
          );
        },
      ),
      _AdminItem(
        icon: Icons.category_outlined,
        color: const Color(0xFF22B573),
        title: l10n.t('tourAdminPanel.menu.categories'),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ManageCategoriesPage(),
            ),
          );
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context, rootNavigator: true).maybePop();
            }
          },
        ),
        title: Text(
          l10n.t('tourAdminPanel.title'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: _companyName?.isNotEmpty == true
            ? PreferredSize(
                preferredSize: Size.fromHeight(36.h),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Text(
                    _companyName!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _AdminCard(item: item);
                  },
                  separatorBuilder: (context, _) => SizedBox(height: 12.h),
                  itemCount: items.length,
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmExit(context),
                  icon: const Icon(Icons.logout, color: Color(0xFFE53935)),
                  label: Text(l10n.t('settings.logout')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE53935),
                    side: BorderSide(
                      color: const Color(0xFFE53935),
                      width: 1.w,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmExit(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.l10n.t('tourAdminPanel.confirmExit')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(context.l10n.t('tourAdminPanel.cancelExit')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(context.l10n.t('settings.logout')),
            ),
          ],
        );
      },
    );

    if (shouldExit == true) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
}

class _AdminItem {
  _AdminItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback onTap;
}

class _AdminCard extends StatelessWidget {
  const _AdminCard({required this.item});

  final _AdminItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: item.color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(22.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(22.r),
        onTap: item.onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Container(
                width: 52.r,
                height: 52.r,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: item.color.withValues(alpha: 0.22),
                      blurRadius: 14.r,
                      offset: Offset(0, 8.h),
                    ),
                  ],
                ),
                child: Icon(item.icon, color: item.color, size: 26.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  item.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, size: 20.sp),
            ],
          ),
        ),
      ),
    );
  }
}
