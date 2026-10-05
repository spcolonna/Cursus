import '../entities/entities.dart';
import '../entities/guild.dart';
import '../entities/notifications.dart';
import '../entities/world.dart';
import '../entities/content.dart';

abstract class AuthRepository {
  Future<User?> getCurrentUser();
  Future<User> signIn({required String name});
  Future<void> signOut();
  Future<bool> isFirstLogin();
  Future<void> markOnboardingDone();
}

abstract class MessengerRepository {
  // Lista completa de mensajeros del jugador
  Future<List<Messenger>> getAllMessengers();
  Future<Messenger?> getMessenger();          // retrocompat — devuelve el primero
  Future<void> saveMessenger(Messenger messenger);
  Future<void> saveAllMessengers(List<Messenger> messengers);
  Future<Messenger> createDefaultWithGender(String name, MessengerGender gender);
  // Desbloquear un slot adicional (descuenta Aureos del mensajero principal)
  Future<Messenger> unlockSlot({
    required Messenger payer,        // mensajero que paga los Aureos
    required String newName,
    required MessengerGender gender,
    required int slotIndex,
  });
}

abstract class MissionRepository {
  Future<Mission?> getActiveMissionFor(String messengerId);    // por mensajero específico
  Future<List<Mission>> getAllActiveMissions();                 // todas las misiones activas
  Future<void> saveMission(Mission mission);
  Future<void> completeMission(String missionId, MissionResult result);
  Future<List<Mission>> getCompletedMissions();
  // Las rutas pueden requerir flags de historia (ej. la ruta nocturna).
  Future<List<GameRoute>> getAvailableRoutes(int messengerRank,
      {Set<String> flags});
  Future<Mission> createMission(GameRoute route, String messengerId, {bool revealEvents});
  Future<Mission> createTutorialMission(int index, String messengerId);
  // Misión de historia: eventos fijos, arcId/epilogue seteados.
  Future<Mission> createStoryMission(StoryMissionConfig config, String messengerId);
}

abstract class GuildRepository {
  /// Estado del gremio para hoy. Si cambió el día, genera el tablón nuevo
  /// conservando la racha de paga.
  Future<GuildState> getState();
  Future<void> saveState(GuildState state);
}

abstract class WorldRepository {
  /// Estado narrativo de la cuenta (reputación, flags, diario, arcos).
  Future<WorldState> getState();
  Future<void> saveState(WorldState state);
}

/// Avisos locales: el juego busca al jugador entre sesión y sesión.
/// El dominio solo conoce este contrato; la implementación con
/// flutter_local_notifications vive en infrastructure/.
abstract class NotificationScheduler {
  Future<void> init();

  Future<NotificationPermission> permissionStatus();

  /// Se pide con contexto narrativo (GDD §7), nunca en frío al abrir la app.
  Future<bool> requestPermission();

  Future<NotificationPrefs> getPrefs();
  Future<void> savePrefs(NotificationPrefs prefs);

  /// Deja programados los avisos de [mission]: los próximos eventos y la
  /// entrega. Reemplaza lo que hubiera de esa misión — se llama tanto al
  /// aceptarla como cada vez que se corre el reloj (resolver, adelantar).
  Future<void> syncMission(Mission mission, {required String messengerName});

  Future<void> cancelMission(String missionId);

  /// Recordatorios fuera de misión: mensajero ocioso ([idleMessengerName]
  /// null si todos están en ruta) y contratos del gremio sin cobrar.
  Future<void> syncReminders(
      {String? idleMessengerName, required bool contractsPending});

  /// Payload del aviso con el que se abrió la app en frío, si hubo uno.
  Future<String?> launchPayload();

  /// Se llama con el payload cada vez que el jugador toca un aviso con la
  /// app ya abierta (o en segundo plano).
  set onTap(void Function(String payload)? handler);

  Future<void> cancelAll();

  /// Lo que hay programado ahora (panel de diagnóstico).
  Future<List<ScheduledNotification>> pending();

  /// Dispara un aviso de prueba dentro de [delay]. Solo para verificar en el
  /// dispositivo que las notificaciones efectivamente llegan.
  Future<void> fireTestNotification({Duration delay});
}