import 'package:flutter/material.dart';

class AppSettingsState {
  const AppSettingsState({
    required this.locale,
    required this.themeMode,
    required this.initialized,
  });

  final Locale locale;
  final ThemeMode themeMode;
  final bool initialized;

  factory AppSettingsState.initial() => const AppSettingsState(
        locale: Locale('ru'),
        themeMode: ThemeMode.light,
        initialized: false,
      );

  bool get isDarkMode => themeMode == ThemeMode.dark;

  AppSettingsState copyWith({
    Locale? locale,
    ThemeMode? themeMode,
    bool? initialized,
  }) {
    return AppSettingsState(
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
      initialized: initialized ?? this.initialized,
    );
  }
}
