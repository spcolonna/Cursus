// lib/data/geo_content.dart
//
// Coordenadas de los mapas. Italia va en longitud/latitud reales
// (aproximadas a la décima de grado); Roma es un plano esquemático en 0..1.
// Al agregar una ruta: sumá sus ciudades a `_cities` y su trazado a
// `_routeWaypoints`. El test `geo_test.dart` falla si falta alguna.

import '../domain/entities/geo.dart';

const _cities = <String, LonLat>{
  // ─── Ciudades ───
  'Roma': LonLat(12.48, 41.90),
  'Ostia': LonLat(12.29, 41.75),
  'Tibur': LonLat(12.80, 41.96),
  'Praeneste': LonLat(12.90, 41.84),
  'Antium': LonLat(12.63, 41.45),
  'Tarracina': LonLat(13.25, 41.29),
  'Capua': LonLat(14.21, 41.08),
  'Cumae': LonLat(14.05, 40.85),
  'Neapolis': LonLat(14.25, 40.85),
  'Pompeii': LonLat(14.49, 40.75),
  'Beneventum': LonLat(14.78, 41.13),
  'Venusia': LonLat(15.81, 40.96),
  'Tarentum': LonLat(17.24, 40.47),
  'Brundisium': LonLat(17.94, 40.64),
  'Narnia': LonLat(12.52, 42.52),
  'Ariminum': LonLat(12.57, 44.06),
  'Ravenna': LonLat(12.20, 44.42),
  'Altinum': LonLat(12.40, 45.55),
  'Aquileia': LonLat(13.37, 45.77),
  'Pisae': LonLat(10.40, 43.72),
  'Luna': LonLat(10.02, 44.07),
  'Genua': LonLat(8.93, 44.41),
  'Nicaea': LonLat(7.27, 43.70),
  'Massilia': LonLat(5.37, 43.30),
  'Arelate': LonLat(4.63, 43.68),
  'Lugdunum': LonLat(4.83, 45.76),
  // ─── Puntos de paso (no se dibujan) ───
  '~mar_antium': LonLat(12.40, 41.35),
  '~mar_gaeta': LonLat(13.45, 40.95),
  '~mar_tirreno': LonLat(11.00, 41.75),
  '~mar_elba': LonLat(10.05, 42.90),
  '~mar_liguria': LonLat(8.50, 43.55),
  '~mar_provenza': LonLat(6.50, 42.95),
  '~valle_rodano': LonLat(4.80, 44.70),
};

const _appiaToCapua = ['Roma', 'Tarracina', 'Capua'];

const _routeWaypoints = <String, List<String>>{
  'real_01': ['Roma', 'Ostia'],
  'real_02': _appiaToCapua,
  'real_03': ['Roma', 'Pisae', 'Genua', 'Nicaea', 'Arelate', '~valle_rodano', 'Lugdunum'],
  'real_nocturna': ['Roma', 'Ostia'],
  'real_04': ['Roma', 'Tibur'],
  'real_05': ['Roma', 'Praeneste'],
  'real_06': ['Roma', 'Antium'],
  'real_07': ['Neapolis', 'Pompeii'],
  'real_08': [..._appiaToCapua, 'Cumae'],
  'real_09': [..._appiaToCapua, 'Beneventum'],
  'real_10': ['Ravenna', 'Altinum', 'Aquileia'],
  'real_11': ['Pisae', 'Luna', 'Genua'],
  'real_12': [..._appiaToCapua, 'Beneventum', 'Venusia', 'Tarentum'],
  'real_13': [..._appiaToCapua, 'Beneventum', 'Venusia', 'Tarentum', 'Brundisium'],
  'real_14': ['Roma', 'Narnia', 'Ariminum', 'Ravenna', 'Altinum', 'Aquileia'],
  'real_15': ['Roma', 'Pisae', 'Genua', 'Nicaea', 'Massilia'],
  'real_16': [..._appiaToCapua, 'Neapolis'],
  'real_17': [..._appiaToCapua, 'Beneventum', 'Venusia', 'Tarentum', 'Brundisium'],
  'real_18': ['Ostia', '~mar_antium', '~mar_gaeta', 'Neapolis'],
  'real_19': ['Ostia', '~mar_tirreno', '~mar_elba', '~mar_liguria', '~mar_provenza', 'Massilia'],
};

const _seaRoutes = {'real_18', 'real_19'};

const _roads = <String, List<String>>{
  'Via Appia': ['Roma', 'Tarracina', 'Capua', 'Beneventum', 'Venusia', 'Tarentum', 'Brundisium'],
  'Via Aurelia': ['Roma', 'Pisae', 'Luna', 'Genua', 'Nicaea', 'Massilia'],
  'Via Flaminia': ['Roma', 'Narnia', 'Ariminum'],
};

// ─── Costas ───
// La península va cerrada por el borde norte del encuadre: así la costa
// francesa, los Alpes y la Dalmacia quedan como tierra.
const _peninsula = [
  LonLat(3.5, 47.0), LonLat(3.5, 43.45), LonLat(4.5, 43.45), LonLat(5.4, 43.25),
  LonLat(6.2, 43.10), LonLat(7.0, 43.55), LonLat(7.5, 43.75), LonLat(8.2, 43.90),
  LonLat(8.9, 44.40), LonLat(9.8, 44.10), LonLat(10.3, 43.90), LonLat(10.3, 43.50),
  LonLat(10.5, 42.95), LonLat(11.1, 42.40), LonLat(11.8, 42.05), LonLat(12.25, 41.72),
  LonLat(12.6, 41.43), LonLat(13.0, 41.25), LonLat(13.6, 41.22), LonLat(14.0, 40.95),
  LonLat(14.25, 40.80), LonLat(14.35, 40.60), LonLat(14.8, 40.65), LonLat(15.0, 40.30),
  LonLat(15.6, 40.05), LonLat(15.8, 39.60), LonLat(16.1, 38.95), LonLat(15.65, 38.25),
  LonLat(16.05, 37.93), LonLat(16.6, 38.40), LonLat(17.1, 38.90), LonLat(16.6, 39.60),
  LonLat(16.5, 39.75), LonLat(17.2, 40.40), LonLat(17.9, 40.25), LonLat(18.4, 39.80),
  LonLat(18.5, 40.15), LonLat(17.95, 40.68), LonLat(16.9, 41.10), LonLat(16.0, 41.45),
  LonLat(16.2, 41.90), LonLat(15.5, 41.95), LonLat(14.7, 42.10), LonLat(14.2, 42.45),
  LonLat(13.6, 43.60), LonLat(12.6, 44.10), LonLat(12.3, 44.45), LonLat(12.45, 45.00),
  LonLat(12.3, 45.40), LonLat(13.1, 45.70), LonLat(13.7, 45.65), LonLat(13.6, 45.10),
  LonLat(13.9, 44.80), LonLat(14.3, 45.30), LonLat(15.0, 45.00), LonLat(15.9, 43.60),
  LonLat(17.0, 43.10), LonLat(18.1, 42.60), LonLat(19.0, 42.10), LonLat(19.0, 47.0),
];

const _sicilia = [
  LonLat(12.4, 37.80), LonLat(13.3, 38.20), LonLat(14.0, 38.05), LonLat(15.6, 38.30),
  LonLat(15.1, 37.50), LonLat(15.2, 37.00), LonLat(15.1, 36.65), LonLat(14.3, 37.00),
  LonLat(13.5, 37.25), LonLat(12.6, 37.60),
];

const _sardinia = [
  LonLat(8.4, 41.10), LonLat(9.2, 41.25), LonLat(9.8, 40.90), LonLat(9.65, 40.00),
  LonLat(9.6, 39.15), LonLat(9.0, 39.10), LonLat(8.4, 38.95), LonLat(8.4, 39.70),
  LonLat(8.5, 40.40), LonLat(8.2, 40.60),
];

const _corsica = [
  LonLat(9.35, 43.0), LonLat(9.55, 42.6), LonLat(9.4, 41.65), LonLat(9.2, 41.37),
  LonLat(8.8, 41.6), LonLat(8.6, 42.0), LonLat(8.6, 42.4), LonLat(9.0, 42.7),
];

const _tiberis = [
  LonLat(12.10, 43.20), LonLat(12.35, 42.75), LonLat(12.52, 42.40), LonLat(12.55, 42.10),
  LonLat(12.48, 41.90), LonLat(12.35, 41.80), LonLat(12.25, 41.73),
];
const _padus = [
  LonLat(7.40, 44.80), LonLat(8.60, 45.10), LonLat(9.70, 45.05), LonLat(10.60, 44.95),
  LonLat(11.60, 44.90), LonLat(12.40, 44.95),
];

// Cordilleras: se dibujan como una hilera de picos a lo largo de la línea.
const _alps = [
  LonLat(6.0, 44.2), LonLat(6.8, 45.0), LonLat(7.2, 45.9), LonLat(8.5, 46.3),
  LonLat(10.0, 46.4), LonLat(11.5, 46.5), LonLat(12.8, 46.5), LonLat(13.8, 46.3),
];
const _apennines = [
  LonLat(8.4, 44.5), LonLat(9.6, 44.4), LonLat(10.8, 44.1), LonLat(11.9, 43.6),
  LonLat(12.7, 43.0), LonLat(13.3, 42.4), LonLat(14.0, 41.9), LonLat(14.9, 41.4),
  LonLat(15.6, 40.8), LonLat(16.0, 40.0), LonLat(16.2, 39.3),
];

// ─── Roma (plano esquemático, 0..1) ───
const _romePlaces = <String, MapPoint>{
  'Roma': MapPoint(0.52, 0.52),
  'Roma — Foro': MapPoint(0.52, 0.52),
  'Roma — Subura': MapPoint(0.64, 0.40),
  'Roma — los dos extremos': MapPoint(0.58, 0.86),
  'Cuartel de Varus': MapPoint(0.44, 0.30),
  'Puerta Sur': MapPoint(0.66, 0.88),
  'Taberna del Buey': MapPoint(0.38, 0.64),
  'Villa del Senador Claudius': MapPoint(0.76, 0.66),
  'Villa de Claudius': MapPoint(0.76, 0.66),
  'Campamento Legionario': MapPoint(0.88, 0.18),
  'Templo de Saturno': MapPoint(0.47, 0.57),
  'Casa del escriba Tiro': MapPoint(0.58, 0.24),
  'Villa del Senador Petro': MapPoint(0.28, 0.20),
  'Basílica Emilia': MapPoint(0.56, 0.48),
  'Curia — Senado de Roma': MapPoint(0.53, 0.44),
  'La Loba Dorada': MapPoint(0.70, 0.34),
  'La Loba Dorada — taberna sin cartel': MapPoint(0.70, 0.34),
};

const _tiber = [
  MapPoint(0.30, 0.0), MapPoint(0.26, 0.15), MapPoint(0.34, 0.30), MapPoint(0.30, 0.45),
  MapPoint(0.36, 0.58), MapPoint(0.32, 0.72), MapPoint(0.22, 0.86), MapPoint(0.18, 1.0),
];

const _walls = [
  MapPoint(0.40, 0.20), MapPoint(0.56, 0.14), MapPoint(0.72, 0.18), MapPoint(0.82, 0.32),
  MapPoint(0.84, 0.52), MapPoint(0.80, 0.72), MapPoint(0.68, 0.84), MapPoint(0.52, 0.82),
  MapPoint(0.40, 0.72), MapPoint(0.37, 0.56), MapPoint(0.36, 0.38),
];

/// Las siete colinas: Capitolio, Palatino, Aventino, Celio, Esquilino,
/// Viminal y Quirinal.
const _hills = [
  MapPoint(0.46, 0.50), MapPoint(0.58, 0.62), MapPoint(0.46, 0.74), MapPoint(0.70, 0.66),
  MapPoint(0.72, 0.44), MapPoint(0.64, 0.30), MapPoint(0.54, 0.28),
];

const GeoAtlas geoAtlas = GeoAtlas(
  cities: _cities,
  romePlaces: _romePlaces,
  routeWaypoints: _routeWaypoints,
  seaRoutes: _seaRoutes,
  land: [_peninsula, _sicilia, _sardinia, _corsica],
  roads: _roads,
  rivers: [_tiberis, _padus],
  ranges: [_alps, _apennines],
  tiber: _tiber,
  walls: _walls,
  hills: _hills,
);
