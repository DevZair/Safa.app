import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safa_app/core/localization/app_localizations.dart';
import 'package:safa_app/core/navigation/app_router.dart';
import 'package:safa_app/core/settings/app_settings_cubit.dart';
import 'package:safa_app/core/settings/app_settings_state.dart';
import 'package:safa_app/core/styles/app_theme.dart';
import 'package:safa_app/features/travel/presentation/cubit/travel_cubit.dart';
import 'package:safa_app/firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("📩 Background message: ${message.notification?.title}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final preferences = await SharedPreferences.getInstance();

  runApp(SafaApp(prefs: preferences));
}

class SafaApp extends StatefulWidget {
  const SafaApp({
    super.key,
    required this.prefs,
    this.enableMessaging = true,
  });

  final bool enableMessaging;
  final SharedPreferences prefs;

  @override
  State<SafaApp> createState() => _SafaAppState();
}

class _SafaAppState extends State<SafaApp> {
  late final GoRouter _router = AppRouter.instance.router;

  @override
  void initState() {
    super.initState();
    if (widget.enableMessaging) {
      _initFirebaseMessaging();
    }
  }

  Future<void> _initFirebaseMessaging() async {
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('🔐 Permission: ${settings.authorizationStatus.name}');

    final token = await messaging.getToken();
    debugPrint("🔥 FCM Token: $token");

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      debugPrint("♻️ Token refreshed: $newToken");
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.notification?.title ?? "No title";
      final body = message.notification?.body ?? "No body";
      debugPrint("📲 Foreground message: $title — $body");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("➡️ Notification opened: ${message.notification?.title}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => TravelCubit()),
        BlocProvider(create: (_) => AppSettingsCubit(widget.prefs)),
      ],
      child: BlocBuilder<AppSettingsCubit, AppSettingsState>(
        builder: (context, settingsState) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Safa',
            locale: settingsState.locale,
            themeMode: settingsState.themeMode,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            routerConfig: _router,
          );
        },
      ),
    );
  }
}

