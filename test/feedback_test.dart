// Tests del feedback que recibe el jugador:
//  · el desglose "Por qué pasó" tiene que sumar EXACTAMENTE la tirada real
//  · el pronóstico previo tiene que usar la misma aritmética que la tirada
// Si alguien toca la fórmula de _calculateOutcome y no toca forecast.dart,
// estos tests se caen. Esa es toda su razón de existir.

import 'package:flutter_test/flutter_test.dart';
import 'package:the_messenger/data/static_game_content.dart';

import 'package:the_messenger/data/game_content_expansion.dart';
import 'package:the_messenger/data/story_content.dart';
import 'package:the_messenger/domain/entities/entities.dart';
import 'package:the_messenger/domain/entities/notifications.dart';
import 'package:the_messenger/domain/entities/world.dart';
import 'package:the_messenger/domain/repositories/repositories.dart';
import 'package:the_messenger/domain/entities/skill_tree.dart';
import 'package:the_messenger/domain/usecases/forecast.dart';
import 'package:the_messenger/domain/usecases/usecases.dart';

const kContent = StaticGameContent();

// ─── Fakes mínimos en memoria ─────────────────────────────────────────────────
class _FakeMessengerRepo implements MessengerRepository {
  final List<Messenger> messengers;
  _FakeMessengerRepo(this.messengers);

  @override
  Future<List<Messenger>> getAllMessengers() async => messengers;
  @override
  Future<Messenger?> getMessenger() async => messengers.firstOrNull;
  @override
  Future<void> saveMessenger(Messenger m) async {
    final i = messengers.indexWhere((x) => x.id == m.id);
    if (i != -1) messengers[i] = m;
  }

  @override
  Future<void> saveAllMessengers(List<Messenger> ms) async {
    messengers
      ..clear()
      ..addAll(ms);
  }

  @override
  Future<Messenger> createDefaultWithGender(String n, MessengerGender g) =>
      throw UnimplementedError();
  @override
  Future<Messenger> unlockSlot(
          {required Messenger payer,
          required String newName,
          required MessengerGender gender,
          required int slotIndex}) =>
      throw UnimplementedError();
}

class _FakeMissionRepo implements MissionRepository {
  Mission? saved;

  @override
  Future<void> saveMission(Mission mission) async => saved = mission;
  @override
  Future<Mission?> getActiveMissionFor(String id) async => saved;
  @override
  Future<List<Mission>> getAllActiveMissions() async =>
      saved == null ? [] : [saved!];
  @override
  Future<void> completeMission(String id, MissionResult r) async {}
  @override
  Future<List<Mission>> getCompletedMissions() async => [];
  @override
  Future<List<GameRoute>> getAvailableRoutes(int rank, WorldState world) async =>
      [];
  @override
  Future<Mission> createMission(GameRoute r, String id,
          {bool revealEvents = false,
      double payFactor = 1.0,
      List<String>? eventIds}) =>
      throw UnimplementedError();
  @override
  Future<Mission> createTutorialMission(int i, String id) =>
      throw UnimplementedError();
  @override
  Future<Mission> createStoryMission(
          StoryMissionConfig c, String id, List<RealEventConfig> events) =>
      throw UnimplementedError();
}

class _FakeWorldRepo implements WorldRepository {
  WorldState state = WorldState.initial();
  @override
  Future<WorldState> getState() async => state;
  @override
  Future<void> saveState(WorldState s) async => state = s;
}

// ─── Datos de prueba ──────────────────────────────────────────────────────────
Messenger _messenger({
  Map<SkillType, int>? skills,
  int fatigue = 0,
}) =>
    Messenger(
      id: 'm1',
      name: 'Marcus',
      gender: MessengerGender.male,
      health: 100,
      fatigue: fatigue,
      status: MessengerStatus.onMission,
      skills: skills ?? {for (final s in SkillType.values) s: 1},
      skillXp: const {},
      completedMissionIds: const [],
      tutorialPhase: 1,
      tutorialMissionIndex: 0,
      tutorialComplete: true,
    );

EventOption _option({
  int risk = 3,
  Map<SkillType, int> skills = const {},
  int timeCost = 0,
}) =>
    EventOption(
      id: 'opt_test',
      text: 'Probás suerte',
      riskLevel: risk,
      timeCostMinutes: timeCost,
      requiredSkills: skills,
      outcomeSuccess: 'Bien.',
      outcomePartial: 'Más o menos.',
      outcomeFail: 'Mal.',
    );

Mission _mission(MissionEvent event) => Mission(
      id: 'mis1',
      routeId: 'route_test',
      messengerId: 'm1',
      origin: 'Roma',
      destination: 'Ostia',
      packageDescription: 'Un tubo lacrado',
      lore: '',
      isTutorial: false,
      tutorialIndex: 0,
      startedAt: DateTime.now().subtract(const Duration(hours: 1)),
      deadlineAt: DateTime.now().add(const Duration(hours: 1)),
      progressPct: 40,
      status: MissionStatus.active,
      packageState: PackageState.intact,
      events: [event],
    );

MissionEvent _event(EventOption option) => MissionEvent(
      id: 'evt_test',
      title: 'Prueba',
      description: 'Algo pasa en el camino.',
      triggersAt: DateTime.now().subtract(const Duration(minutes: 5)),
      deadlineAt: DateTime.now().add(const Duration(minutes: 40)),
      status: EventStatus.active,
      options: [option],
    );

void main() {
  group('Desglose de la tirada', () {
    test('los factores suman exactamente el score', () async {
      // Varias combinaciones: sin skill, con skill, fatiga alta, riesgo extremo.
      final casos = <({Messenger m, EventOption o})>[
        (m: _messenger(), o: _option(risk: 1)),
        (
          m: _messenger(skills: {SkillType.stealth: 4}),
          o: _option(risk: 3, skills: {SkillType.stealth: 2})
        ),
        (
          m: _messenger(skills: {SkillType.stealth: 10}, fatigue: 85),
          o: _option(risk: 5, skills: {SkillType.stealth: 3})
        ),
        (
          m: _messenger(skills: {SkillType.combat: 7}, fatigue: 45),
          o: _option(risk: 4, skills: {SkillType.combat: 2})
        ),
      ];

      for (final caso in casos) {
        // Se repite: el azar cambia el score, pero la suma debe cerrar siempre.
        for (var i = 0; i < 25; i++) {
          final option = caso.o;
          final event = _event(option);
          final mission = _mission(event);
          final useCase = ResolveEventUseCase(
            _FakeMissionRepo(),
            _FakeMessengerRepo([caso.m]),
            _FakeWorldRepo(),
            kContent,
          );
          final res = await useCase.execute(
              mission: mission, event: event, option: option);

          final suma = res.scoreFactors.fold<int>(0, (acc, f) => acc + f.value);
          expect(suma, res.score,
              reason: 'El desglose que ve el jugador no cierra con la tirada');
        }
      }
    });

    test('el resultado se corresponde con los umbrales 55 / 30', () async {
      for (var i = 0; i < 40; i++) {
        final option = _option(risk: 3, skills: {SkillType.stealth: 2});
        final event = _event(option);
        final useCase = ResolveEventUseCase(
          _FakeMissionRepo(),
          _FakeMessengerRepo([
            _messenger(skills: {SkillType.stealth: 3})
          ]),
          _FakeWorldRepo(),
          kContent,
        );
        final res = await useCase.execute(
            mission: _mission(event), event: event, option: option);

        final esperado = res.score >= 55
            ? OutcomeType.success
            : res.score >= 30
                ? OutcomeType.partial
                : OutcomeType.fail;
        expect(res.outcome.type, esperado);
      }
    });

    test('el outcome registra la habilidad usada y su XP', () async {
      final option = _option(risk: 2, skills: {SkillType.survival: 1});
      final event = _event(option);
      final useCase = ResolveEventUseCase(
        _FakeMissionRepo(),
        _FakeMessengerRepo([_messenger()]),
        _FakeWorldRepo(),
        kContent,
      );
      final res = await useCase.execute(
          mission: _mission(event), event: event, option: option);
      expect(res.outcome.usedSkill, SkillType.survival);
      expect(res.outcome.xpGained, 25);
    });

    test('una opción sin habilidad no otorga XP', () async {
      final option = _option(risk: 1);
      final event = _event(option);
      final useCase = ResolveEventUseCase(
        _FakeMissionRepo(),
        _FakeMessengerRepo([_messenger()]),
        _FakeWorldRepo(),
        kContent,
      );
      final res = await useCase.execute(
          mission: _mission(event), event: event, option: option);
      expect(res.outcome.usedSkill, isNull);
      expect(res.outcome.xpGained, 0);
    });
  });

  group('Pronóstico', () {
    test('coincide con la parte determinística de la tirada', () async {
      // baseScore + azar debe caer siempre dentro del rango real de scores.
      final m = _messenger(skills: {SkillType.combat: 3}, fatigue: 50);
      final option = _option(risk: 3, skills: {SkillType.combat: 2});
      final pronostico = forecastFor(option, m);

      for (var i = 0; i < 60; i++) {
        final event = _event(option);
        final useCase = ResolveEventUseCase(
          _FakeMissionRepo(),
          _FakeMessengerRepo([
            _messenger(skills: {SkillType.combat: 3}, fatigue: 50)
          ]),
          _FakeWorldRepo(),
          kContent,
        );
        final res = await useCase.execute(
            mission: _mission(event), event: event, option: option);
        // El azar del camino va de -10 a +19 (sin contar tiradas críticas).
        final critico = res.scoreFactors
            .where(
                (f) => f.label == 'Imprevisto' || f.label == 'Golpe de suerte')
            .fold<int>(0, (acc, f) => acc + f.value);
        final sinCritico = res.score - critico;
        expect(sinCritico, greaterThanOrEqualTo(pronostico.baseScore - 10));
        expect(sinCritico, lessThanOrEqualTo(pronostico.baseScore + 19));
      }
    });

    test('mejor habilidad mejora la banda', () {
      final option = _option(risk: 3, skills: {SkillType.stealth: 2});
      final novato =
          forecastFor(option, _messenger(skills: {SkillType.stealth: 2}));
      final experto =
          forecastFor(option, _messenger(skills: {SkillType.stealth: 5}));
      expect(experto.band.index, lessThan(novato.band.index));
    });

    test('la fatiga alta empeora la banda y lo dice', () {
      final option = _option(risk: 3, skills: {SkillType.speed: 2});
      final descansado =
          forecastFor(option, _messenger(skills: {SkillType.speed: 3}));
      final agotado = forecastFor(
          option, _messenger(skills: {SkillType.speed: 3}, fatigue: 80));
      expect(agotado.band.index, greaterThanOrEqualTo(descansado.band.index));
      expect(agotado.reason.toLowerCase(), contains('agotado'));
    });

    test('el riesgo alto sin habilidad es temerario', () {
      final f = forecastFor(_option(risk: 5), _messenger());
      expect(f.band, anyOf(ForecastBand.risky, ForecastBand.reckless));
      expect(f.reason, isNotEmpty);
    });

    test('la opción prudente sin habilidad no se pinta como temeraria', () {
      // Riesgo 1 sin oficio: casi siempre sale parcial. Antes el pronóstico
      // solo contaba el éxito redondo y decía "tirarse al vacío".
      final f = forecastFor(_option(risk: 1), _messenger());
      expect(f.band.index, lessThanOrEqualTo(ForecastBand.uncertain.index));
    });

    test('el perk de Sigilo 10 baja el riesgo efectivo', () {
      final option = _option(risk: 5, skills: {SkillType.stealth: 3});
      final f =
          forecastFor(option, _messenger(skills: {SkillType.stealth: 10}));
      expect(f.effectiveRisk, 3); // 5 − 2 de "Invisible"
    });
  });

  group('Flags visibles', () {
    test('todo flag que activa una opción tiene texto para el jugador', () {
      // Si un flag no tiene descripción, la sección "Lo que cambió" no puede
      // contarlo y la decisión se siente sin consecuencia.
      final flagsEnContenido = <String>{};
      for (final e in [...allRealEvents, ...allStoryEvents]) {
        for (final o in e.options) {
          flagsEnContenido.addAll(o.setFlags ?? const []);
        }
      }
      for (final c in allStoryChapters) {
        flagsEnContenido.addAll(c.setFlagsOnComplete ?? const []);
      }

      final sinTexto =
          flagsEnContenido.where((f) => flagDescription(f) == null).toList();
      expect(sinTexto, isEmpty,
          reason: 'Estos flags no le dicen nada al jugador: $sinTexto');
    });
  });
  group('Reglas de avisos', () {
    test('el silencio nocturno corre los avisos a las 8', () {
      final medianoche = DateTime(2026, 7, 27, 23, 30);
      final corrido = applyQuietHours(medianoche, NotificationKind.delivery);
      expect(corrido.day, 28);
      expect(corrido.hour, kQuietEndHour);

      final madrugada = DateTime(2026, 7, 27, 3, 15);
      final corrido2 = applyQuietHours(madrugada, NotificationKind.idle);
      expect(corrido2.day, 27);
      expect(corrido2.hour, kQuietEndHour);
    });

    test('los eventos de una misión en curso sí pueden sonar de noche', () {
      final medianoche = DateTime(2026, 7, 27, 23, 30);
      expect(applyQuietHours(medianoche, NotificationKind.event), medianoche);
    });

    test('un horario diurno no se toca', () {
      final tarde = DateTime(2026, 7, 27, 15, 0);
      for (final kind in NotificationKind.values) {
        expect(applyQuietHours(tarde, kind), tarde);
      }
    });

    test('isQuietHour cubre los bordes', () {
      expect(isQuietHour(DateTime(2026, 7, 27, 21, 59)), isFalse);
      expect(isQuietHour(DateTime(2026, 7, 27, 22, 0)), isTrue);
      expect(isQuietHour(DateTime(2026, 7, 27, 7, 59)), isTrue);
      expect(isQuietHour(DateTime(2026, 7, 27, 8, 0)), isFalse);
    });

    test('las preferencias se apagan y prenden por tipo', () {
      var prefs = const NotificationPrefs();
      expect(prefs.allows(NotificationKind.event), isTrue);

      prefs = prefs.toggle(NotificationKind.event);
      expect(prefs.allows(NotificationKind.event), isFalse);
      expect(prefs.allows(NotificationKind.delivery), isTrue);

      prefs = prefs.toggle(NotificationKind.event);
      expect(prefs.allows(NotificationKind.event), isTrue);

      // El interruptor general manda sobre todo lo demás.
      prefs = prefs.copyWith(enabled: false);
      for (final kind in NotificationKind.values) {
        expect(prefs.allows(kind), isFalse);
      }
    });

    test('la ventana de decisión es la del GDD', () {
      expect(kDecisionWindowMinutes, 60);
    });
  });

  group('Árbol legible', () {
    test('cada nivel dice cuánto suma a la tirada', () {
      for (final skill in SkillType.values) {
        for (var level = 1; level <= kMaxSkillLevelElite; level++) {
          final efectos = skillEffectsAt(skill, level);
          final suma =
              efectos.firstWhere((e) => e.label == 'Suma a tus tiradas');
          expect(suma.value, '+${level * 15}');
        }
      }
    });

    test('subir de nivel siempre cambia algo visible', () {
      for (final skill in SkillType.values) {
        for (var level = 1; level < kMaxSkillLevelElite; level++) {
          expect(skillLevelDelta(skill, level), isNotEmpty,
              reason: '$skill Nv.$level → ${level + 1} no muestra ninguna '
                  'mejora: el jugador no sabe para qué sube');
        }
      }
      expect(skillLevelDelta(SkillType.speed, kMaxSkillLevelElite), isEmpty);
    });

    test('los efectos mostrados salen de SkillPerks, no de texto suelto', () {
      // Contactos 10 paga +20%: si alguien toca el perk, esto se cae.
      final contactos = skillEffectsAt(SkillType.contacts, 10);
      expect(contactos.any((e) => e.value == '+20%'), isTrue);
      // Supervivencia 10 anula el castigo por fatiga.
      final superv = skillEffectsAt(SkillType.survival, 10);
      expect(superv.any((e) => e.value == 'ninguno'), isTrue);
    });

    test('todos los niveles élite tienen precio en Sellos', () {
      for (var level = 6; level <= kMaxSkillLevelElite; level++) {
        expect(sealCostForLevel[level], isNotNull);
      }
      expect(sealCostForLevel.values.reduce((a, b) => a + b), 50);
    });
  });

  group('Calidad del contenido', () {
    test('ningún evento tiene dos opciones normales con el mismo perfil', () {
      // Si dos opciones cuestan lo mismo y arriesgan lo mismo, elegir no
      // significa nada. Las opciones secretas quedan afuera: su valor es
      // haberlas desbloqueado con la historia, no el intercambio de riesgo.
      for (final e in [...allRealEvents, ...allStoryEvents]) {
        final perfiles = e.options
            .where((o) => o.requiredFlag == null)
            .map((o) => '${o.riskLevel}/${o.timeCostMinutes}/'
                '${o.requiredSkills.keys.map((k) => k.name).join("+")}')
            .toList();
        expect(perfiles.toSet().length, perfiles.length,
            reason: 'El evento ${e.id} tiene opciones indistinguibles');
      }
    });

    test('los eventos del pool común siempre tienen una salida prudente', () {
      // Se aplica al pool que se repite misión tras misión. Los eventos de
      // arco quedan exentos a propósito: en el clímax de una historia es
      // legítimo que no haya ninguna opción cómoda.
      for (final e in allRealEvents) {
        final riesgos = e.options.map((o) => o.riskLevel).toList();
        expect(riesgos.reduce((a, b) => a < b ? a : b), lessThanOrEqualTo(2),
            reason: '${e.id} no tiene ninguna salida prudente');
        expect(riesgos.reduce((a, b) => a > b ? a : b), greaterThan(1),
            reason: '${e.id} no tiene ninguna opción con peligro real');
      }
    });

    test('las opciones secretas piden un flag que alguien otorga', () {
      final otorgados = <String>{};
      for (final e in [...allRealEvents, ...allStoryEvents]) {
        for (final o in e.options) {
          otorgados.addAll(o.setFlags ?? const []);
        }
      }
      for (final c in allStoryChapters) {
        otorgados.addAll(c.setFlagsOnComplete ?? const []);
      }

      final pedidos = <String>{};
      for (final e in [...allRealEvents, ...allStoryEvents]) {
        for (final o in e.options) {
          if (o.requiredFlag != null) pedidos.add(o.requiredFlag!);
        }
      }
      final sinOrigen = pedidos.difference(otorgados);
      expect(sinOrigen, isEmpty,
          reason: 'Opciones que nunca se pueden desbloquear: $sinOrigen');
    });
  });
}
