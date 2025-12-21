import 'package:flutter/material.dart';

class AppSettingsState {
  const AppSettingsState({
    required this.locale,
    required this.themeMode,
    required this.initialized,
    required this.adminLogin,
    required this.adminPassword,
  });

  final Locale locale;
  final ThemeMode themeMode;
  final bool initialized;
  final String adminLogin;
  final String adminPassword;

  factory AppSettingsState.initial() => const AppSettingsState(
        locale: Locale('ru'),
        themeMode: ThemeMode.light,
        initialized: false,
        adminLogin: '',
        adminPassword: '',
      );

  bool get isDarkMode => themeMode == ThemeMode.dark;

  AppSettingsState copyWith({
    Locale? locale,
    ThemeMode? themeMode,
    bool? initialized,
    String? adminLogin,
    String? adminPassword,
  }) {
    return AppSettingsState(
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
      initialized: initialized ?? this.initialized,
      adminLogin: adminLogin ?? this.adminLogin,
      adminPassword: adminPassword ?? this.adminPassword,
    );
  }
}
