import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  AppLocalizations(this.locale, this._values);

  final Locale locale;
  final Map<String, String> _values;

  static const supportedLocales = [
    Locale('ru'),
    Locale('kk'),
    Locale('uz'),
  ];

  static const delegate = _AppLocalizationsDelegate();

  static Future<AppLocalizations> load(Locale locale) async {
    final languageCode = supportedLocales
            .map((l) => l.languageCode)
            .contains(locale.languageCode)
        ? locale.languageCode
        : supportedLocales.first.languageCode;

    final raw =
        await rootBundle.loadString('assets/i18n/$languageCode.json');
    final Map<String, dynamic> jsonMap = json.decode(raw);

    final values = jsonMap.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    return AppLocalizations(Locale(languageCode), values);
  }

  static AppLocalizations of(BuildContext context) {
    final result =
        Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(result != null, 'No AppLocalizations found in context');
    return result!;
  }

  String t(
    String key, {
    Map<String, String>? params,
  }) {
    var value = _values[key] ?? key;
    if (params != null) {
      params.forEach((paramKey, paramValue) {
        value = value.replaceAll('{$paramKey}', paramValue);
      });
    }
    return value;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .any((element) => element.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return AppLocalizations.load(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate old) => false;
}

extension LocalizationX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
