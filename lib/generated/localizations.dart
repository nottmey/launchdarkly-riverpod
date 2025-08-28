// GENERATED CODE
//
// After the template files .arb have been changed,
// generate this class by the command in the terminal:
// flutter pub run lokalise_flutter_sdk:gen-lok-l10n
//
// Please see https://pub.dev/packages/lokalise_flutter_sdk

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes
// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:lokalise_flutter_sdk/lokalise_flutter_sdk.dart';
import 'intl/messages_all.dart';

class L10nExtension {
  L10nExtension._internal();

  static const LocalizationsDelegate<L10nExtension> delegate =
      _AppLocalizationDelegate();

  static const List<Locale> supportedLocales = [
    Locale.fromSubtags(languageCode: 'en'),
    Locale.fromSubtags(languageCode: 'de'),
    Locale.fromSubtags(languageCode: 'nl')
  ];

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static final Map<String, List<String>> _metadata = {'title': []};

  static Future<L10nExtension> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    Lokalise.instance.metadata = _metadata;

    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = L10nExtension._internal();
      return instance;
    });
  }

  static L10nExtension of(BuildContext context) {
    final instance = Localizations.of<L10nExtension>(context, L10nExtension);
    assert(instance != null,
        'No instance of L10nExtension present in the widget tree. Did you add L10nExtension.delegate in localizationsDelegates?');
    return instance!;
  }

  /// `English Title`
  String get title {
    return Intl.message(
      'English Title',
      name: 'title',
      desc: '',
      args: [],
    );
  }
}

class _AppLocalizationDelegate extends LocalizationsDelegate<L10nExtension> {
  const _AppLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => L10nExtension.supportedLocales.any(
      (supportedLocale) => supportedLocale.languageCode == locale.languageCode);

  @override
  Future<L10nExtension> load(Locale locale) => L10nExtension.load(locale);

  @override
  bool shouldReload(_AppLocalizationDelegate old) => false;
}
