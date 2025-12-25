import 'package:flutter/material.dart';
import 'package:safa_app/core/localization/app_localizations.dart';
import 'package:safa_app/features/settings/presentation/pages/admin_tour/manage_tours_page.dart';
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
            MaterialPageRoute(
              builder: (context) => const TourRequestsPage(),
            ),
          );
        },
      ),
      _AdminItem(
        icon: Icons.tour_outlined,
        color: const Color(0xFF3BA7F2),
        title: l10n.t('tourAdminPanel.menu.tours'),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ManageToursPage(),
            ),
          );
        },
      ),
      _AdminItem(
        icon: Icons.people_outline,
        color: const Color(0xFF8D6BFF),
        title: l10n.t('tourAdminPanel.menu.guides'),
        onTap: () {
          // TODO: Implement navigation to manage guides page
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Manage Guides coming soon!')),
          );
        },
      ),
      _AdminItem(
        icon: Icons.category_outlined,
        color: const Color(0xFF22B573),
        title: l10n.t('tourAdminPanel.menu.categories'),
        onTap: () {
          // TODO: Implement navigation to manage categories page
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Manage Categories coming soon!')),
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
        title: Text(
          l10n.t('tourAdminPanel.title'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: _companyName?.isNotEmpty == true
            ? PreferredSize(
                preferredSize: const Size.fromHeight(36),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
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
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _AdminCard(item: item);
                  },
                  separatorBuilder: (context, _) => const SizedBox(height: 12),
                  itemCount: items.length,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmExit(context),
                  icon: const Icon(Icons.logout, color: Color(0xFFE53935)),
                  label: Text(l10n.t('settings.logout')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE53935),
                    side: const BorderSide(color: Color(0xFFE53935)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
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
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: item.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: item.color.withValues(alpha: 0.22),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(item.icon, color: item.color, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  item.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
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
