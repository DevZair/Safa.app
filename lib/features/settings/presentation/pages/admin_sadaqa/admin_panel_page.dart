import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safa_app/core/localization/app_localizations.dart';
import 'package:safa_app/features/sadaqa/domain/entities/sadaqa_company.dart';
import 'package:safa_app/features/settings/presentation/pages/admin_sadaqa/admin_company_profile_page.dart';
import 'package:safa_app/features/settings/presentation/pages/admin_sadaqa/admin_help_requests_page.dart';
import 'package:safa_app/features/settings/presentation/pages/admin_sadaqa/admin_notes_page.dart';
import 'package:safa_app/features/settings/presentation/pages/admin_sadaqa/admin_posts_page.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key, this.companyName});

  final String? companyName;

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
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
        icon: Icons.note_alt_outlined,
        color: const Color(0xFF3BA7F2),
        title: l10n.t('settings.admin.menu.notes'),
        onTap: () => _openNotes(context, _companyName),
      ),
      _AdminItem(
        icon: Icons.article_outlined,
        color: const Color(0xFF8D6BFF),
        title: l10n.t('settings.admin.menu.posts'),
        onTap: () => _openPosts(context, _companyName),
      ),
      _AdminItem(
        icon: Icons.contact_support_outlined,
        color: const Color(0xFF22B573),
        title: l10n.t('settings.admin.menu.help'),
        onTap: () => _openHelpRequests(context, _companyName),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.t('settings.admin.panel.title'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 6.w),
            child: IconButton(
              tooltip: 'Профиль компании',
              onPressed: _openCompanyProfile,
              icon: CircleAvatar(
                radius: 18.r,
                backgroundColor: const Color(0xFFE8EEF5),
                child: const Icon(
                  Icons.account_circle_outlined,
                  color: Color(0xFF3BA7F2),
                ),
              ),
            ),
          ),
        ],
        bottom: _companyName?.isNotEmpty == true
            ? PreferredSize(
                preferredSize: Size.fromHeight(36.h),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Text(
                    _companyName!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.7,
                      ),
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
                  label: const Text('Выйти'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE53935),
                    side: BorderSide(color: const Color(0xFFE53935), width: 1.w),
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

  Future<void> _openCompanyProfile() async {
    final updated = await Navigator.of(context, rootNavigator: true)
        .push<SadaqaCompany>(
      MaterialPageRoute(
        builder: (_) => AdminCompanyProfilePage(companyName: _companyName),
      ),
    );

    if (!mounted || updated == null) return;

    setState(() => _companyName = updated.title);
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

void _openNotes(BuildContext context, String? companyName) {
  Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute(
      builder: (_) => AdminNotesPage(companyName: companyName),
    ),
  );
}

void _openHelpRequests(BuildContext context, String? companyName) {
  Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute(
      builder: (_) => AdminHelpRequestsPage(companyName: companyName),
    ),
  );
}

void _openPosts(BuildContext context, String? companyName) {
  Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute(
      builder: (_) => AdminPostsPage(companyName: companyName),
    ),
  );
}

Future<void> _confirmExit(BuildContext context) async {
  final shouldExit = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Выйти из админки?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Выйти'),
          ),
        ],
      );
    },
  );

  if (shouldExit == true) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
