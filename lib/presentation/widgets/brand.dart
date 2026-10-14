// lib/presentation/widgets/brand.dart
//
// La marca de Cursus: el sello de cera cinabrio con la V de *via* y el
// wordmark en capitales romanas. Todo por código: el mismo pintor sirve
// para la app, el splash y el ícono (tool/gen_icon_test.dart).

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

/// Nombre del juego tal como se muestra.
const String kGameName = 'Cursus';


/// El sello de la marca: cera cinabrio plana, contorno de tinta y una V
/// romana grabada. Más sobrio que el sello del juego ([paintWaxSeal]): sin
/// brillo, para que se lea a 64 px.
class BrandSealPainter extends CustomPainter {
  /// Fondo cuadrado de cal detrás del sello (para el ícono de la app).
  final bool withBackground;
  const BrandSealPainter({this.withBackground = false});

  /// Borde de la gota de cera: [lobes] ondas suaves, sin picos.
  static Path dropPath(Offset c, double r, {int lobes = 9}) {
    final path = Path();
    const steps = 360;
    for (var i = 0; i <= steps; i++) {
      final a = i / steps * 2 * math.pi;
      final rr = r *
          (1 + 0.045 * math.cos(a * lobes) + 0.02 * math.sin(a * 2 + 0.7));
      final p = Offset(c.dx + math.sin(a) * rr, c.dy - math.cos(a) * rr);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    return path..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final c = size.center(Offset.zero);
    if (withBackground) {
      canvas.drawRect(Offset.zero & size, Paint()..color = AppColors.paper);
    }
    final r = s / 2 * (withBackground ? 0.72 : 0.9);
    final line = math.max(1.2, s * 0.022);
    final drop = dropPath(c, r);
    // Sombra dura de la cera, el cuerpo y el contorno de tinta.
    canvas.drawPath(drop.shift(Offset(0, r * 0.06)), Paint()..color = AppColors.ink);
    canvas.drawPath(drop, Paint()..color = AppColors.cinnabar);
    // La huella de la matriz: un anillo hundido y el disco interior.
    canvas.drawCircle(c, r * 0.72, Paint()..color = AppColors.cinnabarDeep);
    canvas.drawCircle(c, r * 0.64, Paint()..color = AppColors.cinnabarLight);
    canvas.drawCircle(c.translate(r * 0.02, r * 0.03), r * 0.62,
        Paint()..color = AppColors.cinnabar);
    canvas.drawPath(
        drop,
        Paint()
          ..color = AppColors.ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = line
          ..strokeJoin = StrokeJoin.round);
    _paintV(canvas, c.translate(0, r * 0.02), r * 0.78);
  }

  /// V capital de inscripción: trazo izquierdo grueso, derecho fino,
  /// remates planos. Grabada: hueco oscuro y un filo de luz abajo.
  void _paintV(Canvas canvas, Offset c, double h) {
    final top = c.dy - h * 0.42;
    final bottom = c.dy + h * 0.44;
    final halfW = h * 0.42;
    final thick = h * 0.17;
    final thin = h * 0.07;
    final left = c.dx - halfW, right = c.dx + halfW;
    // Pie de la V: el grueso llega un poco antes que el fino.
    final x0 = c.dx - thick * 0.45, x1 = c.dx + thin * 0.9;

    Offset meet(Offset a1, Offset a2, Offset b1, Offset b2) {
      final d = (a1.dx - a2.dx) * (b1.dy - b2.dy) - (a1.dy - a2.dy) * (b1.dx - b2.dx);
      final t = ((a1.dx - b1.dx) * (b1.dy - b2.dy) - (a1.dy - b1.dy) * (b1.dx - b2.dx)) / d;
      return Offset(a1.dx + t * (a2.dx - a1.dx), a1.dy + t * (a2.dy - a1.dy));
    }

    final inner = meet(Offset(left + thick, top), Offset(x0 + thick, bottom),
        Offset(right - thin, top), Offset(x1 - thin, bottom));
    final v = Path()
      ..moveTo(left, top)
      ..lineTo(left + thick, top)
      ..lineTo(inner.dx, inner.dy)
      ..lineTo(right - thin, top)
      ..lineTo(right, top)
      ..lineTo(x1, bottom)
      ..lineTo(x0, bottom)
      ..close();
    final serifH = h * 0.05, serifOut = h * 0.07;
    v
      ..addRect(Rect.fromLTRB(
          left - serifOut, top - serifH, left + thick + serifOut, top))
      ..addRect(Rect.fromLTRB(
          right - thin - serifOut, top - serifH, right + serifOut * 0.8, top));
    final edge = math.max(1.0, h * 0.035);
    canvas.drawPath(v.shift(Offset(0, edge)), Paint()..color = AppColors.cinnabarLight);
    canvas.drawPath(v, Paint()..color = AppColors.cinnabarDeep);
  }

  @override
  bool shouldRepaint(BrandSealPainter old) =>
      old.withBackground != withBackground;
}

/// Solo el sello.
class BrandSeal extends StatelessWidget {
  final double size;
  const BrandSeal({super.key, this.size = 56});

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: size,
        child: const CustomPaint(painter: BrandSealPainter()),
      );
}

/// stacked: sello arriba · horizontal: sello al costado · wordmark: solo el
/// texto (cuando el sello ya está en pantalla).
enum BrandLayout { stacked, horizontal, wordmark }

/// Sello + CURSUS (+ el subtítulo, si [tagline]).
class BrandMark extends StatelessWidget {
  final BrandLayout layout;
  final double size; // alto del wordmark
  final bool tagline;
  /// Color del texto: cal sobre fondos oscuros, tinta sobre papel.
  final Color color;

  /// Sombras del texto (el halo del título sobre el cielo).
  final List<Shadow>? shadows;
  const BrandMark({
    super.key,
    this.layout = BrandLayout.stacked,
    this.size = 40,
    this.tagline = false,
    this.color = AppColors.paper,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final word = Text(
      kGameName.toUpperCase(),
      maxLines: 1,
      softWrap: false,
      style: AppTextStyles.brandWordmark(size, color).copyWith(shadows: shadows),
    );
    final taglineText = AppLocalizations.of(context).brandTagline;
    final sub = Text(
      taglineText.toUpperCase(),
      style: AppTextStyles.brandTagline(size * 0.3, color),
    );
    final text = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: layout != BrandLayout.horizontal
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [word, if (tagline) ...[SizedBox(height: size * 0.25), sub]],
    );
    return Semantics(
      label: '$kGameName, $taglineText',
      excludeSemantics: true,
      child: switch (layout) {
        BrandLayout.wordmark => text,
        BrandLayout.stacked => Column(mainAxisSize: MainAxisSize.min, children: [
              BrandSeal(size: size * 2.6),
              SizedBox(height: size * 0.45),
              text,
            ]),
        BrandLayout.horizontal => Row(mainAxisSize: MainAxisSize.min, children: [
              BrandSeal(size: size * 1.35),
              SizedBox(width: size * 0.35),
              Flexible(child: FittedBox(fit: BoxFit.scaleDown, child: text)),
            ]),
      },
    );
  }
}
