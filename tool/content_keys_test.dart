// Vuelca todas las claves del contenido con su español a
// build/content_keys_es.json, para traducir.
//   flutter test tool/content_keys_test.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:the_messenger/data/localized_content.dart';

void main() {
  test('volcar claves', () {
    final out = File('build/content_keys_es.json')..createSync(recursive: true);
    out.writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(contentKeys()));
  });
}
