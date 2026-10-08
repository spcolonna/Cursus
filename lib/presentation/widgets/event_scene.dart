// lib/presentation/widgets/event_scene.dart
//
// Escenario pintado detrás de cada evento: el cielo sigue la hora real, hay
// tres planos con parallax lento y cada categoría tiene su lugar (puente,
// templo, posada, puerto…). Los efectos (lluvia, antorchas, agua, nubes) se
// apagan con movimiento reducido. Cuando exista la ilustración del evento
// (`assets/art/events/<id>.jpg`), `EventBackdrop` la muestra en su lugar.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/entities.dart';
import '../providers/providers.dart';
import '../theme/art_palette.dart';
import '../theme/motion.dart';
import '../theme/sky.dart';
import 'art_image.dart';

/// Espacio libre que la pantalla de evento deja arriba para ver la escena.
const double kEventStageGap = 116;

/// Fondo de un evento. Usa lo mejor que haya: la ilustración del evento, la
/// del escenario de su categoría o el escenario pintado por código.
class EventBackdrop extends StatelessWidget {
  final MissionEvent event;
  const EventBackdrop({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final painted = EventScene(category: event.category);
    final scene = ArtImage(
        asset: ArtPaths.scene(event.category.name), fallback: painted);
    final id = event.configId;
    if (id == null) return scene;
    return ArtImage(asset: ArtPaths.event(id), fallback: scene);
  }
}

class EventScene extends ConsumerStatefulWidget {
  final EventCategory category;

  /// Hora del día (0-24). Por defecto, la del cielo vivo.
  final double? hour;

  /// La escena ocupa todo el alto (banners); si no, solo la franja de arriba
  /// de una pantalla completa.
  final bool banner;
  const EventScene(
      {super.key, required this.category, this.hour, this.banner = false});

  @override
  ConsumerState<EventScene> createState() => _EventSceneState();
}

class _EventSceneState extends ConsumerState<EventScene>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final _clock = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      if (AppMotion.userPrefersReduced.value) return;
      _clock.value = elapsed.inMilliseconds / 1000;
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
    final double hour = widget.hour ?? ref.watch<double>(skyHourProvider);
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: EventScenePainter(
            category: widget.category,
            sky: SkyPalette.at(hour),
            clock: _clock,
            banner: widget.banner,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PINTOR
// ═══════════════════════════════════════════════════════════════

class EventScenePainter extends CustomPainter {
  final EventCategory category;
  final SkyPalette sky;
  final ValueNotifier<double> clock;
  final bool banner;

  EventScenePainter({
    required this.category,
    required this.sky,
    required this.clock,
    this.banner = false,
  }) : super(repaint: clock);

  double get t => clock.value;

  bool get _night => sky.night >= 0.5;

  /// Faroles, antorchas y ventanas: se prenden al caer la tarde.
  bool get _lit => sky.lamps >= 0.5;
  bool get _storm => category == EventCategory.storm;

  /// Las cosas se oscurecen de noche, se tiñen al atardecer y se funden con
  /// el horizonte con la distancia. Sin saltos: siguen el peso de cada cielo.
  Color _shade(Color c, {double far = 0}) {
    var out = c;
    out = Color.lerp(out, SkyKeyframe.night.top, 0.55 * sky.night)!;
    out = Color.lerp(out, SkyKeyframe.dusk.top, 0.3 * sky.dusk)!;
    if (_storm) out = Color.lerp(out, ArtColors.stormTop, 0.35)!;
    if (far > 0) out = Color.lerp(out, _skyBottom, far)!;
    return out;
  }

  Color get _skyTop => _storm ? ArtColors.stormTop : sky.top;
  Color get _skyMid => _storm
      ? Color.lerp(ArtColors.stormTop, ArtColors.stormBottom, 0.5)!
      : sky.mid;
  Color get _skyBottom => _storm ? ArtColors.stormBottom : sky.horizon;

  /// Alto de la franja donde vive la escena: arriba de todo, donde la
  /// pantalla de evento deja una ventana libre ([kEventStageGap]). Abajo de
  /// la franja el suelo sigue liso hasta el borde.
  static double stageHeight(Size size) =>
      math.min(size.height * 0.36, size.width * 0.9);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final stage = banner ? size : Size(w, stageHeight(size));
    final h = stage.height;
    final horizon = h * 0.62;

    _sky(canvas, size, stage, horizon);
    canvas.save();
    canvas.clipRect(Offset.zero & stage);
    // Plano lejano: colinas azuladas, se mueven casi nada.
    final drift = math.sin(t * 0.05) * 6;
    _ridge(canvas, stage, horizon - h * 0.04, h * 0.06, 1.3, 1,
        _shade(ArtColors.hillFar, far: 0.35), drift * 0.3);

    switch (category) {
      case EventCategory.road:
        _roadScene(canvas, stage, horizon, drift);
      case EventCategory.patrol:
        _patrolScene(canvas, stage, horizon, drift);
      case EventCategory.river:
        _riverScene(canvas, stage, horizon, drift);
      case EventCategory.storm:
        _stormScene(canvas, stage, horizon, drift);
      case EventCategory.bandits:
        _banditsScene(canvas, stage, horizon, drift);
      case EventCategory.temple:
        _templeScene(canvas, stage, horizon, drift);
      case EventCategory.forum:
        _forumScene(canvas, stage, horizon, drift);
      case EventCategory.inn:
        _innScene(canvas, stage, horizon, drift);
      case EventCategory.port:
        _portScene(canvas, stage, horizon, drift);
      case EventCategory.subura:
        _suburaScene(canvas, stage, horizon, drift);
    }
    canvas.restore();

    // El borde inferior de la franja se funde con el suelo de abajo.
    final seam = Rect.fromLTRB(0, h * 0.78, w, h);
    canvas.drawRect(
      seam,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _shade(ArtColors.hillNear).withValues(alpha: 0),
            _shade(ArtColors.hillNear),
          ],
        ).createShader(seam),
    );

    // Suelo bajo la franja: el mismo plano cercano, oscureciéndose.
    final below = Rect.fromLTRB(0, h, w, size.height);
    canvas.drawRect(
      below,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_shade(ArtColors.hillNear), ArtColors.silhouette],
        ).createShader(below),
    );

    // Bruma baja: une los planos.
    final mist = Rect.fromLTWH(0, horizon - h * 0.08, w, h * 0.3);
    canvas.drawRect(
      mist,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [ArtColors.mist.withValues(alpha: 0), ArtColors.mist,
            ArtColors.mist.withValues(alpha: 0)],
        ).createShader(mist),
    );
  }

  // ─── Cielo ───
  void _sky(Canvas canvas, Size full, Size size, double horizon) {
    final rect = Offset.zero & full;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_skyTop, _skyMid, _skyBottom, _skyBottom],
          stops: [
            0,
            size.height / full.height * 0.34,
            size.height / full.height * 0.62,
            1
          ],
        ).createShader(rect),
    );
    final w = size.width;
    if (_storm) return _clouds(canvas, size, horizon, dark: true);

    if (sky.stars > 0.02) {
      final rng = math.Random(7);
      for (var i = 0; i < 70; i++) {
        final x = rng.nextDouble() * w;
        final y = rng.nextDouble() * horizon * 0.85;
        final tw = 0.55 + 0.45 * math.sin(t * (0.8 + rng.nextDouble()) + i);
        canvas.drawCircle(
            Offset(x, y),
            rng.nextDouble() * 1.2 + 0.4,
            Paint()
              ..color = ArtColors.star
                  .withValues(alpha: (0.35 + 0.5 * tw) * sky.stars));
      }
    }
    // El sol (o la luna) cruza el cielo con la hora: sale a la izquierda.
    final body = Offset(w * sky.celestialX,
        horizon - sky.celestialAltitude * horizon * 0.7 + 10);
    if (sky.isMoon) {
      canvas.drawCircle(body, 30,
          Paint()..color = SkyPalette.moonColor.withValues(alpha: 0.12));
      canvas.drawCircle(body, 16, Paint()..color = SkyPalette.moonColor);
      canvas.drawCircle(body.translate(6, -3), 14,
          Paint()..color = _skyTop.withValues(alpha: 0.85));
    } else {
      canvas.drawCircle(body, 46,
          Paint()..color = sky.sunColor.withValues(alpha: 0.2));
      canvas.drawCircle(body, 22, Paint()..color = sky.sunColor);
    }
    _clouds(canvas, size, horizon);
  }

  void _clouds(Canvas canvas, Size size, double horizon, {bool dark = false}) {
    final w = size.width;
    final paint = Paint()
      ..color = dark
          ? ArtColors.silhouette.withValues(alpha: 0.45)
          : sky.cloud.withValues(alpha: 0.6 - 0.2 * sky.night);
    final rng = math.Random(dark ? 3 : 11);
    final count = dark ? 7 : 4;
    for (var i = 0; i < count; i++) {
      final speed = 4 + rng.nextDouble() * 6;
      final baseX = rng.nextDouble() * (w + 200);
      final x = (baseX + t * speed) % (w + 200) - 100;
      final y = horizon * (0.12 + rng.nextDouble() * (dark ? 0.6 : 0.45));
      final s = 0.7 + rng.nextDouble() * (dark ? 1.4 : 0.7);
      _cloud(canvas, Offset(x, y), s, paint);
    }
  }

  void _cloud(Canvas canvas, Offset c, double s, Paint p) {
    canvas.drawOval(Rect.fromCenter(center: c, width: 90 * s, height: 22 * s), p);
    canvas.drawCircle(c.translate(-14 * s, -8 * s), 14 * s, p);
    canvas.drawCircle(c.translate(10 * s, -12 * s), 18 * s, p);
  }

  // ─── Planos genéricos ───

  /// Silueta de colinas: suma de senos con semilla, para que cada plano
  /// tenga su perfil y no se repita.
  void _ridge(Canvas canvas, Size size, double baseY, double amp, double freq,
      int seed, Color color, double shift) {
    final w = size.width;
    final rng = math.Random(seed);
    final p1 = rng.nextDouble() * 6, p2 = rng.nextDouble() * 6;
    final path = Path()..moveTo(-20, size.height);
    for (var x = -20.0; x <= w + 20; x += 8) {
      final u = (x + shift) / w;
      final y = baseY -
          amp * (0.6 * math.sin(u * math.pi * 2 * freq + p1) +
              0.4 * math.sin(u * math.pi * 5 * freq + p2));
      path.lineTo(x, y);
    }
    path
      ..lineTo(w + 20, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _ground(Canvas canvas, Size size, double y, Color color) {
    canvas.drawRect(Rect.fromLTRB(0, y, size.width, size.height),
        Paint()..color = color);
  }

  void _cypress(Canvas canvas, Offset base, double height, {double sway = 0}) {
    final w = height * 0.22;
    final top = base.translate(sway, -height);
    final path = Path()
      ..moveTo(base.dx - w / 2, base.dy)
      ..quadraticBezierTo(base.dx - w * 0.7, base.dy - height * 0.55, top.dx, top.dy)
      ..quadraticBezierTo(base.dx + w * 0.7, base.dy - height * 0.55, base.dx + w / 2, base.dy)
      ..close();
    canvas.drawPath(path, Paint()..color = _shade(ArtColors.cypress));
  }

  /// Camino que se pierde en el horizonte.
  void _road(Canvas canvas, Size size, double horizon, {double curve = 0.12}) {
    final w = size.width, h = size.height;
    final path = Path()
      ..moveTo(w * 0.5 - 4, horizon + 4)
      ..quadraticBezierTo(w * (0.5 + curve), horizon + (h - horizon) * 0.35,
          w * 0.18, h)
      ..lineTo(w * 0.82, h)
      ..quadraticBezierTo(w * (0.5 + curve * 1.4), horizon + (h - horizon) * 0.35,
          w * 0.5 + 4, horizon + 4)
      ..close();
    canvas.drawPath(path, Paint()..color = _shade(ArtColors.stoneShade));
    // Adoquines: líneas que se abren con la perspectiva.
    final joint = Paint()
      ..color = _shade(ArtColors.stoneDark)
      ..strokeWidth = 1.5;
    for (var i = 1; i < 9; i++) {
      final f = i / 9;
      final y = horizon + 4 + (h - horizon) * f * f;
      final half = 4 + (w * 0.32) * f * f;
      final cx = w * 0.5 + w * curve * math.sin(f * math.pi) * 0.8;
      canvas.drawLine(Offset(cx - half, y), Offset(cx + half, y), joint);
    }
  }

  void _torch(Canvas canvas, Offset top, {double scale = 1}) {
    final flick = 1 + 0.12 * math.sin(t * 13 + top.dx) + 0.06 * math.sin(t * 29);
    canvas.drawLine(top, top.translate(0, 26 * scale),
        Paint()
          ..color = _shade(ArtColors.leatherDark)
          ..strokeWidth = 3 * scale);
    canvas.drawCircle(top, 26 * scale * flick,
        Paint()..color = ArtColors.torchGlow);
    canvas.drawOval(
        Rect.fromCenter(
            center: top.translate(0, -4 * scale),
            width: 8 * scale,
            height: 14 * scale * flick),
        Paint()..color = ArtColors.torch);
  }

  void _window(Canvas canvas, Rect r) {
    final lit = _lit || _storm;
    canvas.drawRect(r,
        Paint()..color = lit ? ArtColors.torch : _shade(ArtColors.stoneDark));
    if (lit) {
      canvas.drawRect(r.inflate(5), Paint()..color = ArtColors.torchGlow);
    }
  }

  void _building(Canvas canvas, Rect body, {bool roof = true, int windows = 2,
      double far = 0}) {
    canvas.drawRect(body, Paint()..color = _shade(ArtColors.stone, far: far));
    canvas.drawRect(Rect.fromLTWH(body.right - body.width * 0.25, body.top,
            body.width * 0.25, body.height),
        Paint()..color = _shade(ArtColors.stoneShade, far: far));
    if (roof) {
      final r = Path()
        ..moveTo(body.left - 6, body.top)
        ..lineTo(body.center.dx, body.top - body.width * 0.28)
        ..lineTo(body.right + 6, body.top)
        ..close();
      canvas.drawPath(r, Paint()..color = _shade(ArtColors.terracotta, far: far));
    }
    for (var i = 0; i < windows; i++) {
      final x = body.left + body.width * (i + 1) / (windows + 1) - 4;
      _window(canvas, Rect.fromLTWH(x, body.top + body.height * 0.3, 8, 11));
    }
  }

  void _columns(Canvas canvas, Rect area, int count, Color color, Color shade) {
    final colW = area.width / (count * 2 - 1);
    for (var i = 0; i < count; i++) {
      final x = area.left + i * colW * 2;
      canvas.drawRect(Rect.fromLTWH(x, area.top, colW, area.height),
          Paint()..color = color);
      canvas.drawRect(Rect.fromLTWH(x + colW * 0.65, area.top, colW * 0.35, area.height),
          Paint()..color = shade);
    }
  }

  void _water(Canvas canvas, Rect r) {
    canvas.drawRect(r, Paint()..color = _shade(ArtColors.water));
    final shine = Paint()
      ..color = _shade(ArtColors.waterLight).withValues(alpha: 0.7)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final rng = math.Random(5);
    for (var i = 0; i < 26; i++) {
      final y = r.top + 6 + rng.nextDouble() * (r.height - 10);
      final depth = (y - r.top) / r.height;
      final len = 10 + 28 * depth;
      final x = (rng.nextDouble() * r.width + math.sin(t * 0.8 + i) * 6) % r.width;
      canvas.drawLine(Offset(r.left + x, y), Offset(r.left + x + len, y), shine);
    }
  }

  // ─── Escenas ───

  void _roadScene(Canvas c, Size s, double hz, double drift) {
    _ridge(c, s, hz + s.height * 0.02, s.height * 0.035, 0.9, 2,
        _shade(ArtColors.hillMid, far: 0.15), drift);
    _ground(c, s, hz + s.height * 0.05, _shade(ArtColors.hillNear));
    _road(c, s, hz + s.height * 0.02);
    for (final (x, hh) in [(0.12, 0.2), (0.2, 0.15), (0.84, 0.22), (0.92, 0.17)]) {
      _cypress(c, Offset(s.width * x, hz + s.height * 0.1), s.height * hh,
          sway: math.sin(t * 0.7 + x * 9) * 1.5);
    }
    // Miliario al costado del camino.
    final m = Rect.fromLTWH(s.width * 0.7, hz + s.height * 0.1, 14, 34);
    c.drawRRect(RRect.fromRectAndCorners(m, topLeft: const Radius.circular(7),
        topRight: const Radius.circular(7)), Paint()..color = _shade(ArtColors.stone));
  }

  void _patrolScene(Canvas c, Size s, double hz, double drift) {
    _roadScene(c, s, hz, drift);
    final w = s.width, base = hz + s.height * 0.12;
    // Barrera del puesto de control.
    final post = Paint()..color = _shade(ArtColors.leatherDark);
    c.drawRect(Rect.fromLTWH(w * 0.3, base - 40, 8, 40), post);
    c.drawRect(Rect.fromLTWH(w * 0.68, base - 40, 8, 40), post);
    final bar = Paint()
      ..color = _shade(ArtColors.legionRed)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    c.drawLine(Offset(w * 0.3, base - 30), Offset(w * 0.69, base - 30), bar);
    // Estandartes de la legión, recortados contra el cielo.
    for (final x in [0.24, 0.76]) {
      final top = Offset(w * x, base - 96);
      c.drawLine(top, Offset(w * x, base), Paint()
        ..color = ArtColors.silhouette
        ..strokeWidth = 3);
      final sway = math.sin(t * 1.6 + x * 10) * 3;
      final flag = Path()
        ..moveTo(top.dx - 14, top.dy + 10)
        ..lineTo(top.dx + 14, top.dy + 10)
        ..lineTo(top.dx + 14 + sway, top.dy + 40)
        ..lineTo(top.dx + sway, top.dy + 34)
        ..lineTo(top.dx - 14 + sway, top.dy + 40)
        ..close();
      c.drawPath(flag, Paint()..color = _shade(ArtColors.legionRed));
      c.drawCircle(top, 5, Paint()..color = _shade(ArtColors.bronze));
    }
    if (_lit) {
      _torch(c, Offset(w * 0.34, base - 58));
      _torch(c, Offset(w * 0.64, base - 58));
    }
  }

  void _riverScene(Canvas c, Size s, double hz, double drift) {
    final w = s.width, h = s.height;
    _ridge(c, s, hz + h * 0.01, h * 0.03, 0.8, 4,
        _shade(ArtColors.hillMid, far: 0.15), drift);
    _ground(c, s, hz + h * 0.04, _shade(ArtColors.hillNear));
    final river = Rect.fromLTWH(0, hz + h * 0.1, w, h * 0.14);
    _water(c, river);
    // Puente de piedra de tres ojos.
    final deckY = river.top - 16;
    c.drawRect(Rect.fromLTWH(w * 0.08, deckY, w * 0.84, 18),
        Paint()..color = _shade(ArtColors.stone));
    for (var i = 0; i < 3; i++) {
      final cx = w * (0.25 + i * 0.25);
      final arch = Path()
        ..addRect(Rect.fromLTWH(cx - w * 0.125, deckY + 14, w * 0.25, river.height * 0.7))
        ..addOval(Rect.fromCenter(
            center: Offset(cx, deckY + 14 + river.height * 0.7),
            width: w * 0.17,
            height: river.height * 1.1));
      arch.fillType = PathFillType.evenOdd;
      c.drawPath(arch, Paint()..color = _shade(ArtColors.stoneShade));
    }
    // Juncos en la orilla.
    final reed = Paint()
      ..color = _shade(ArtColors.laurelDark)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 14; i++) {
      final x = w * (0.02 + i * 0.07);
      final sway = math.sin(t * 1.2 + i) * 2;
      c.drawLine(Offset(x, river.bottom + 4),
          Offset(x + sway, river.bottom - 18 - (i % 3) * 6), reed);
    }
  }

  void _stormScene(Canvas c, Size s, double hz, double drift) {
    _roadScene(c, s, hz, drift);
    final w = s.width, h = s.height;
    // Lluvia en diagonal.
    final rain = Paint()
      ..color = ArtColors.rain
      ..strokeWidth = 1.4;
    final rng = math.Random(9);
    for (var i = 0; i < 90; i++) {
      final x0 = rng.nextDouble() * (w + 60);
      final speed = 380 + rng.nextDouble() * 220;
      final y = (rng.nextDouble() * h + t * speed) % h;
      final x = (x0 - (t * speed * 0.25)) % (w + 60) - 30;
      c.drawLine(Offset(x, y), Offset(x - 5, y + 16), rain);
    }
    // Relámpago: un destello cada ~7 s.
    final phase = t % 7.3;
    if (phase < 0.18) {
      c.drawRect(Offset.zero & s,
          Paint()..color = ArtColors.star.withValues(alpha: 0.18 * (1 - phase / 0.18)));
      final bolt = Path()
        ..moveTo(w * 0.62, 0)
        ..lineTo(w * 0.57, hz * 0.35)
        ..lineTo(w * 0.63, hz * 0.4)
        ..lineTo(w * 0.55, hz * 0.8);
      c.drawPath(bolt, Paint()
        ..color = ArtColors.star
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5);
    }
  }

  void _banditsScene(Canvas c, Size s, double hz, double drift) {
    final w = s.width, h = s.height;
    _ridge(c, s, hz, h * 0.03, 1, 6, _shade(ArtColors.hillMid, far: 0.1), drift);
    _ground(c, s, hz + h * 0.04, _shade(ArtColors.hillNear));
    _road(c, s, hz + h * 0.02, curve: -0.1);
    // Bosque cerrado a los costados: el camino se angosta.
    for (var i = 0; i < 9; i++) {
      final left = i.isEven;
      final x = left ? w * (0.02 + i * 0.035) : w * (0.98 - i * 0.035);
      _cypress(c, Offset(x, hz + h * (0.12 + (i % 3) * 0.03)), h * (0.18 + (i % 4) * 0.04),
          sway: math.sin(t * 0.9 + i) * 2);
    }
    // Rocas y una fogata a lo lejos: alguien espera.
    final rock = Paint()..color = _shade(ArtColors.stoneDark);
    c.drawOval(Rect.fromLTWH(w * 0.26, hz + h * 0.08, 56, 26), rock);
    c.drawOval(Rect.fromLTWH(w * 0.62, hz + h * 0.1, 44, 22), rock);
    final fire = Offset(w * 0.56, hz + h * 0.03);
    final f = 1 + 0.2 * math.sin(t * 11);
    c.drawCircle(fire, 18 * f, Paint()..color = ArtColors.torchGlow);
    c.drawCircle(fire, 3.5, Paint()..color = ArtColors.torch);
  }

  void _templeScene(Canvas c, Size s, double hz, double drift) {
    final w = s.width, h = s.height;
    _ground(c, s, hz + h * 0.02, _shade(ArtColors.hillNear));
    final base = hz + h * 0.1;
    final tw = w * 0.62, left = (w - tw) / 2;
    // Podio y escalinata.
    for (var i = 0; i < 5; i++) {
      c.drawRect(Rect.fromLTWH(left - i * 6, base + i * 7, tw + i * 12, 7),
          Paint()..color = _shade(i.isEven ? ArtColors.stone : ArtColors.stoneShade));
    }
    final colTop = base - h * 0.17;
    _columns(c, Rect.fromLTWH(left + 8, colTop, tw - 16, base - colTop),
        6, _shade(ArtColors.stone), _shade(ArtColors.stoneShade));
    // Entablamento y frontón.
    c.drawRect(Rect.fromLTWH(left - 4, colTop - 12, tw + 8, 12),
        Paint()..color = _shade(ArtColors.stone));
    final ped = Path()
      ..moveTo(left - 8, colTop - 12)
      ..lineTo(w / 2, colTop - 12 - tw * 0.2)
      ..lineTo(left + tw + 8, colTop - 12)
      ..close();
    c.drawPath(ped, Paint()..color = _shade(ArtColors.stone));
    c.drawPath(ped, Paint()
      ..color = _shade(ArtColors.stoneShade)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3);
    // Humo de incienso.
    final smoke = Paint()
      ..color = ArtColors.mist
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final sx = w / 2;
    final p = Path()..moveTo(sx, base);
    for (var i = 1; i <= 6; i++) {
      p.lineTo(sx + math.sin(t * 0.9 + i * 0.8) * 8, base - i * 14);
    }
    c.drawPath(p, smoke);
    if (_night) {
      _torch(c, Offset(left - 10, base - 20));
      _torch(c, Offset(left + tw + 10, base - 20));
    }
  }

  void _forumScene(Canvas c, Size s, double hz, double drift) {
    final w = s.width, h = s.height;
    // Ciudad al fondo.
    for (var i = 0; i < 6; i++) {
      final bw = w * 0.18;
      _building(c, Rect.fromLTWH(w * (i * 0.17 - 0.03), hz - h * (0.06 + (i % 3) * 0.02),
          bw, h * 0.12), windows: 1, far: 0.35);
    }
    _ground(c, s, hz + h * 0.04, _shade(ArtColors.stoneDark));
    // Basílica con arcada al frente.
    final top = hz - h * 0.05, bot = hz + h * 0.1;
    c.drawRect(Rect.fromLTRB(w * 0.06, top, w * 0.94, bot),
        Paint()..color = _shade(ArtColors.stone));
    final arch = Paint()..color = _shade(ArtColors.stoneDark);
    for (var i = 0; i < 6; i++) {
      final cx = w * (0.14 + i * 0.144);
      final r = Rect.fromLTWH(cx - 12, top + h * 0.05, 24, bot - top - h * 0.05);
      c.drawRRect(RRect.fromRectAndCorners(r,
          topLeft: const Radius.circular(12), topRight: const Radius.circular(12)), arch);
    }
    c.drawRect(Rect.fromLTWH(w * 0.04, top - 10, w * 0.92, 10),
        Paint()..color = _shade(ArtColors.terracotta));
    // Estatua sobre pedestal.
    final px = w * 0.5, py = bot + h * 0.06;
    c.drawRect(Rect.fromLTWH(px - 12, py - 22, 24, 22),
        Paint()..color = _shade(ArtColors.stoneShade));
    c.drawOval(Rect.fromLTWH(px - 6, py - 54, 12, 34),
        Paint()..color = _shade(ArtColors.bronze));
    c.drawCircle(Offset(px, py - 58), 6, Paint()..color = _shade(ArtColors.bronze));
  }

  void _innScene(Canvas c, Size s, double hz, double drift) {
    final w = s.width, h = s.height;
    _ridge(c, s, hz + h * 0.01, h * 0.03, 0.7, 8, _shade(ArtColors.hillMid, far: 0.15), drift);
    _ground(c, s, hz + h * 0.04, _shade(ArtColors.hillNear));
    _road(c, s, hz + h * 0.03, curve: 0.2);
    // La posada: dos pisos, tejas, ventanas cálidas.
    final body = Rect.fromLTWH(w * 0.08, hz - h * 0.04, w * 0.42, h * 0.16);
    _building(c, body, windows: 3);
    c.drawRect(Rect.fromLTWH(body.left + body.width * 0.4, body.bottom - 30, 20, 30),
        Paint()..color = _shade(ArtColors.leatherDark));
    // Cartel colgante que se mece.
    final hook = Offset(body.right + 6, body.top + 20);
    c.drawLine(hook.translate(-8, 0), hook.translate(18, 0),
        Paint()..color = _shade(ArtColors.leatherDark)..strokeWidth = 3);
    c.save();
    c.translate(hook.dx + 10, hook.dy);
    c.rotate(math.sin(t * 1.3) * 0.08);
    c.drawRect(const Rect.fromLTWH(-12, 6, 24, 16), Paint()..color = _shade(ArtColors.felt));
    c.restore();
    _window(c, Rect.fromLTWH(body.left + 12, body.bottom - 24, 10, 12));
    if (_lit) _torch(c, Offset(body.right + 4, body.bottom - 30), scale: 0.8);
    _cypress(c, Offset(w * 0.78, hz + h * 0.1), h * 0.2, sway: math.sin(t * 0.7) * 1.5);
  }

  void _portScene(Canvas c, Size s, double hz, double drift) {
    final w = s.width, h = s.height;
    _water(c, Rect.fromLTWH(0, hz - h * 0.02, w, h * 0.3));
    // Barco que se mece en el muelle.
    final rock = math.sin(t * 1.1) * 0.03;
    final shipC = Offset(w * 0.6, hz + h * 0.06);
    c.save();
    c.translate(shipC.dx, shipC.dy);
    c.rotate(rock);
    final hull = Path()
      ..moveTo(-70, -6)
      ..lineTo(70, -6)
      ..quadraticBezierTo(60, 16, 40, 18)
      ..lineTo(-46, 18)
      ..quadraticBezierTo(-64, 12, -70, -6)
      ..close();
    c.drawPath(hull, Paint()..color = _shade(ArtColors.leatherDark));
    c.drawLine(const Offset(0, -6), const Offset(0, -96),
        Paint()..color = _shade(ArtColors.leatherDark)..strokeWidth = 4);
    final sail = Path()
      ..moveTo(-40, -88)
      ..quadraticBezierTo(0, -70 + math.sin(t * 1.5) * 3, 40, -88)
      ..lineTo(36, -26)
      ..quadraticBezierTo(0, -14, -36, -26)
      ..close();
    c.drawPath(sail, Paint()..color = _shade(ArtColors.sail));
    c.drawRect(const Rect.fromLTWH(-38, -62, 76, 8),
        Paint()..color = _shade(ArtColors.legionRed));
    c.restore();
    // Muelle de madera y faro.
    c.drawRect(Rect.fromLTWH(0, hz + h * 0.12, w * 0.46, 14),
        Paint()..color = _shade(ArtColors.felt));
    for (var i = 0; i < 5; i++) {
      c.drawRect(Rect.fromLTWH(w * (0.04 + i * 0.09), hz + h * 0.12, 6, h * 0.08),
          Paint()..color = _shade(ArtColors.feltDark));
    }
    final lh = Rect.fromLTWH(w * 0.1, hz - h * 0.14, 26, h * 0.14);
    c.drawRect(lh, Paint()..color = _shade(ArtColors.stone));
    final glow = 0.6 + 0.4 * math.sin(t * 2);
    c.drawCircle(Offset(lh.center.dx, lh.top - 8), 24 * glow,
        Paint()..color = ArtColors.torchGlow);
    c.drawCircle(Offset(lh.center.dx, lh.top - 8), 6, Paint()..color = ArtColors.torch);
    _ground(c, s, hz + h * 0.28, _shade(ArtColors.hillNear));
  }

  void _suburaScene(Canvas c, Size s, double hz, double drift) {
    final w = s.width, h = s.height;
    _ground(c, s, hz + h * 0.05, _shade(ArtColors.stoneDark));
    // Ínsulas apretadas a los dos lados del callejón.
    for (var i = 0; i < 3; i++) {
      final lw = w * (0.2 - i * 0.03);
      final top = hz - h * (0.22 - i * 0.04);
      _building(c, Rect.fromLTWH(w * 0.02 + i * lw * 0.9, top, lw, hz + h * 0.12 - top),
          roof: false, windows: 2, far: 0.1 * (2 - i));
      _building(c, Rect.fromLTWH(w * 0.98 - (i + 1) * lw * 0.9 - lw * 0.1, top, lw, hz + h * 0.12 - top),
          roof: false, windows: 2, far: 0.1 * (2 - i));
    }
    // Ropa tendida entre ventanas.
    final line = Paint()
      ..color = _shade(ArtColors.stoneDark)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final y = hz - h * 0.12;
    final cord = Path()
      ..moveTo(w * 0.22, y)
      ..quadraticBezierTo(w * 0.5, y + 22, w * 0.78, y);
    c.drawPath(cord, line);
    final cloth = [ArtColors.legionRed, ArtColors.sail, ArtColors.felt, ArtColors.sail];
    for (var i = 0; i < 4; i++) {
      final x = w * (0.3 + i * 0.12);
      final sway = math.sin(t * 1.4 + i) * 2;
      c.drawRect(Rect.fromLTWH(x + sway, y + 10 + (i.isEven ? 4 : 8), 16, 20),
          Paint()..color = _shade(cloth[i]));
    }
    _torch(c, Offset(w * 0.3, hz + h * 0.02), scale: 0.8);
  }

  @override
  bool shouldRepaint(EventScenePainter old) =>
      old.category != category || old.sky.hour != sky.hour;
}
