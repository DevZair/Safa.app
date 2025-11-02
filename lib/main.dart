import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:safa_app/core/navigation/app_shell.dart';
import 'package:safa_app/firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("📩 Background message: ${message.notification?.title}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const SafaApp());
}

class SafaApp extends StatefulWidget {
  const SafaApp({super.key});

  @override
  State<SafaApp> createState() => _SafaAppState();
}

class _SafaAppState extends State<SafaApp> {
  @override
  void initState() {
    super.initState();
    _initFirebaseMessaging();
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Safa',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2C7A7B)),
        useMaterial3: true,
      ),
      home: const AppShell(),
    );
  }
}
