// lib/presentation/widgets/route_map.dart
//
// El mapa de la ruta: Italia para los viajes largos y el plano de Roma para
// los recados urbanos. La cámara encuadra la ruta sola. En la pantalla de
// misión pinta a 60 fps con su propio Ticker (sin rebuilds): el tramo
// recorrido en oro, los eventos como hitos y el mensajero que avanza.

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/entities.dart';
import '../../domain/entities/geo.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../theme/art_palette.dart';

/// Posición (0..1) de cada evento sobre el camino.
List<double> eventMarks(Mission mission) {
  final total =
      mission.deadlineAt.difference(mission.startedAt).inSeconds.toDouble();
  if (total <= 0) return const [];
  return [
    for (final e in mission.events)
      (e.triggersAt.difference(mission.startedAt).inSeconds / total)
          .clamp(0.0, 1.0),
  ];
}

/// Mapa en vivo de una misión en curso.
class RouteMapView extends ConsumerStatefulWidget {
  final Mission mission;
  final double height;
  const RouteMapView({super.key, required this.mission, this.height = 190});

  @override
  ConsumerState<RouteMapView> createState() => _RouteMapViewState();
}

class _RouteMapViewState extends ConsumerState<RouteMapView>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final _clock = ValueNotifier<double>(0); // segundos desde que se abrió

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      // Con movimiento reducido alcanza con un cuadro por segundo: la barra
      // avanza igual, sin el trote ni el pulso.
      if (AppMotion.userPrefersReduced.value &&
          (elapsed.inMilliseconds - _clock.value * 1000).abs() < 1000) {
        return;
      }
      _clock.value = elapsed.inMilliseconds / 1000;
    })
      ..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.mission;
    final atlas = ref.watch(gameContentProvider).atlas;
    final geometry = atlas.routeFor(m.routeId, m.origin, m.destination) ??
        _fallbackGeometry;
    return Semantics(
      label: 'Mapa de la ruta de ${m.origin} a ${m.destination}',
      image: true,
      child: _MapFrame(
        height: widget.height,
        child: RepaintBoundary(
          child: CustomPaint(
            painter: RouteMapPainter(
              atlas: atlas,
              geometry: geometry,
              mission: m,
              clock: _clock,
              animate: !AppMotion.reduced(context),
            ),
          ),
        ),
      ),
    );
  }
}

/// Miniatura estática de una ruta para las cards de selección.
class RouteMapThumbnail extends ConsumerWidget {
  final String routeId;
  final String origin;
  final String destination;
  final double size;
  const RouteMapThumbnail({
    super.key,
    required this.routeId,
    required this.origin,
    required this.destination,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final atlas = ref.watch(gameContentProvider).atlas;
    final geometry =
        atlas.routeFor(routeId, origin, destination) ?? _fallbackGeometry;
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: _MapFrame(
          height: size,
          radius: AppRadii.sm,
          child: CustomPaint(
            painter: RouteMapPainter(
              atlas: atlas,
              geometry: geometry,
              thumbnail: true,
            ),
          ),
        ),
      ),
    );
  }
}

const _fallbackGeometry = RouteGeometry(
  map: MapKind.rome,
  points: [MapPoint(0.4, 0.6), MapPoint(0.6, 0.4)],
);

class _MapFrame extends StatelessWidget {
  final double height;
  final double radius;
  final Widget child;
  const _MapFrame(
      {required this.height, required this.child, this.radius = AppRadii.md});

  @override
  Widget build(BuildContext context) => Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: AppColors.outline, width: 2.5),
          boxShadow: const [
            BoxShadow(
                color: AppColors.outline, offset: Offset(0, 4), blurRadius: 0),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius - 2),
          child: child,
        ),
      );
}

// ═══════════════════════════════════════════════════════════════
// PINTOR
// ═══════════════════════════════════════════════════════════════

class RouteMapPainter extends CustomPainter {
  final GeoAtlas atlas;
  final RouteGeometry geometry;
  final Mission? mission;
  final ValueNotifier<double>? clock;
  final bool animate;
  final bool thumbnail;

  RouteMapPainter({
    required this.atlas,
    required this.geometry,
    this.mission,
    this.clock,
    this.animate = false,
    this.thumbnail = false,
  }) : super(repaint: clock);

  double get _aspect =>
      geometry.map == MapKind.italy ? kItalyMapAspect : 1.0;

  /// Transformación mapa (0..1) → pantalla, encuadrando la ruta.
  _Camera _camera(Size size) {
    final pts = geometry.points.map((p) => Offset(p.x * _aspect, p.y));
    var minX = double.infinity, minY = double.infinity;
    var maxX = -double.infinity, maxY = -double.infinity;
    for (final p in pts) {
      minX = math.min(minX, p.dx);
      maxX = math.max(maxX, p.dx);
      minY = math.min(minY, p.dy);
      maxY = math.max(maxY, p.dy);
    }
    final minSpan = geometry.map == MapKind.italy
        ? 0.02
        : (thumbnail ? 0.55 : 0.5);
    final span = math.max(maxX - minX, maxY - minY);
    final pad = math.max(span * 0.35, minSpan * 0.5);
    var bw = maxX - minX + pad * 2;
    var bh = maxY - minY + pad * 2;
    final ratio = size.width / size.height;
    if (bw / bh < ratio) {
      bw = bh * ratio;
    } else {
      bh = bw / ratio;
    }
    final scale = size.width / bw;
    // Se corre un poco hacia arriba: el medallón del mensajero flota encima.
    final center = Offset((minX + maxX) / 2, (minY + maxY) / 2 - pad * 0.1);
    return _Camera(scale, center, size, _aspect);
  }

  // El fondo no cambia entre cuadros: se graba una vez por tamaño y se
  // reproduce. Solo la ruta y el mensajero se pintan en cada tick.
  ui.Picture? _background;
  Size? _backgroundSize;

  @override
  void paint(Canvas canvas, Size size) {
    final cam = _camera(size);
    if (_background == null || _backgroundSize != size) {
      final recorder = ui.PictureRecorder();
      final c = Canvas(recorder);
      if (geometry.map == MapKind.italy) {
        _paintItaly(c, size, cam);
      } else {
        _paintRome(c, size, cam);
      }
      _background?.dispose();
      _background = recorder.endRecording();
      _backgroundSize = size;
    }
    canvas.drawPicture(_background!);
    _paintRoute(canvas, cam);
  }

  // ─── Fondo: Italia ───
  void _paintItaly(Canvas canvas, Size size, _Camera cam) {
    canvas.drawRect(Offset.zero & size, Paint()..color = ArtColors.sea);
    if (!thumbnail) _waves(canvas, size);

    final landFill = Paint()..color = ArtColors.land;
    final coast = Paint()
      ..color = AppColors.outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = thumbnail ? 1.5 : 2.5
      ..strokeJoin = StrokeJoin.round;
    // Sombra de costa: un borde claro hacia el mar, como en las cartas viejas.
    final shore = Paint()
      ..color = ArtColors.seaWave
      ..style = PaintingStyle.stroke
      ..strokeWidth = thumbnail ? 3 : 7
      ..strokeJoin = StrokeJoin.round;
    final landPath = Path();
    for (final poly in atlas.land) {
      final path = Path()
        ..addPolygon([for (final p in poly) cam.map(p.project)], true);
      landPath.addPath(path, Offset.zero);
      canvas.drawPath(path, shore);
      canvas.drawPath(path, landFill);
      canvas.drawPath(path, coast);
    }
    if (!thumbnail) _landTexture(canvas, size, landPath);

    // Ríos.
    final river = Paint()
      ..color = ArtColors.river
      ..style = PaintingStyle.stroke
      ..strokeWidth = thumbnail ? 1.5 : 2.5
      ..strokeCap = StrokeCap.round;
    for (final r in atlas.rivers) {
      canvas.drawPath(
          _smooth([for (final p in r) cam.map(p.project)], bend: false), river);
    }

    // Cordilleras: picos a lo largo de la línea, con su ladera en sombra.
    final peakLight = Paint()..color = ArtColors.landLight;
    final peakShade = Paint()..color = ArtColors.landShade;
    final peakSize = (cam.scale * 0.012).clamp(4.0, 11.0);
    for (final range in atlas.ranges) {
      final path =
          _smooth([for (final p in range) cam.map(p.project)], bend: false);
      for (final m in path.computeMetrics()) {
        for (var d = 0.0; d < m.length; d += peakSize * 1.6) {
          final c = m.getTangentForOffset(d)!.position;
          final jitter = math.sin(d * 0.37) * peakSize * 0.5;
          final base = c.translate(jitter * 0.4, jitter);
          final top = base.translate(0, -peakSize * 1.2);
          canvas.drawPath(
              Path()
                ..moveTo(base.dx - peakSize, base.dy)
                ..lineTo(top.dx, top.dy)
                ..lineTo(base.dx, base.dy)
                ..close(),
              peakLight);
          canvas.drawPath(
              Path()
                ..moveTo(top.dx, top.dy)
                ..lineTo(base.dx + peakSize, base.dy)
                ..lineTo(base.dx, base.dy)
                ..close(),
              peakShade);
        }
      }
    }

    if (!thumbnail) {
      // Las vías consulares, de fondo.
      final road = Paint()
        ..color = ArtColors.road
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;
      for (final via in atlas.roads.values) {
        final pts = [for (final n in via) cam.map(atlas.cities[n]!.project)];
        _dashed(canvas, _smooth(pts, bend: false), road, 5, 4);
      }
      // Ciudades.
      final dot = Paint()..color = ArtColors.city;
      final ring = Paint()
        ..color = AppColors.outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      for (final p in atlas.visibleCities.values) {
        final c = cam.map(p);
        if (!(Offset.zero & size).inflate(8).contains(c)) continue;
        canvas.drawCircle(c, 3, dot);
        canvas.drawCircle(c, 3, ring);
      }
    }
  }

  /// Matas sueltas sobre la tierra: rompen el plano sin ensuciar la ruta.
  void _landTexture(Canvas canvas, Size size, Path land) {
    canvas.save();
    canvas.clipPath(land);
    final tuft = Paint()
      ..color = ArtColors.landLight
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final rng = math.Random(23);
    final count = (size.width * size.height / 2200).round();
    for (var i = 0; i < count; i++) {
      final p = Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height);
      canvas.drawLine(p, p.translate(-2, -3), tuft);
      canvas.drawLine(p, p.translate(2, -3), tuft);
    }
    canvas.restore();
  }

  void _waves(Canvas canvas, Size size) {
    final wave = Paint()
      ..color = ArtColors.seaWave
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    const stepX = 34.0, stepY = 22.0;
    for (var row = 0; row * stepY < size.height + stepY; row++) {
      final y = row * stepY + 8;
      final shift = row.isOdd ? stepX / 2 : 0.0;
      for (var x = -stepX + shift; x < size.width + stepX; x += stepX) {
        final p = Path()
          ..moveTo(x, y)
          ..quadraticBezierTo(x + 4, y - 3, x + 8, y)
          ..quadraticBezierTo(x + 12, y + 3, x + 16, y);
        canvas.drawPath(p, wave);
      }
    }
  }

  // ─── Fondo: Roma ───
  void _paintRome(Canvas canvas, Size size, _Camera cam) {
    canvas.drawRect(Offset.zero & size, Paint()..color = ArtColors.land);
    final hill = Paint()..color = ArtColors.landLight;
    for (final h in atlas.hills) {
      canvas.drawCircle(cam.map(h), cam.scale * 0.075, hill);
    }
    // Muralla serviana.
    final walls = Path()
      ..addPolygon([for (final p in atlas.walls) cam.map(p)], true);
    _dashed(
        canvas,
        walls,
        Paint()
          ..color = ArtColors.wall
          ..style = PaintingStyle.stroke
          ..strokeWidth = thumbnail ? 1.5 : 3
          ..strokeCap = StrokeCap.square,
        thumbnail ? 3 : 7,
        thumbnail ? 2 : 4);
    // El Tíber.
    final tiber = _smooth([for (final p in atlas.tiber) cam.map(p)], bend: false);
    canvas.drawPath(
        tiber,
        Paint()
          ..color = AppColors.outline
          ..style = PaintingStyle.stroke
          ..strokeWidth = cam.scale * 0.055 + 3
          ..strokeCap = StrokeCap.round);
    canvas.drawPath(
        tiber,
        Paint()
          ..color = ArtColors.river
          ..style = PaintingStyle.stroke
          ..strokeWidth = cam.scale * 0.055
          ..strokeCap = StrokeCap.round);
    if (!thumbnail) {
      final dot = Paint()..color = ArtColors.city;
      for (final p in atlas.romePlaces.values.toSet()) {
        canvas.drawRect(
            Rect.fromCenter(center: cam.map(p), width: 5, height: 5), dot);
      }
    }
  }

  // ─── La ruta ───
  void _paintRoute(Canvas canvas, _Camera cam) {
    final pts = [for (final p in geometry.points) cam.map(p)];
    final path = _smooth(pts, bend: pts.length == 2);
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;
    final len = metric.length;
    final now = DateTime.now();
    final progress =
        mission == null ? 0.0 : mission!.progressAt(now).clamp(0.0, 1.0);

    // Base oscura para que el oro se lea sobre tierra y sobre mar.
    canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.outline
          ..style = PaintingStyle.stroke
          ..strokeWidth = thumbnail ? 5 : 9
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round);

    // Lo que falta: punteado.
    final remaining = Paint()
      ..color = geometry.bySea ? ArtColors.waterLight : ArtColors.city
      ..style = PaintingStyle.stroke
      ..strokeWidth = thumbnail ? 2 : 3
      ..strokeCap = StrokeCap.round;
    for (var d = len * progress; d < len; d += thumbnail ? 7 : 12) {
      canvas.drawPath(
          metric.extractPath(d, math.min(d + (thumbnail ? 3.5 : 6), len)),
          remaining);
    }

    // Lo recorrido: oro, con un halo suave.
    if (progress > 0) {
      final done = metric.extractPath(0, len * progress);
      canvas.drawPath(
          done,
          Paint()
            ..color = AppColors.gold.withValues(alpha: 0.25)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 10
            ..strokeCap = StrokeCap.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
      canvas.drawPath(
          done,
          Paint()
            ..color = AppColors.gold
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4
            ..strokeCap = StrokeCap.round);
    }

    final start = metric.getTangentForOffset(0)!.position;
    final end = metric.getTangentForOffset(len)!.position;
    _dot(canvas, start, thumbnail ? 3.5 : 6, ArtColors.city, AppColors.outline);
    if (thumbnail) {
      _dot(canvas, end, 4, AppColors.gold, AppColors.outline);
      return;
    }
    _flag(canvas, end, progress >= 1);

    final m = mission;
    if (m == null) return;

    // Eventos: hitos sobre el camino.
    for (final (i, mark) in eventMarks(m).indexed) {
      final e = m.events[i];
      final pos = metric.getTangentForOffset(len * mark)!.position;
      final resolved = e.status == EventStatus.resolved;
      final blocking = e.isUnresolved && !now.isBefore(e.triggersAt);
      final pulse = animate && blocking
          ? 1 + 0.18 * math.sin((clock?.value ?? 0) * 5)
          : 1.0;
      if (blocking && animate) {
        canvas.drawCircle(
            pos,
            13 * pulse,
            Paint()
              ..color = AppColors.amber.withValues(alpha: 0.25)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
      }
      _dot(
        canvas,
        pos,
        6.5 * pulse,
        resolved
            ? AppColors.green
            : blocking
                ? AppColors.amber
                : AppColors.bgCard2,
        resolved ? AppColors.greenDark : AppColors.outline,
      );
    }

    // El mensajero: un medallón que avanza y "trota" (o se mece, en barco).
    final t = clock?.value ?? 0;
    final tangent = metric.getTangentForOffset(len * progress)!;
    final bob = animate && progress < 1
        ? (geometry.bySea ? math.sin(t * 2.2) * 2.2 : math.sin(t * 7) * 1.6)
        : 0.0;
    final c = tangent.position.translate(0, -16 + bob);
    canvas.drawCircle(c.translate(0, 3), 15, Paint()..color = AppColors.goldShadow);
    canvas.drawCircle(c, 15, Paint()..color = AppColors.gold);
    canvas.drawCircle(
        c,
        15,
        Paint()
          ..color = AppColors.outline
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5);
    _icon(canvas, c, geometry.bySea ? Icons.sailing : Icons.directions_run, 18,
        AppColors.outline);
  }

  // ─── Utilidades ───

  /// Curva suave (Catmull-Rom) por los puntos. Con [bend], una ruta de dos
  /// puntos se arquea un poco para no parecer una regla.
  static Path _smooth(List<Offset> pts, {required bool bend}) {
    if (pts.length == 2 && bend) {
      final a = pts[0], b = pts[1];
      final mid = Offset.lerp(a, b, 0.5)!;
      final d = b - a;
      final normal = Offset(-d.dy, d.dx) * 0.14;
      return Path()
        ..moveTo(a.dx, a.dy)
        ..quadraticBezierTo(mid.dx + normal.dx, mid.dy + normal.dy, b.dx, b.dy);
    }
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 0; i < pts.length - 1; i++) {
      final p0 = pts[math.max(0, i - 1)];
      final p1 = pts[i];
      final p2 = pts[i + 1];
      final p3 = pts[math.min(pts.length - 1, i + 2)];
      final c1 = p1 + (p2 - p0) / 6;
      final c2 = p2 - (p3 - p1) / 6;
      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    }
    return path;
  }

  static void _dashed(
      Canvas canvas, Path path, Paint paint, double on, double off) {
    for (final m in path.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += on + off) {
        canvas.drawPath(m.extractPath(d, math.min(d + on, m.length)), paint);
      }
    }
  }

  void _dot(Canvas canvas, Offset c, double r, Color fill, Color border) {
    canvas.drawCircle(c, r, Paint()..color = fill);
    canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = border
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
  }

  void _flag(Canvas canvas, Offset base, bool reached) {
    final pole = Paint()
      ..color = AppColors.outline
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final top = base.translate(0, -26);
    canvas.drawLine(base, top, pole);
    final cloth = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(top.dx + 16, top.dy + 5)
      ..lineTo(top.dx, top.dy + 11)
      ..close();
    canvas.drawPath(
        cloth, Paint()..color = reached ? AppColors.gold : AppColors.amber);
    canvas.drawPath(
        cloth,
        Paint()
          ..color = AppColors.outline
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);
    _dot(canvas, base, 5, AppColors.gold, AppColors.outline);
  }

  void _icon(Canvas canvas, Offset c, IconData icon, double size, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          fontSize: size,
          color: color,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(RouteMapPainter old) =>
      old.mission != mission ||
      old.geometry != geometry ||
      old.animate != animate;
}

class _Camera {
  final double scale;
  final Offset center;
  final Size size;
  final double aspect;
  const _Camera(this.scale, this.center, this.size, this.aspect);

  Offset map(MapPoint p) => Offset(
        (p.x * aspect - center.dx) * scale + size.width / 2,
        (p.y - center.dy) * scale + size.height / 2,
      );
}
