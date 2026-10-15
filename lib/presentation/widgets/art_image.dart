// lib/presentation/widgets/art_image.dart
//
// Ilustraciones raster opcionales. Cada pieza tiene una ruta fija por id
// (ver docs/ART_PROMPTS.md); si el archivo no está en el bundle, se dibuja el
// fallback vectorial sin parpadeo ni error en consola.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/motion.dart';

/// Dónde va cada ilustración.
class ArtPaths {
  ArtPaths._();
  static String event(String configId) => 'assets/art/events/$configId.jpg';
  /// Escenario genérico por categoría: lo usan los eventos sin ilustración.
  static String scene(String category) => 'assets/art/scenes/$category.jpg';
  static String story(String storyId) => 'assets/art/story/$storyId.jpg';
  static String npc(String npcId) => 'assets/art/npcs/$npcId.png';
  static String ending(String endingId) => 'assets/art/endings/$endingId.jpg';
}

/// Qué ilustraciones vinieron en el bundle. Se carga una vez al arrancar;
/// mientras no cargó, todo usa el fallback.
class ArtCatalog {
  ArtCatalog._();

  static Set<String> _assets = const {};

  static Future<void> load([AssetBundle? bundle]) async {
    try {
      final manifest =
          await AssetManifest.loadFromAssetBundle(bundle ?? rootBundle);
      _assets = manifest
          .listAssets()
          .where((a) => a.startsWith('assets/art/'))
          .toSet();
    } catch (_) {
      _assets = const {};
    }
  }

  static bool has(String asset) => _assets.contains(asset);

  /// Para tests.
  static void debugSet(Set<String> assets) => _assets = assets;
}

class ArtImage extends StatelessWidget {
  final String asset;
  final Widget fallback;
  final BoxFit fit;

  /// Qué parte queda a la vista cuando el recorte corta la imagen.
  final Alignment alignment;
  const ArtImage({
    super.key,
    required this.asset,
    required this.fallback,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    if (!ArtCatalog.has(asset)) return fallback;
    final fade = AppMotion.of(context, AppMotion.base);
    return Image.asset(
      asset,
      fit: fit,
      alignment: alignment,
      // Si el archivo está pero no decodifica, también vale el fallback.
      errorBuilder: (_, __, ___) => fallback,
      frameBuilder: (_, child, frame, sync) => sync
          ? child
          : AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: fade,
              curve: AppMotion.enter,
              child: child,
            ),
    );
  }
}
