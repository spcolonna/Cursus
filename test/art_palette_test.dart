// Arte por código (theme/art_palette.dart): el mapa al fresco tiene que
// dejar leer la ruta, y el sello de cera se dibuja en un solo lugar.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_messenger/presentation/theme/app_theme.dart';
import 'package:the_messenger/presentation/theme/art_palette.dart';
import 'package:the_messenger/presentation/theme/sky.dart';

double _c(Color a, Color b) => SkyPalette.contrastOn(a, b);

void main() {
  test('la ruta del mapa se lee sobre tierra y sobre mar (≥3:1)', () {
    for (final ground in [ArtColors.land, ArtColors.sea, ArtColors.seaShore]) {
      expect(_c(ground, AppColors.ink), greaterThanOrEqualTo(3.0),
          reason: 'base de tinta sobre $ground');
    }
    // Lo recorrido y el medallón (ocre, con ícono de tinta) y lo que falta
    // (cal o agua) contra la base de tinta.
    for (final stroke in [
      AppColors.ochre,
      ArtColors.city,
      ArtColors.waterLight,
    ]) {
      expect(_c(AppColors.ink, stroke), greaterThanOrEqualTo(3.0),
          reason: '$stroke sobre tinta');
    }
  });

  test('mar y tierra se distinguen, y la costa en tinta los separa', () {
    expect(ArtColors.sea, isNot(ArtColors.land));
    expect(_c(ArtColors.land, AppColors.ink), greaterThanOrEqualTo(4.5));
    expect(_c(ArtColors.sea, AppColors.ink), greaterThanOrEqualTo(4.5));
  });

  test('los árboles comparten tierra con el cielo y se distinguen de día', () {
    final day = SkyPalette.at(13);
    expect(day.tree, isNot(day.landNear));
    // De noche todo es silueta: el follaje vuelve a ser la tierra.
    expect(SkyPalette.at(1).tree, SkyPalette.at(1).landNear);
  });

  test('el sello de cera se pinta en un solo lugar (insignia.dart)', () {
    final hits = <String>[];
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      if (RegExp(r'class _?\w*WaxSeal\w*Painter')
          .hasMatch(f.readAsStringSync())) {
        hits.add(f.path);
      }
    }
    expect(hits, ['lib/presentation/widgets/insignia.dart']);
  });
}
