import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../data/localized_content.dart';
import '../../domain/entities/content_l10n.dart';

/// Idiomas del juego. El español es la fuente; el resto se superpone.
const kLanguages = ['es', 'en'];

/// El idioma que corresponde: el elegido en Ajustes o, si no hay, el del
/// teléfono (español si lo habla; si no, inglés).
String resolveLanguage(String? chosen, Locale device) {
  if (chosen != null && kLanguages.contains(chosen)) return chosen;
  return device.languageCode == 'es' ? 'es' : 'en';
}

/// Carga la tabla del contenido del idioma y la deja activa.
Future<void> applyLanguage(String lang) async {
  Intl.defaultLocale = lang;
  if (lang == 'es') {
    // La fuente por clave: retraduce al español lo guardado en otro idioma.
    ContentL10n.use('es', contentKeys());
    return;
  }
  try {
    final raw = await rootBundle.loadString('assets/l10n/content_$lang.json');
    final table = (jsonDecode(raw) as Map<String, dynamic>)
        .map((k, v) => MapEntry(k, v as String));
    ContentL10n.use(lang, table);
  } catch (e) {
    debugPrint('Content l10n ($lang): $e');
    ContentL10n.use(lang, const {});
  }
}
