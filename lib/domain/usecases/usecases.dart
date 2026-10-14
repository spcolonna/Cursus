import 'dart:math';
import '../entities/entities.dart';
import '../entities/guild.dart';
import '../entities/skill_tree.dart';
import '../entities/world.dart';
import '../entities/content.dart';
import '../entities/notifications.dart';
import '../entities/progression.dart';
import 'event_selection.dart';
import 'forecast.dart';
import '../repositories/content_catalog.dart';
import '../repositories/repositories.dart';
import '../entities/game_clock.dart';

// ─── Sign In ──────────────────────────────────────────────────────────────────
class SignInUseCase {
  final AuthRepository _auth;
  SignInUseCase(this._auth);

  /// Modo invitado inmediato (GDD §7). Auth real llega con Firebase (Fase 4).
  Future<({User user, bool isFirstLogin})> executeAsGuest({
    String displayName = 'Mensajero',
  }) async {
    final user = await _auth.signIn(name: displayName.trim().isEmpty
        ? 'Mensajero'
        : displayName.trim());
    final isFirst = await _auth.isFirstLogin();
    return (user: user, isFirstLogin: isFirst);
  }
}

// ─── Home State ───────────────────────────────────────────────────────────────
// Un slot por mensajero — cada uno puede tener su propia misión activa
class MessengerSlot {
  final Messenger messenger;
  final Mission? activeMission;
  final MissionEvent? pendingEvent;
  final TutorialMission? nextTutorial;
  final List<GameRoute> availableRoutes;

  const MessengerSlot({
    required this.messenger,
    this.activeMission,
    this.pendingEvent,
    this.nextTutorial,
    this.availableRoutes = const [],
  });
}

/// Lo que toca jugar en la historia: el arco, su capítulo y el rango que pide.
class StoryStep {
  final StoryArcDef arc;
  final StoryMissionConfig chapter;
  final int requiredRank;
  const StoryStep(this.arc, this.chapter, this.requiredRank);
}

/// Próximo capítulo de la historia según el mundo, o null si no queda
/// ninguno abierto. Los arcos se juegan en orden: uno que pide otro arco
/// terminado espera a que se cierre.
StoryStep? nextStoryStep(GameContentCatalog content, WorldState world) {
  for (final arc in content.arcs) {
    if (world.arcCompleted(arc.id)) continue;
    if (arc.requiredArc != null && !world.arcCompleted(arc.requiredArc!)) {
      continue;
    }
    final stage = world.arcProgress[arc.id] ?? 0;
    if (stage >= arc.stageCount) continue;
    final chapter = content.storyMissionFor(arc.id, stage, world.flags);
    if (chapter == null) continue;
    return StoryStep(arc, chapter, max(arc.minRank, chapter.minRank));
  }
  return null;
}

class HomeState {
  final List<MessengerSlot> slots;
  // Próximo capítulo de historia disponible (lo juega el mensajero principal).
  final StoryMissionConfig? nextStoryMission;
  /// Título del arco de [nextStoryMission].
  final String? storyArcTitle;
  /// Capítulo que sigue pero pide más rango: el Home lo muestra cerrado,
  /// para que el jugador sepa que la historia sigue y qué le falta.
  final StoryStep? lockedStory;
  /// Eventos que se resolvieron solos mientras el jugador no estaba mirando.
  /// El Home tiene que avisarlo: pasó algo y no fue decisión suya.
  final List<AutoResolvedEvent> autoResolved;

  const HomeState({
    required this.slots,
    this.nextStoryMission,
    this.storyArcTitle,
    this.lockedStory,
    this.autoResolved = const [],
  });

  // Retrocompat — primer mensajero
  Messenger? get messenger => slots.isEmpty ? null : slots.first.messenger;
  Mission? get activeMission => slots.isEmpty ? null : slots.first.activeMission;
  MissionEvent? get pendingEvent => slots.isEmpty ? null : slots.first.pendingEvent;
  TutorialMission? get nextTutorial => slots.isEmpty ? null : slots.first.nextTutorial;
  List<GameRoute> get availableRoutes => slots.isEmpty ? [] : slots.first.availableRoutes;

  /// Slot del mensajero [messengerId]; sin id (o si ya no existe), el principal.
  MessengerSlot? slotFor(String? messengerId) {
    if (slots.isEmpty) return null;
    return slots.where((s) => s.messenger.id == messengerId).firstOrNull ??
        slots.first;
  }

  bool get tutorialDone => messenger?.tutorialComplete ?? false;

  // ¿Se puede desbloquear un nuevo slot?
  bool get canUnlockNextSlot {
    final primaryDone = messenger?.tutorialComplete ?? false;
    final nextSlot = slots.length;
    final required = messengerSlotRequiredTutorials[nextSlot] ?? 999;
    return primaryDone &&
        (messenger?.tutorialMissionIndex ?? 0) >= required &&
        messengerSlotCosts.containsKey(nextSlot);
  }

  int get nextSlotCost => messengerSlotCosts[slots.length] ?? 999;
}

/// Un evento que se resolvió por instinto: el jugador no llegó a decidir.
class AutoResolvedEvent {
  final String messengerName;
  final String eventTitle;
  final String chosenOptionText;
  const AutoResolvedEvent({
    required this.messengerName,
    required this.eventTitle,
    required this.chosenOptionText,
  });
}

// ─── Get Home State ───────────────────────────────────────────────────────────
class GetHomeStateUseCase {
  final MessengerRepository _messenger;
  final MissionRepository _mission;
  final WorldRepository _world;
  final GameContentCatalog _content;
  GetHomeStateUseCase(
      this._messenger, this._mission, this._world, this._content);

  /// Solo lee. [autoResolved] es lo que devolvió
  /// [AutoResolveExpiredEventsUseCase] justo antes, para avisarle al jugador.
  Future<HomeState> execute(
      {List<AutoResolvedEvent> autoResolved = const []}) async {
    final messengers = await _messenger.getAllMessengers();
    if (messengers.isEmpty) {
      return const HomeState(slots: []);
    }
    final world = await _world.getState();

    final activeMissions = await _mission.getAllActiveMissions();

    final slots = <MessengerSlot>[];

    for (final m in messengers) {
      final activeMission = activeMissions
          .where((x) => x.messengerId == m.id)
          .firstOrNull;

      List<GameRoute> availableRoutes = [];
      TutorialMission? nextTutorial;

      if (activeMission == null) {
        if (!m.tutorialComplete) {
          final idx = m.tutorialMissionIndex;
          final tutorials = _content.tutorialMissions;
          if (idx < tutorials.length) {
            nextTutorial = tutorials[idx];
          }
        } else {
          availableRoutes = [
            for (final r in await _mission.getAvailableRoutes(m.rank, world))
              r.patron != null &&
                      hasFactionPerk(_content.factionUnlocks, world,
                          FactionPerk.patronPay,
                          faction: r.patron)
                  ? r.copyWith(payBonus: kPatronPayBonus)
                  : r
          ];
        }
      }

      slots.add(MessengerSlot(
        messenger: m,
        activeMission: activeMission,
        pendingEvent: activeMission?.pendingEvent,
        nextTutorial: nextTutorial,
        availableRoutes: availableRoutes,
      ));
    }

    // Historia: próximo capítulo, si el mensajero principal está libre.
    StoryStep? step;
    final primary = messengers.first;
    final primaryBusy =
        activeMissions.any((x) => x.messengerId == primary.id);
    if (primary.tutorialComplete && !primaryBusy) {
      step = nextStoryStep(_content, world);
    }
    final open = step != null && primary.rank >= step.requiredRank;
    // El primer capítulo de todos no se anuncia cerrado: recién salido del
    // tutorial, el jugador tiene que aprender las rutas primero.
    final teaser = step != null &&
        !open &&
        (step.chapter.stage > 0 || step.arc.requiredArc != null);

    return HomeState(
      slots: slots,
      nextStoryMission: open ? step.chapter : null,
      storyArcTitle: step?.arc.title,
      lockedStory: teaser ? step : null,
      autoResolved: autoResolved,
    );
  }
}

// ─── Reparación de arcos ──────────────────────────────────────────────────────
// Partidas viejas: si el evento que decidía el camino se auto-resolvió antes
// de que la auto-resolución aplicara flags, el arco quedó sin flag de camino.
// El catálogo cae en la variante por defecto; acá se deja el mundo coherente
// con esa variante (flag puesto y una línea de diario).
class RepairArcStateUseCase {
  final WorldRepository _world;
  final GameContentCatalog _content;
  RepairArcStateUseCase(this._world, this._content);

  /// Devuelve true si tuvo que reparar algo.
  Future<bool> execute() async {
    var world = await _world.getState();
    var repaired = false;
    for (final arc in _content.arcs) {
      if (world.arcCompleted(arc.id)) continue;
      final stage = world.arcProgress[arc.id] ?? 0;
      // Solo los arcos en curso: uno sin empezar todavía no tiene camino.
      if (stage == 0 || stage >= arc.stageCount) continue;

      final chapter = _content.storyMissionFor(arc.id, stage, world.flags);
      final missing = chapter?.requiredFlag;
      if (missing == null || world.hasFlag(missing)) continue;

      world = world.applyChoiceEffects(
        setFlags: [missing],
        journalNote: 'Las cosas se acomodaron solas mientras no mirabas. '
            'El camino siguió por donde siguió.',
      );
      repaired = true;
    }
    if (repaired) await _world.saveState(world);
    return repaired;
  }
}

// ─── Auto-resolución ─────────────────────────────────────────────────────────
// Eventos cuya ventana de decisión venció se resuelven solos con la opción más
// segura, a resultado parcial. Evita misiones congeladas para siempre si el
// jugador no abre la app. Escribe en disco: se corre antes de leer el Home.
class AutoResolveExpiredEventsUseCase {
  final MessengerRepository _messenger;
  final MissionRepository _mission;
  final WorldRepository _world;
  AutoResolveExpiredEventsUseCase(this._messenger, this._mission, this._world);

  Future<List<AutoResolvedEvent>> execute({DateTime? now}) async {
    final report = <AutoResolvedEvent>[];
    final missions = await _mission.getAllActiveMissions();
    if (missions.isEmpty) return report;
    final messengers = await _messenger.getAllMessengers();
    for (final mission in missions) {
      // Se relee por misión: la anterior pudo haber dejado flags nuevos.
      final world = await _world.getState();
      await _autoResolveExpired(
          mission, messengers, world, now ?? GameClock.now(), report);
    }
    return report;
  }

  /// Resuelve automáticamente los eventos con ventana de decisión vencida
  /// (no aplica a tutoriales: sus ventanas son de minutos y son guiados).
  /// Aplica los efectos narrativos de la opción elegida (rep/flags/diario):
  /// sin ellos, un evento de historia auto-resuelto trababa el arco.
  Future<Mission> _autoResolveExpired(Mission mission,
      List<Messenger> messengers, WorldState world, DateTime now,
      [List<AutoResolvedEvent>? report]) async {
    if (mission.isTutorial) return mission;
    var messenger =
        messengers.where((m) => m.id == mission.messengerId).firstOrNull;

    var current = mission;
    var changed = false;

    while (true) {
      final expired = current.events
          .where((e) => e.isUnresolved && now.isAfter(e.deadlineAt))
          .firstOrNull;
      if (expired == null) break;

      // La opción más segura entre las que el mensajero puede usar.
      final usable = expired.options
          .where((o) =>
              optionVisible(o, world) &&
              meetsOptionRequirements(o, messenger, world: world))
          .toList()
        ..sort((a, b) => a.riskLevel.compareTo(b.riskLevel));
      final option = usable.isNotEmpty ? usable.first : expired.options.first;

      final outcome = EventOutcome(
        type: OutcomeType.partial,
        narrative:
            'No estabas ahí para decidir. Tu mensajero actuó por instinto: '
            '${option.text.toLowerCase()}. Salió del paso, pero perdió tiempo.',
        healthDelta: -5,
        timeDeltaMinutes: option.timeCostMinutes,
        packageState: current.packageState,
        chosenOptionText: '${option.text} (por instinto)',
      );

      final updatedEvents = current.events.map((e) {
        if (e.id == expired.id) {
          return e.copyWith(status: EventStatus.resolved, outcome: outcome);
        }
        return e;
      }).toList();

      current = current
          .copyWith(events: updatedEvents)
          .delayedBy(outcome.timeDeltaMinutes);
      changed = true;
      report?.add(AutoResolvedEvent(
        messengerName: messenger?.name ?? 'Tu mensajero',
        eventTitle: expired.title,
        chosenOptionText: option.text,
      ));

      if (option.repDelta != null ||
          option.setFlags != null ||
          option.journalNote != null) {
        world = world.applyChoiceEffects(
          repDelta: option.repDelta,
          setFlags: option.setFlags,
          journalNote: option.journalNote == null
              ? null
              : 'No estabas: tu mensajero decidió por vos. '
                  '${option.journalNote}',
        );
        await _world.saveState(world);
      }

      if (messenger != null) {
        messenger = messenger.copyWith(
          health: (messenger.health + outcome.healthDelta).clamp(0, 100),
          fatigue: (messenger.fatigue + SkillPerks.fatiguePerEvent(messenger))
              .clamp(0, 100),
        );
        await _messenger.saveMessenger(messenger);
      }
    }

    if (changed) await _mission.saveMission(current);
    return current;
  }
}

// ─── Accept Tutorial Mission ──────────────────────────────────────────────────
class AcceptTutorialUseCase {
  final MissionRepository _mission;
  final MessengerRepository _messenger;
  AcceptTutorialUseCase(this._mission, this._messenger);

  Future<Mission> execute(int tutorialIndex, {String? messengerId}) async {
    final messengers = await _messenger.getAllMessengers();
    final messenger = messengerId != null
        ? messengers.firstWhere((m) => m.id == messengerId)
        : messengers.first;
    if (messenger.status == MessengerStatus.injured || messenger.health <= 0) {
      throw Exception('Tu mensajero está herido. Curate en la tienda antes de salir.');
    }
    final mission = await _mission.createTutorialMission(tutorialIndex, messenger.id);
    await _messenger.saveMessenger(messenger.copyWith(status: MessengerStatus.onMission));
    return mission;
  }
}

// ─── Accept Real Mission ──────────────────────────────────────────────────────
class AcceptMissionUseCase {
  final MissionRepository _mission;
  final MessengerRepository _messenger;
  // Con el mundo y el catálogo, los eventos se eligen con
  // [pickEventsForMission]; sin ellos, el repositorio sortea del pool.
  final WorldRepository? _world;
  final GameContentCatalog? _content;
  final Random _rng;
  AcceptMissionUseCase(this._mission, this._messenger,
      {WorldRepository? world, GameContentCatalog? content, Random? rng})
      : _world = world,
        _content = content,
        _rng = rng ?? Random();

  Future<Mission> execute(GameRoute route, {String? messengerId}) async {
    final messengers = await _messenger.getAllMessengers();
    final messenger = messengerId != null
        ? messengers.firstWhere((m) => m.id == messengerId)
        : messengers.first;
    if (messenger.status == MessengerStatus.injured || messenger.health <= 0) {
      throw Exception('Tu mensajero está herido. Curate en la tienda antes de salir.');
    }

    // Consumir boosts comprados en la tienda para esta misión.
    final boosts = Set<String>.from(messenger.activeBoosts);
    // Sandalias de Mercurio (-20%) + perk de Velocidad 6-10 (hasta -12%).
    var durationFactor = SkillPerks.missionDurationFactor(messenger);
    if (boosts.remove('boost_speed')) durationFactor *= 0.8;
    var effectiveRoute = route;
    if (durationFactor < 1.0) {
      effectiveRoute = route.copyWith(
          durationMinutes: (route.durationMinutes * durationFactor).round());
    }
    final revealEvents = boosts.remove('boost_events'); // Mapa del explorador

    // Qué eventos salen: el pool de la ruta más las consecuencias de lo que
    // el jugador hizo antes.
    List<String>? eventIds;
    final world = await _world?.getState();
    final cfg = _content?.routeById(route.id);
    if (world != null && cfg != null) {
      final content = _content!;
      final count = cfg.minEvents +
          _rng.nextInt((cfg.maxEvents - cfg.minEvents + 1).clamp(1, 10));
      final picked = pickEventsForMission(
        pool: [
          for (final id in cfg.eventPoolIds)
            if (content.eventById(id) case final e?) e,
          ...content.consequenceEvents,
        ],
        count: count,
        world: world,
        rng: _rng,
      );
      eventIds = [for (final e in picked) e.id];
      await _world!.saveState(world.recordEvents(eventIds,
          once: [for (final e in picked) if (e.once) e.id]));
    }

    // La paga se fija con la ruta NOMINAL: ir más rápido no cobra menos.
    final mission = await _mission.createMission(
      effectiveRoute, messenger.id,
      revealEvents: revealEvents,
      eventIds: eventIds,
      payFactor:
          routePayFactor(route.durationMinutes, route.danger) * route.payBonus);
    await _messenger.saveMessenger(messenger.copyWith(
      status: MessengerStatus.onMission,
      activeBoosts: boosts,
    ));
    return mission;
  }
}

// ─── Accept Story Mission ─────────────────────────────────────────────────────
// El capítulo lo juega el mensajero principal.
class AcceptStoryMissionUseCase {
  final MissionRepository _mission;
  final MessengerRepository _messenger;
  final GameContentCatalog _content;
  AcceptStoryMissionUseCase(this._mission, this._messenger, this._content);

  Future<Mission> execute(StoryMissionConfig config) async {
    final messenger = (await _messenger.getAllMessengers()).first;
    final arc = _content.arcs.where((a) => a.id == config.arcId).firstOrNull;
    final rank = max(arc?.minRank ?? 0, config.minRank);
    if (messenger.rank < rank) {
      throw Exception('Este capítulo pide rango $rank.');
    }
    if (messenger.status == MessengerStatus.injured || messenger.health <= 0) {
      throw Exception('Tu mensajero está herido. Curate en la tienda antes de salir.');
    }
    if (messenger.status != MessengerStatus.idle) {
      throw Exception('Tu mensajero principal está ocupado.');
    }
    final events = [
      for (final id in config.fixedEventIds)
        if (_content.eventById(id) case final e?) e,
    ];
    final mission =
        await _mission.createStoryMission(config, messenger.id, events);
    await _messenger
        .saveMessenger(messenger.copyWith(status: MessengerStatus.onMission));
    return mission;
  }
}

// ─── Apply Shop Item ──────────────────────────────────────────────────────────
/// Skill que sube cada manual de la tienda.
SkillType? manualSkillFor(String itemId) => switch (itemId) {
      'skill_speed_1' => SkillType.speed,
      'skill_stealth_1' => SkillType.stealth,
      'skill_combat_1' => SkillType.combat,
      'skill_survival_1' => SkillType.survival,
      'skill_contacts_1' => SkillType.contacts,
      _ => null,
    };

/// Precio en Denarios del manual que sube una skill desde [currentLevel]
/// (GDD §5: 200 / 500 / 1.200 / 2.500). null = ya está en el nivel máximo.
int? manualPriceFor(int currentLevel) => switch (currentLevel) {
      1 => 200,
      2 => 500,
      3 => 1200,
      4 => 2500,
      _ => null,
    };

/// Compra con moneda blanda: cobra de la billetera común (la del principal)
/// y aplica el efecto al mensajero [targetId].
class ApplyShopItemUseCase {
  final MessengerRepository _messenger;
  ApplyShopItemUseCase(this._messenger);

  Future<Messenger> execute({
    required String targetId,
    required String itemId,
    int denariosCost = 0,
    int aureosCost = 0,
  }) async {
    final all = await _messenger.getAllMessengers();
    var payer = all.first;
    var target = all.firstWhere((m) => m.id == targetId);

    final manualSkill = manualSkillFor(itemId);
    if (manualSkill != null) {
      final price = manualPriceFor(target.skillLevel(manualSkill));
      if (price == null) {
        throw Exception('${target.name} ya tiene ${manualSkill.label} '
            'en nivel $kMaxSkillLevel. Un manual no le enseña nada nuevo.');
      }
      denariosCost = price;
    }
    if (payer.denarios < denariosCost) {
      throw Exception('Denarios insuficientes (necesitás $denariosCost, '
          'tenés ${payer.denarios})');
    }
    if (payer.aureos < aureosCost) {
      throw Exception('Aureos insuficientes (necesitás $aureosCost, '
          'tenés ${payer.aureos})');
    }
    payer = payer.copyWith(
      denarios: payer.denarios - denariosCost,
      aureos: payer.aureos - aureosCost,
    );
    if (target.id == payer.id) target = payer;

    Messenger updated = switch (itemId) {
      'boost_health_small' =>
        target.copyWith(health: (target.health + 30).clamp(0, 100)),
      'boost_health_full' => target.copyWith(health: 100),
      'boost_fatigue' => target.copyWith(fatigue: 0),
      // Boosts persistentes: se consumen al aceptar la próxima misión.
      'boost_speed' || 'boost_events' =>
        target.copyWith(activeBoosts: {...target.activeBoosts, itemId}),
      // El mapa del mercado negro es el mismo mapa, pagado en Denarios.
      'boost_events_black' =>
        target.copyWith(activeBoosts: {...target.activeBoosts, 'boost_events'}),
      // Los Sellos son de la billetera común.
      'seal_single' => target.copyWith(seals: target.seals + 1),
      'seal_pack_10' => target.copyWith(seals: target.seals + 10),
      _ when manualSkill != null => target.raiseSkill(manualSkill),
      _ => target,
    };
    if (itemId.startsWith('seal_') && target.id != payer.id) {
      payer = payer.copyWith(
          seals: payer.seals + (itemId == 'seal_pack_10' ? 10 : 1));
      updated = target;
    }

    // Curarse saca al mensajero del estado "herido".
    if (updated.status == MessengerStatus.injured && updated.health > 0) {
      updated = updated.copyWith(status: MessengerStatus.idle);
    }

    if (updated.id != payer.id) await _messenger.saveMessenger(payer);
    await _messenger.saveMessenger(updated);
    return updated;
  }
}

// ─── Compras con dinero real ──────────────────────────────────────────────────
/// Lo que entrega cada producto de la tienda real. Vive en el dominio para que
/// lo acrediten por igual la compra confirmada por la tienda y el sandbox.
class PurchaseReward {
  final int aureos;
  final int denarios;
  final int seals;
  final bool fullRest;     // salud 100 y fatiga 0
  final bool extraSlot;    // abre el 2.º mensajero gratis
  final int skillPicks;    // niveles de skill a elección

  const PurchaseReward({
    this.aureos = 0,
    this.denarios = 0,
    this.seals = 0,
    this.fullRest = false,
    this.extraSlot = false,
    this.skillPicks = 0,
  });
}

PurchaseReward? purchaseRewardFor(String shopItemId) => switch (shopItemId) {
      'aureos_small' => const PurchaseReward(aureos: 50),
      'aureos_medium' => const PurchaseReward(aureos: 120),
      'aureos_large' => const PurchaseReward(aureos: 300),
      'aureos_mega' => const PurchaseReward(aureos: 800, denarios: 500),
      'bundle_starter' => const PurchaseReward(
          aureos: 30, seals: 2, fullRest: true, extraSlot: true),
      'bundle_warrior' => const PurchaseReward(aureos: 50, skillPicks: 2),
      _ => null,
    };

/// Los niveles de skill a elección se guardan como boosts con prefijo
/// [kSkillPickPrefix], uno por nivel. `iap_skill_pick_2` es el formato de la
/// versión 1.0.0+2 y vale por dos.
const kSkillPickPrefix = 'iap_skill_pick';
const _kLegacySkillPick2 = 'iap_skill_pick_2';

int skillPicksOf(Messenger m) => m.activeBoosts
    .where((b) => b.startsWith(kSkillPickPrefix))
    .fold(0, (n, b) => n + (b == _kLegacySkillPick2 ? 2 : 1));

class CreditPurchaseUseCase {
  final MessengerRepository _messenger;
  CreditPurchaseUseCase(this._messenger);

  /// Acredita [shopItemId] al mensajero principal. Devuelve null si el
  /// producto no existe.
  Future<PurchaseReward?> execute(String shopItemId) async {
    final reward = purchaseRewardFor(shopItemId);
    if (reward == null) return null;
    final all = await _messenger.getAllMessengers();
    if (all.isEmpty) return null;
    var primary = all.first;

    final stamp = DateTime.now().microsecondsSinceEpoch;
    primary = primary.copyWith(
      aureos: primary.aureos + reward.aureos,
      denarios: primary.denarios + reward.denarios,
      seals: primary.seals + reward.seals,
      health: reward.fullRest ? 100 : null,
      fatigue: reward.fullRest ? 0 : null,
      activeBoosts: {
        ...primary.activeBoosts,
        for (var i = 0; i < reward.skillPicks; i++)
          '$kSkillPickPrefix:$stamp:$i',
      },
      status: reward.fullRest && primary.status == MessengerStatus.injured
          ? MessengerStatus.idle
          : null,
    );
    await _messenger.saveMessenger(primary);

    if (reward.extraSlot && all.length < 2) {
      // unlockSlot cobra el slot: se le devuelve lo cobrado al principal.
      final cost = messengerSlotCosts[1] ?? 0;
      final funded = primary.copyWith(aureos: primary.aureos + cost);
      await _messenger.unlockSlot(
        payer: funded,
        newName: 'Mensajero II',
        gender: primary.gender,
        slotIndex: 1,
      );
    }
    return reward;
  }
}

/// Usa un nivel a elección (Pack del Guerrero) en [skill].
class UseSkillPickUseCase {
  final MessengerRepository _messenger;
  UseSkillPickUseCase(this._messenger);

  Future<Messenger> execute({
    required String messengerId,
    required SkillType skill,
  }) async {
    final all = await _messenger.getAllMessengers();
    // Los niveles los compra (y guarda) el principal; se aplican a cualquiera.
    var owner = all.first;
    if (skillPicksOf(owner) <= 0) {
      throw Exception('No te quedan niveles para elegir.');
    }
    final boosts = Set<String>.from(owner.activeBoosts);
    final pick = boosts.firstWhere((b) => b.startsWith(kSkillPickPrefix));
    boosts.remove(pick);
    if (pick == _kLegacySkillPick2) boosts.add('$kSkillPickPrefix:legacy');
    owner = owner.copyWith(activeBoosts: boosts);

    var target =
        owner.id == messengerId ? owner : all.firstWhere((m) => m.id == messengerId);
    if (target.skillLevel(skill) >= kMaxSkillLevel) {
      throw Exception(
          'Esa habilidad ya está en nivel $kMaxSkillLevel. Elegí otra.');
    }
    target = target.raiseSkill(skill);
    if (target.id == owner.id) {
      await _messenger.saveMessenger(target);
    } else {
      await _messenger.saveMessenger(owner);
      await _messenger.saveMessenger(target);
    }
    return target;
  }
}

// ─── Premio de "Primeros pasos" ──────────────────────────────────────────────
const int kChecklistRewardAureos = 3;
const int kChecklistRewardSeals = 1;

/// Acredita el premio del checklist en la billetera común (el principal).
class ClaimChecklistRewardUseCase {
  final MessengerRepository _messenger;
  ClaimChecklistRewardUseCase(this._messenger);

  Future<bool> execute() async {
    final messengers = await _messenger.getAllMessengers();
    if (messengers.isEmpty) return false;
    final m = messengers.first;
    await _messenger.saveMessenger(m.copyWith(
      aureos: m.aureos + kChecklistRewardAureos,
      seals: m.seals + kChecklistRewardSeals,
    ));
    return true;
  }
}

// ─── Skip to next event ───────────────────────────────────────────────────────
// Cuesta denarios. El costo escala con el tiempo que se ahorra.
class SkipToNextEventUseCase {
  final MissionRepository _mission;
  final MessengerRepository _messenger;
  SkipToNextEventUseCase(this._mission, this._messenger);

  // Calcular cuánto cuesta adelantar (preview sin ejecutar)
  static int costFor(Mission mission, {DateTime? now}) {
    final at = now ?? GameClock.now();
    final minutesAhead = mission.minutesToNextStopAt(at);
    // Sin eventos por delante y ya en destino: no hay nada que cobrar.
    if (minutesAhead <= 0 && mission.nextUpcomingEventAt(at) == null) return 0;
    // 1 denario por minuto adelantado, mínimo 5, máximo 300
    return minutesAhead.clamp(5, 300);
  }

  Future<({Mission mission, int cost})> execute({
    required Mission mission,
    required String messengerId,
  }) async {
    final cost = costFor(mission);
    final messengers = await _messenger.getAllMessengers();
    // La billetera es una sola: paga el principal, sea cual sea el mensajero.
    final payer = messengers.first;

    if (payer.denarios < cost) {
      throw Exception('Denarios insuficientes (necesitás $cost, tenés ${payer.denarios})');
    }

    final updatedMission = mission.fastForward(GameClock.now());
    await _mission.saveMission(updatedMission);
    await _messenger.saveMessenger(payer.copyWith(
      denarios: payer.denarios - cost,
    ));

    return (mission: updatedMission, cost: cost);
  }
}

// ─── Adelantar por anuncio ───────────────────────────────────────────────────
// Premio del rewarded ad (GDD §6.4): adelanta hasta [minutes] sin saltear el
// próximo evento ni pasarse de la llegada.
class AdvanceMissionUseCase {
  final MissionRepository _mission;
  AdvanceMissionUseCase(this._mission);

  Future<Mission?> execute(String messengerId, int minutes) async {
    if (minutes <= 0) return null;
    final mission = await _mission.getActiveMissionFor(messengerId);
    if (mission == null) return null;
    final updated =
        mission.fastForward(GameClock.now(), max: Duration(minutes: minutes));
    await _mission.saveMission(updated);
    return updated;
  }
}

// ─── Unlock Messenger Slot ────────────────────────────────────────────────────
class UnlockMessengerSlotUseCase {
  final MessengerRepository _messenger;
  UnlockMessengerSlotUseCase(this._messenger);

  Future<Messenger> execute({
    required Messenger payer,
    required String newName,
    required MessengerGender gender,
  }) async {
    final allMessengers = await _messenger.getAllMessengers();
    final nextSlot = allMessengers.length; // 0-indexed, siguiente disponible

    final requiredTutorials = messengerSlotRequiredTutorials[nextSlot] ?? 999;
    if (!payer.tutorialComplete || payer.tutorialMissionIndex < requiredTutorials) {
      throw Exception('Necesitás completar las pruebas de Varus primero');
    }

    return _messenger.unlockSlot(
      payer: payer,
      newName: newName,
      gender: gender,
      slotIndex: nextSlot,
    );
  }
}

// ─── Complete Mission ─────────────────────────────────────────────────────────
// Única fuente de verdad para cerrar una misión: calcula calificación, recompensa,
// y deja al mensajero herido si llegó con la salud en 0.
/// Todo lo que dejó una entrega. Los deltas se exponen para que la UI pueda
/// mostrarlos: sin esto, el jugador nunca se entera de qué cambió.
class MissionCompletion {
  final MissionResult result;
  /// Denarios pagados por la entrega (ya con perks de Contactos/Velocidad).
  final int denariosDelta;
  /// Fatiga que se descuenta al llegar (siempre negativa o cero).
  final int fatigueDelta;
  /// XP acumulado durante el viaje, por habilidad.
  final Map<SkillType, int> xpGained;
  /// Reputación que movió el cierre del capítulo de historia.
  final Map<Faction, int> repDelta;
  /// Entrada de diario del capítulo, si la misión era de un arco.
  final String? journalEntry;
  /// Flags de historia que quedaron activados al entregar.
  final List<String> flagsSet;
  /// Título ganado si el capítulo cerró un arco.
  final String? endingTitle;
  /// Final alcanzado (`end_varus`…), para su ilustración.
  final String? endingId;
  /// El mensajero terminó herido (salud en 0).
  final bool injured;
  /// Posta amiga que alivió la fatiga al llegar ([RestStop]).
  final String? restStop;

  const MissionCompletion({
    required this.result,
    required this.denariosDelta,
    required this.fatigueDelta,
    required this.xpGained,
    required this.repDelta,
    required this.flagsSet,
    this.journalEntry,
    this.endingTitle,
    this.endingId,
    this.injured = false,
    this.restStop,
  });
}

/// Puntaje de tiempo (0-100) según los minutos que las decisiones le
/// costaron al viaje. Cuánto tarda el jugador en tocar ENTREGAR no cuenta:
/// el juego es casual y nadie debería tener que mirar el reloj.
/// Sin retraso → 100 · 25% de retraso → 50 · piso 20.
double timeScoreFor(Mission mission) {
  final delay = mission.events
      .where((e) => e.status == EventStatus.resolved)
      .fold<int>(0, (sum, e) => sum + (e.outcome?.timeDeltaMinutes ?? 0));
  if (delay <= 0) return 100;
  final base =
      mission.deadlineAt.difference(mission.startedAt).inMinutes - delay;
  if (base <= 0) return 20;
  return (100 - delay / base * 200).clamp(20.0, 100.0);
}

class CompleteMissionUseCase {
  final MissionRepository _mission;
  final MessengerRepository _messenger;
  final WorldRepository _world;
  final GameContentCatalog _content;
  CompleteMissionUseCase(
      this._mission, this._messenger, this._world, this._content);

  /// Cierra la misión y devuelve todo lo que cambió, no solo la nota:
  /// es lo que la pantalla de resultado necesita para contarle al jugador
  /// en qué ayudó (o no) lo que hizo.
  Future<MissionCompletion?> execute(String messengerId) async {
    final allMissions = await _mission.getAllActiveMissions();
    final mission = allMissions.where((m) => m.messengerId == messengerId).firstOrNull;
    if (mission == null) return null;

    final messengers = await _messenger.getAllMessengers();
    final messenger = messengers.where((m) => m.id == messengerId).firstOrNull;

    final timeScore = timeScoreFor(mission);
    final packageScore = switch (mission.packageState) {
      PackageState.intact      => 100.0,
      PackageState.wetMinor    => 75.0,
      PackageState.damaged     => 50.0,
      PackageState.compromised => 25.0,
      PackageState.lost        => 0.0,
    };
    final resolved = mission.events.where((e) => e.status == EventStatus.resolved);
    final successCount = resolved.where((e) => e.outcome?.type == OutcomeType.success).length;
    final decisionScore = resolved.isEmpty ? 70.0 : (successCount / resolved.length * 100);
    final total = timeScore * 0.30 + packageScore * 0.35 + decisionScore * 0.35;
    final grade = switch (total) {
      >= 90 => 'S', >= 75 => 'A', >= 60 => 'B', >= 40 => 'C', _ => 'F',
    };
    // Paga = tabla por nota × factor de la ruta (fijado al aceptar).
    final baseReward = (gradeBaseReward(grade) * mission.payFactor).round();
    // Perks: Contactos 6-10 (+5% a +20%) y Velocidad 10 (+25 en nota S).
    var denarioReward = baseReward;
    if (messenger != null) {
      denarioReward =
          (baseReward * SkillPerks.payMultiplier(messenger)).round();
      if (grade == 'S') denarioReward += SkillPerks.gradeSBonus(messenger);
    }

    final result = MissionResult(
      grade: grade, timeScore: timeScore,
      packageScore: packageScore, decisionScore: decisionScore,
      arrivedAt: GameClock.now(),
      denarios: denarioReward,
    );
    await _mission.completeMission(mission.id, result);

    // XP acumulado en el viaje: sale de los eventos ya resueltos.
    final xpGained = <SkillType, int>{};
    for (final e in resolved) {
      final skill = e.outcome?.usedSkill;
      final xp = e.outcome?.xpGained ?? 0;
      if (skill != null && xp > 0) {
        xpGained[skill] = (xpGained[skill] ?? 0) + xp;
      }
    }

    // ── Historia: avanzar el arco y aplicar el peso del capítulo.
    var repDelta = <Faction, int>{};
    var flagsSet = <String>[];
    String? journalEntry;
    String? endingTitle;
    String? endingId;
    if (mission.arcId != null) {
      final config = _content.storyMissionById(mission.routeId);
      if (config != null) {
        repDelta = config.repDeltaOnComplete ?? const {};
        flagsSet = config.setFlagsOnComplete ?? const [];
        journalEntry = config.journalEntry;
        endingTitle = config.endingTitle;
        endingId = config.endingId;
        var world = await _world.getState();
        world = world
            .applyRepDeltas(config.repDeltaOnComplete)
            .addFlags(config.setFlagsOnComplete)
            .addJournal(config.journalEntry);
        if (config.isFinal) {
          world = world.copyWith(
            completedArcs: {
              ...world.completedArcs,
              '${config.arcId}:${config.endingId}',
            },
          );
        } else {
          world = world.copyWith(arcProgress: {
            ...world.arcProgress,
            config.arcId: config.stage + 1,
          });
        }
        await _world.saveState(world);
      }
    } else if (!mission.isTutorial) {
      // Ruta real: quien la encarga te tiene más en cuenta si llegó bien.
      final patron = _content.routeById(mission.routeId)?.patron;
      if (patron != null) {
        final world = await _world.getState();
        final gain =
            world.applyPatronDelivery(patron, grade, dateKey(GameClock.now()));
        if (gain.gained > 0) {
          await _world.saveState(gain.world);
          repDelta = {patron: gain.gained};
        }
      }
    }

    // Posta amiga en el camino (premio de un final): se llega más entero.
    RestStop? restStop;
    if (mission.arcId == null && !mission.isTutorial) {
      final world = await _world.getState();
      restStop = _content.restStops
          .where((r) =>
              r.routeIds.contains(mission.routeId) && world.hasFlag(r.flag))
          .firstOrNull;
    }

    var fatigueDelta = 0;
    var injured = false;
    if (messenger != null) {
      final completedIds = [...messenger.completedMissionIds, mission.id];
      int nextTutIdx = messenger.tutorialMissionIndex;
      bool tutComplete = messenger.tutorialComplete;
      if (mission.isTutorial) {
        nextTutIdx = messenger.tutorialMissionIndex + 1;
        if (nextTutIdx >= _content.tutorialMissions.length) {
          tutComplete = true;
        }
      }
      // Si llegó con la salud en 0, queda herido y no podrá salir hasta curarse.
      injured = messenger.health <= 0;
      final newStatus =
          injured ? MessengerStatus.injured : MessengerStatus.idle;
      final newFatigue =
          (messenger.fatigue - 10 - (restStop?.fatigueRelief ?? 0)).clamp(0, 100);
      fatigueDelta = newFatigue - messenger.fatigue;
      await _messenger.saveMessenger(messenger.copyWith(
        status: newStatus,
        fatigue: newFatigue,
        completedMissionIds: completedIds,
        tutorialMissionIndex: nextTutIdx,
        tutorialComplete: tutComplete,
      ));
      // La paga va a la billetera común, que es la del principal.
      final primary = (await _messenger.getAllMessengers()).first;
      await _messenger.saveMessenger(
          primary.copyWith(denarios: primary.denarios + denarioReward));
    }
    return MissionCompletion(
      result: result,
      denariosDelta: denarioReward,
      fatigueDelta: fatigueDelta,
      xpGained: xpGained,
      repDelta: repDelta,
      flagsSet: flagsSet,
      journalEntry: journalEntry,
      endingTitle: endingTitle,
      endingId: endingId,
      injured: injured,
      restStop: restStop?.name,
    );
  }
}

// ─── Resolve Event ────────────────────────────────────────────────────────────

/// Un sumando de la tirada de un evento. La lista completa explica el
/// resultado sin revelar la fórmula: "Sigilo Nv.3 +45 · Riesgo alto −24".
class ScoreFactor {
  final String label;
  final int value;
  const ScoreFactor({required this.label, required this.value});
}

/// Resultado de resolver un evento, con todo lo que la UI necesita para
/// explicarle al jugador qué pasó y por qué.
class EventResolution {
  final EventOutcome outcome;
  final bool missionComplete;
  final MissionResult? result;
  final List<SkillType> leveledUpSkills;
  final Map<Faction, int>? repDelta;
  /// Puntaje final de la tirada y su desglose (ver [ScoreFactor]).
  final int score;
  final int effectiveRisk;
  final List<ScoreFactor> scoreFactors;
  /// Flags de historia que activó la decisión.
  final List<String> flagsSet;
  /// Nota que quedó en el diario, si la opción dejaba una.
  final String? journalNote;

  const EventResolution({
    required this.outcome,
    required this.missionComplete,
    required this.leveledUpSkills,
    required this.score,
    required this.effectiveRisk,
    required this.scoreFactors,
    required this.flagsSet,
    this.result,
    this.repDelta,
    this.journalNote,
  });
}

class ResolveEventUseCase {
  final MissionRepository _mission;
  final MessengerRepository _messenger;
  final WorldRepository _world;
  final _rng = Random();
  final GameContentCatalog _content;
  ResolveEventUseCase(
      this._mission, this._messenger, this._world, this._content);

  Future<EventResolution> execute({
    required Mission mission,
    required MissionEvent event,
    required EventOption option,
  }) async {
    final messengers = await _messenger.getAllMessengers();
    final messenger = messengers
        .where((m) => m.id == mission.messengerId)
        .firstOrNull;

    // La UI ya oculta/bloquea estas opciones; el dominio no confía en ella.
    final world = await _world.getState();
    if (!optionVisible(option, world) ||
        !meetsOptionRequirements(option, messenger, world: world)) {
      throw Exception('Tu mensajero no puede tomar esa opción todavía.');
    }

    final roll = _calculateOutcome(option, messenger, mission.isTutorial);
    final raw = roll.outcome;
    final usedSkill = option.requiredSkills.keys.firstOrNull;
    const xpPerEvent = 25;
    final outcome = EventOutcome(
      type: raw.type,
      narrative: raw.narrative,
      healthDelta: raw.healthDelta,
      timeDeltaMinutes: raw.timeDeltaMinutes,
      packageState: raw.packageState,
      chosenOptionText: option.text,
      usedSkill: usedSkill,
      xpGained: usedSkill == null ? 0 : xpPerEvent,
    );

    // ── Efectos narrativos: la decisión deja huella (con cualquier resultado)
    if (option.repDelta != null ||
        option.setFlags != null ||
        option.journalNote != null) {
      final world = await _world.getState();
      await _world.saveState(world.applyChoiceEffects(
        repDelta: option.repDelta,
        setFlags: option.setFlags,
        journalNote: option.journalNote,
      ));
    }

    var updatedEvents = mission.events.map((e) {
      if (e.id == event.id) return e.copyWith(status: EventStatus.resolved, outcome: outcome);
      return e;
    }).toList();

    // ── Evento encadenado: la decisión tiene secuela en esta misma misión.
    if (option.followUpEventId != null) {
      final followUp = _buildFollowUp(option.followUpEventId!, mission);
      if (followUp != null) updatedEvents = [...updatedEvents, followUp];
    }

    // El siguiente evento queda `pending`: aparece recién en su `triggersAt`.

    final resolvedCount = updatedEvents.where((e) => e.status == EventStatus.resolved).length;
    final newProgress = updatedEvents.isEmpty
        ? 90
        : ((resolvedCount / updatedEvents.length) * 85).round().clamp(10, 90);

    // El paquete solo empeora: un éxito posterior no repara el daño previo.
    final worstPackage = outcome.packageState.index > mission.packageState.index
        ? outcome.packageState
        : mission.packageState;

    final updatedMission = mission
        .copyWith(
          progressPct: newProgress,
          packageState: worstPackage,
          events: updatedEvents,
        )
        .delayedBy(outcome.timeDeltaMinutes);
    await _mission.saveMission(updatedMission);

    final leveledUpSkills = <SkillType>[];
    if (messenger != null) {
      final newHealth = (messenger.health + outcome.healthDelta).clamp(0, 100);
      final newFatigue = (messenger.fatigue +
              SkillPerks.fatiguePerEvent(messenger))
          .clamp(0, 100);
      var updated = messenger.copyWith(health: newHealth, fatigue: newFatigue);
      // XP solo a la skill que se usó (la primera requerida por la opción).
      if (usedSkill != null) {
        final r = updated.addSkillXp(usedSkill, xpPerEvent);
        updated = r.messenger;
        leveledUpSkills.addAll(r.leveledUp);
      }
      await _messenger.saveMessenger(updated);
    }

    // Nunca auto-completar al resolver eventos.
    // La misión se completa solo cuando el jugador aprieta "Entregar mensaje".
    return EventResolution(
      outcome: outcome,
      missionComplete: false,
      result: null,
      leveledUpSkills: leveledUpSkills,
      repDelta: option.repDelta,
      score: roll.score,
      effectiveRisk: roll.effectiveRisk,
      scoreFactors: roll.factors,
      flagsSet: option.setFlags ?? const <String>[],
      journalNote: option.journalNote,
    );
  }

  /// Construye el evento encadenado, programado entre el momento actual y el
  /// final de la misión. Si no queda tiempo suficiente, no se encadena.
  MissionEvent? _buildFollowUp(String eventId, Mission mission) {
    final cfg = _content.eventById(eventId);
    if (cfg == null) return null;

    final now = GameClock.now();
    final remaining = mission.deadlineAt.difference(now);
    if (remaining.inMinutes < 10) return null;

    // A mitad del tiempo restante, con un mínimo de 5 minutos.
    final delayMin = (remaining.inMinutes ~/ 2).clamp(5, 24 * 60);
    final triggerAt = now.add(Duration(minutes: delayMin));
    return MissionEvent(
      id: 'followup_${DateTime.now().millisecondsSinceEpoch}',
      configId: cfg.id,
      category: cfg.category,
      npcId: cfg.npcId,
      title: cfg.title,
      description: cfg.description,
      triggersAt: triggerAt,
      deadlineAt: triggerAt.add(const Duration(minutes: kDecisionWindowMinutes)),
      status: EventStatus.pending,
      options: cfg.options.map((o) => o.toEventOption()).toList(),
    );
  }

  ({EventOutcome outcome, int score, int effectiveRisk, List<ScoreFactor> factors})
      _calculateOutcome(
          EventOption option, Messenger? messenger, bool isTutorial) {
    // Habilidad principal de la opción: define perks y XP.
    final usedSkill = option.requiredSkills.keys.firstOrNull;
    // Cada sumando queda registrado: el jugador tiene derecho a saber
    // por qué le fue bien o mal (se muestra en la pantalla de resultado).
    final factors = <ScoreFactor>[
      const ScoreFactor(label: 'Oficio de mensajero', value: 40),
    ];

    int score = 40;
    for (final entry in option.requiredSkills.entries) {
      final level = messenger?.skillLevel(entry.key) ?? 1;
      score += level * 15;
      factors.add(ScoreFactor(
          label: '${entry.key.label} Nv.$level', value: level * 15));
    }
    // Perks de Sigilo/Combate: bonus plano y reducción de riesgo.
    if (messenger != null) {
      final perkBonus = SkillPerks.scoreBonus(usedSkill, messenger);
      score += perkBonus;
      if (perkBonus != 0) {
        factors.add(ScoreFactor(
            label: 'Perks de ${usedSkill?.label ?? 'tu camino'}',
            value: perkBonus));
      }
    }
    final effectiveRisk = messenger == null
        ? option.riskLevel
        : (option.riskLevel - SkillPerks.riskReduction(usedSkill, messenger))
            .clamp(0, 5);
    score -= effectiveRisk * 8;
    factors.add(ScoreFactor(
        label: 'Riesgo ${_riskLabel(effectiveRisk)}',
        value: -effectiveRisk * 8));
    // La fatiga alta deteriora el desempeño (Supervivencia 9/10 la atenúa).
    final fatigue = messenger?.fatigue ?? 0;
    final fatigueFactor =
        messenger == null ? 1.0 : SkillPerks.fatiguePenaltyFactor(messenger);
    var fatiguePenalty = 0;
    if (fatigue >= 70) {
      fatiguePenalty = (15 * fatigueFactor).round();
    } else if (fatigue >= 40) {
      fatiguePenalty = (7 * fatigueFactor).round();
    }
    if (fatiguePenalty != 0) {
      score -= fatiguePenalty;
      factors.add(
          ScoreFactor(label: 'Fatiga $fatigue', value: -fatiguePenalty));
    }
    final luck = _rng.nextInt(30) - 10;
    score += luck;
    factors.add(ScoreFactor(label: 'El camino', value: luck));

    var type = score >= 55 ? OutcomeType.success
        : score >= 30 ? OutcomeType.partial
        : OutcomeType.fail;

    // Tiradas críticas (ver forecast.dart). El ajuste entra al desglose para
    // que la suma de factores siga cerrando con el score.
    final crit = _rng.nextInt(100);
    if (type != OutcomeType.fail && crit < mishapPercent(option.riskLevel)) {
      factors.add(ScoreFactor(label: 'Imprevisto', value: 29 - score));
      score = 29;
      type = OutcomeType.fail;
    } else if (type != OutcomeType.success &&
        crit >= 100 - kLuckyBreakPercent) {
      factors.add(ScoreFactor(label: 'Golpe de suerte', value: 55 - score));
      score = 55;
      type = OutcomeType.success;
    }

    final narrative = switch (type) {
      OutcomeType.success => option.outcomeSuccess ?? _genericSuccess(),
      OutcomeType.partial => option.outcomePartial ?? _genericPartial(),
      OutcomeType.fail    => option.outcomeFail    ?? _genericFail(),
    };

    // Perks defensivos: Combate 8 protege el paquete al fallar,
    // Combate 10 reduce el costo de salud, Supervivencia 7 amortigua parciales.
    final partialHealth = messenger == null
        ? -5
        : SkillPerks.partialHealthDelta(messenger);
    final failHealth = messenger == null
        ? (isTutorial ? -10 : -20)
        : SkillPerks.failHealthDelta(usedSkill, messenger, isTutorial);
    final failPackage = isTutorial ||
            (messenger != null &&
                SkillPerks.combatProtectsPackage(usedSkill, messenger))
        ? PackageState.intact
        : PackageState.wetMinor;

    final outcome = switch (type) {
      OutcomeType.success => EventOutcome(
        type: type, narrative: narrative,
        healthDelta: 0, timeDeltaMinutes: 0, packageState: PackageState.intact,
      ),
      OutcomeType.partial => EventOutcome(
        type: type, narrative: narrative,
        healthDelta: partialHealth, timeDeltaMinutes: option.timeCostMinutes,
        packageState: PackageState.intact,
      ),
      OutcomeType.fail => EventOutcome(
        type: type, narrative: narrative,
        healthDelta: failHealth,
        timeDeltaMinutes: option.timeCostMinutes * 2,
        packageState: failPackage,
      ),
    };
    return (
      outcome: outcome,
      score: score,
      effectiveRisk: effectiveRisk,
      factors: factors,
    );
  }

  String _riskLabel(int risk) => switch (risk) {
        0 || 1 => 'mínimo',
        2 => 'bajo',
        3 => 'medio',
        4 => 'alto',
        _ => 'extremo',
      };

  String _genericSuccess() => ['Tu instinto no te falló. Salís del paso sin contratiempos.',
    'Una decisión precisa en el momento exacto. El camino queda libre.',
    'Lo lograste. Cada obstáculo superado te hace más fuerte.'][_rng.nextInt(3)];

  String _genericPartial() => ['No salió perfecto, pero sobreviviste. El mensaje sigue en camino.',
    'Fue más difícil de lo esperado. Llegaste al otro lado, pero no sin costo.',
    'Una victoria amarga. El paquete está bien, pero perdiste tiempo.'][_rng.nextInt(3)];

  String _genericFail() => ['Las cosas no salieron como planeabas. Perdiste tiempo valioso.',
    'Una decisión equivocada. Ahora vas más lento y el tiempo corre.',
    'El camino te venció esta vez. Pero seguís en pie.'][_rng.nextInt(3)];
}

// ─── Ascend Skill (Caminos del Mensajero) ─────────────────────────────────────
// Sube una skill a nivel élite (6-10) gastando Sellos del Gremio.
// Los Sellos son de la cuenta: viven en el mensajero principal, que paga
// aunque el ascendido sea otro mensajero.
class AscendSkillUseCase {
  final MessengerRepository _messenger;
  AscendSkillUseCase(this._messenger);

  Future<Messenger> execute({
    required String messengerId,
    required SkillType skill,
  }) async {
    final messengers = await _messenger.getAllMessengers();
    final target = messengers.where((m) => m.id == messengerId).firstOrNull;
    if (target == null) throw Exception('Ese mensajero ya no está disponible');
    final payer = messengers.first;

    final current = target.skillLevel(skill);
    if (current < kMaxSkillLevel) {
      throw Exception('Primero alcanzá el nivel $kMaxSkillLevel con experiencia');
    }
    if (current >= kMaxSkillLevelElite) {
      throw Exception('${skill.label} ya está en el nivel máximo');
    }
    final cost = sealCostForLevel[current + 1] ?? 999;
    if (payer.seals < cost) {
      throw Exception('Sellos insuficientes (necesitás $cost, tenés ${payer.seals})');
    }

    if (payer.id == target.id) {
      final updated =
          target.ascendSkill(skill).copyWith(seals: payer.seals - cost);
      await _messenger.saveMessenger(updated);
      return updated;
    }
    await _messenger.saveMessenger(payer.copyWith(seals: payer.seals - cost));
    final updated = target.ascendSkill(skill);
    await _messenger.saveMessenger(updated);
    return updated;
  }
}

// ─── Guild: estado, paga diaria y contratos ───────────────────────────────────
class GetGuildStateUseCase {
  final GuildRepository _guild;
  GetGuildStateUseCase(this._guild);
  Future<GuildState> execute() => _guild.getState();
}

// Cobrar la paga diaria del gremio (login con racha de 7 días, cíclica).
class ClaimDailyPayUseCase {
  final GuildRepository _guild;
  final MessengerRepository _messenger;
  ClaimDailyPayUseCase(this._guild, this._messenger);

  Future<({DailyPayReward reward, int day})> execute() async {
    final state = await _guild.getState();
    if (!state.canClaimDailyPay) {
      throw Exception('Ya cobraste la paga de hoy');
    }
    final day = state.nextPayDay;
    final reward = dailyPaySchedule[day - 1];

    final primary = await _messenger.getMessenger();
    if (primary != null) {
      await _messenger.saveMessenger(primary.copyWith(
        denarios: primary.denarios + reward.denarios,
        aureos: primary.aureos + reward.aureos,
        seals: primary.seals + reward.seals,
      ));
    }
    await _guild.saveState(state.copyWith(
      streakDay: day,
      lastPayDate: dateKey(GameClock.now()),
    ));
    return (reward: reward, day: day);
  }
}

// Registrar progreso de contratos (se llama al entregar o resolver eventos).
class RecordContractProgressUseCase {
  final GuildRepository _guild;
  RecordContractProgressUseCase(this._guild);

  Future<GuildState> recordDelivery(String grade) => _record((t) =>
      t.goal == ContractGoal.deliver ||
      (t.goal == ContractGoal.gradeA && (grade == 'A' || grade == 'S')));

  Future<GuildState> recordEvent({
    required OutcomeType outcome,
    SkillType? usedSkill,
  }) =>
      _record((t) =>
          t.goal == ContractGoal.resolveEvents ||
          (t.goal == ContractGoal.eventSuccesses &&
              outcome == OutcomeType.success) ||
          (t.goal == ContractGoal.useSkill && t.skill == usedSkill));

  Future<GuildState> _record(bool Function(ContractTemplate) matches) async {
    final state = await _guild.getState();
    final updated = state.contracts.map((c) {
      if (c.claimed || c.completed || !matches(c.template)) return c;
      return c.copyWith(progress: c.progress + 1);
    }).toList();
    final newState = state.copyWith(contracts: updated);
    await _guild.saveState(newState);
    return newState;
  }
}

// Cobrar la recompensa de un contrato completado.
class ClaimContractUseCase {
  final GuildRepository _guild;
  final MessengerRepository _messenger;
  ClaimContractUseCase(this._guild, this._messenger);

  Future<({GuildState state, ContractReward reward})> execute(
      String templateId) async {
    final state = await _guild.getState();
    final idx = state.contracts.indexWhere((c) => c.templateId == templateId);
    if (idx < 0) throw Exception('Contrato inexistente');
    final contract = state.contracts[idx];
    if (!contract.completed) throw Exception('Contrato incompleto');
    if (contract.claimed) throw Exception('Contrato ya cobrado');

    final reward = contract.template.reward;
    final primary = await _messenger.getMessenger();
    if (primary != null) {
      await _messenger.saveMessenger(primary.copyWith(
        denarios: primary.denarios + reward.denarios,
        seals: primary.seals + reward.seals,
      ));
    }

    final updated = [...state.contracts];
    updated[idx] = contract.copyWith(claimed: true);
    final newState = state.copyWith(contracts: updated);
    await _guild.saveState(newState);
    return (state: newState, reward: reward);
  }
}
// ─── Cambiar un contrato (favor del Gremio) ──────────────────────────────────
class RerollContractUseCase {
  final GuildRepository _guild;
  final WorldRepository _world;
  final GameContentCatalog _content;
  RerollContractUseCase(this._guild, this._world, this._content);

  /// ¿Puede cambiar [templateId] ahora? (tiene el favor, no lo usó hoy y el
  /// contrato no está cobrado).
  static bool canReroll(GuildState guild, WorldState world,
          List<FactionUnlock> unlocks, DailyContract contract) =>
      !guild.rerollUsed &&
      !contract.claimed &&
      hasFactionPerk(unlocks, world, FactionPerk.contractReroll) &&
      rerollContractId(
              contract.templateId, guild.contracts.map((c) => c.templateId)) !=
          null;

  Future<GuildState> execute(String templateId) async {
    final state = await _guild.getState();
    final world = await _world.getState();
    final idx = state.contracts.indexWhere((c) => c.templateId == templateId);
    if (idx < 0) throw Exception('Contrato inexistente');
    if (!canReroll(state, world, _content.factionUnlocks, state.contracts[idx])) {
      throw Exception('Hoy no podés cambiar este contrato');
    }
    final next = rerollContractId(
        templateId, state.contracts.map((c) => c.templateId))!;
    final updated = [...state.contracts];
    updated[idx] = DailyContract(templateId: next);
    final newState = state.copyWith(contracts: updated, rerollUsed: true);
    await _guild.saveState(newState);
    return newState;
  }
}
