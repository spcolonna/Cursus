// lib/presentation/theme/sky.dart
//
// El cielo vivo: el mundo sigue la hora real del jugador. `SkyPalette.at`
// interpola sin saltos entre cuatro cielos (alba, día, atardecer, noche) y
// devuelve todo lo que pinta un paisaje: las tres bandas del cielo, el tono
// de la tierra, dónde está el sol o la luna y cuántas estrellas se ven.
//
// Regla de legibilidad: sobre el cielo solo van títulos grandes, en
// `titleColor` (tinta o cal, la que más contraste da con ese cielo). Todo
// texto chico va sobre papel.

import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

import 'app_theme.dart';

enum SkyPhase { dawn, day, dusk, night }

extension SkyPhaseX on SkyPhase {
  String get label => switch (this) {
        SkyPhase.dawn => 'Alba',
        SkyPhase.day => 'Día',
        SkyPhase.dusk => 'Atardecer',
        SkyPhase.night => 'Noche',
      };
}

/// Un cielo fijo: arriba, al medio, sobre el horizonte y la tierra.
class SkyKeyframe {
  final Color top, mid, horizon, land;
  const SkyKeyframe(this.top, this.mid, this.horizon, this.land);

  static const dawn = SkyKeyframe(Color(0xFF9DB7D5), Color(0xFFE9C3B0),
      Color(0xFFF6C9A6), Color(0xFF5B5470));
  static const day = SkyKeyframe(Color(0xFF8EC3D6), Color(0xFFBFD9D6),
      Color(0xFFF4E3B5), Color(0xFF6E7F4E));
  static const dusk = SkyKeyframe(Color(0xFF7A3B5C), Color(0xFFC4544A),
      Color(0xFFF0A35E), Color(0xFF3A2230));
  static const night = SkyKeyframe(Color(0xFF0F1024), Color(0xFF1B2147),
      Color(0xFF2F5D9E), Color(0xFF0A0B18));

  static SkyKeyframe of(SkyPhase p) => switch (p) {
        SkyPhase.dawn => dawn,
        SkyPhase.day => day,
        SkyPhase.dusk => dusk,
        SkyPhase.night => night,
      };
}

class SkyPalette {
  /// Hora del día (0-24) que se pintó.
  final double hour;
  final SkyPhase phase;
  final Color top, mid, horizon, land;

  /// Cuánto pesa cada cielo en la mezcla (suman 1).
  final double dawn, day, dusk, night;

  const SkyPalette._({
    required this.hour,
    required this.phase,
    required this.top,
    required this.mid,
    required this.horizon,
    required this.land,
    required this.dawn,
    required this.day,
    required this.dusk,
    required this.night,
  });

  // Cortes de fase: los mismos que usaban las escenas de evento.
  static const dawnStart = 5.5,
      dayStart = 8.0,
      duskStart = 18.0,
      nightStart = 20.5;

  /// Los cielos puros caen en estas horas; entre medio, se funden.
  static const _anchors = <(double, SkyPhase)>[
    (4.5, SkyPhase.night),
    (6.5, SkyPhase.dawn),
    (9.0, SkyPhase.day),
    (17.0, SkyPhase.day),
    (19.25, SkyPhase.dusk),
    (21.0, SkyPhase.night),
    (28.5, SkyPhase.night),
  ];

  static SkyPhase phaseAt(double hour) {
    final h = _wrap(hour);
    if (h >= dawnStart && h < dayStart) return SkyPhase.dawn;
    if (h >= dayStart && h < duskStart) return SkyPhase.day;
    if (h >= duskStart && h < nightStart) return SkyPhase.dusk;
    return SkyPhase.night;
  }

  static double _wrap(double hour) => ((hour % 24) + 24) % 24;

  factory SkyPalette.at(double hour) {
    final h = _wrap(hour);
    // Antes del primer ancla es la noche que viene de ayer.
    final x = h < _anchors.first.$1 ? h + 24 : h;
    var i = 0;
    while (i < _anchors.length - 2 && x >= _anchors[i + 1].$1) {
      i++;
    }
    final (h0, p0) = _anchors[i];
    final (h1, p1) = _anchors[i + 1];
    final raw = ((x - h0) / (h1 - h0)).clamp(0.0, 1.0);
    final t = raw * raw * (3 - 2 * raw); // smoothstep: sin quiebres
    final a = SkyKeyframe.of(p0), b = SkyKeyframe.of(p1);
    final w = {for (final p in SkyPhase.values) p: 0.0};
    w[p0] = w[p0]! + (1 - t);
    w[p1] = w[p1]! + t;
    return SkyPalette._(
      hour: h,
      phase: phaseAt(h),
      top: Color.lerp(a.top, b.top, t)!,
      mid: Color.lerp(a.mid, b.mid, t)!,
      horizon: Color.lerp(a.horizon, b.horizon, t)!,
      land: Color.lerp(a.land, b.land, t)!,
      dawn: w[SkyPhase.dawn]!,
      day: w[SkyPhase.day]!,
      dusk: w[SkyPhase.dusk]!,
      night: w[SkyPhase.night]!,
    );
  }

  /// Hora local del dispositivo, en horas con decimales.
  static double hourOf(DateTime t) => t.hour + t.minute / 60 + t.second / 3600;

  // ─── Tierra por capas: lo lejano se funde con el horizonte ───
  Color get landFar => Color.lerp(land, horizon, 0.55)!;
  Color get landMid => Color.lerp(land, horizon, 0.28)!;
  Color get landNear => land;

  /// Nubes: claras de día, apenas más claras que el cielo de noche.
  Color get cloud => Color.lerp(
      Color.lerp(mid, horizon, 0.4)!, AppColors.onSky, 0.55 * (1 - night))!;

  /// Intensidad de las estrellas (0-1).
  double get stars => night;

  /// Ventanas y faroles prendidos: atardecer y noche.
  double get lamps => (dusk + night).clamp(0.0, 1.0);

  /// El sol cruza de 5.5 a 20.5 h; la luna el resto. Posición en unidades
  /// del cielo: x de 0 a 1, altura de 0 (horizonte) a 1 (cenit).
  bool get isMoon => hour < dawnStart || hour >= nightStart;
  double get _arc {
    if (!isMoon) {
      return ((hour - dawnStart) / (nightStart - dawnStart)).clamp(0.0, 1.0);
    }
    final since =
        hour >= nightStart ? hour - nightStart : hour + 24 - nightStart;
    return (since / (24 - nightStart + dawnStart)).clamp(0.0, 1.0);
  }

  double get celestialX => 0.1 + 0.8 * _arc;
  double get celestialAltitude => math.sin(_arc * math.pi);

  Color get sunColor => Color.lerp(
      const Color(0xFFFBE7B0), const Color(0xFFF7B267), dusk + dawn * 0.6)!;
  static const moonColor = Color(0xFFEDE6CF);

  /// Título sobre el cielo: tinta o cal, la que más se lee contra la banda
  /// alta (donde van los títulos).
  Color get titleColor =>
      contrastOn(top, AppColors.ink) >= contrastOn(top, AppColors.onSky)
          ? AppColors.ink
          : AppColors.onSky;

  /// Halo del título: el color opuesto, difuso. Sostiene el contraste cuando
  /// una nube o el sol pasan por detrás de las letras.
  List<Shadow> get titleHalo => [
        Shadow(
          color: (titleColor == AppColors.ink
                  ? AppColors.onSky
                  : AppColors.scrimSky)
              .withValues(alpha: 0.7),
          blurRadius: 10,
        ),
      ];

  /// Íconos de la barra de estado acordes al cielo de arriba.
  SystemUiOverlayStyle get statusBar => titleColor == AppColors.ink
      ? SystemUiOverlayStyle.dark
      : SystemUiOverlayStyle.light;

  /// El papel de la página baja un poco el brillo de noche.
  bool get dimPaper => night >= 0.5;

  static double contrastOn(Color bg, Color fg) {
    final a = bg.computeLuminance(), b = fg.computeLuminance();
    return (math.max(a, b) + 0.05) / (math.min(a, b) + 0.05);
  }
}
