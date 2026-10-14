// Apps de prueba con los textos de la interfaz cargados. Las pantallas leen
// sus textos con AppLocalizations.of(context): sin estos delegates fallan.
// Los tests corren en español (el idioma fuente).

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:the_messenger/l10n/app_localizations.dart';

/// Idioma de los tests.
const kTestLocale = Locale('es');

/// Idiomas de la app.
const kTestSupportedLocales = AppLocalizations.supportedLocales;

/// Delegates de la app, para los tests que arman su propio MaterialApp.
const kTestLocalizationsDelegates = <LocalizationsDelegate<dynamic>>[
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

/// Un MaterialApp en español con [home].
Widget localizedApp(Widget home, {Locale locale = kTestLocale}) => MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: kTestLocalizationsDelegates,
      home: home,
    );

/// Un MaterialApp.router en español.
Widget localizedRouterApp(RouterConfig<Object> router,
        {Locale locale = kTestLocale}) =>
    MaterialApp.router(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: kTestLocalizationsDelegates,
      routerConfig: router,
    );

/// Los textos en español, para tests sin widgets.
AppLocalizations get esStrings => lookupAppLocalizations(kTestLocale);
