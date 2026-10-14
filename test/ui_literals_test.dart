// Trinquete de la localización: ningún texto de cara al jugador escrito a
// mano en lib/presentation. Todo sale de lib/l10n/app_*.arb vía
// AppLocalizations.of(context) (o del catálogo de contenido ya traducido).
//
// Detecta `Text('…')`, `Text("…")` y los parámetros de texto de los
// componentes (`GameChip('…')`, `label:`, `title:`, `body:`, `semanticLabel:`,
// `hintText:`, `errorText:`, `note:`) cuyo literal tiene letras una vez
// quitadas las interpolaciones (`$x`, `${…}`). Números, símbolos y armados
// como '$a · $b' pasan.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Excepciones explícitas: 'archivo relativo a lib/presentation|literal sin
/// interpolaciones'.
/// Cada una con su motivo. Mantenela chica.
const _allowlist = <String>{
  // Unidades que se escriben igual en español e inglés.
  'screens/home/parts/slot.dart| km',
  'screens/skills/skill_tree_screen.dart|/ XP',
};

final _patterns = <RegExp>[
  RegExp(r'''\bText\(\s*(r?'(?:[^'\\\n]|\\.)*'|r?"(?:[^"\\\n]|\\.)*")'''),
  RegExp(r'''\bGameChip\(\s*(r?'(?:[^'\\\n]|\\.)*'|r?"(?:[^"\\\n]|\\.)*")'''),
  RegExp(r'''\b(?:label|title|body|semanticLabel|hintText|errorText|note|subtitle|tooltip|barrierLabel):\s*(r?'(?:[^'\\\n]|\\.)*'|r?"(?:[^"\\\n]|\\.)*")'''),
];

String _withoutInterpolation(String lit) =>
    lit.replaceAll(RegExp(r'\$[A-Za-z_]\w*'), '');

final _letters = RegExp(r'[A-Za-zÁÉÍÓÚÜÑáéíóúüñ]');

void main() {
  test('lib/presentation no tiene textos sueltos en la UI', () {
    final root = Directory('lib/presentation');
    final offenders = <String>[];
    for (final f in root.listSync(recursive: true).whereType<File>()) {
      if (!f.path.endsWith('.dart')) continue;
      final rel = f.path.substring(root.path.length + 1);
      final lines = f.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        // Las interpolaciones se quitan antes: pueden llevar comillas
        // adentro (${a ?? '?'}).
        var line = lines[i];
        String prev;
        do {
          prev = line;
          line = line.replaceAll(RegExp(r'\$\{[^{}]*\}'), '');
        } while (line != prev);
        if (line.trimLeft().startsWith('//')) continue;
        for (final p in _patterns) {
          for (final m in p.allMatches(line)) {
            final raw = m.group(1)!;
            final lit = raw.substring(raw.startsWith('r') ? 2 : 1, raw.length - 1);
            final text = _withoutInterpolation(lit);
            if (!_letters.hasMatch(text)) continue;
            if (_allowlist.contains('$rel|$text')) continue;
            offenders.add('$rel:${i + 1}  $lit');
          }
        }
      }
    }
    expect(offenders, isEmpty,
        reason: 'Pasá estos textos a lib/l10n/app_es.arb + app_en.arb:\n'
            '${offenders.join('\n')}');
  });
}
