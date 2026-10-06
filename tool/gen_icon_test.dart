// tool/gen_icon_test.dart
//
// Genera los PNG de la marca a partir de BrandSealPainter, para que el
// ícono y el launch screen salgan del mismo dibujo que la app:
//
//   flutter test tool/gen_icon_test.dart
//   dart run flutter_launcher_icons && dart run flutter_native_splash:create

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_messenger/presentation/widgets/brand.dart';

Future<void> _render(String path, double size, CustomPainter painter,
    {double padding = 0}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.translate(padding, padding);
  painter.paint(canvas, Size.square(size - padding * 2));
  final image = await recorder.endRecording().toImage(size.toInt(), size.toInt());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path).writeAsBytesSync(bytes!.buffer.asUint8List());
}

void main() {
  test('genera los PNG de la marca', () async {
    // Ícono completo (iOS no admite transparencia): sello sobre cal.
    await _render('assets/icon/icon.png', 1024,
        const BrandSealPainter(withBackground: true));
    // Primer plano del ícono adaptativo de Android: zona segura del 66%.
    await _render('assets/icon/icon_foreground.png', 1024,
        const BrandSealPainter(),
        padding: 1024 * 0.25);
    // Sello del launch screen nativo.
    await _render('assets/icon/splash_seal.png', 768, const BrandSealPainter(),
        padding: 768 * 0.2);
    expect(File('assets/icon/icon.png').existsSync(), isTrue);
  });
}
