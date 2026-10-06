// Invariante 3 (WCAG AA): todo par texto/fondo que usa la interfaz está en
// kTextPairs (app_theme.dart). Si agregás una combinación, sumala ahí.
import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_messenger/presentation/theme/app_theme.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  test('cada par de kTextPairs cumple AA', () {
    final fails = <String>[];
    for (final p in kTextPairs) {
      final ratio = _contrast(p.fg, p.bg);
      final min = p.large ? 3.0 : 4.5;
      if (ratio < min) {
        fails.add('${p.name}: ${ratio.toStringAsFixed(2)} < $min');
      }
    }
    expect(fails, isEmpty);
  });

  test('los pigmentos de rol se leen como texto sobre papel', () {
    for (final c in [
      AppColors.ink,
      AppColors.inkSoft,
      AppColors.inkMuted,
      AppColors.ochreDeep,
      AppColors.sienna,
      AppColors.cinnabar,
      AppColors.egyptianBlue,
      AppColors.verdigris,
      AppColors.tyrian,
    ]) {
      expect(kTextPairs.any((p) => p.fg == c && p.bg == AppColors.paperDeep),
          isTrue,
          reason: '$c falta en kTextPairs');
    }
  });

  test('las notas S/A/B/C/F se leen sobre su propio fondo', () {
    for (final g in ['S', 'A', 'B', 'C', 'F']) {
      expect(_contrast(gradeColor(g), gradeBackground(g)),
          greaterThanOrEqualTo(4.5),
          reason: 'nota $g');
    }
  });

  test('un chip teñido sigue leyéndose con su color', () {
    for (final c in [
      AppColors.ochreDeep,
      AppColors.sienna,
      AppColors.cinnabar,
      AppColors.egyptianBlue,
      AppColors.verdigris,
      AppColors.tyrian,
    ]) {
      expect(_contrast(c, paperTint(c)), greaterThanOrEqualTo(4.5),
          reason: '$c');
    }
  });
}
