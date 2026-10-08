// lib/presentation/theme/art_palette.dart
//
// Colores de la ilustración por código (mapas, escenas, mensajero, sellos).
// Son colores de pintura, no de interfaz: nunca se usan para texto. El texto
// sigue saliendo de AppColors y su tabla de contraste.

import 'package:flutter/material.dart';

class ArtColors {
  ArtColors._();

  // ─── Mapas: carta pintada al fresco ───
  // Mar de azul egipcio aguado, tierra de cal y ocre, todo contorneado en
  // tinta. La ruta (tinta + ocre) tiene que ganarle siempre al fondo.
  static const sea = Color(0xFFA9C4D6);
  static const seaWave = Color(0xFF7FA2BF);
  static const seaShore = Color(0xFFC9DBE5);
  static const land = Color(0xFFE8D7AE);
  static const landLight = Color(0xFFF5ECD3);
  static const landShade = Color(0xFFC4A266);
  static const road = Color(0xFF7A6450);
  static const river = Color(0xFF3F72A8);
  static const wall = Color(0xFFB5562F);
  static const city = Color(0xFFF7F0DE);

  // ─── Cera y metal ───
  // Cera cinabrio (la del sello de marca) y metales de pigmento, sin grises
  // fríos: el hierro y la plata tiran a tierra.
  static const wax = Color(0xFFA8322D);
  static const waxLight = Color(0xFFC4473C);
  static const waxDark = Color(0xFF6E1F1B);
  static const iron = Color(0xFF8C8578);
  static const ironDark = Color(0xFF57514A);
  static const silver = Color(0xFFDCD6C8);
  static const silverDark = Color(0xFF948C7E);
  static const bronze = Color(0xFFB07F3A);
  static const bronzeDark = Color(0xFF6B4A22);
  static const laurel = Color(0xFF5E7F45);
  static const laurelDark = Color(0xFF3D5A2E);

  // ─── Personajes ───
  static const skin = Color(0xFFD9A577);
  static const skinLight = Color(0xFFE6B98E);
  static const skinShade = Color(0xFFB47F55);
  static const skinWeary = Color(0xFFC9A184);
  static const hairDark = Color(0xFF2B1A10);
  static const hairLight = Color(0xFF6B4423);
  static const leather = Color(0xFF6B4A2B);
  static const leatherDark = Color(0xFF3F2A17);
  static const felt = Color(0xFF8B6B3E);
  static const feltDark = Color(0xFF5C4526);
  static const bandage = Color(0xFFEDE3CC);
  static const blush = Color(0x33C0392B);

  // ─── Mensajeros por slot: túnica, sombra y el muro del retrato ───
  // Muros de fresco (ocre, celeste, cal, rojo pompeyano) detrás de cada uno.
  static const tunicCinnabar = Color(0xFFA4302B);
  static const tunicCinnabarShade = Color(0xFF6E1C18);
  static const tunicTyrian = Color(0xFF6B3E6E);
  static const tunicTyrianShade = Color(0xFF4A2A4D);
  static const tunicBlue = Color(0xFF2D5A9A);
  static const tunicBlueShade = Color(0xFF1F3F6E);
  static const tunicVerdigris = Color(0xFF3F7F72);
  static const tunicVerdigrisShade = Color(0xFF2B5A50);
  static const wallOchre = Color(0xFFDDB15C);
  static const wallOchreShade = Color(0xFFBF8C35);
  static const wallSky = Color(0xFF9DB7C4);
  static const wallSkyShade = Color(0xFF6F93A8);
  static const wallLime = Color(0xFFE3CFA4);
  static const wallLimeShade = Color(0xFFC9B07E);
  static const wallPompeian = Color(0xFFC9725A);
  static const wallPompeianShade = Color(0xFFA4503C);

  // ─── Escenas: tormenta y astros ───
  // Los cielos por hora viven en theme/sky.dart (SkyPalette).
  static const stormTop = Color(0xFF1C2430);
  static const stormBottom = Color(0xFF4A5868);
  static const star = Color(0xFFF2EAD0);

  // ─── Escenas: planos ───
  // Las colinas no viven acá: salen de SkyPalette (landFar/Mid/Near), así
  // escenas y cielo comparten tierra. La piedra es cal y travertino; el
  // follaje, el verde de los cipreses de los frescos.
  static const stone = Color(0xFFE2D2AE);
  static const stoneShade = Color(0xFFB39B72);
  static const stoneDark = Color(0xFF6B5A45);
  static const terracotta = Color(0xFFB5562F);
  static const water = Color(0xFF3D6E9E);
  static const waterLight = Color(0xFF7FA9C9);
  static const torch = Color(0xFFF7B267);
  static const torchGlow = Color(0x55F7B267);
  static const rain = Color(0x66C9D6E3);
  static const mist = Color(0x33F2E8D5);
  static const silhouette = Color(0xFF1A1420);
  static const legionRed = Color(0xFFA8322D);
  static const cypress = Color(0xFF2C4231);
  static const sail = Color(0xFFEDE3C8);
}
