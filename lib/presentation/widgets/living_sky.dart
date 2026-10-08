// lib/presentation/widgets/living_sky.dart
//
// El paisaje de la hora real: cielo, sol o luna, estrellas, nubes que
// derivan y tres planos de siluetas (colinas, Roma a lo lejos con su domo y
// su acueducto, pinos piñoneros y cipreses cerca). Las nubes y las estrellas
// se quedan quietas con movimiento reducido. Los colores salen de
// `SkyPalette`; la hora, de `skyPaletteProvider` (con override de debug).

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../theme/art_palette.dart';
import '../theme/motion.dart';
import '../theme/sky.dart';

class LivingSkyBackground extends ConsumerStatefulWidget {
  /// Dónde queda el horizonte, como fracción del alto (0-1).
  final double horizon;

  /// Cielo fijo (previews y tests); por defecto, el de la hora real.
  final SkyPalette? palette;

  /// Franja de arriba que tapa la barra de estado: el sol y la luna no
  /// suben hasta ahí.
  final double topInset;

  /// Franja horizontal (0-1) por donde cruza el sol o la luna: el home la
  /// angosta para que no pase por detrás del título ni de las monedas.
  final (double, double) celestialSpan;

  const LivingSkyBackground({
    super.key,
    this.horizon = 0.72,
    this.palette,
    this.topInset = 0,
    this.celestialSpan = (0.1, 0.9),
  });

  @override
  ConsumerState<LivingSkyBackground> createState() => _LivingSkyState();
}

class _LivingSkyState extends ConsumerState<LivingSkyBackground>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final _clock = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    // Las nubes van lento: con ~15 cuadros por segundo alcanza y sobra.
    _ticker = createTicker((elapsed) {
      final s = elapsed.inMilliseconds / 1000;
      if (s - _clock.value >= 1 / 15) _clock.value = s;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animate = !AppMotion.reduced(context);
    if (animate && !_ticker.isActive) _ticker.start();
    if (!animate && _ticker.isActive) _ticker.stop();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SkyPalette palette =
        widget.palette ?? ref.watch<SkyPalette>(skyPaletteProvider);
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: LivingSkyPainter(
              palette: palette,
              horizon: widget.horizon,
              topInset: widget.topInset,
              celestialSpan: widget.celestialSpan,
              clock: _clock),
        ),
      ),
    );
  }
}

class LivingSkyPainter extends CustomPainter {
  final SkyPalette palette;
  final double horizon;
  final double topInset;
  final (double, double) celestialSpan;
  final ValueNotifier<double> clock;

  LivingSkyPainter(
      {required this.palette,
      required this.horizon,
      required this.clock,
      this.topInset = 0,
      this.celestialSpan = (0.1, 0.9)})
      : super(repaint: clock);

  double get t => clock.value;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final hz = h * horizon;
    final p = palette;

    // ─── Cielo: tres bandas ───
    final sky = Offset.zero & size;
    canvas.drawRect(
      sky,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [p.top, p.mid, p.horizon, p.horizon],
          stops: [0, horizon * 0.55, horizon, 1],
        ).createShader(sky),
    );

    _stars(canvas, w, hz);
    _celestial(canvas, w, hz);
    _clouds(canvas, w, hz);

    // ─── Plano lejano: colinas y Roma ───
    _ridge(canvas, size, hz - h * 0.02, h * 0.05, 1.2, 3, p.landFar);
    _rome(canvas, size, hz);
    // ─── Plano medio ───
    _ridge(canvas, size, hz + h * 0.07, h * 0.04, 0.8, 5, p.landMid);
    // ─── Plano cercano: pinos y cipreses ───
    _ridge(canvas, size, hz + h * 0.16, h * 0.03, 0.6, 8, p.landNear);
    for (final (x, s) in [(0.06, 1.0), (0.14, 0.7), (0.9, 0.85)]) {
      _cypress(canvas, Offset(w * x, hz + h * 0.18), h * 0.2 * s);
    }
    _pine(canvas, Offset(w * 0.24, hz + h * 0.17), h * 0.22);
    _pine(canvas, Offset(w * 0.78, hz + h * 0.18), h * 0.17);
  }

  void _stars(Canvas canvas, double w, double hz) {
    if (palette.stars < 0.02) return;
    final rng = math.Random(7);
    for (var i = 0; i < 60; i++) {
      final x = rng.nextDouble() * w;
      final y = rng.nextDouble() * hz * 0.8;
      final r = rng.nextDouble() * 1.1 + 0.4;
      final tw = 0.6 + 0.4 * math.sin(t * (0.6 + rng.nextDouble()) + i);
      canvas.drawCircle(
          Offset(x, y),
          r,
          Paint()
            ..color = ArtColors.star
                .withValues(alpha: (0.3 + 0.6 * tw) * palette.stars));
    }
  }

  void _celestial(Canvas canvas, double w, double hz) {
    final p = palette;
    final span = math.max(0.0, hz - topInset - 16);
    final (x0, x1) = celestialSpan;
    // celestialX va de 0.1 a 0.9: se reescala a la franja pedida.
    final u = (p.celestialX - 0.1) / 0.8;
    final c = Offset(
        w * (x0 + (x1 - x0) * u), hz - 6 - p.celestialAltitude * span * 0.85);
    if (p.isMoon) {
      canvas.drawCircle(
          c, 26, Paint()..color = SkyPalette.moonColor.withValues(alpha: 0.12));
      canvas.drawCircle(c, 13, Paint()..color = SkyPalette.moonColor);
      // La sombra de la luna toma el color del cielo a esa altura.
      final local =
          Color.lerp(p.top, p.mid, (c.dy / (hz * 0.55)).clamp(0.0, 1.0))!;
      canvas.drawCircle(c.translate(5, -3), 11.5, Paint()..color = local);
    } else {
      canvas.drawCircle(
          c, 40, Paint()..color = p.sunColor.withValues(alpha: 0.22));
      canvas.drawCircle(c, 18, Paint()..color = p.sunColor);
    }
  }

  void _clouds(Canvas canvas, double w, double hz) {
    final paint = Paint()
      ..color = palette.cloud.withValues(alpha: 0.75 - 0.35 * palette.night);
    final rng = math.Random(11);
    for (var i = 0; i < 4; i++) {
      final speed = 3 + rng.nextDouble() * 4;
      final x = (rng.nextDouble() * (w + 220) + t * speed) % (w + 220) - 110;
      final y = hz * (0.15 + rng.nextDouble() * 0.45);
      final s = 0.6 + rng.nextDouble() * 0.6;
      canvas.drawOval(
          Rect.fromCenter(center: Offset(x, y), width: 96 * s, height: 18 * s),
          paint);
      canvas.drawCircle(Offset(x - 16 * s, y - 6 * s), 12 * s, paint);
      canvas.drawCircle(Offset(x + 10 * s, y - 9 * s), 15 * s, paint);
    }
  }

  /// Silueta de colinas: suma de senos con semilla.
  void _ridge(Canvas canvas, Size size, double baseY, double amp, double freq,
      int seed, Color color) {
    final w = size.width;
    final rng = math.Random(seed);
    final p1 = rng.nextDouble() * 6, p2 = rng.nextDouble() * 6;
    final path = Path()..moveTo(-10, size.height);
    for (var x = -10.0; x <= w + 10; x += 6) {
      final u = x / w;
      path.lineTo(
          x,
          baseY -
              amp *
                  (0.6 * math.sin(u * math.pi * 2 * freq + p1) +
                      0.4 * math.sin(u * math.pi * 5 * freq + p2)));
    }
    path
      ..lineTo(w + 10, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  /// Roma a lo lejos: un domo sobre su tambor, unos techos y el acueducto
  /// que llega desde la derecha.
  void _rome(Canvas canvas, Size size, double hz) {
    final w = size.width, h = size.height;
    final ink = Paint()
      ..color = Color.lerp(palette.landFar, palette.land, 0.35)!;
    final base = hz + h * 0.01;
    final cx = w * 0.58, r = h * 0.07;
    canvas.drawRect(
        Rect.fromLTWH(cx - r * 1.1, base - r * 0.9, r * 2.2, r * 0.9), ink);
    canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, base - r * 0.9), radius: r),
        math.pi,
        math.pi,
        true,
        ink);
    for (final (x, bw, bh) in [
      (0.44, 0.07, 0.05),
      (0.5, 0.05, 0.07),
      (0.66, 0.06, 0.06)
    ]) {
      canvas.drawRect(Rect.fromLTWH(w * x, base - h * bh, w * bw, h * bh), ink);
    }
    // Acueducto: un tablero largo con arcos calados.
    final top = base - h * 0.075;
    final arches = Path()
      ..addRect(Rect.fromLTRB(w * 0.7, top, w + 4, base))
      ..fillType = PathFillType.evenOdd;
    final span = h * 0.045;
    for (var x = w * 0.71; x < w; x += span * 1.35) {
      arches.addRRect(RRect.fromRectAndCorners(
          Rect.fromLTWH(x, top + h * 0.018, span, base - top - h * 0.018),
          topLeft: Radius.circular(span / 2),
          topRight: Radius.circular(span / 2)));
    }
    canvas.drawPath(arches, ink);
    // Al caer la tarde, alguna ventana prendida.
    if (palette.lamps > 0.05) {
      final lamp = Paint()
        ..color = ArtColors.torch.withValues(alpha: 0.85 * palette.lamps);
      for (final x in [0.455, 0.515, 0.675]) {
        canvas.drawRect(Rect.fromLTWH(w * x, base - h * 0.03, 2.5, 3), lamp);
      }
    }
  }

  void _cypress(Canvas canvas, Offset base, double height) {
    final sway = math.sin(t * 0.7 + base.dx) * 1.2;
    final w = height * 0.22;
    final path = Path()
      ..moveTo(base.dx - w / 2, base.dy)
      ..quadraticBezierTo(base.dx - w * 0.7, base.dy - height * 0.55,
          base.dx + sway, base.dy - height)
      ..quadraticBezierTo(
          base.dx + w * 0.7, base.dy - height * 0.55, base.dx + w / 2, base.dy)
      ..close();
    canvas.drawPath(path, Paint()..color = palette.landNear);
  }

  /// Pino piñonero: tronco fino y copa ancha y chata, como un paraguas.
  void _pine(Canvas canvas, Offset base, double height) {
    final paint = Paint()..color = palette.landNear;
    final top = base.translate(height * 0.08, -height);
    canvas.drawLine(base, top.translate(0, height * 0.12),
        paint..strokeWidth = math.max(2, height * 0.05));
    final sway = math.sin(t * 0.5 + base.dx) * 1.5;
    final crown = Offset(top.dx + sway, top.dy);
    canvas.drawOval(
        Rect.fromCenter(
            center: crown, width: height * 0.9, height: height * 0.22),
        paint);
    canvas.drawOval(
        Rect.fromCenter(
            center: crown.translate(-height * 0.18, -height * 0.07),
            width: height * 0.5,
            height: height * 0.16),
        paint);
    canvas.drawOval(
        Rect.fromCenter(
            center: crown.translate(height * 0.2, -height * 0.05),
            width: height * 0.45,
            height: height * 0.14),
        paint);
  }

  @override
  bool shouldRepaint(LivingSkyPainter old) =>
      old.palette.hour != palette.hour ||
      old.horizon != horizon ||
      old.topInset != topInset ||
      old.celestialSpan != celestialSpan;
}
