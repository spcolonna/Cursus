// Fase 3: rangos de facción, rutas por reputación y encargos semanales.
import 'package:flutter_test/flutter_test.dart';
import 'package:the_messenger/data/faction_content.dart';
import 'package:the_messenger/data/game_content_expansion.dart';
import 'package:the_messenger/data/static_game_content.dart';
import 'package:the_messenger/domain/entities/content.dart';
import 'package:the_messenger/domain/entities/entities.dart';
import 'package:the_messenger/domain/entities/guild.dart';
import 'package:the_messenger/domain/entities/weekly.dart';
import 'package:the_messenger/domain/entities/world.dart';
import 'package:the_messenger/domain/repositories/repositories.dart';
import 'package:the_messenger/domain/usecases/usecases.dart';
import 'package:the_messenger/domain/usecases/weekly_usecases.dart';

const kContent = StaticGameContent();

// ─── Fakes en memoria ─────────────────────────────────────────────────────────
class _Messengers extends Fake implements MessengerRepository {
  final List<Messenger> list;
  _Messengers(this.list);
  @override
  Future<List<Messenger>> getAllMessengers() async => List.of(list);
  @override
  Future<Messenger?> getMessenger() async => list.firstOrNull;
  @override
  Future<void> saveMessenger(Messenger m) async {
    final i = list.indexWhere((x) => x.id == m.id);
    i == -1 ? list.add(m) : list[i] = m;
  }
}

class _Missions extends Fake implements MissionRepository {
  final List<Mission> active;
  _Missions(this.active);
  @override
  Future<List<Mission>> getAllActiveMissions() async => List.of(active);
  @override
  Future<Mission?> getActiveMissionFor(String id) async =>
      active.where((m) => m.messengerId == id).firstOrNull;
  @override
  Future<void> completeMission(String id, MissionResult r) async =>
      active.removeWhere((m) => m.id == id);
}

class _World implements WorldRepository {
  WorldState state;
  _World([WorldState? s]) : state = s ?? WorldState.initial();
  @override
  Future<WorldState> getState() async => state;
  @override
  Future<void> saveState(WorldState s) async => state = s;
}

class _Weekly implements WeeklyRepository {
  WeeklyState? saved;
  @override
  Future<WeeklyState?> load() async => saved;
  @override
  Future<void> save(WeeklyState s) async => saved = s;
}

class _Guild implements GuildRepository {
  GuildState state;
  _Guild(this.state);
  @override
  Future<GuildState> getState() async => state;
  @override
  Future<void> saveState(GuildState s) async => state = s;
}

Messenger _messenger() => Messenger(
      id: 'm1',
      name: 'Marcus',
      gender: MessengerGender.male,
      health: 100,
      fatigue: 0,
      status: MessengerStatus.onMission,
      skills: {for (final s in SkillType.values) s: 1},
      skillXp: const {},
      completedMissionIds: const [],
      tutorialPhase: 1,
      tutorialMissionIndex: 0,
      tutorialComplete: true,
    );

Mission _mission(String routeId, {int minutes = 120, bool tutorial = false}) {
  final start = DateTime(2026, 1, 1, 8);
  return Mission(
    id: 'mis_$routeId',
    routeId: routeId,
    messengerId: 'm1',
    origin: 'Roma',
    destination: 'Capua',
    packageDescription: 'Carta',
    lore: '',
    isTutorial: tutorial,
    tutorialIndex: tutorial ? 0 : -1,
    startedAt: start,
    deadlineAt: start.add(Duration(minutes: minutes)),
    progressPct: 100,
    status: MissionStatus.active,
    packageState: PackageState.intact,
    events: const [],
  );
}

WorldState _withRep(Map<Faction, int> rep) =>
    WorldState.initial().applyRepDeltas(rep);

void main() {
  // ─── Escalones ──────────────────────────────────────────────────────────────
  group('Escalones de facción', () {
    test('los umbrales coinciden con los nombres de siempre', () {
      expect(factionTier(-40), FactionTier.enemy);
      expect(factionTier(-39), FactionTier.suspect);
      expect(factionTier(-9), FactionTier.unknown);
      expect(factionTier(9), FactionTier.unknown);
      expect(factionTier(10), FactionTier.known);
      expect(factionTier(30), FactionTier.respected);
      expect(factionTier(60), FactionTier.legend);
      for (final t in FactionTier.values) {
        expect(factionTier(t.threshold), t, reason: t.name);
        expect(reputationTitle(t.threshold), t.label);
      }
    });

    test('subir de escalón queda en el diario y se puede celebrar', () {
      final before = WorldState.initial();
      final after = before.applyRepDeltas({Faction.legions: 12});
      expect(after.tierOf(Faction.legions), FactionTier.known);
      expect(after.journal.last.text, contains('Las Legiones'));
      expect(after.tierUpsSince(before), {Faction.legions: FactionTier.known});
      // Bajar o moverse dentro del escalón no anota nada.
      final down = after.applyRepDeltas({Faction.legions: -5});
      expect(down.journal.length, after.journal.length);
      expect(down.tierUpsSince(after), isEmpty);
    });
  });

  // ─── Reputación por entrega ─────────────────────────────────────────────────
  group('Reputación del patrón', () {
    test('S suma 2, A/B suman 1, C y F nada; una vez por día', () {
      final w = WorldState.initial();
      expect(w.applyPatronDelivery(Faction.legions, 'S', 'd1').gained, 2);
      expect(w.applyPatronDelivery(Faction.legions, 'B', 'd1').gained, 1);
      expect(w.applyPatronDelivery(Faction.legions, 'C', 'd1').gained, 0);

      final first = w.applyPatronDelivery(Faction.legions, 'A', 'd1');
      final again = first.world.applyPatronDelivery(Faction.legions, 'S', 'd1');
      expect(again.gained, 0, reason: 'tope diario por facción');
      final other =
          first.world.applyPatronDelivery(Faction.patricians, 'A', 'd1');
      expect(other.gained, 1, reason: 'el tope es por facción');
      final tomorrow = first.world.applyPatronDelivery(Faction.legions, 'A', 'd2');
      expect(tomorrow.gained, 1);
    });

    test('entregar una ruta con patrón suma reputación y la muestra',
        () async {
      final world = _World();
      final missions = _Missions([_mission('real_02', minutes: 480)]);
      final uc = CompleteMissionUseCase(
          missions, _Messengers([_messenger()]), world, kContent);
      final done = await uc.execute('m1');
      expect(done!.result.grade, 'A');
      expect(done.repDelta, {Faction.patricians: 1});
      expect(world.state.repOf(Faction.patricians), 1);

      // Segunda entrega el mismo día: no suma.
      missions.active.add(_mission('real_02', minutes: 480));
      final again = await uc.execute('m1');
      expect(again!.repDelta, isEmpty);
      expect(world.state.repOf(Faction.patricians), 1);
    });
  });

  // ─── Rutas ──────────────────────────────────────────────────────────────────
  group('Rutas de facción', () {
    RealMissionConfig route(String id) =>
        allRealMissions.firstWhere((r) => r.id == id);

    test('piden rango y reputación con quien las encarga', () {
      final appia = route('real_17');
      expect(appia.isOfferedTo(4, _withRep({Faction.legions: 29})), isFalse);
      expect(appia.isOfferedTo(4, _withRep({Faction.legions: 30})), isTrue);
      expect(appia.isOfferedTo(3, _withRep({Faction.legions: 60})), isFalse);
      expect(route('real_19').requiredRank, 5);
    });

    test('cada ruta de facción está en la escalera y tiene ritmo', () {
      for (final r in factionMissions) {
        final unlock = factionUnlocks
            .where((u) => u.kind == FactionUnlockKind.route && u.ref == r.id)
            .single;
        expect(unlock.faction, r.patron, reason: r.id);
        expect(unlock.tier.threshold, r.minReputation, reason: r.id);
        // Al menos un evento cada 8 h (skill balance).
        expect(r.minEvents * 8 * 60, greaterThanOrEqualTo(r.durationMinutes),
            reason: r.id);
        for (final e in r.eventPoolIds) {
          expect(kContent.eventById(e), isNotNull, reason: '${r.id}: $e');
        }
      }
    });

    test('todas las rutas tienen patrón y los desbloqueos no suman score', () {
      for (final r in allRealMissions) {
        expect(r.patron, isNotNull, reason: r.id);
      }
      for (final u in factionUnlocks) {
        if (u.kind == FactionUnlockKind.perk) expect(u.perk, isNotNull);
        if (u.kind != FactionUnlockKind.perk) expect(u.ref, isNotNull);
      }
      // Los únicos favores mecánicos: cambiar contrato y +10% de paga.
      expect(FactionPerk.values,
          [FactionPerk.contractReroll, FactionPerk.patronPay]);
    });

    test('la tarifa de facción sube la paga un 10%', () {
      expect(
          hasFactionPerk(factionUnlocks, _withRep({Faction.legions: 10}),
              FactionPerk.patronPay,
              faction: Faction.legions),
          isTrue);
      expect(
          hasFactionPerk(factionUnlocks, WorldState.initial(),
              FactionPerk.patronPay,
              faction: Faction.guild),
          isFalse,
          reason: 'el Gremio arranca en Conocido: su tarifa pide Leyenda');
    });
  });

  // ─── Cambiar contrato ───────────────────────────────────────────────────────
  group('Cambiar un contrato', () {
    test('pide Respetado con el Gremio y se usa una vez por día', () async {
      final guild = _Guild(GuildState.freshFor(DateTime(2026, 3, 2)));
      final first = guild.state.contracts.first.templateId;

      final low = RerollContractUseCase(guild, _World(), kContent);
      expect(() => low.execute(first), throwsException);

      final uc = RerollContractUseCase(
          guild, _World(_withRep({Faction.guild: 20})), kContent);
      final after = await uc.execute(first);
      final replaced = after.contracts.first;
      expect(replaced.templateId, isNot(first));
      expect(replaced.progress, 0);
      expect(after.contracts.map((c) => c.templateId).toSet(), hasLength(3));
      expect(after.rerollUsed, isTrue);
      expect(() => uc.execute(after.contracts[1].templateId), throwsException);
    });
  });

  // ─── Encargos semanales ─────────────────────────────────────────────────────
  group('Encargos semanales', () {
    const pool = weeklyCommissionPool;

    test('semana ISO: los bordes de año caen bien', () {
      expect(isoWeekKey(DateTime(2026, 1, 1)), '2026-W01'); // jueves
      expect(isoWeekKey(DateTime(2027, 1, 1)), '2026-W53'); // viernes
      expect(isoWeekKey(DateTime(2024, 12, 30)), '2025-W01'); // lunes
      // Lunes a domingo, misma semana.
      expect(isoWeekKey(DateTime(2026, 10, 5)), isoWeekKey(DateTime(2026, 10, 11)));
      expect(isoWeekKey(DateTime(2026, 10, 12)),
          isNot(isoWeekKey(DateTime(2026, 10, 11))));
    });

    test('tres por semana, el del Sello siempre, deterministas', () {
      final seen = <String>{};
      for (var w = 0; w < 30; w++) {
        final key = isoWeekKey(DateTime(2026, 1, 5).add(Duration(days: 7 * w)));
        final ids = weeklyIdsFor(key, pool);
        expect(ids, hasLength(3));
        expect(ids.first, kWeeklySealId);
        expect(ids.toSet(), hasLength(3));
        expect(weeklyIdsFor(key, pool), ids);
        seen.addAll(ids);
      }
      expect(seen.length, greaterThan(8), reason: 'que roten');
    });

    test('contenido: solo el del Sello da Sellos, nunca Aureos', () {
      expect(pool.map((d) => d.id).toSet(), hasLength(pool.length));
      for (final d in pool) {
        expect(d.seals, d.id == kWeeklySealId ? 1 : 0, reason: d.id);
        if (d.id != kWeeklySealId) {
          expect(d.denarios, inInclusiveRange(70, 110), reason: d.id);
        }
        if (d.goal == WeeklyGoal.patronDelivery) {
          expect(d.faction, isNotNull, reason: d.id);
        }
        expect(d.intro, isNotEmpty);
        expect(d.journal, isNotEmpty);
      }
    });

    test('avanza con entregas y eventos, cobra una vez y anota', () async {
      final repo = _Weekly();
      final now = DateTime(2026, 10, 6);
      final get = GetWeeklyUseCase(repo, kContent);
      // Forzamos un tablón conocido: Sello + rutas de Legiones + eventos.
      await repo.save(WeeklyState(weekKey: isoWeekKey(now), entries: const [
        WeeklyEntry(id: kWeeklySealId),
        WeeklyEntry(id: 'w_legion_routes'),
        WeeklyEntry(id: 'w_resolve6'),
      ]));
      final record = RecordWeeklyProgressUseCase(get, repo, kContent);

      // real_03 es de las Legiones; el tutorial no cuenta.
      await record.recordDelivery(_mission('real_04', tutorial: true), 'S',
          now: now);
      var s = await record.recordDelivery(_mission('real_03'), 'A', now: now);
      expect(s.entries[0].progress, 0, reason: 'A no es S');
      expect(s.entries[1].progress, 1);
      s = await record.recordDelivery(_mission('real_10'), 'S', now: now);
      expect(s.entries[0].progress, 1);
      expect(s.entries[1].progress, 2);
      s = await record.recordDelivery(_mission('real_13'), 'S', now: now);
      expect(s.entries[0].progress, 1, reason: 'no pasa del objetivo');
      s = await record.recordEvent(OutcomeType.fail, now: now);
      expect(s.entries[2].progress, 1);

      final messengers = _Messengers([_messenger()]);
      final world = _World();
      final claim = ClaimWeeklyCommissionUseCase(
          get, repo, messengers, world, kContent);
      await claim.execute(kWeeklySealId, now: now);
      final legion = await claim.execute('w_legion_routes', now: now);
      expect(messengers.list.first.seals, 1);
      expect(messengers.list.first.denarios, legion.def.denarios);
      expect(world.state.repOf(Faction.legions), 3);
      expect(world.state.journal.map((j) => j.text),
          contains(legion.def.journal));
      expect(() => claim.execute(kWeeklySealId, now: now), throwsException);
      expect(() => claim.execute('w_resolve6', now: now), throwsException);
    });

    test('el lunes se renueva el tablón', () async {
      final repo = _Weekly();
      final get = GetWeeklyUseCase(repo, kContent);
      final a = await get.execute(now: DateTime(2026, 10, 11)); // domingo
      final b = await get.execute(now: DateTime(2026, 10, 12)); // lunes
      expect(a.weekKey, isNot(b.weekKey));
      expect(b.entries.every((e) => e.progress == 0 && !e.claimed), isTrue);
    });

    test('el estado sobrevive el ida y vuelta por JSON', () {
      const s = WeeklyState(weekKey: '2026-W41', entries: [
        WeeklyEntry(id: kWeeklySealId, progress: 1, claimed: true),
        WeeklyEntry(id: 'w_deliver5', progress: 3),
      ]);
      final back = WeeklyState.fromJson(s.toJson());
      expect(back.weekKey, s.weekKey);
      expect(back.entries[0].claimed, isTrue);
      expect(back.entries[1].progress, 3);
    });
  });
}
