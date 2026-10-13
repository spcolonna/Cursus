import 'package:firebase_analytics/firebase_analytics.dart';

import '../../domain/entities/analytics.dart';
import '../../domain/repositories/repositories.dart';
import 'analytics_service.dart';

/// Manda los eventos a Firebase Analytics. Los nombres y parámetros ya
/// vienen validados contra los límites de Firebase (`AnalyticsEvent.isValid`).
class FirebaseAnalyticsSink implements AnalyticsSink, AnalyticsCollectionControl {
  FirebaseAnalytics get _fa => FirebaseAnalytics.instance;

  @override
  Future<void> log(AnalyticsEvent event) =>
      _fa.logEvent(name: event.name, parameters: event.params);

  @override
  Future<void> setUserProperty(String name, String? value) =>
      _fa.setUserProperty(name: name, value: value);

  /// El opt-out de Ajustes también apaga lo que Firebase mide solo
  /// (first_open, session_start, screen_view).
  @override
  Future<void> setCollectionEnabled(bool enabled) =>
      _fa.setAnalyticsCollectionEnabled(enabled);
}
