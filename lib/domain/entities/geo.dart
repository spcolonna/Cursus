// Geografía de los mapas: Italia (rutas largas) y Roma (recados urbanos).
// Puro: las coordenadas viven en `data/geo_content.dart` y llegan por el
// catálogo. Las pantallas solo reciben puntos normalizados (0..1).

/// Encuadre del mapa de Italia: de Lugdunum a Brundisium y de los Alpes a
/// Sicilia. Fuera de esta caja nada se dibuja.
const double kMapLonMin = 3.5;
const double kMapLonMax = 19.0;
const double kMapLatMin = 36.5;
const double kMapLatMax = 47.0;

/// Coseno de la latitud media: sin esto Italia sale achatada.
const double _lonScale = 0.743;

/// Ancho / alto del mapa de Italia en la proyección.
const double kItalyMapAspect =
    (kMapLonMax - kMapLonMin) * _lonScale / (kMapLatMax - kMapLatMin);

enum MapKind { italy, rome }

/// Punto en coordenadas del mapa, de 0 a 1 en cada eje (y crece hacia abajo).
class MapPoint {
  final double x;
  final double y;
  const MapPoint(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      other is MapPoint && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'MapPoint($x, $y)';
}

/// Longitud y latitud reales, en grados.
class LonLat {
  final double lon;
  final double lat;
  const LonLat(this.lon, this.lat);

  /// Proyección equirectangular dentro del encuadre del mapa.
  MapPoint get project => MapPoint(
        (lon - kMapLonMin) / (kMapLonMax - kMapLonMin),
        (kMapLatMax - lat) / (kMapLatMax - kMapLatMin),
      );
}

/// El trazado de una misión sobre uno de los dos mapas.
class RouteGeometry {
  final MapKind map;
  final List<MapPoint> points;
  final bool bySea;
  const RouteGeometry(
      {required this.map, required this.points, this.bySea = false});
}

/// Todo lo que hace falta para dibujar los mapas.
class GeoAtlas {
  /// Ciudades del mapa de Italia. Los nombres que empiezan con `~` son puntos
  /// de paso (alta mar, pasos de montaña) y no se dibujan.
  final Map<String, LonLat> cities;

  /// Lugares de la ciudad de Roma, ya normalizados.
  final Map<String, MapPoint> romePlaces;

  /// Por dónde va cada ruta real: nombres de [cities], en orden.
  final Map<String, List<String>> routeWaypoints;

  /// Rutas que van por mar.
  final Set<String> seaRoutes;

  /// Costas: la península con la costa francesa y dálmata, y las islas.
  final List<List<LonLat>> land;

  /// Las tres vías consulares, para dibujarlas de fondo.
  final Map<String, List<String>> roads;

  /// Ríos (el Tíber y el Po) y cordilleras (Alpes y Apeninos), de fondo.
  final List<List<LonLat>> rivers;
  final List<List<LonLat>> ranges;

  /// Mapa de Roma: el Tíber, la muralla serviana y las siete colinas.
  final List<MapPoint> tiber;
  final List<MapPoint> walls;
  final List<MapPoint> hills;

  const GeoAtlas({
    required this.cities,
    required this.romePlaces,
    required this.routeWaypoints,
    required this.seaRoutes,
    required this.land,
    required this.roads,
    this.rivers = const [],
    this.ranges = const [],
    required this.tiber,
    required this.walls,
    required this.hills,
  });

  /// "Neapolis por mar, de noche" → "Neapolis"; "Roma — Foro" → "Roma".
  static String baseName(String place) {
    var s = place.split(' — ').first;
    s = s.split(' por ').first;
    return s.trim();
  }

  MapPoint? _cityPoint(String name) =>
      (cities[name] ?? cities[baseName(name)])?.project;

  MapPoint? _romePoint(String name) => romePlaces[name];

  /// El lugar es parte de la ciudad y no una ciudad de Italia.
  bool _isUrban(String name) =>
      romePlaces.containsKey(name) && name != 'Roma';

  /// Trazado de una misión. Null si algún extremo no está en el atlas (un
  /// test garantiza que no pase con el contenido actual).
  RouteGeometry? routeFor(String routeId, String origin, String destination) {
    final via = routeWaypoints[routeId];
    if (via != null) {
      final pts = [for (final n in via) cities[n]?.project];
      if (pts.any((p) => p == null)) return null;
      return RouteGeometry(
        map: MapKind.italy,
        points: pts.cast<MapPoint>(),
        bySea: seaRoutes.contains(routeId),
      );
    }
    if (_isUrban(origin) || _isUrban(destination)) {
      final a = _romePoint(origin);
      final b = _romePoint(destination);
      if (a == null || b == null) return null;
      return RouteGeometry(map: MapKind.rome, points: [a, b]);
    }
    final a = _cityPoint(origin);
    final b = _cityPoint(destination);
    if (a == null || b == null) return null;
    return RouteGeometry(map: MapKind.italy, points: [a, b]);
  }

  /// Ciudades visibles (sin puntos de paso), proyectadas.
  Map<String, MapPoint> get visibleCities => {
        for (final e in cities.entries)
          if (!e.key.startsWith('~')) e.key: e.value.project,
      };
}
