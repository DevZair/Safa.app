import 'package:shared_preferences/shared_preferences.dart';

enum StorageKeys {
  token('token'),
  languageCode('language_code'),
  fcmToken('fcm_token'),
  baseUrl('base_url');
  

  const StorageKeys(this.key);
  final String key;
}

late final SharedPreferences $storage;

class DBService {
  static Future<void> initialize() async {
    $storage = await SharedPreferences.getInstance();
  }

  static String get token {
    return $storage.getString(StorageKeys.token.name) ?? '';
  }

  static set token(String token) {
    $storage.setString(StorageKeys.token.name, token);
  }

  static String get languageCode {
    return $storage.getString(StorageKeys.languageCode.name) ?? 'ru';
  }

  static set languageCode(String code) {
    $storage.setString(StorageKeys.languageCode.name, code);
  }

  static String get fcmToken {
    return $storage.getString(StorageKeys.fcmToken.name) ?? '';
  }

  static set fcmToken(String token) {
    $storage.setString(StorageKeys.fcmToken.name, token);
  }

  static String get baseUrl {
    return $storage.getString(StorageKeys.baseUrl.name) ?? '';
  }

  static set baseUrl(String token) {
    $storage.setString(StorageKeys.baseUrl.name, token);
  }
}