import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:safa_app/core/navigation/app_shell.dart';
import 'package:safa_app/features/sadaqa/presentation/pages/request_help.dart';
import 'package:safa_app/features/sadaqa/presentation/pages/sadaqa_detail.dart';
import 'package:safa_app/features/sadaqa/presentation/pages/sadaqa_page.dart';
import 'package:safa_app/features/settings/presentation/pages/settings_page.dart';
import 'package:safa_app/features/travel/presentation/pages/travel_company_page.dart';
import 'package:safa_app/features/travel/presentation/pages/travel_page.dart';

enum AppRoute {
  sadaqa,
  sadaqaDetail,
  requestHelp,
  travel,
  travelCompany,
  settings
}

class AppRouter {
  AppRouter._();

  static final AppRouter instance = AppRouter._();

  final _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'rootNavigator');
  final _sadaqaNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'sadaqaNavigator');

  late final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/sadaqa',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _sadaqaNavigatorKey,
            routes: [
              GoRoute(
                path: '/sadaqa',
                name: AppRoute.sadaqa.name,
                builder: (context, state) => const SadaqaPage(),
                routes: [
                  GoRoute(
                    path: 'detail',
                    name: AppRoute.sadaqaDetail.name,
                    builder: (context, state) {
                      final args = state.extra;
                      if (args is! SadaqaDetailArgs) {
                        throw ArgumentError(
                          'Expected SadaqaDetailArgs, but got $args',
                        );
                      }
                      return SadaqaDetail(
                        cause: args.cause,
                        isFavorite: args.isFavorite,
                        onFavoriteChanged: args.onFavoriteChanged,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'request-help',
                    name: AppRoute.requestHelp.name,
                    builder: (context, state) => const RequestHelpPage(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/travel',
                name: AppRoute.travel.name,
                builder: (context, state) => const TravelPage(),
                routes: [
                  GoRoute(
                    path: 'company',
                    name: AppRoute.travelCompany.name,
                    builder: (context, state) {
                      final args = state.extra;
                      if (args is! TravelCompanyDetailArgs) {
                        throw ArgumentError(
                          'Expected TravelCompanyDetailArgs, but got $args',
                        );
                      }
                      return TravelCompanyPage(company: args.company);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: AppRoute.settings.name,
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
