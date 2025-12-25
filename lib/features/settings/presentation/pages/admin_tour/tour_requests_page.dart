import 'package:flutter/material.dart';
import 'package:safa_app/core/localization/app_localizations.dart';

class TourRequestsPage extends StatefulWidget {
  const TourRequestsPage({super.key});

  @override
  State<TourRequestsPage> createState() => _TourRequestsPageState();
}

class _TourRequestsPageState extends State<TourRequestsPage> {
  // Dummy data for now
  final List<Map<String, String>> _requests = List.generate(
    10,
    (index) => {
      'name': 'User ${index + 1}',
      'tour': 'Tour to Mecca #${index + 1}',
      'date': '2025-12-${10 + index}',
    },
  );

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
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          final request = _requests[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(request['name']!),
              subtitle: Text('${request['tour']!}\n${request['date']!}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Implement navigation to request detail page
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Details for ${request['name']}')),
                );
              },
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 8),
      ),
    );
  }
}
