// lib/presentation/widgets/messenger_avatar.dart
// Retrato del mensajero — dibujado en Flutter puro, sin assets ni emojis.
//
// Tres capas de identidad, para que el jugador reconozca a los suyos de un vistazo:
//   · Género    → pelo y tono de piel
//   · Slot      → color de túnica y fondo (los 4 mensajeros nunca se confunden)
//   · Rango     → broche en el hombro (1 sin marca … 5 laurel dorado)
//   · Estado    → vendaje si está herido, velo apagado si la fatiga es alta
//
// Proporción fija 1 : 1.2 — [size] es el ANCHO, la altura sale sola.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/entities/entities.dart';
import '../theme/app_theme.dart';

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
class MessengerAvatar extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final palette = _paletteFor(slotIndex);
    return Container(
      width: size,
      height: size * 1.2,
      decoration: highlighted
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(size * 0.2),
              boxShadow: [
                BoxShadow(
                    color: palette.accent.withValues(alpha: 0.45),
                    blurRadius: size * 0.28),
              ],
            )
          : null,
      child: CustomPaint(
        size: Size(size, size * 1.2),
        painter: MessengerPainter(
          gender: gender,
          palette: palette,
          rank: rank,
          injured: status == MessengerStatus.injured || health < 35,
          weary: fatigue >= 70,
        ),
      ),
    );
  }
}

// ─── Painter ──────────────────────────────────────────────────────────────────
class MessengerPainter extends CustomPainter {
  final MessengerGender gender;
  final MessengerPalette palette;
  final int rank;
  final bool injured;
  final bool weary;

  const MessengerPainter({
    required this.gender,
    required this.palette,
    required this.rank,
    required this.injured,
    required this.weary,
  });

  bool get _isMale => gender == MessengerGender.male;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final bgRect = Rect.fromLTWH(0, 0, w, h);
    final rrect =
        RRect.fromRectAndRadius(bgRect, Radius.circular(w * 0.2));

    // Recortar todo al marco: ninguna capa se sale del retrato.
    canvas.save();
    canvas.clipRRect(rrect);

    // Fondo
    canvas.drawRect(
      bgRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: palette.background,
        ).createShader(bgRect),
    );

    final skin = Paint()
      ..color = _isMale ? const Color(0xFFD4A574) : const Color(0xFFE8C49A);
    final headR = w * 0.22;
    final headCenter = Offset(w / 2, h * 0.28);

    // Cabeza
    canvas.drawCircle(headCenter, headR, skin);

    // Cuello
    canvas.drawRect(
        Rect.fromLTWH(w * 0.42, h * 0.44, w * 0.16, h * 0.06), skin);

    // Túnica
    final bodyPath = Path()
      ..moveTo(w * 0.18, h * 0.48)
      ..lineTo(w * 0.82, h * 0.48)
      ..lineTo(w * 0.78, h * 0.85)
      ..lineTo(w * 0.22, h * 0.85)
      ..close();
    canvas.drawPath(bodyPath, Paint()..color = palette.tunic);

    // Pliegue lateral: da volumen sin sombras caras.
    final foldPath = Path()
      ..moveTo(w * 0.60, h * 0.48)
      ..lineTo(w * 0.82, h * 0.48)
      ..lineTo(w * 0.78, h * 0.85)
      ..lineTo(w * 0.62, h * 0.85)
      ..close();
    canvas.drawPath(foldPath, Paint()..color = palette.tunicShade);

    // Cinturón
    canvas.drawRect(
      Rect.fromLTWH(w * 0.18, h * 0.57, w * 0.64, h * 0.06),
      Paint()..color = const Color(0xFFC9A84C),
    );

    _paintHair(canvas, w, h, headCenter, headR, skin);

    // Bolsa del correo
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.62, h * 0.52, w * 0.2, h * 0.15),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFFC9A84C).withValues(alpha: 0.8),
    );

    _paintRankMark(canvas, w, h);
    if (injured) _paintBandage(canvas, w, h, headCenter, headR);
    if (weary) {
      canvas.drawRect(bgRect, Paint()..color = const Color(0x66000000));
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

  void _paintHair(Canvas canvas, double w, double h, Offset headCenter,
      double headR, Paint skin) {
    if (_isMale) {
      final hair = Paint()..color = const Color(0xFF4A2800);
      canvas.drawArc(
        Rect.fromCircle(center: headCenter, radius: headR),
        math.pi,
        math.pi,
        true,
        hair,
      );
    } else {
      final hair = Paint()..color = const Color(0xFF2C1800);
      canvas.drawCircle(headCenter, headR * 1.08, hair);
      canvas.drawCircle(headCenter, headR * 0.95, skin);
      for (final side in [true, false]) {
        final outer = side ? 0.18 : 0.82;
        final inner = side ? 0.22 : 0.78;
        final ctrlOut = side ? 0.10 : 0.90;
        final ctrlIn = side ? 0.14 : 0.86;
        final path = Path()
          ..moveTo(w * outer, h * 0.28)
          ..quadraticBezierTo(w * ctrlOut, h * 0.45, w * (side ? 0.16 : 0.84),
              h * 0.56)
          ..lineTo(w * inner, h * 0.56)
          ..quadraticBezierTo(w * ctrlIn, h * 0.44, w * inner, h * 0.28);
        canvas.drawPath(path, hair);
      }
    }
  }

  /// Broche en el hombro: la marca visible del rango (1 sin marca, 5 laurel).
  void _paintRankMark(Canvas canvas, double w, double h) {
    if (rank <= 1) return;
    final center = Offset(w * 0.30, h * 0.53);
    final r = w * 0.055;
    final color = switch (rank) {
      2 => const Color(0xFFB87333), // bronce
      3 => const Color(0xFFC0C0C0), // plata
      _ => AppColors.gold,
    };
    canvas.drawCircle(center, r, Paint()..color = color);
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.012
        ..color = AppColors.outline.withValues(alpha: 0.7),
    );
    if (rank < 5) return;

    // Laurel: dos arcos dorados abrazando el broche.
    final laurel = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.018
      ..strokeCap = StrokeCap.round
      ..color = AppColors.gold;
    final box = Rect.fromCircle(center: center, radius: r * 1.9);
    canvas.drawArc(box, math.pi * 0.55, math.pi * 0.75, false, laurel);
    canvas.drawArc(box, math.pi * 1.7, math.pi * 0.75, false, laurel);
  }

  void _paintBandage(
      Canvas canvas, double w, double h, Offset headCenter, double headR) {
    final bandage = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = h * 0.045
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFEDE3D0);
    canvas.drawLine(
      Offset(headCenter.dx - headR * 1.05, headCenter.dy - headR * 0.15),
      Offset(headCenter.dx + headR * 1.05, headCenter.dy + headR * 0.35),
      bandage,
    );
  }

  @override
  bool shouldRepaint(covariant MessengerPainter old) =>
      old.gender != gender ||
      old.palette != palette ||
      old.rank != rank ||
      old.injured != injured ||
      old.weary != weary;
}
