// El contenido traducido: toda clave tiene su traducción, no sobra ninguna
// y la capa de traducción efectivamente cambia lo que lee el juego.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:the_messenger/data/localized_content.dart';
import 'package:the_messenger/data/static_game_content.dart';
import 'package:the_messenger/domain/entities/content_l10n.dart';

void main() {
  final keys = contentKeys();
  final en = (jsonDecode(File('assets/l10n/content_en.json').readAsStringSync())
          as Map<String, dynamic>)
      .cast<String, String>();

  tearDown(() => ContentL10n.use('es', const {}));

  test('no sobran claves en inglés', () {
    expect(en.keys.where((k) => !keys.containsKey(k)).toList(), isEmpty);
  });

  test('todo el contenido tiene inglés', () {
    final missing = keys.keys.where((k) => !en.containsKey(k)).toList();
    expect(missing, isEmpty,
        reason:
            '${missing.length} claves sin traducir, p. ej. ${missing.take(5)}');
  });

  test('las traducciones conservan los {marcadores}', () {
    final mark = RegExp(r'\{\w+\}');
    for (final e in en.entries) {
      final es = keys[e.key];
      if (es == null) continue;
      expect(mark.allMatches(e.value).map((m) => m[0]).toSet(),
          mark.allMatches(es).map((m) => m[0]).toSet(),
          reason: e.key);
    }
  });

  test('el catálogo entrega el texto del idioma activo', () {
    const catalog = StaticGameContent();
    final es = catalog.eventById('evt_patrol')!.title;
    ContentL10n.use('en', {'evt_patrol.title': 'The patrol'});
    expect(catalog.eventById('evt_patrol')!.title, 'The patrol');
    ContentL10n.use('es', const {});
    expect(catalog.eventById('evt_patrol')!.title, es);
  });
}
