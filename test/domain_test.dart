import 'package:flutter_test/flutter_test.dart';
import 'package:the_messenger/domain/entities/entities.dart';
import 'package:the_messenger/domain/entities/guild.dart';
import 'package:the_messenger/domain/entities/skill_tree.dart';
import 'package:the_messenger/domain/entities/world.dart';
import 'package:the_messenger/data/story_content.dart';
import 'package:the_messenger/data/game_content.dart';

Messenger _messenger({Map<SkillType, int>? skills, int seals = 0}) => Messenger(
      id: 'm1',
      name: 'Test',
      gender: MessengerGender.male,
      health: 100,
      fatigue: 0,
      status: MessengerStatus.idle,
      skills: skills ?? {for (final s in SkillType.values) s: 1},
      skillXp: {for (final s in SkillType.values) s: 0},
      completedMissionIds: const [],
      tutorialPhase: 1,
      tutorialMissionIndex: 4,
      tutorialComplete: true,
      seals: seals,
    );

void main() {
  group('Caminos del Mensajero', () {
    test('cada camino tiene 10 nodos con nombre y perk', () {
      for (final skill in SkillType.values) {
        final nodes = skillTree[skill]!;
        expect(nodes.length, kMaxSkillLevelElite);
        for (var i = 0; i < nodes.length; i++) {
          expect(nodes[i].level, i + 1);
          expect(nodes[i].name, isNotEmpty);
          expect(nodes[i].perk, isNotEmpty);
        }
      }
    });

    test('costos de ascenso definidos para niveles 6-10', () {
      expect(sealCostForLevel.keys, containsAll([6, 7, 8, 9, 10]));
      // Escalado creciente
      expect(sealCostForLevel[6]!, lessThan(sealCostForLevel[10]!));
    });

    test('perk de Velocidad reduce duración de misiones', () {
      final base = _messenger();
      final veloz = _messenger(skills: {
        for (final s in SkillType.values) s: s == SkillType.speed ? 10 : 1
      });
      expect(SkillPerks.missionDurationFactor(base), 1.0);
      expect(SkillPerks.missionDurationFactor(veloz), 0.88);
      expect(SkillPerks.gradeSBonus(veloz), 25);
    });

    test('perk de Sigilo 6 relaja el gating de opciones de sigilo', () {
      const option = EventOption(
        id: 'o1', text: 'Rodeás por el callejón',
        riskLevel: 3, timeCostMinutes: 0,
        requiredSkills: {SkillType.stealth: 7},
      );
      final sigiloso6 = _messenger(skills: {
        for (final s in SkillType.values) s: s == SkillType.stealth ? 6 : 1
      });
      // Nivel 6 con requisito 7: pasa gracias al descuento del perk.
      expect(meetsOptionRequirements(option, sigiloso6), isTrue);
      expect(meetsOptionRequirements(option, _messenger()), isFalse);
    });

    test('Supervivencia reduce fatiga y su penalización', () {
      final superviviente = _messenger(skills: {
        for (final s in SkillType.values) s: s == SkillType.survival ? 10 : 1
      });
      expect(SkillPerks.fatiguePerEvent(_messenger()), 8);
      expect(SkillPerks.fatiguePerEvent(superviviente), 4);
      expect(SkillPerks.fatiguePenaltyFactor(superviviente), 0.0);
    });

    test('Contactos multiplica la paga', () {
      final conectado = _messenger(skills: {
        for (final s in SkillType.values) s: s == SkillType.contacts ? 8 : 1
      });
      expect(SkillPerks.payMultiplier(conectado), 1.12);
    });

    test('ascendSkill sube hasta 10 y no más', () {
      var m = _messenger(skills: {
        for (final s in SkillType.values) s: s == SkillType.combat ? 9 : 1
      });
      m = m.ascendSkill(SkillType.combat);
      expect(m.skillLevel(SkillType.combat), 10);
      m = m.ascendSkill(SkillType.combat);
      expect(m.skillLevel(SkillType.combat), 10);
    });
  });

  group('Gremio', () {
    test('el tablón diario siempre tiene 3 contratos y el 3° paga Sello', () {
      final state = GuildState.freshFor(DateTime(2026, 7, 9));
      expect(state.contracts.length, 3);
      expect(state.contracts[2].template.reward.seals, greaterThan(0));
    });

    test('los contratos son deterministas por fecha', () {
      final a = contractIdsForDate(DateTime(2026, 7, 9));
      final b = contractIdsForDate(DateTime(2026, 7, 9));
      final c = contractIdsForDate(DateTime(2026, 7, 10));
      expect(a, b);
      expect(a, isNot(equals(c)));
    });

    test('la racha continúa si se cobró ayer y se corta si no', () {
      final yesterday =
          dateKey(DateTime.now().subtract(const Duration(days: 1)));
      final continua = GuildState.freshFor(DateTime.now(),
          streakDay: 3, lastPayDate: yesterday);
      expect(continua.nextPayDay, 4);

      final cortada = GuildState.freshFor(DateTime.now(),
          streakDay: 3, lastPayDate: '2020-01-01');
      expect(cortada.nextPayDay, 1);
    });

    test('la racha cicla después del día 7', () {
      final yesterday =
          dateKey(DateTime.now().subtract(const Duration(days: 1)));
      final state = GuildState.freshFor(DateTime.now(),
          streakDay: 7, lastPayDate: yesterday);
      expect(state.nextPayDay, 1);
    });

    test('no se puede cobrar dos veces el mismo día', () {
      final state = GuildState.freshFor(DateTime.now(),
          streakDay: 1, lastPayDate: dateKey(DateTime.now()));
      expect(state.canClaimDailyPay, isFalse);
    });
  });

  group('El mundo recuerda', () {
    test('reputación inicial: Gremio +10, resto en 0', () {
      final w = WorldState.initial();
      expect(w.repOf(Faction.guild), 10);
      expect(w.repOf(Faction.legions), 0);
    });

    test('applyRepDeltas suma y respeta el clamp -100..100', () {
      var w = WorldState.initial();
      w = w.applyRepDeltas({Faction.underworld: 3, Faction.patricians: -2});
      expect(w.repOf(Faction.underworld), 3);
      expect(w.repOf(Faction.patricians), -2);
      w = w.applyRepDeltas({Faction.underworld: 200});
      expect(w.repOf(Faction.underworld), 100);
    });

    test('los flags y el diario se acumulan', () {
      var w = WorldState.initial();
      w = w.addFlags(['paid_bandits']).addJournal('Pagué el peaje.');
      expect(w.hasFlag('paid_bandits'), isTrue);
      expect(w.journal.length, 1);
    });

    test('reputationTitle escala con el valor', () {
      expect(reputationTitle(70), 'Leyenda');
      expect(reputationTitle(0), 'Desconocido');
      expect(reputationTitle(-50), 'Enemigo');
    });

    test('opción con requiredFlag es invisible sin el flag', () {
      const secret = EventOption(
        id: 'o', text: '...', riskLevel: 1, timeCostMinutes: 0,
        requiredSkills: {}, requiredFlag: 'paid_bandits',
      );
      expect(optionVisible(secret, WorldState.initial()), isFalse);
      expect(
          optionVisible(secret,
              WorldState.initial().addFlags(['paid_bandits'])),
          isTrue);
    });

    test('gating por reputación mínima', () {
      const gated = EventOption(
        id: 'o', text: '...', riskLevel: 1, timeCostMinutes: 0,
        requiredSkills: {}, minReputation: {Faction.patricians: 20},
      );
      expect(meetsOptionRequirements(gated, null,
          world: WorldState.initial()), isFalse);
      expect(
          meetsOptionRequirements(gated, null,
              world: WorldState.initial()
                  .applyRepDeltas({Faction.patricians: 25})),
          isTrue);
    });
  });

  group('Arco 1 — La Sombra del Senado', () {
    test('tiene 5 capítulos y todos los eventos existen', () {
      for (var stage = 0; stage < arcStageCount(kArcClaudius); stage++) {
        // Al menos una variante por stage (con o sin flags).
        final anyVariant = storyArcClaudius.where((m) => m.stage == stage);
        expect(anyVariant, isNotEmpty, reason: 'stage $stage sin capítulo');
        for (final m in anyVariant) {
          for (final id in m.fixedEventIds) {
            expect(storyEventById(id), isNotNull,
                reason: 'evento $id no existe');
          }
        }
      }
    });

    test('el capítulo IV ramifica según el bando elegido', () {
      final varus = storyMissionFor(kArcClaudius, 3, {'path_varus'});
      final claudius = storyMissionFor(kArcClaudius, 3, {'path_claudius'});
      final under = storyMissionFor(kArcClaudius, 3, {'path_underworld'});
      expect(varus?.id, 'claudius_4_varus');
      expect(claudius?.id, 'claudius_4_claudius');
      expect(under?.id, 'claudius_4_underworld');
    });

    test('los capítulos finales otorgan endingId distinto por bando', () {
      final endVarus = storyMissionFor(kArcClaudius, 4, {'path_varus'});
      final endUnder = storyMissionFor(kArcClaudius, 4, {'path_underworld'});
      expect(endVarus?.isFinal, isTrue);
      expect(endVarus?.endingId, 'end_varus');
      expect(endUnder?.endingId, 'end_underworld');
      // El final de los Bajos Fondos abre la ruta nocturna.
      expect(endUnder?.setFlagsOnComplete, contains('route_nocturna_unlocked'));
    });

    test('sin flag de bando, el capítulo IV no está disponible', () {
      expect(storyMissionFor(kArcClaudius, 3, {}), isNull);
    });

    test('el arco se marca completo con el final elegido', () {
      final w = WorldState.initial()
          .copyWith(completedArcs: {'$kArcClaudius:end_varus'});
      expect(w.arcCompleted(kArcClaudius), isTrue);
    });
  });

  group('Adelantar el tiempo', () {
    MissionEvent futureEvent(Duration inFuture) {
      final t = DateTime.now().add(inFuture);
      return MissionEvent(
        id: 'e', title: 't', description: 'd',
        triggersAt: t, deadlineAt: t.add(const Duration(minutes: 45)),
        status: EventStatus.pending, options: const [],
      );
    }

    test('shiftBy adelanta triggersAt y deadlineAt juntos', () {
      final e = futureEvent(const Duration(hours: 2));
      final shifted = e.shiftBy(const Duration(hours: -2));
      // El evento queda ~ahora (a decidir), sin resolverse.
      expect(shifted.triggersAt.isBefore(DateTime.now().add(const Duration(minutes: 1))), isTrue);
      expect(shifted.status, EventStatus.pending);
      expect(shifted.outcome, isNull);
      // La ventana de decisión de 45 min se conserva.
      expect(shifted.deadlineAt.difference(shifted.triggersAt).inMinutes, 45);
    });

    test('adelantar deja el evento activable, no resuelto', () {
      // Simula el resultado del skip: el evento se trae al pasado inmediato.
      final e = futureEvent(const Duration(hours: 3));
      final advance = e.triggersAt.difference(DateTime.now()) +
          const Duration(seconds: 1);
      final shifted = e.shiftBy(-advance);
      final now = DateTime.now();
      // Ya "llegó" (bloquea) pero sigue pendiente de decisión.
      expect(now.isBefore(shifted.triggersAt), isFalse);
      expect(now.isAfter(shifted.deadlineAt), isFalse); // aún dentro de la ventana
      expect(shifted.status, EventStatus.pending);
    });
  });

  group('Eventos con prosa', () {
    test('todos los eventos reales tienen prosa por opción', () {
      for (final e in realEventPool) {
        for (final o in e.options) {
          expect(o.outcomeSuccess, isNotNull,
              reason: '${e.id}/${o.id} sin prosa de éxito');
          expect(o.outcomeFail, isNotNull,
              reason: '${e.id}/${o.id} sin prosa de fallo');
        }
      }
    });

    test('el follow-up de huir de bandidos apunta a un evento real', () {
      final bandits = realEventPool.firstWhere((e) => e.id == 'evt_bandits');
      final flee = bandits.options.firstWhere((o) => o.id == 'opt_run');
      expect(flee.followUpEventId, 'evt_bandits_revenge');
      expect(realEventPool.any((e) => e.id == flee.followUpEventId), isTrue);
    });
  });
}
