// lib/presentation/widgets/messenger_avatar.dart
// Retrato del mensajero — dibujado en Flutter puro, sin assets ni emojis.
//
// Tres capas de identidad, para que el jugador reconozca a los suyos de un vistazo:
//   · Género    → pelo y tono de piel
//   · Slot      → color de túnica y fondo (los 4 mensajeros nunca se confunden)
//   · Rango     → fíbula de la capa (hierro … oro con laurel) y petasos que
//                 crece: sin sombrero, fieltro, banda, alas, alas de oro
//   · Estado    → cara (contento, neutro, cansado, dolorido), vendaje si
//                 está herido; respira y parpadea en reposo
//
// Proporción fija 1 : 1.2 — [size] es el ANCHO, la altura sale sola.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/entities/entities.dart';
import '../theme/app_theme.dart';
import '../theme/art_palette.dart';

// ─── Paleta por slot ──────────────────────────────────────────────────────────
class MessengerPalette {
  final Color tunic;
  final Color tunicShade;
  final Color accent;
  final List<Color> background;
  const MessengerPalette(
      this.tunic, this.tunicShade, this.accent, this.background);
}

const List<MessengerPalette> _slotPalettes = [
  // 0 — carmesí (el mensajero original)
  MessengerPalette(Color(0xFF8B0000), Color(0xFF5E0000), AppColors.red,
      [Color(0xFF1565C0), Color(0xFF0D47A1)]),
  // 1 — púrpura
  MessengerPalette(Color(0xFF4A0080), Color(0xFF320058), AppColors.purple,
      [Color(0xFF6A1B9A), Color(0xFF4A148C)]),
  // 2 — cielo
  MessengerPalette(Color(0xFF1A5A78), Color(0xFF103C52), AppColors.sky,
      [Color(0xFF15607D), Color(0xFF0A2E3E)]),
  // 3 — verde oliva
  MessengerPalette(Color(0xFF226633), Color(0xFF154020), AppColors.green,
      [Color(0xFF1F5E3A), Color(0xFF0C2E1C)]),
];

MessengerPalette _paletteFor(int slotIndex) =>
    _slotPalettes[slotIndex.clamp(0, _slotPalettes.length - 1)];

/// Color identitario del slot — para bordes, chips y selectores.
Color messengerAccent(int slotIndex) => _paletteFor(slotIndex).accent;

// ─── Widget ───────────────────────────────────────────────────────────────────
class MessengerAvatar extends StatefulWidget {
  final MessengerGender gender;
  final int slotIndex;
  final int rank;
  final MessengerStatus status;
  final int fatigue;
  final int health;

  /// Ancho del retrato. La altura es [size] × 1.2.
  final double size;

  /// Halo del color del slot — para destacar al mensajero seleccionado.
  final bool highlighted;

  const MessengerAvatar({
    super.key,
    required this.gender,
    required this.size,
    this.slotIndex = 0,
    this.rank = 1,
    this.status = MessengerStatus.idle,
    this.fatigue = 0,
    this.health = 100,
    this.highlighted = false,
  });

  /// Retrato de un mensajero existente.
  MessengerAvatar.from(
    Messenger messenger, {
    super.key,
    required this.size,
    this.highlighted = false,
  })  : gender = messenger.gender,
        slotIndex = messenger.slotIndex,
        rank = messenger.rank,
        status = messenger.status,
        fatigue = messenger.fatigue,
        health = messenger.health;

  @override
  State<MessengerAvatar> createState() => _MessengerAvatarState();
}

class _MessengerAvatarState extends State<MessengerAvatar>
    with SingleTickerProviderStateMixin {
  /// Respiración y parpadeo. Solo en retratos grandes: en las listas con
  /// íconos chicos no se nota y cuesta frames.
  static const _minAnimatedSize = 48.0;
  static const _cycle = Duration(milliseconds: 4200);

  AnimationController? _breath;

  bool get _wantsAnimation => widget.size >= _minAnimatedSize;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(MessengerAvatar old) {
    super.didUpdateWidget(old);
    _syncAnimation();
  }

  void _syncAnimation() {
    final animate = _wantsAnimation && !AppMotion.reduced(context);
    if (animate && _breath == null) {
      _breath = AnimationController(vsync: this, duration: _cycle)..repeat();
    } else if (!animate && _breath != null) {
      _breath!.dispose();
      _breath = null;
    }
  }

  @override
  void dispose() {
    _breath?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final palette = _paletteFor(w.slotIndex);
    final injured = w.status == MessengerStatus.injured || w.health < 35;
    return Container(
      width: w.size,
      height: w.size * 1.2,
      decoration: w.highlighted
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(w.size * 0.2),
              boxShadow: [
                BoxShadow(
                    color: palette.accent.withValues(alpha: 0.45),
                    blurRadius: w.size * 0.28),
              ],
            )
          : null,
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size(w.size, w.size * 1.2),
          painter: MessengerPainter(
            gender: w.gender,
            palette: palette,
            rank: w.rank,
            injured: injured,
            weary: w.fatigue >= 70,
            mood: moodFor(fatigue: w.fatigue, health: w.health, injured: injured),
            breath: _breath,
          ),
        ),
      ),
    );
  }
}

/// Cara del mensajero según cómo está.
enum MessengerMood { content, neutral, tired, hurt }

MessengerMood moodFor(
    {required int fatigue, required int health, required bool injured}) {
  if (injured) return MessengerMood.hurt;
  if (fatigue >= 70) return MessengerMood.tired;
  if (fatigue < 40 && health >= 70) return MessengerMood.content;
  return MessengerMood.neutral;
}

// ─── Painter ──────────────────────────────────────────────────────────────────
//
// Capas, de atrás hacia adelante: fondo con luz detrás de la cabeza, capucha
// caída de la paenula, cuello, paenula (capa de viaje en dos tonos), correa
// y bolsa del correo, fíbula de rango, cabeza con cara, pelo y petasos.
class MessengerPainter extends CustomPainter {
  final MessengerGender gender;
  final MessengerPalette palette;
  final int rank;
  final bool injured;
  final bool weary;
  final MessengerMood mood;

  /// Fase 0..1 del ciclo de respiración. Null = quieto.
  final Animation<double>? breath;

  MessengerPainter({
    required this.gender,
    required this.palette,
    required this.rank,
    required this.injured,
    required this.weary,
    this.mood = MessengerMood.neutral,
    this.breath,
  }) : super(repaint: breath);

  bool get _isMale => gender == MessengerGender.male;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final bgRect = Rect.fromLTWH(0, 0, w, h);
    final rrect = RRect.fromRectAndRadius(bgRect, Radius.circular(w * 0.2));
    final phase = breath?.value ?? 0.0;
    final inhale = math.sin(phase * 2 * math.pi);
    // Parpadeo: un cierre corto cerca del final del ciclo.
    final blinking = breath != null && phase > 0.93 && phase < 0.97;

    canvas.save();
    canvas.clipRRect(rrect);

    // Fondo + luz detrás de la cabeza.
    canvas.drawRect(
      bgRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: palette.background,
        ).createShader(bgRect),
    );
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.3),
      w * 0.42,
      Paint()
        ..shader = RadialGradient(colors: [
          AppColors.parchment.withValues(alpha: 0.18),
          AppColors.parchment.withValues(alpha: 0),
        ]).createShader(
            Rect.fromCircle(center: Offset(w * 0.5, h * 0.3), radius: w * 0.42)),
    );

    // El cuerpo respira: sube y se ensancha apenas. La cabeza acompaña.
    final droop = weary ? h * 0.02 : 0.0;
    final bodyLift = -inhale * h * 0.008;
    final headCenter = Offset(w / 2, h * 0.31 + bodyLift * 1.4 + droop);
    final headR = w * 0.2;

    canvas.save();
    canvas.translate(0, bodyLift);
    _paintBody(canvas, w, h, inhale);
    canvas.restore();

    _paintHead(canvas, w, h, headCenter, headR, blinking);
    _paintHat(canvas, w, h, headCenter, headR);
    if (injured) _paintBandage(canvas, w, h, headCenter, headR);
    if (weary) {
      canvas.drawRect(bgRect, Paint()..color = AppColors.shadowSoft.withValues(alpha: 0.25));
    }

    canvas.restore();

    // Marco
    canvas.drawRRect(
      rrect.deflate(w * 0.015),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.03
        ..color = palette.accent.withValues(alpha: 0.65),
    );
  }

  // ─── Cuerpo: paenula, correa, bolsa y fíbula ───
  void _paintBody(Canvas canvas, double w, double h, double inhale) {
    final skin = Paint()..color = _skinColor;
    final spread = 1 + inhale * 0.012;

    // Capucha caída detrás de los hombros.
    final hood = Path()
      ..moveTo(w * 0.26, h * 0.5)
      ..quadraticBezierTo(w * 0.5, h * 0.4, w * 0.74, h * 0.5)
      ..quadraticBezierTo(w * 0.5, h * 0.6, w * 0.26, h * 0.5)
      ..close();
    canvas.drawPath(hood, Paint()..color = palette.tunicShade);

    // Cuello.
    canvas.drawRect(Rect.fromLTWH(w * 0.43, h * 0.43, w * 0.14, h * 0.09), skin);
    canvas.drawRect(Rect.fromLTWH(w * 0.43, h * 0.47, w * 0.14, h * 0.02),
        Paint()..color = ArtColors.skinShade);

    // Paenula: campana que cae desde los hombros.
    final cx = w / 2;
    Path cloak(double l, double r) => Path()
      ..moveTo(cx - w * l * spread, h * 0.53)
      ..quadraticBezierTo(cx - w * 0.2, h * 0.49, cx, h * 0.5)
      ..quadraticBezierTo(cx + w * 0.2, h * 0.49, cx + w * r * spread, h * 0.53)
      ..quadraticBezierTo(cx + w * (r + 0.1), h * 0.75, cx + w * (r + 0.16), h * 1.02)
      ..lineTo(cx - w * (l + 0.16), h * 1.02)
      ..quadraticBezierTo(cx - w * (l + 0.1), h * 0.75, cx - w * l * spread, h * 0.53)
      ..close();
    canvas.drawPath(cloak(0.3, 0.3), Paint()..color = palette.tunic);
    // Lado en sombra (luz desde la izquierda).
    canvas.save();
    canvas.clipPath(cloak(0.3, 0.3));
    canvas.drawRect(Rect.fromLTWH(cx + w * 0.12, 0, w, h),
        Paint()..color = palette.tunicShade);
    // Pliegues.
    final fold = Paint()
      ..color = palette.tunicShade
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.012
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - w * 0.16, h * 0.7), Offset(cx - w * 0.22, h * 1.0), fold);
    canvas.drawLine(Offset(cx, h * 0.52), Offset(cx, h * 1.0), fold);
    canvas.restore();

    // Correa cruzada y bolsa del correo.
    final strap = Paint()
      ..color = ArtColors.leather
      ..strokeWidth = w * 0.045
      ..strokeCap = StrokeCap.butt;
    canvas.drawLine(Offset(cx - w * 0.22, h * 0.53), Offset(cx + w * 0.24, h * 0.86), strap);
    final bag = RRect.fromRectAndRadius(
        Rect.fromLTWH(cx + w * 0.14, h * 0.8, w * 0.24, h * 0.16),
        Radius.circular(w * 0.03));
    canvas.drawRRect(bag, Paint()..color = ArtColors.leather);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(cx + w * 0.14, h * 0.8, w * 0.24, h * 0.06),
            Radius.circular(w * 0.03)),
        Paint()..color = ArtColors.leatherDark);
    canvas.drawCircle(Offset(cx + w * 0.26, h * 0.86), w * 0.022,
        Paint()..color = AppColors.gold);

    _paintFibula(canvas, w, h, Offset(cx - w * 0.2, h * 0.545));
  }

  /// Fíbula que cierra la paenula: el metal dice el rango.
  /// 1 hierro · 2 bronce · 3 plata · 4 oro · 5 oro con laurel.
  void _paintFibula(Canvas canvas, double w, double h, Offset c) {
    final metal = switch (rank) {
      <= 1 => (ArtColors.iron, ArtColors.ironDark),
      2 => (ArtColors.bronze, ArtColors.bronzeDark),
      3 => (ArtColors.silver, ArtColors.silverDark),
      _ => (AppColors.gold, AppColors.goldShadow),
    };
    final r = w * 0.055;
    if (rank >= 5) {
      final laurel = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.02
        ..strokeCap = StrokeCap.round
        ..color = ArtColors.laurel;
      final box = Rect.fromCircle(center: c, radius: r * 1.8);
      canvas.drawArc(box, math.pi * 0.55, math.pi * 0.75, false, laurel);
      canvas.drawArc(box, math.pi * 1.7, math.pi * 0.75, false, laurel);
    }
    canvas.drawCircle(c, r, Paint()..color = metal.$2);
    canvas.drawCircle(c.translate(-r * 0.12, -r * 0.12), r * 0.82, Paint()..color = metal.$1);
    canvas.drawCircle(c.translate(-r * 0.3, -r * 0.3), r * 0.22,
        Paint()..color = AppColors.white.withValues(alpha: 0.55));
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.01
        ..color = AppColors.outline.withValues(alpha: 0.7),
    );
  }

  // ─── Cabeza y cara ───
  Color get _skinColor => weary
      ? ArtColors.skinWeary
      : (_isMale ? ArtColors.skin : ArtColors.skinLight);

  void _paintHead(Canvas canvas, double w, double h, Offset c, double r,
      bool blinking) {
    final skin = Paint()..color = _skinColor;
    final shade = Paint()..color = ArtColors.skinShade;

    // Pelo de atrás (rodete o melena) y orejas.
    if (!_isMale) {
      final hair = Paint()..color = ArtColors.hairDark;
      canvas.drawCircle(c.translate(0, -r * 0.05), r * 1.1, hair);
      canvas.drawCircle(c.translate(r * 0.95, r * 0.15), r * 0.42, hair);
    }
    canvas.drawCircle(c.translate(-r * 0.98, r * 0.08), r * 0.2, skin);
    canvas.drawCircle(c.translate(r * 0.98, r * 0.08), r * 0.2, shade);

    // Cara: óvalo con sombra a la derecha.
    final face = Rect.fromCenter(center: c, width: r * 2, height: r * 2.15);
    canvas.drawOval(face, skin);
    canvas.save();
    canvas.clipPath(Path()..addOval(face));
    canvas.drawOval(face.shift(Offset(r * 0.55, 0)), shade);
    canvas.restore();
    canvas.drawOval(face.deflate(r * 0.04).shift(Offset(-r * 0.04, 0)),
        Paint()..color = _skinColor.withValues(alpha: 0.5));

    _paintHair(canvas, c, r);
    _paintFace(canvas, c, r, blinking);
  }

  void _paintHair(Canvas canvas, Offset c, double r) {
    final hair = Paint()..color = _isMale ? ArtColors.hairLight : ArtColors.hairDark;
    if (_isMale) {
      // Pelo corto con rulos: un casquete y bucles sobre la frente.
      canvas.drawArc(Rect.fromCircle(center: c.translate(0, -r * 0.05), radius: r * 1.04),
          math.pi * 1.05, math.pi * 0.9, true, hair);
      for (var i = 0; i < 5; i++) {
        final x = -r * 0.62 + i * r * 0.31;
        canvas.drawCircle(c.translate(x, -r * 0.62 + (i.isOdd ? r * 0.05 : 0)),
            r * 0.2, hair);
      }
    } else {
      // Raya al medio y pelo recogido.
      final top = Path()
        ..moveTo(c.dx - r * 1.0, c.dy - r * 0.05)
        ..quadraticBezierTo(c.dx - r * 0.9, c.dy - r * 1.15, c.dx, c.dy - r * 1.08)
        ..quadraticBezierTo(c.dx + r * 0.9, c.dy - r * 1.15, c.dx + r * 1.0, c.dy - r * 0.05)
        ..quadraticBezierTo(c.dx + r * 0.6, c.dy - r * 0.62, c.dx, c.dy - r * 0.7)
        ..quadraticBezierTo(c.dx - r * 0.6, c.dy - r * 0.62, c.dx - r * 1.0, c.dy - r * 0.05)
        ..close();
      canvas.drawPath(top, hair);
    }
  }

  void _paintFace(Canvas canvas, Offset c, double r, bool blinking) {
    final ink = Paint()
      ..color = ArtColors.hairDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.09
      ..strokeCap = StrokeCap.round;
    final eyeY = c.dy + r * 0.05;
    final eyeDx = r * 0.4;
    final closedish = blinking || mood == MessengerMood.tired;

    for (final side in [-1.0, 1.0]) {
      final e = Offset(c.dx + side * eyeDx, eyeY);
      if (blinking) {
        canvas.drawLine(e.translate(-r * 0.13, 0), e.translate(r * 0.13, 0), ink);
      } else {
        canvas.drawOval(
            Rect.fromCenter(
                center: e,
                width: r * 0.2,
                height: closedish ? r * 0.12 : r * 0.26),
            Paint()..color = ArtColors.hairDark);
        if (!closedish) {
          canvas.drawCircle(e.translate(-r * 0.03, -r * 0.05), r * 0.045,
              Paint()..color = AppColors.white.withValues(alpha: 0.8));
        }
      }
      if (mood == MessengerMood.tired) {
        // Ojeras.
        canvas.drawArc(
            Rect.fromCenter(center: e.translate(0, r * 0.14), width: r * 0.26, height: r * 0.12),
            0, math.pi, false,
            Paint()
              ..color = ArtColors.skinShade
              ..style = PaintingStyle.stroke
              ..strokeWidth = r * 0.05);
      }
      // Cejas: el ánimo se lee acá primero.
      final browY = eyeY - r * 0.3;
      final (inner, outer) = switch (mood) {
        MessengerMood.content => (-r * 0.02, -r * 0.06),
        MessengerMood.neutral => (0.0, 0.0),
        MessengerMood.tired => (-r * 0.02, r * 0.06),
        MessengerMood.hurt => (-r * 0.1, r * 0.04),
      };
      canvas.drawLine(
          Offset(c.dx + side * eyeDx * 0.55, browY + inner),
          Offset(c.dx + side * eyeDx * 1.4, browY + outer),
          ink..strokeWidth = r * 0.08);
    }

    // Nariz: una sombra corta.
    canvas.drawLine(Offset(c.dx + r * 0.04, c.dy + r * 0.15),
        Offset(c.dx + r * 0.1, c.dy + r * 0.38),
        Paint()
          ..color = ArtColors.skinShade
          ..strokeWidth = r * 0.08
          ..strokeCap = StrokeCap.round);

    // Boca.
    final mouthY = c.dy + r * 0.62;
    final mouth = Paint()
      ..color = ArtColors.hairDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.08
      ..strokeCap = StrokeCap.round;
    final m = switch (mood) {
      MessengerMood.content => r * 0.12,
      MessengerMood.neutral => r * 0.03,
      MessengerMood.tired => -r * 0.02,
      MessengerMood.hurt => -r * 0.1,
    };
    canvas.drawPath(
        Path()
          ..moveTo(c.dx - r * 0.24, mouthY)
          ..quadraticBezierTo(c.dx, mouthY + m * 1.6, c.dx + r * 0.24, mouthY),
        mouth);
    if (mood == MessengerMood.content) {
      for (final side in [-1.0, 1.0]) {
        canvas.drawCircle(Offset(c.dx + side * r * 0.6, c.dy + r * 0.42), r * 0.16,
            Paint()..color = ArtColors.blush);
      }
    }
  }

  // ─── Petasos: el sombrero del viajero, que crece con el rango ───
  void _paintHat(Canvas canvas, double w, double h, Offset c, double r) {
    if (rank <= 1) return;
    final brimY = c.dy - r * 0.62;
    final felt = Paint()..color = ArtColors.felt;
    final feltDark = Paint()..color = ArtColors.feltDark;

    // Alas del dios mensajero (rango 4-5), detrás de la copa.
    if (rank >= 4) {
      final wing = Paint()..color = rank >= 5 ? AppColors.gold : AppColors.parchment;
      final wingShade = Paint()..color = rank >= 5 ? AppColors.goldShadow : ArtColors.stoneShade;
      for (final side in [-1.0, 1.0]) {
        final base = Offset(c.dx + side * r * 0.62, brimY - r * 0.35);
        for (var i = 0; i < 3; i++) {
          final len = r * (rank >= 5 ? 0.85 : 0.6) * (1 - i * 0.2);
          final tip = base.translate(side * len, -len * 0.5 + i * r * 0.16);
          final feather = Path()
            ..moveTo(base.dx, base.dy + i * r * 0.12)
            ..quadraticBezierTo(base.dx + side * len * 0.5, tip.dy - r * 0.12,
                tip.dx, tip.dy)
            ..quadraticBezierTo(base.dx + side * len * 0.6, tip.dy + r * 0.16,
                base.dx, base.dy + i * r * 0.12 + r * 0.12)
            ..close();
          canvas.drawPath(feather, i == 0 ? wing : wingShade);
        }
      }
    }

    // Copa baja y redondeada.
    final crown = Rect.fromCenter(
        center: Offset(c.dx, brimY - r * 0.28), width: r * 1.3, height: r * 0.8);
    canvas.drawArc(crown, math.pi, math.pi, true, felt);
    canvas.drawRect(Rect.fromLTWH(crown.left, crown.center.dy, crown.width, r * 0.3), felt);
    canvas.drawArc(crown, math.pi * 1.5, math.pi * 0.5, true, feltDark);

    // Banda (rango 3+): cuero, bronce o oro.
    if (rank >= 3) {
      final band = switch (rank) {
        3 => ArtColors.legionRed,
        4 => ArtColors.bronze,
        _ => AppColors.gold,
      };
      canvas.drawRect(
          Rect.fromLTWH(crown.left, crown.center.dy + r * 0.08, crown.width, r * 0.16),
          Paint()..color = band);
    }

    // Ala ancha.
    final brim = Rect.fromCenter(
        center: Offset(c.dx, brimY + r * 0.02), width: r * 2.7, height: r * 0.5);
    canvas.drawOval(brim, feltDark);
    canvas.drawOval(brim.translate(0, -r * 0.06), felt);
  }

  void _paintBandage(Canvas canvas, double w, double h, Offset c, double r) {
    final bandage = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.24
      ..strokeCap = StrokeCap.round
      ..color = ArtColors.bandage;
    canvas.drawLine(
      Offset(c.dx - r * 1.05, c.dy - r * 0.4),
      Offset(c.dx + r * 1.05, c.dy - r * 0.05),
      bandage,
    );
    canvas.drawCircle(Offset(c.dx + r * 0.35, c.dy - r * 0.18), r * 0.07,
        Paint()..color = ArtColors.wax);
  }

  @override
  bool shouldRepaint(covariant MessengerPainter old) =>
      old.gender != gender ||
      old.palette != palette ||
      old.rank != rank ||
      old.injured != injured ||
      old.weary != weary ||
      old.mood != mood ||
      old.breath != breath;
}

/// Retrato que "vuela" entre pantallas (home → misión → perfil): el mismo
/// mensajero se mueve en vez de aparecer de golpe.
class MessengerHero extends StatelessWidget {
  final Messenger messenger;
  final double size;
  final bool highlighted;
  const MessengerHero(this.messenger,
      {super.key, required this.size, this.highlighted = false});

  static String tagFor(String messengerId) => 'avatar-$messengerId';

  @override
  Widget build(BuildContext context) => Hero(
        tag: tagFor(messenger.id),
        // Durante el vuelo el retrato se dibuja sin halo, en el tamaño del
        // destino escalado: evita que el halo "salte".
        child: MessengerAvatar.from(messenger,
            size: size, highlighted: highlighted),
      );
}
