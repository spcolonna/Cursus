import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_messenger/data/game_content.dart';
import 'package:the_messenger/data/game_content_expansion.dart';
import 'package:the_messenger/data/geo_content.dart';
import 'package:the_messenger/data/npc_content.dart';
import 'package:the_messenger/data/static_game_content.dart';
import 'package:the_messenger/data/story_content.dart';
import 'package:the_messenger/domain/entities/entities.dart';
import 'package:the_messenger/domain/entities/geo.dart';
import 'package:the_messenger/infrastructure/audio/sfx_service.dart';
import 'package:the_messenger/infrastructure/local/local_repositories.dart';
import 'package:the_messenger/presentation/widgets/art_image.dart';
import 'package:the_messenger/presentation/widgets/messenger_avatar.dart';
import 'package:the_messenger/presentation/widgets/widgets.dart';
import 'helpers/localized_app.dart';

void main() {
  // ─── ArtImage ───
  group('ArtImage', () {
    const fallback = Text('vector', textDirection: TextDirection.ltr);

    testWidgets('sin la ilustración en el bundle dibuja el fallback',
        (tester) async {
      ArtCatalog.debugSet(const {});
      await tester.pumpWidget(
          const ArtImage(asset: 'assets/art/events/evt_x.jpg', fallback: fallback));
      expect(find.text('vector'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('si el archivo está anotado pero no carga, también',
        (tester) async {
      const asset = 'assets/art/events/evt_roto.jpg';
      ArtCatalog.debugSet(const {asset});
      await tester.pumpWidget(const ArtImage(asset: asset, fallback: fallback));
      await tester.pumpAndSettle();
      expect(find.text('vector'), findsOneWidget);
      ArtCatalog.debugSet(const {});
    });

    test('las rutas de cada pieza siguen la convención', () {
      expect(ArtPaths.event('evt_storm'), 'assets/art/events/evt_storm.jpg');
      expect(ArtPaths.npc('varus'), 'assets/art/npcs/varus.jpg');
      expect(ArtPaths.story('claudius_1'), 'assets/art/story/claudius_1.jpg');
      expect(ArtPaths.ending('end_varus'), 'assets/art/endings/end_varus.jpg');
    });
  });

  // ─── Mapas ───
  group('Atlas', () {
    bool inside(MapPoint p) => p.x >= 0 && p.x <= 1 && p.y >= 0 && p.y <= 1;

    test('todas las rutas reales tienen trazado dentro del mapa', () {
      for (final r in allRealMissions) {
        final g = geoAtlas.routeFor(r.id, r.origin, r.destination);
        expect(g, isNotNull, reason: '${r.id}: ${r.origin} → ${r.destination}');
        expect(g!.map, MapKind.italy, reason: r.id);
        expect(g.points.length, greaterThanOrEqualTo(2), reason: r.id);
        expect(g.points.every(inside), isTrue, reason: r.id);
      }
    });

    test('los capítulos de historia y el tutorial caen en el plano de Roma', () {
      final urban = [
        for (final s in storyArcClaudius) (s.id, s.origin, s.destination),
        for (final t in tutorialMissions) (t.id, t.origin, t.destination),
      ];
      for (final (id, o, d) in urban) {
        final g = geoAtlas.routeFor(id, o, d);
        expect(g, isNotNull, reason: '$id: $o → $d');
        expect(g!.map, MapKind.rome, reason: id);
        expect(g.points.every(inside), isTrue, reason: id);
      }
    });

    test('los puntos de paso y las vías nombran ciudades del atlas', () {
      for (final via in [
        ...geoAtlas.routeWaypoints.values,
        ...geoAtlas.roads.values,
      ]) {
        for (final name in via) {
          expect(geoAtlas.cities.containsKey(name), isTrue, reason: name);
        }
      }
    });

    test('las rutas por mar están en el catálogo de trazados', () {
      for (final id in geoAtlas.seaRoutes) {
        expect(geoAtlas.routeWaypoints.containsKey(id), isTrue, reason: id);
      }
    });

    test('el nombre base saca los apodos de la ruta', () {
      expect(GeoAtlas.baseName('Neapolis por mar, de noche'), 'Neapolis');
      expect(GeoAtlas.baseName('Ostia — Muelle Viejo'), 'Ostia');
      expect(GeoAtlas.baseName('Roma'), 'Roma');
    });
  });

  // ─── Escenarios y personajes ───
  group('Contenido con arte', () {
    final npcIds = {for (final n in allNpcs) n.id};

    test('los ids de NPC son únicos y en snake_case', () {
      expect(npcIds.length, allNpcs.length);
      for (final id in npcIds) {
        expect(RegExp(r'^[a-z_]+$').hasMatch(id), isTrue, reason: id);
      }
    });

    test('cada npcId de un evento existe', () {
      final events = [
        ...allRealEvents.map((e) => (e.id, e.npcId)),
        ...allStoryEvents.map((e) => (e.id, e.npcId)),
        ...tutorialEvents.map((e) => (e.id, e.npcId)),
      ];
      for (final (id, npc) in events) {
        if (npc == null) continue;
        expect(npcIds.contains(npc), isTrue, reason: '$id → $npc');
      }
    });

    test('los NPC de los encargos semanales tienen retrato', () {
      for (final w in const StaticGameContent().weeklyCommissions) {
        expect(npcIds.contains(NpcDef.idFromName(w.npcName)), isTrue,
            reason: w.npcName);
      }
    });

    test('ningún evento del pool queda sin escenario propio salvo el camino', () {
      // El camino abierto es el escenario por defecto: que los eventos de
      // ciudad, río o templo no caigan ahí por olvido.
      final road = allRealEvents
          .where((e) => e.category == EventCategory.road)
          .map((e) => e.id)
          .toList();
      expect(road.length, lessThan(allRealEvents.length ~/ 2),
          reason: 'demasiados eventos en "road": $road');
    });

    test('idFromName saca tildes y espacios', () {
      expect(NpcDef.idFromName('Décimo'), 'decimo');
      expect(NpcDef.idFromName('la Viuda'), 'la_viuda');
    });
  });

  // ─── Migración de MissionEvent ───
  group('MissionEvent v2', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('una misión nueva guarda configId, escenario y personaje', () async {
      final repo = LocalMissionRepository();
      final cfg = allRealMissions.first;
      final m = await repo.createMission(_routeOf(cfg), 'm1');
      expect(m.events, isNotEmpty);
      for (final e in m.events) {
        expect(cfg.eventPoolIds, contains(e.configId));
      }
      final loaded = (await repo.getAllActiveMissions()).single;
      expect(loaded.events.map((e) => e.configId),
          m.events.map((e) => e.configId));
      expect(loaded.events.map((e) => e.category),
          m.events.map((e) => e.category));
    });

    test('un guardado sin configId se reconoce por el título', () async {
      final repo = LocalMissionRepository();
      final m = await repo.createMission(_routeOf(allRealMissions.first), 'm1');
      final p = await SharedPreferences.getInstance();
      // Simula el formato de antes de la Fase 4.
      final raw = jsonDecode(p.getString('active_missions_v2')!) as List;
      for (final mission in raw) {
        for (final e in (mission as Map)['events'] as List) {
          (e as Map)
            ..remove('configId')
            ..remove('category')
            ..remove('npcId');
        }
      }
      await p.setString('active_missions_v2', jsonEncode(raw));

      final loaded = (await repo.getAllActiveMissions()).single;
      for (final (i, e) in loaded.events.indexed) {
        expect(e.configId, m.events[i].configId);
        expect(e.category, m.events[i].category);
      }
    });

    test('un título desconocido queda sin configId y en el camino', () async {
      final repo = LocalMissionRepository();
      await repo.createMission(_routeOf(allRealMissions.first), 'm1');
      final p = await SharedPreferences.getInstance();
      final raw = jsonDecode(p.getString('active_missions_v2')!) as List;
      final e = ((raw.first as Map)['events'] as List).first as Map;
      e
        ..remove('configId')
        ..remove('category')
        ..['title'] = 'Un evento que ya no existe';
      await p.setString('active_missions_v2', jsonEncode(raw));

      final loaded = (await repo.getAllActiveMissions()).single;
      expect(loaded.events.first.configId, isNull);
      expect(loaded.events.first.category, EventCategory.road);
    });

    test('copyWith conserva los datos del arte', () {
      final e = MissionEvent(
        id: 'x',
        configId: 'evt_storm',
        category: EventCategory.storm,
        npcId: 'marco',
        title: 't',
        description: 'd',
        triggersAt: DateTime(2026),
        deadlineAt: DateTime(2026),
        status: EventStatus.pending,
        options: const [],
      ).copyWith(status: EventStatus.resolved);
      expect((e.configId, e.category, e.npcId),
          ('evt_storm', EventCategory.storm, 'marco'));
    });
  });

  // ─── Monedas que vuelan ───
  testWidgets('un premio lanza monedas hasta el contador visible',
      (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(
      locale: kTestLocale,
      supportedLocales: kTestSupportedLocales,
      localizationsDelegates: kTestLocalizationsDelegates,
      home: Scaffold(
        body: Builder(builder: (c) {
          ctx = c;
          return const Align(
            alignment: Alignment.topRight,
            child: CurrencyChip(type: CurrencyType.denarios, value: 100),
          );
        }),
      ),
    ));
    final icons = find.byIcon(CurrencyType.denarios.icon);
    final before = tester.widgetList(icons).length;
    showRewardToast(ctx, [(type: CurrencyType.denarios, amount: 50)]);
    await tester.pump(const Duration(milliseconds: 300)); // sale la primera
    await tester.pump(const Duration(milliseconds: 300)); // ya vuela
    expect(tester.widgetList(icons).length, greaterThan(before + 1),
        reason: 'el aviso y al menos una moneda en vuelo');
    // Todas llegan, el chip salta y nada queda colgado.
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump(const Duration(milliseconds: 1500));
    expect(tester.takeException(), isNull);
  });

  // ─── Sonido y retrato ───
  test('cada efecto de sonido tiene su archivo', () {
    for (final s in Sfx.values) {
      expect(File('assets/${s.asset}').existsSync(), isTrue, reason: s.asset);
    }
  });

  test('la cara del mensajero sigue su estado', () {
    expect(moodFor(fatigue: 10, health: 100, injured: false),
        MessengerMood.content);
    expect(moodFor(fatigue: 50, health: 100, injured: false),
        MessengerMood.neutral);
    expect(moodFor(fatigue: 80, health: 100, injured: false),
        MessengerMood.tired);
    expect(moodFor(fatigue: 0, health: 20, injured: true), MessengerMood.hurt);
  });
}

GameRoute _routeOf(RealMissionConfig c) => GameRoute(
      id: c.id,
      origin: c.origin,
      destination: c.destination,
      distanceKm: c.distanceKm,
      durationMinutes: c.durationMinutes,
      danger: c.danger,
      requiredRank: c.requiredRank,
      eventCount: c.minEvents,
      lore: c.lore,
    );
