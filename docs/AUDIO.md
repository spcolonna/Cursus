# Cursus — audio

Hoja de cues para reemplazar el audio provisorio **archivo por archivo, sin tocar código**: mismo nombre, mismo formato, mismo lugar. Todo lo que hoy suena sale de dos scripts con síntesis de stdlib:

```bash
python3 tool/gen_sfx.py     # 18 SFX + el motivo como sonido de aviso (Android e iOS)
python3 tool/gen_music.py   # 7 temas en loop (AAC; necesita afconvert, viene con macOS)
```

Si reemplazás un archivo a mano, **no vuelvas a correr el script** (lo pisa), o sacá esa entrada del script.

## Identidad sonora

- **Instrumentos:** lira (cuerda pulsada), aulos (doble flauta de caña: un tubo hace el bordón, el otro la melodía), tambor de marco con sonajas, bucina (metal) para los momentos de rango. Para los efectos, materiales del oficio: papel, pergamino, tablilla de madera, cuero, cera, bronce.
- **Modos:** dórico como casa; frigio para la intriga política (Claudius), mixolidio para la taberna (Lucius), eólico para el atardecer.
- **El motivo:** tres notas de lira que suben por quintas, **D – A – E** (un camino que se abre). Es la firma de Cursus: suena en el splash, en la entrega con nota S y en cada aviso. Todos los temas abren con el motivo transportado a su tono; la música final debería conservarlo.
- **Qué no:** sintes modernos, épica orquestal de tráiler, percusión de guerra. Es un juego de cartas y caminos, no de batallas.

## Niveles

| Tipo | Objetivo |
|---|---|
| Música | −16 LUFS integrado (los placeholders apuntan a RMS −18 dBFS: aproximado, medilo con una herramienta real), pico ≤ −1 dBTP |
| SFX | Pico −3 dBFS, normalizados por pico; el volumen relativo lo da `Sfx.volume` en código |
| Aviso | Igual que el SFX del motivo; ≤ 30 s (límite de iOS) |

En la app, la música va al 60% por defecto (ajustable) y baja **−8 dB** (ducking) mientras el jugador decide un evento o hay una celebración en pantalla.

## Música — `assets/audio/music_<nombre>.m4a`

AAC en contenedor M4A, mono o estéreo, 60-90 s, **en loop**. La vuelta del loop no es gapless (el reproductor reinicia): cerrá cada tema con un respiro y abrí sin ataque fuerte. Cambio entre temas: fundido cruzado de 1,5 s (lo hace el código).

| Archivo | Cuándo suena | Mood | Tono / tempo (placeholder) |
|---|---|---|---|
| `music_home_dawn.m4a` | Home y menús, alba (5:30-8:00) | Despertar, aire frío, esperanza quieta | D dórico · 66 bpm · sin percusión |
| `music_home_day.m4a` | Home y menús, día (8:00-18:00) | Mercado, oficio, ganas de salir | E dórico · 88 bpm · tambor liviano |
| `music_home_dusk.m4a` | Home y menús, atardecer (18:00-20:30) | Cansancio dulce, balance del día | A eólico · 72 bpm · un golpe por compás |
| `music_home_night.m4a` | Home y menús, noche | Íntimo, estrellas, poco movimiento | D dórico · 54 bpm · lira suelta y bordón |
| `music_travel.m4a` | Misión en viaje y eventos (sin arco) | Andar: paso firme, paisaje que pasa | D dórico · 96 bpm · tambor de marcha |
| `music_arc_claudius.m4a` | Capítulos de *arc_claudius* | Intriga del Senado, peso, secreto | E frigio · 60 bpm · ostinato grave |
| `music_arc_lucius.m4a` | Capítulos de *arc_lucius* | Taberna del Buey: calor, ruido, sospecha | G mixolidio · 104 bpm · sonajas |

Silencio en el splash, el login, el onboarding y la elección de personaje: la música entra recién en el home. El resultado de misión sigue con el tema de la misión entregada. Qué suena dónde lo decide `musicTrackFor` en `lib/presentation/widgets/music_director.dart`; un arco nuevo con tema propio se agrega en `MusicTrack.forArc` (`lib/infrastructure/audio/music_service.dart`).

## SFX — `assets/audio/sfx_<nombre>.wav`

WAV PCM 16 bits, mono, 44,1 kHz. Cortos: el oído los escucha cientos de veces.

| Archivo | Cuándo | Material / idea | Duración |
|---|---|---|---|
| `sfx_tap.wav` | Cualquier botón | Yema sobre papel + tablilla | ~0,05 s |
| `sfx_back.wav` | Volver | Hoja que se da vuelta + madera grave | ~0,12 s |
| `sfx_toggle.wav` | Interruptores | Pestillo de madera, dos golpecitos | ~0,08 s |
| `sfx_error_soft.wav` | Acción no disponible | Lira apagada que baja + cuero | ~0,55 s |
| `sfx_coin.wav` | Cobro chico | Bronce sobre la mesa | ~0,4 s |
| `sfx_coins_many.wav` | Cobro grande, compra | Bolsa de cuero y lluvia de monedas | ~0,8 s |
| `sfx_seal_stamp.wav` | Sello de nota, nodos 6-10 | Golpe + cera que se aplasta y cruje | ~0,4 s |
| `sfx_level_up.wav` | Sube una habilidad | Arpegio de lira + brillo | ~1,1 s |
| `sfx_rank_up.wav` | Rango nuevo | Fanfarria de bucina + tambor | ~1,7 s |
| `sfx_achievement.wav` | Logro | Arpegio alto + monedas | ~1,2 s |
| `sfx_weekly_complete.wav` | Encargo semanal | Acorde rasgueado + bucina | ~1,2 s |
| `sfx_event_arrive.wav` | Llega un evento | Dos notas de alerta + golpes | ~0,7 s |
| `sfx_page_unroll.wav` | Se abre un pergamino | Pergamino que roza y cruje | ~0,5 s |
| `sfx_success.wav` | Evento bien / nota A | Tríada de lira que sube | ~1 s |
| `sfx_partial.wav` | Evento a medias / nota B-C | Dos notas, suspendido | ~0,8 s |
| `sfx_fail.wav` | Evento mal / nota F | Lira que baja + golpe sordo | ~1 s |
| `sfx_delivery.wav` | Entregar la carta | Papel + bucina + monedas | ~1 s |
| `sfx_motif.wav` | Splash, nota S | **El motivo** D–A–E | ~1,9 s |

## Aviso (notificación)

El mismo motivo, en el formato nativo de cada plataforma. Los genera `gen_sfx.py` a partir de `sfx_motif.wav`:

| Plataforma | Archivo | Notas |
|---|---|---|
| Android | `android/app/src/main/res/raw/cursus_motif.wav` | Protegido del shrinker por `res/raw/keep.xml` |
| iOS | `ios/Runner/cursus_motif.caf` | PCM 16 bits; está en *Copy Bundle Resources* de Runner |

Android fija el sonido **al crear el canal**: si cambiás el sonido (o su nombre), hace falta un canal nuevo (`cursus_road_v3`) y sumar el viejo a `_legacyChannelIds` en `notification_service.dart`. Reemplazar el archivo con el mismo nombre alcanza para instalaciones nuevas, pero no cambia el sonido de un canal ya creado.

## Checklist al reemplazar

- [ ] Mismo nombre y extensión; los tests (`test/music_test.dart`, `test/art_test.dart`) verifican que existan.
- [ ] Música: loop sin clic, entra suave, ≤ 1 MB por tema si se puede (AAC 64-96 kbps).
- [ ] El motivo D–A–E reconocible en los temas y en el aviso.
- [ ] Licencia: original encargada o CC0. Registrá autor y licencia acá abajo.

## Créditos

Todo el audio actual es provisorio y sintetizado por los scripts de `tool/` (sin licencias de terceros).
