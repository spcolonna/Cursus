import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../infrastructure/audio/music_service.dart';
import '../providers/providers.dart';
import '../theme/sky.dart';

/// Hay una celebración (logro, rango, escalón) en pantalla. La escribe
/// `CelebrationHost` y la escucha `MusicDirector` para bajar la música.
final ValueNotifier<bool> celebrationVisible = ValueNotifier(false);

/// La ruta que el jugador tiene delante. Ojo: con `push`, go_router deja
/// `currentConfiguration.uri` en la ruta de abajo (p. ej. /home bajo /event);
/// la pantalla de arriba es el último match imperativo.
Uri visibleRouteUri(GoRouter router) {
  final config = router.routerDelegate.currentConfiguration;
  if (config.isEmpty) return config.uri;
  final top = config.last;
  return top is ImperativeRouteMatch ? top.matches.uri : config.uri;
}

/// Pantallas sin música: el arranque y el onboarding (la música entra
/// recién en el home, con el jugador ya adentro).
const _silentPaths = {'/', '/login', '/onboarding', '/character'};
const _missionPaths = {'/mission', '/event'};

MusicTrack homeTrackFor(SkyPhase phase) => switch (phase) {
      SkyPhase.dawn => MusicTrack.homeDawn,
      SkyPhase.day => MusicTrack.homeDay,
      SkyPhase.dusk => MusicTrack.homeDusk,
      SkyPhase.night => MusicTrack.homeNight,
    };

bool _isMissionTrack(MusicTrack? t) =>
    t == MusicTrack.travel ||
    t == MusicTrack.arcClaudius ||
    t == MusicTrack.arcLucius;

/// El tema de cada pantalla:
///   · arranque y onboarding: silencio;
///   · misión y evento: el tema del arco si es un capítulo, si no el camino;
///   · resultado: sigue el tema de la misión que se acaba de entregar;
///   · el resto (home, perfil, tienda…): el del cielo de la hora.
MusicTrack? musicTrackFor(
  String path, {
  required SkyPhase phase,
  String? arcId,
  MusicTrack? previous,
}) {
  if (_silentPaths.contains(path)) return null;
  if (_missionPaths.contains(path)) {
    return MusicTrack.forArc(arcId) ?? MusicTrack.travel;
  }
  if (path == '/mission-result') {
    return _isMissionTrack(previous) ? previous : MusicTrack.travel;
  }
  return homeTrackFor(phase);
}

/// Mientras el jugador decide, la música baja (y el evento se lee mejor).
bool musicDucksOn(String path) => path == '/event';

/// Elige la música según la ruta, la hora y la misión abierta, y se la pide
/// a `MusicService`. Vive sobre toda la app (MaterialApp.router → builder).
class MusicDirector extends ConsumerStatefulWidget {
  final GoRouter router;
  final Widget child;
  const MusicDirector({super.key, required this.router, required this.child});

  @override
  ConsumerState<MusicDirector> createState() => _MusicDirectorState();
}

class _MusicDirectorState extends ConsumerState<MusicDirector> {
  @override
  void initState() {
    super.initState();
    widget.router.routerDelegate.addListener(_schedule);
    celebrationVisible.addListener(_schedule);
    _schedule();
  }

  @override
  void dispose() {
    widget.router.routerDelegate.removeListener(_schedule);
    celebrationVisible.removeListener(_schedule);
    super.dispose();
  }

  // El router avisa en medio de un build: se aplica al frame siguiente.
  void _schedule() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _sync();
    });
  }

  void _sync() {
    final music = ref.read(musicServiceProvider);
    final uri = visibleRouteUri(widget.router);
    final arcId = ref
        .read(homeProvider)
        .valueOrNull
        ?.slotFor(uri.queryParameters['m'])
        ?.activeMission
        ?.arcId;
    music.play(musicTrackFor(
      uri.path,
      phase: ref.read(skyPaletteProvider).phase,
      arcId: arcId,
      previous: music.wanted,
    ));
    music.duck('event', musicDucksOn(uri.path));
    music.duck('celebration', celebrationVisible.value);
  }

  @override
  Widget build(BuildContext context) {
    // Cambia la fase del cielo o carga la misión: puede cambiar el tema.
    ref.listen(
        skyPaletteProvider.select((s) => s.phase), (_, __) => _schedule());
    ref.listen(homeProvider.select((h) => h.hasValue), (_, __) => _schedule());
    return widget.child;
  }
}
