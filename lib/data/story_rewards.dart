// ═══════════════════════════════════════════════════════════════
// PREMIOS DE LOS FINALES — lo que cada final de arco abre en el juego.
//
// Arco 1:
//   end_varus      → correo exprés (real_16) y cambiar contratos, sin
//                    esperar la reputación (ver `openedByFlag` y `orFlag`).
//   end_claudius   → ruta a la villa de Claudius en Tibur (real_20).
//   end_underworld → Ruta Nocturna (real_nocturna, en game_content.dart).
// Arco 2:
//   end_lucius_family → la Posta del Buey: −10 de fatiga en la Appia.
//   end_lucius_legion → ruta militar a Capua (real_21).
//   end_lucius_book   → Mapa del contrabandista en la tienda.
// Ningún premio suma al score de una decisión (cap de +25%).
// ═══════════════════════════════════════════════════════════════

import '../domain/entities/content.dart';
import '../domain/entities/world.dart';

const List<RealMissionConfig> storyRewardMissions = [
  RealMissionConfig(
    id: 'real_20',
    origin: 'Roma',
    destination: 'Tibur — villa de Claudius',
    distanceKm: 30,
    durationMinutes: 240,
    danger: 0.25,
    requiredRank: 2,
    patron: Faction.patricians,
    requiredFlag: 'ending_claudius',
    lore: 'La correspondencia privada de Claudius, entre el Senado y su villa. '
        'Paga bien y nadie te pregunta nada; vos tampoco preguntás.',
    packageOptions: [
      'Un borrador de discurso con tachaduras de puño del Senador',
      'Una caja de higos secos con una carta en el fondo',
    ],
    eventPoolIds: [
      'evt_letter_bribe', 'evt_pickpocket', 'evt_cart_jam',
      'evt_wedding_road', 'evt_tax_collector',
    ],
    minEvents: 1,
    maxEvents: 2,
  ),
  RealMissionConfig(
    id: 'real_21',
    origin: 'Roma',
    destination: 'Capua — castra de la Appia',
    distanceKm: 200,
    durationMinutes: 600,
    danger: 0.45,
    requiredRank: 4,
    patron: Faction.legions,
    requiredFlag: 'ending_lucius_legion',
    lore: 'El correo de la Décima por la Appia. Con la placa del toro, '
        'los puestos se abren; los bandidos, no tanto.',
    packageOptions: [
      'La paga de una cohorte, en una caja con tres cerraduras',
      'Órdenes de marcha selladas con el toro de la Décima',
    ],
    eventPoolIds: [
      'evt_patrol', 'evt_deserter', 'evt_old_soldier', 'evt_bandits',
      'evt_landslide', 'evt_heatwave',
    ],
    minEvents: 2,
    maxEvents: 3,
  ),
];

/// Postas amigas: con el flag, esas rutas cansan menos al llegar.
const List<RestStop> restStops = [
  RestStop(
    flag: 'ending_lucius_family',
    name: 'Posta del Buey',
    // Las rutas que salen de Roma por la Via Appia.
    routeIds: {
      'real_02', 'real_08', 'real_09', 'real_12', 'real_13',
      'real_16', 'real_17', 'real_21',
    },
    fatigueRelief: 10,
  ),
];
