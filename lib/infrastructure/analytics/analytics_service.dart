import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/analytics.dart';
import '../../domain/repositories/repositories.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Salidas de analytics. Hoy: consola (debug) y un buffer en el dispositivo
// que un tester puede copiar desde Ajustes. Para Firebase se agrega un sink
// más a la lista (ver docs/ANALYTICS.md) sin tocar ningún otro archivo.
// ─────────────────────────────────────────────────────────────────────────────

/// Fachada que usa la app: reparte a todos los sinks, respeta el opt-out y
/// nunca tira.
class AnalyticsService implements AnalyticsSink {
  final List<AnalyticsSink> sinks;
  bool enabled;
  AnalyticsService(this.sinks, {this.enabled = true});

  /// Disparar y olvidar, para los notifiers.
  void track(AnalyticsEvent event) {
    log(event);
  }

  @override
  Future<void> log(AnalyticsEvent event) async {
    assert(event.isValid, 'Evento de analytics inválido: $event');
    if (!enabled || !event.isValid) return;
    for (final s in sinks) {
      try {
        await s.log(event);
      } catch (_) {
        // Medir nunca rompe el juego.
      }
    }
  }

  final Map<String, String?> _props = {};

  /// Solo manda la propiedad si cambió: el Home la fija en cada refresco.
  @override
  Future<void> setUserProperty(String name, String? value) async {
    if (!enabled) return;
    if (_props.containsKey(name) && _props[name] == value) return;
    _props[name] = value;
    for (final s in sinks) {
      try {
        await s.setUserProperty(name, value);
      } catch (_) {}
    }
  }
}

/// Imprime cada evento en modo debug. En release no hace nada.
class ConsoleAnalyticsSink implements AnalyticsSink {
  @override
  Future<void> log(AnalyticsEvent event) async {
    if (kDebugMode) debugPrint('[analytics] $event');
  }

  @override
  Future<void> setUserProperty(String name, String? value) async {
    if (kDebugMode) debugPrint('[analytics] user.$name = $value');
  }
}

/// Últimos [capacity] eventos con su hora, guardados en el dispositivo.
/// Sirve para la beta cerrada antes de tener Firebase: el tester copia el
/// JSON desde Ajustes y lo manda.
class LocalBufferAnalyticsSink implements AnalyticsSink {
  static const _kBuffer = 'analytics_buffer_v2';
  static const _kProps = 'analytics_props_v2';
  final int capacity;
  LocalBufferAnalyticsSink({this.capacity = 500});

  List<Map<String, dynamic>>? _events;
  Map<String, String>? _props;
  Future<void> _pending = Future.value();

  Future<void> _ensureLoaded() async {
    if (_events != null) return;
    final p = await SharedPreferences.getInstance();
    try {
      _events = (jsonDecode(p.getString(_kBuffer) ?? '[]') as List)
          .cast<Map<String, dynamic>>();
      _props = (jsonDecode(p.getString(_kProps) ?? '{}') as Map)
          .cast<String, String>();
    } catch (_) {
      _events = [];
      _props = {};
    }
  }

  /// Las escrituras van en fila para que dos eventos seguidos no se pisen.
  Future<void> _enqueue(Future<void> Function() job) =>
      _pending = _pending.then((_) => job()).catchError((_) {});

  @override
  Future<void> log(AnalyticsEvent event) => _enqueue(() async {
        await _ensureLoaded();
        _events!
            .add({'t': DateTime.now().toIso8601String(), ...event.toJson()});
        if (_events!.length > capacity) {
          _events!.removeRange(0, _events!.length - capacity);
        }
        final p = await SharedPreferences.getInstance();
        await p.setString(_kBuffer, jsonEncode(_events));
      });

  @override
  Future<void> setUserProperty(String name, String? value) =>
      _enqueue(() async {
        await _ensureLoaded();
        if (value == null) {
          _props!.remove(name);
        } else {
          _props![name] = value;
        }
        final p = await SharedPreferences.getInstance();
        await p.setString(_kProps, jsonEncode(_props));
      });

  /// Todo lo guardado, listo para pegar en un mensaje.
  Future<String> export(RetentionLog? retention) async {
    await _pending;
    await _ensureLoaded();
    return const JsonEncoder.withIndent(' ').convert({
      'exportedAt': DateTime.now().toIso8601String(),
      'userProperties': _props,
      if (retention != null) 'retention': retention.toJson(),
      'events': _events,
    });
  }

  Future<void> clear() => _enqueue(() async {
        _events = [];
        final p = await SharedPreferences.getInstance();
        await p.remove(_kBuffer);
      });
}
