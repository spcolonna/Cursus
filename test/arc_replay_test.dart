// Volver a recorrer un arco terminado: corre aparte de la partida, y un
// final nuevo suma a la galería y abre su premio.
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_messenger/data/static_game_content.dart';
import 'package:the_messenger/data/story_content.dart';
import 'package:the_messenger/domain/entities/entities.dart';
import 'package:the_messenger/domain/entities/world.dart';
import 'package:the_messenger/domain/repositories/repositories.dart';
import 'package:the_messenger/domain/usecases/usecases.dart';
import 'package:the_messenger/infrastructure/local/local_repositories.dart';

const kContent = StaticGameContent();

// ─── Fakes en memoria ─────────────────────────────────────────────────────────
class _MessengerRepo implements MessengerRepository {
  final List<Messenger> messengers;
  _MessengerRepo(this.messengers);

  @override
  Future<List<Messenger>> getAllMessengers() async => List.of(messengers);
  @override
  Future<Messenger?> getMessenger() async => messengers.firstOrNull;
  @override
  Future<void> saveMessenger(Messenger m) async {
    final i = messengers.indexWhere((x) => x.id == m.id);
    if (i != -1) {
      messengers[i] = m;
    } else {
      messengers.add(m);
    }
  }

  @override
  Future<void> saveAllMessengers(List<Messenger> ms) async => messengers
    ..clear()
    ..addAll(ms);
  @override
  Future<Messenger> createDefaultWithGender(String n, MessengerGender g) =>
      throw UnimplementedError();
  @override
  Future<Messenger> unlockSlot(
      {required Messenger payer,
      required String newName,
      required MessengerGender gender,
      required int slotIndex}) async {
    final cost = messengerSlotCosts[slotIndex]!;
    if (payer.aureos < cost) throw Exception('Aureos insuficientes');
    await saveMessenger(payer.copyWith(aureos: payer.aureos - cost));
    final m = _messenger(id: 'm$slotIndex', name: newName);
    messengers.add(m);
    return m;
  }
}

class _MissionRepo implements MissionRepository {
  Mission? saved;
  MissionResult? completed;
  _MissionRepo([this.saved]);

  @override
  Future<void> saveMission(Mission mission) async => saved = mission;
  @override
  Future<Mission?> getActiveMissionFor(String id) async => saved;
  @override
  Future<List<Mission>> getAllActiveMissions() async =>
      saved == null ? [] : [saved!];
  @override
  Future<void> completeMission(String id, MissionResult r) async =>
      completed = r;
  @override
  Future<List<Mission>> getCompletedMissions() async => [];
  @override
  Future<List<GameRoute>> getAvailableRoutes(
          int rank, WorldState world) async =>
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

class _WorldRepo implements WorldRepository {
  WorldState state = WorldState.initial();
  @override
  Future<WorldState> getState() async => state;
  @override
  Future<void> saveState(WorldState s) async => state = s;
}

// ─── Datos de prueba ──────────────────────────────────────────────────────────
Messenger _messenger({
  String id = 'm1',
  String name = 'Marcus',
  Map<SkillType, int>? skills,
  Set<String> boosts = const {},
  int denarios = 0,
  int aureos = 0,
}) =>
    Messenger(
      id: id,
      name: name,
      gender: MessengerGender.male,
      health: 100,
      fatigue: 0,
      status: MessengerStatus.onMission,
      skills: skills ?? {for (final s in SkillType.values) s: 1},
      skillXp: const {},
      completedMissionIds: const [],
      tutorialPhase: 1,
      tutorialMissionIndex: 0,
      tutorialComplete: true,
      activeBoosts: boosts,
      denarios: denarios,
      aureos: aureos,
    );

Mission _storyMission(String chapterId, {String arcId = kArcClaudius}) {
  final now = DateTime.now();
  return Mission(
    id: 'mis1',
    routeId: chapterId,
    messengerId: 'm1',
    origin: 'Roma',
    destination: 'Tibur',
    packageDescription: 'Un tubo lacrado',
    lore: '',
    isTutorial: false,
    tutorialIndex: 0,
    startedAt: now.subtract(const Duration(hours: 2)),
    deadlineAt: now.subtract(const Duration(minutes: 1)),
    progressPct: 100,
    status: MissionStatus.active,
    packageState: PackageState.intact,
    events: const [],
    arcId: arcId,
  );
}

/// La partida terminó el arco 1 por el camino de Varus.
WorldState _canon() => WorldState.initial().copyWith(
      flags: {'path_varus', 'told_varus', 'ending_varus', 'claudius_vetoed'},
      completedArcs: {'$kArcClaudius:end_varus'},
      arcProgress: {kArcClaudius: 4},
    );

void main() {
  group('Recorrido de un arco', () {
    test('solo se empieza con el arco terminado y sin capítulos en viaje',
        () async {
      final world = _WorldRepo()..state = WorldState.initial();
      final uc = StartArcReplayUseCase(world, _MissionRepo(), kContent);
      expect(() => uc.execute(kArcClaudius), throwsException);

      world.state = _canon();
      final busy = StartArcReplayUseCase(
          world,
          _MissionRepo(_storyMission('lucius_1_varus', arcId: kArcLucius)),
          kContent);
      expect(() => busy.execute(kArcClaudius), throwsException);

      await uc.execute(kArcClaudius);
      final r = world.state.replay!;
      expect(r.arcId, kArcClaudius);
      expect(r.stage, 0);
      // Lo que decidió la partida en el arco deja de contar...
      expect(
          r.hidden, containsAll(['path_varus', 'told_varus', 'ending_varus']));
      // ...y la partida en sí no cambia.
      expect(world.state.flags, _canon().flags);
    });

    test('el arco recorrido ve sus propios flags; el resto, los de la partida',
        () {
      final w = _canon().copyWith(
        replay: const ArcReplay(
          arcId: kArcClaudius,
          stage: 3,
          flags: {'path_claudius'},
          hidden: {'path_varus', 'told_varus', 'ending_varus'},
        ),
      );
      final view = w.viewFor(kArcClaudius);
      expect(view.hasFlag('path_claudius'), isTrue);
      expect(view.hasFlag('path_varus'), isFalse);
      expect(view.hasFlag('claudius_vetoed'), isTrue);
      expect(w.viewFor(kArcLucius).hasFlag('path_varus'), isTrue);

      final step = nextStoryStep(kContent, w)!;
      expect(step.isReplay, isTrue);
      expect(step.chapter.id, 'claudius_4_claudius');
    });

    test('las decisiones del recorrido no tocan reputación ni diario', () {
      final w = _canon().copyWith(replay: const ArcReplay(arcId: kArcClaudius));
      final next = w.applyChoiceEffectsFor(kArcClaudius,
          repDelta: {Faction.patricians: 3},
          setFlags: ['path_claudius'],
          journalNote: 'algo');
      expect(next.reputation, w.reputation);
      expect(next.journal, isEmpty);
      expect(next.flags, w.flags);
      expect(next.replay!.flags, {'path_claudius'});
    });

    test(
        'un final nuevo suma a la galería, abre su premio y cierra el recorrido',
        () async {
      final world = _WorldRepo()
        ..state = _canon().copyWith(
          replay: const ArcReplay(
            arcId: kArcClaudius,
            stage: 4,
            flags: {'path_claudius'},
            hidden: {'path_varus', 'ending_varus'},
          ),
        );
      final completion = await CompleteMissionUseCase(
              _MissionRepo(_storyMission('claudius_5_claudius')),
              _MessengerRepo([_messenger()]),
              world,
              kContent)
          .execute('m1');
      expect(completion!.isReplay, isTrue);
      expect(completion.endingIsNew, isTrue);
      expect(completion.endingId, 'end_claudius');
      final s = world.state;
      expect(s.replay, isNull);
      expect(s.endingsFound,
          {'$kArcClaudius:end_varus', '$kArcClaudius:end_claudius'});
      expect(s.hasFlag('ending_claudius'), isTrue);
      // Las consecuencias de ese final no pisan las de la partida.
      expect(s.hasFlag('varus_cold'), isFalse);
      expect(s.arcProgress[kArcClaudius], 4);
      expect(s.reputation, _canon().reputation);
    });

    test('el recorrido se guarda y se recupera', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = LocalWorldRepository();
      await repo.saveState(_canon().copyWith(
        replay: const ArcReplay(
            arcId: kArcLucius, stage: 2, flags: {'a'}, hidden: {'b'}),
      ));
      final r = (await repo.getState()).replay!;
      expect((r.arcId, r.stage), (kArcLucius, 2));
      expect(r.flags, {'a'});
      expect(r.hidden, {'b'});
    });

    test('cada final tiene pista y los tres arcos suman 9', () {
      final endings = [
        for (final a in kContent.arcs) ...kContent.endingsOf(a.id),
      ];
      expect(endings, hasLength(9));
      for (final e in endings) {
        expect(kContent.endingHint(e.endingId!), isNotNull, reason: e.id);
      }
    });
  });
}
