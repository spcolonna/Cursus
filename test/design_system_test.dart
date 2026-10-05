// Trinquete del design system: los colores sueltos en pantallas solo pueden
// bajar. Si este test falla porque agregaste uno, usá un token de AppColors
// (o agregalo al theme). Si falla porque migraste y bajó, actualizá el tope.
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_messenger/presentation/theme/motion.dart';
import 'package:the_messenger/presentation/widgets/components.dart';

const _maxRawColors = 69; // `Color(0x…)` en lib/presentation/screens
const _maxMaterialColors = 48; // `Colors.xxx` de Material en pantallas

/// Pantallas ya migradas: cero colores sueltos.
const _clean = [
  'event/event_screen.dart',
  'mission/mission_screen.dart',
  'mission/mission_result_screen.dart',
];

void main() {
  final screens = Directory('lib/presentation/screens')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));

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
