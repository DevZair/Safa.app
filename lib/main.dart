import 'package:safa_app/features/travel/data/repositories/travel_repository_impl.dart';
import 'package:safa_app/features/travel/domain/repositories/travel_repository.dart';
import 'package:safa_app/features/travel/presentation/cubit/travel_cubit.dart';
import 'package:safa_app/core/localization/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:safa_app/core/settings/app_settings_state.dart';
import 'package:safa_app/core/settings/app_settings_cubit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:safa_app/core/navigation/app_router.dart';
import 'package:safa_app/core/service/db_service.dart';
import 'package:safa_app/core/styles/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safa_app/firebase_options.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

const Size _designSize = Size(440, 956);

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("📩 Background message: ${message.notification?.title}");
}

void _installKeyEventGuard(WidgetsBinding binding) {
  if (!kDebugMode) return;

  final originalHandler = binding.platformDispatcher.onKeyData;
  final pressedPhysicalKeys = <int>{};

  binding.platformDispatcher.onKeyData = (ui.KeyData data) {
    if (data.type == ui.KeyEventType.down) {
      pressedPhysicalKeys.add(data.physical);
    } else if (data.type == ui.KeyEventType.up &&
        !pressedPhysicalKeys.remove(data.physical)) {
      debugPrint(
        'Dropping stray KeyUpEvent for physical key 0x${data.physical.toRadixString(16)}',
      );
      return true;
    }
    return originalHandler?.call(data) ?? false;
  };
}

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  _installKeyEventGuard(binding);

  const enableMessaging = !kIsWeb;

  if (enableMessaging) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
  await DBService.initialize();

  final preferences = await SharedPreferences.getInstance();

  runApp(
    ScreenUtilInit(
      designSize: _designSize,
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      builder: (_, child) => child ?? const SizedBox.shrink(),
      child: SafaApp(prefs: preferences, enableMessaging: enableMessaging),
    ),
  );
}

class SafaApp extends StatefulWidget {
  const SafaApp({super.key, required this.prefs, this.enableMessaging = true});

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

    try {
      final token = await messaging.getToken();
      if (token != null && token.isNotEmpty) {
        DBService.fcmToken = token;
        debugPrint("🔥 FCM Token: $token");
      } else {
        debugPrint("⚠️ FCM token not available yet");
      }
    } catch (error) {
      debugPrint("⚠️ FCM token not available yet: $error");
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      DBService.fcmToken = newToken;
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
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<TravelRepository>(
          create: (_) => TravelRepositoryImpl(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                TravelCubit(repository: context.read<TravelRepository>()),
          ),
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
      ),
    );
  }
}
