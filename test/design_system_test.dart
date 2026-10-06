// Design system: las pantallas no definen colores propios. Si este test
// falla, usá un token de AppColors (o agregalo al theme).
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_messenger/presentation/theme/motion.dart';
import 'package:the_messenger/presentation/widgets/components.dart';

const _maxRawColors = 0; // `Color(0x…)` en screens/ y widgets/
const _maxMaterialColors = 0; // `Colors.xxx` de Material en screens/ y widgets/

/// Pantallas ya migradas: cero colores sueltos.
const _clean = [
  'event/event_screen.dart',
  'mission/mission_screen.dart',
  'mission/mission_result_screen.dart',
  'home/home_screen.dart',
  'home/parts/slot.dart',
  'home/parts/guild.dart',
  'home/parts/hire.dart',
  'home/parts/story.dart',
  'home/parts/nav.dart',
];

void main() {
  // Los colores viven en theme/ (AppColors para interfaz, ArtColors para
  // pintura). Pantallas y widgets solo los nombran.
  final screens = [
    for (final dir in ['screens', 'widgets'])
      ...Directory('lib/presentation/$dir')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart')),
  ];

  int count(RegExp re, Iterable<File> files) => files
      .map((f) => re.allMatches(f.readAsStringSync()).length)
      .fold(0, (a, b) => a + b);

  final rawColor = RegExp(r'Color\(0x');
  final materialColor = RegExp(r'(^|[^A-Za-z])Colors\.', multiLine: true);

  test('los colores sueltos en pantallas no aumentan', () {
    expect(count(rawColor, screens), lessThanOrEqualTo(_maxRawColors));
    expect(count(materialColor, screens), lessThanOrEqualTo(_maxMaterialColors));
  });

  test('las pantallas migradas no tienen colores sueltos', () {
    for (final path in _clean) {
      final f = File('lib/presentation/screens/$path');
      expect(count(rawColor, [f]), 0, reason: path);
      expect(count(materialColor, [f]), 0, reason: path);
    }
  });

  test('sin estilos de texto sueltos ni fuentes viejas', () {
    final rawStyle = RegExp(r'(^|[^A-Za-z.])TextStyle\(', multiLine: true);
    for (final f in screens) {
      expect(count(rawStyle, [f]), 0, reason: f.path);
    }
    final pubspec = File('pubspec.yaml').readAsStringSync();
    for (final family in ['Marcellus', 'Figtree', 'Literata']) {
      expect(pubspec, contains('family: $family'));
    }
    for (final old in ['Fredoka', 'Nunito']) {
      expect(pubspec.contains(old), isFalse, reason: old);
      expect(
          Directory('lib').listSync(recursive: true).whereType<File>().any(
              (f) => f.readAsStringSync().contains("'$old'")),
          isFalse,
          reason: old);
    }
  });

  test('userMessageFor limpia excepciones y oculta errores técnicos', () {
    expect(userMessageFor(Exception('Aureos insuficientes')),
        'Aureos insuficientes');
    expect(userMessageFor(Exception('Null check operator used on a null value')),
        contains('Probá de nuevo'));
    expect(userMessageFor(TypeError()), contains('Probá de nuevo'));
  });

  testWidgets('con movimiento reducido las duraciones colapsan',
      (tester) async {
    late Duration normal;
    late Duration reduced;
    await tester.pumpWidget(Builder(builder: (context) {
      normal = AppMotion.of(context, AppMotion.slow);
      return const SizedBox();
    }));
    AppMotion.userPrefersReduced.value = true;
    await tester.pumpWidget(Builder(builder: (context) {
      reduced = AppMotion.of(context, AppMotion.slow);
      return const SizedBox.shrink();
    }));
    AppMotion.userPrefersReduced.value = false;
    expect(normal, AppMotion.slow);
    expect(reduced.inMilliseconds, lessThanOrEqualTo(1));
  });
}
