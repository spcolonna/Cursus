// lib/presentation/widgets/insignia.dart
//
// Piezas de metal y cera: el sello de cera (notas, nodos 6-10 del árbol) y
// el escudo de cada facción. Todo por código, en el estilo plano del juego:
// contorno oscuro de 2,5, sombreado en dos tonos y un brillo.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/entities/world.dart';
import '../theme/app_theme.dart';
import '../theme/art_palette.dart';
import 'faction_widgets.dart';

// ═══════════════════════════════════════════════════════════════
// SELLO DE CERA
// ═══════════════════════════════════════════════════════════════

/// Contorno ondulado de un sello de cera: un círculo con [lobes] gotas.
Path waxSealPath(Offset c, double r, {int lobes = 12, double wobble = 0.08}) {
  final path = Path();
  const steps = 72;
  for (var i = 0; i <= steps; i++) {
    final a = i / steps * 2 * math.pi;
    final rr = r * (1 + wobble * math.sin(a * lobes) + wobble * 0.4 * math.sin(a * 3 + 1));
    final p = Offset(c.dx + math.cos(a) * rr, c.dy + math.sin(a) * rr);
    i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
  }
  return path..close();
}

/// Pinta un sello de cera completo: gota, relieve interior y brillo.
void paintWaxSeal(
  Canvas canvas,
  Offset c,
  double r, {
  Color color = ArtColors.wax,
  Color shade = ArtColors.waxDark,
  Color light = ArtColors.waxLight,
  double outline = 2.5,
}) {
  final drop = waxSealPath(c, r);
  canvas.drawPath(drop.shift(Offset(0, r * 0.08)), Paint()..color = shade);
  canvas.drawPath(drop, Paint()..color = color);
  // Relieve: el anillo que deja la matriz.
  canvas.drawCircle(
      c,
      r * 0.68,
      Paint()
        ..color = shade
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.2, r * 0.1));
  canvas.drawCircle(c.translate(-r * 0.05, -r * 0.05), r * 0.6, Paint()..color = light);
  canvas.drawCircle(c, r * 0.6, Paint()..color = color.withValues(alpha: 0.55));
  // Brillo.
  canvas.drawOval(
      Rect.fromCenter(
          center: c.translate(-r * 0.32, -r * 0.4), width: r * 0.42, height: r * 0.22),
      Paint()..color = AppColors.white.withValues(alpha: 0.35));
  if (outline > 0) {
    canvas.drawPath(
        drop,
        Paint()
          ..color = AppColors.outline
          ..style = PaintingStyle.stroke
          ..strokeWidth = outline
          ..strokeJoin = StrokeJoin.round);
  }
}

/// Sello de cera con un contenido encima (una letra, un ícono).
class WaxSeal extends StatelessWidget {
  final double size;
  final Color color;
  final Color shade;
  final Color light;
  final Widget? child;
  const WaxSeal({
    super.key,
    required this.size,
    this.color = ArtColors.wax,
    this.shade = ArtColors.waxDark,
    this.light = ArtColors.waxLight,
    this.child,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _WaxSealPainter(color, shade, light),
          child: child == null ? null : Center(child: child),
        ),
      );
}

class _WaxSealPainter extends CustomPainter {
  final Color color, shade, light;
  const _WaxSealPainter(this.color, this.shade, this.light);

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.shortestSide / 2 * 0.88;
    paintWaxSeal(canvas, size.center(Offset.zero), r,
        color: color, shade: shade, light: light,
        outline: (size.shortestSide * 0.05).clamp(1.5, 2.5));
  }

  @override
  bool shouldRepaint(_WaxSealPainter old) =>
      old.color != color || old.shade != shade || old.light != light;
}

// ═══════════════════════════════════════════════════════════════
// ESCUDO DE FACCIÓN
// ═══════════════════════════════════════════════════════════════

/// Escudo con el emblema de la facción: el Gremio es una tablilla sellada,
/// las Legiones un águila, los Patricios una corona de laurel y los Bajos
/// Fondos una daga cruzada con una llave.
class FactionCrest extends StatelessWidget {
  final Faction faction;
  final double size;
  const FactionCrest({super.key, required this.faction, this.size = 40});

  @override
  Widget build(BuildContext context) => Semantics(
        label: faction.label,
        image: true,
        child: SizedBox(
          width: size,
          height: size * 1.12,
          child: CustomPaint(painter: _CrestPainter(faction)),
        ),
      );
}

class _CrestPainter extends CustomPainter {
  final Faction faction;
  const _CrestPainter(this.faction);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final shield = Path()
      ..moveTo(w * 0.08, h * 0.06)
      ..lineTo(w * 0.92, h * 0.06)
      ..lineTo(w * 0.92, h * 0.5)
      ..quadraticBezierTo(w * 0.9, h * 0.82, w * 0.5, h * 0.97)
      ..quadraticBezierTo(w * 0.1, h * 0.82, w * 0.08, h * 0.5)
      ..close();
    final color = factionColor(faction);
    final dark = Color.lerp(color, AppColors.outline, 0.45)!;
    canvas.drawPath(shield.shift(Offset(0, h * 0.03)), Paint()..color = AppColors.outline);
    canvas.drawPath(shield, Paint()..color = color);
    // Mitad derecha en sombra.
    canvas.save();
    canvas.clipPath(shield);
    canvas.drawRect(Rect.fromLTWH(w * 0.5, 0, w, h), Paint()..color = dark.withValues(alpha: 0.45));
    canvas.restore();
    canvas.drawPath(
        shield,
        Paint()
          ..color = AppColors.outline
          ..style = PaintingStyle.stroke
          ..strokeWidth = (w * 0.06).clamp(1.5, 2.5)
          ..strokeJoin = StrokeJoin.round);

    final c = Offset(w * 0.5, h * 0.46);
    final s = w * 0.3;
    final emblem = Paint()..color = AppColors.parchment;
    final ink = Paint()
      ..color = AppColors.parchment
      ..style = PaintingStyle.stroke
      ..strokeWidth = (w * 0.06).clamp(1.2, 3.0)
      ..strokeCap = StrokeCap.round;
    switch (faction) {
      case Faction.guild:
        // Tablilla con su sello.
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromCenter(center: c, width: s * 1.5, height: s * 1.15),
                Radius.circular(s * 0.12)),
            emblem);
        paintWaxSeal(canvas, c.translate(s * 0.35, s * 0.3), s * 0.36, outline: 1.2);
      case Faction.legions:
        // Águila: cuerpo y alas abiertas.
        final eagle = Path()
          ..moveTo(c.dx, c.dy - s * 0.7)
          ..lineTo(c.dx + s * 0.18, c.dy - s * 0.3)
          ..lineTo(c.dx + s * 0.95, c.dy - s * 0.55)
          ..lineTo(c.dx + s * 0.55, c.dy + s * 0.05)
          ..lineTo(c.dx + s * 0.2, c.dy + s * 0.1)
          ..lineTo(c.dx + s * 0.3, c.dy + s * 0.7)
          ..lineTo(c.dx, c.dy + s * 0.45)
          ..lineTo(c.dx - s * 0.3, c.dy + s * 0.7)
          ..lineTo(c.dx - s * 0.2, c.dy + s * 0.1)
          ..lineTo(c.dx - s * 0.55, c.dy + s * 0.05)
          ..lineTo(c.dx - s * 0.95, c.dy - s * 0.55)
          ..lineTo(c.dx - s * 0.18, c.dy - s * 0.3)
          ..close();
        canvas.drawPath(eagle, emblem);
      case Faction.patricians:
        // Corona de laurel.
        final box = Rect.fromCircle(center: c, radius: s * 0.8);
        canvas.drawArc(box, math.pi * 0.6, math.pi * 0.85, false, ink);
        canvas.drawArc(box, math.pi * 1.55, math.pi * 0.85, false, ink);
        for (var i = 0; i < 5; i++) {
          for (final side in [-1.0, 1.0]) {
            final a = math.pi / 2 + side * (math.pi * 0.25 + i * math.pi * 0.14);
            final p = c + Offset(math.cos(a), math.sin(a)) * s * 0.8;
            canvas.drawOval(
                Rect.fromCenter(center: p, width: s * 0.3, height: s * 0.16), emblem);
          }
        }
      case Faction.underworld:
        // Daga y llave cruzadas.
        canvas.save();
        canvas.translate(c.dx, c.dy);
        canvas.rotate(math.pi / 4);
        canvas.drawLine(Offset(0, -s * 0.9), Offset(0, s * 0.5), ink);
        canvas.drawLine(Offset(-s * 0.3, s * 0.35), Offset(s * 0.3, s * 0.35), ink);
        canvas.rotate(-math.pi / 2);
        canvas.drawLine(Offset(0, -s * 0.6), Offset(0, s * 0.8), ink);
        canvas.drawCircle(Offset(0, -s * 0.75), s * 0.2, ink);
        canvas.drawLine(Offset(0, s * 0.6), Offset(s * 0.22, s * 0.6), ink);
        canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_CrestPainter old) => old.faction != faction;
}
