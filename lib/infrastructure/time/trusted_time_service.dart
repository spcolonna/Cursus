import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/game_clock.dart';

/// Un punto de referencia: a esta hora del juego, el reloj monotónico del
/// sistema (que no se puede tocar y sigue contando con el teléfono
/// dormido) marcaba [elapsedMs].
class ClockAnchor {
  final DateTime gameTime;
  final int elapsedMs;
  const ClockAnchor(this.gameTime, this.elapsedMs);
}

/// Estima la hora del juego sin red.
/// - Mismo encendido del teléfono: ancla + tiempo monotónico transcurrido.
///   Cambiar la hora del teléfono no mueve nada.
/// - Si se reinició (el monotónico volvió a cero) o no hay monotónico: hora
///   del dispositivo + la última diferencia con el servidor, y nunca antes
///   del ancla.
DateTime estimateGameTime({
  required DateTime deviceNow,
  required Duration lastSkew,
  ClockAnchor? anchor,
  int? elapsedMs,
}) {
  if (anchor != null && elapsedMs != null && elapsedMs >= anchor.elapsedMs) {
    return anchor.gameTime
        .add(Duration(milliseconds: elapsedMs - anchor.elapsedMs));
  }
  final guess = deviceNow.add(lastSkew);
  if (anchor != null && guess.isBefore(anchor.gameTime)) return anchor.gameTime;
  return guess;
}

/// Mantiene [GameClock] confiable: al arrancar y al volver de segundo plano
/// estima la hora con el ancla guardada y después la corrige con la hora
/// del servidor (cabecera Date de HTTPS: no necesita cuenta ni Firebase).
class TrustedTimeService {
  static const _kAnchorGame = 'clock_anchor_game_ms_v1';
  static const _kAnchorElapsed = 'clock_anchor_elapsed_ms_v1';
  static const _kSkew = 'clock_skew_ms_v1';
  static const _channel = MethodChannel('cursus/clock');

  final Future<int?> Function() elapsedMs;
  final Future<DateTime?> Function() serverTime;
  final DateTime Function() deviceNow;

  TrustedTimeService({
    Future<int?> Function()? elapsedMs,
    Future<DateTime?> Function()? serverTime,
    DateTime Function()? deviceNow,
  })  : elapsedMs = elapsedMs ?? _nativeElapsed,
        serverTime = serverTime ?? fetchServerTime,
        deviceNow = deviceNow ?? DateTime.now;

  /// Estima ya (rápido, sin red) y guarda el ancla.
  Future<void> restore() async {
    final p = await SharedPreferences.getInstance();
    final elapsed = await elapsedMs();
    final game = estimateGameTime(
      deviceNow: deviceNow(),
      lastSkew: Duration(milliseconds: p.getInt(_kSkew) ?? 0),
      anchor: _readAnchor(p),
      elapsedMs: elapsed,
    );
    GameClock.setBase(game);
    await _save(p, game, elapsed);
  }

  /// Corrige con el servidor. Sin red no hace nada (queda la estimación).
  Future<bool> syncWithServer() async {
    final server = await serverTime();
    if (server == null) return false;
    final p = await SharedPreferences.getInstance();
    GameClock.setBase(server);
    await _save(p, server, await elapsedMs());
    return true;
  }

  /// Al abrir o volver: estimación inmediata y corrección en segundo plano.
  Future<void> refresh() async {
    await restore();
    unawaited(syncWithServer());
  }

  Future<void> _save(SharedPreferences p, DateTime game, int? elapsed) async {
    await p.setInt(
        _kSkew, game.difference(deviceNow()).inMilliseconds);
    if (elapsed == null) return;
    await p.setInt(_kAnchorGame, game.millisecondsSinceEpoch);
    await p.setInt(_kAnchorElapsed, elapsed);
  }

  ClockAnchor? _readAnchor(SharedPreferences p) {
    final game = p.getInt(_kAnchorGame);
    final elapsed = p.getInt(_kAnchorElapsed);
    if (game == null || elapsed == null) return null;
    return ClockAnchor(DateTime.fromMillisecondsSinceEpoch(game), elapsed);
  }

  static Future<int?> _nativeElapsed() async {
    try {
      return await _channel.invokeMethod<int>('elapsedRealtime');
    } catch (_) {
      return null; // tests o plataforma sin el canal
    }
  }

  /// Hora del servidor por la cabecera Date de una respuesta HTTPS, con la
  /// mitad de la ida y vuelta sumada.
  static Future<DateTime?> fetchServerTime() async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 4);
    try {
      final sw = Stopwatch()..start();
      final req = await client
          .headUrl(Uri.parse('https://www.google.com/generate_204'))
          .timeout(const Duration(seconds: 4));
      final res = await req.close().timeout(const Duration(seconds: 4));
      sw.stop();
      final date = res.headers.date;
      if (date == null) return null;
      return date.add(sw.elapsed ~/ 2).toLocal();
    } catch (e) {
      debugPrint('Server time: $e');
      return null;
    } finally {
      client.close(force: true);
    }
  }
}
