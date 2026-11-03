import '../entities/entities.dart';
import '../entities/guild.dart';
import '../entities/notifications.dart';
import '../entities/world.dart';
import '../entities/content.dart';
import '../entities/progression.dart';
import '../entities/weekly.dart';
import '../entities/analytics.dart';
import '../entities/remote_flags.dart';
import '../entities/save_snapshot.dart';

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
  // Las rutas pueden pedir flags de historia (la nocturna) o reputación con
  // la facción que las encarga.
  Future<List<GameRoute>> getAvailableRoutes(int messengerRank, WorldState world);
  /// [eventIds] son los eventos ya elegidos (ver `pickEventsForMission`);
  /// sin ellos, se sortean del pool de la ruta.
  Future<Mission> createMission(GameRoute route, String messengerId,
      {bool revealEvents, double payFactor, List<String>? eventIds});
  Future<Mission> createTutorialMission(int index, String messengerId);
  // Misión de historia: eventos fijos, arcId/epilogue seteados.
  Future<Mission> createStoryMission(StoryMissionConfig config,
      String messengerId, List<RealEventConfig> events);
}

abstract class GuildRepository {
  /// Estado del gremio para hoy. Si cambió el día, genera el tablón nuevo
  /// conservando la racha de paga.
  Future<GuildState> getState();
  Future<void> saveState(GuildState state);
}

/// Progresión de la cuenta: estadísticas, logros y títulos.
abstract class ProgressionRepository {
  /// null si la partida es anterior a la progresión v2 (hay que migrarla).
  Future<ProgressionState?> load();
  Future<void> save(ProgressionState state);
  /// Títulos del esquema viejo, para migrarlos una sola vez.
  Future<({List<String> titles, String? equipped})> legacyTitles();
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

  /// Cancela los avisos de toda misión que ya no esté en [activeMissionIds]
  /// (entregada, abandonada o de una partida anterior).
  Future<void> keepOnlyMissions(Set<String> activeMissionIds);

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

/// Encargos semanales. null = nunca se guardó.
abstract class WeeklyRepository {
  Future<WeeklyState?> load();
  Future<void> save(WeeklyState state);
}

/// Adónde van los eventos de analytics (Firebase, consola, buffer local).
/// Nunca debe tirar: medir no puede romper una acción del jugador.
abstract class AnalyticsSink {
  Future<void> log(AnalyticsEvent event);
  Future<void> setUserProperty(String name, String? value);
}

/// Ajustes remotos. [current] siempre responde (defaults o lo último
/// activado); [refresh] busca valores nuevos para la próxima vez y nunca tira.
abstract class RemoteFlagsSource {
  RemoteFlags get current;
  Future<void> refresh();
}

/// Días activos y sesiones de este dispositivo. null = primera apertura.
abstract class RetentionRepository {
  Future<RetentionLog?> load();
  Future<void> save(RetentionLog log);
}

// ─── Cuenta y guardado en la nube ─────────────────────────────────────────────

enum AccountProvider { google, apple }

/// La identidad en la nube. Arranca anónima e invisible; vincular con Google
/// o Apple permite recuperar la partida en otro dispositivo.
abstract class CloudAccount {
  String? get uid;
  bool get isAnonymous;
  Set<AccountProvider> get linkedProviders;

  /// Asegura una sesión (anónima si no hay ninguna). Devuelve el uid o null
  /// sin red o sin Auth habilitado.
  Future<String?> ensureSignedIn();

  /// Vincula la cuenta anónima actual. Si esa cuenta de Google/Apple ya
  /// tenía partida, entra en ella y devuelve [LinkOutcome.switchedAccount].
  Future<LinkOutcome> link(AccountProvider provider);

  /// Entra con una cuenta existente (bienvenida: "Ya tengo partida").
  Future<LinkOutcome> signInWith(AccountProvider provider);

  /// Borra la cuenta de Auth (reautentica si hace falta).
  Future<void> deleteAccount();
  Future<void> signOut();
}

enum LinkOutcome { linked, switchedAccount, canceled }

abstract class CloudSaveRemote {
  Future<SaveSnapshot?> fetch(String uid);

  /// Sube la partida y devuelve la revisión con la que quedó.
  Future<int> put(String uid, SaveSnapshot snapshot);
  Future<void> delete(String uid);
}
