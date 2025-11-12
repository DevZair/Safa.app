import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_settings_state.dart';

class AppSettingsCubit extends Cubit<AppSettingsState> {
  AppSettingsCubit(this._preferences) : super(AppSettingsState.initial()) {
    _hydrate();
  }

  final SharedPreferences _preferences;

  static const _localeKey = 'app_locale';
  static const _themeKey = 'app_theme_mode';

  Future<void> _hydrate() async {
    final storedLocale = _preferences.getString(_localeKey);
    final storedTheme = _preferences.getInt(_themeKey);

    emit(
      state.copyWith(
        locale: storedLocale != null ? Locale(storedLocale) : state.locale,
        themeMode: storedTheme != null
            ? ThemeMode.values[storedTheme]
            : state.themeMode,
        initialized: true,
      ),
    );
  }

  Future<void> changeLocale(Locale locale) async {
    if (locale.languageCode == state.locale.languageCode) return;
    await _preferences.setString(_localeKey, locale.languageCode);
    emit(state.copyWith(locale: locale));
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    if (mode == state.themeMode) return;
    await _preferences.setInt(_themeKey, mode.index);
    emit(state.copyWith(themeMode: mode));
  }

  Future<void> toggleDarkMode(bool isDark) {
    return updateThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }
}




