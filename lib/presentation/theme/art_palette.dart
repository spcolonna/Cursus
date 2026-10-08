// lib/presentation/theme/art_palette.dart
//
// Colores de la ilustración por código (mapas, escenas, mensajero, sellos).
// Son colores de pintura, no de interfaz: nunca se usan para texto. El texto
// sigue saliendo de AppColors y su tabla de contraste.

import 'package:flutter/material.dart';

class ArtColors {
  ArtColors._();

  // ─── Mapas ───
  static const sea = Color(0xFF10294A);
  static const seaWave = Color(0xFF1B3A60);
  static const land = Color(0xFF4B3F2A);
  static const landLight = Color(0xFF6A5A3B);
  static const landShade = Color(0xFF3A301F);
  static const road = Color(0xFF7D6A45);
  static const river = Color(0xFF2A6A98);
  static const wall = Color(0xFF9A8258);
  static const city = Color(0xFFD9C9A0);

  // ─── Cera y metal ───
  static const wax = Color(0xFFA3221B);
  static const waxLight = Color(0xFFC8392E);
  static const waxDark = Color(0xFF5E0F0B);
  static const iron = Color(0xFF8A8A8A);
  static const ironDark = Color(0xFF555555);
  static const silver = Color(0xFFD8D8D8);
  static const silverDark = Color(0xFF8C8C8C);
  static const bronze = Color(0xFFB0793A);
  static const bronzeDark = Color(0xFF6B4520);
  static const laurel = Color(0xFF5F8A3A);
  static const laurelDark = Color(0xFF34531E);

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
  static const hillFar = Color(0xFF3E5470);
  static const hillMid = Color(0xFF2E3F2C);
  static const hillNear = Color(0xFF1E2A1C);
  static const stone = Color(0xFFB8A98A);
  static const stoneShade = Color(0xFF7E715A);
  static const stoneDark = Color(0xFF4A4234);
  static const terracotta = Color(0xFFA0522D);
  static const terracottaDark = Color(0xFF6E3519);
  static const water = Color(0xFF2A5F86);
  static const waterLight = Color(0xFF4F8DB5);
  static const torch = Color(0xFFFFB347);
  static const torchGlow = Color(0x55FFB347);
  static const rain = Color(0x66C9D6E3);
  static const mist = Color(0x33E8E0D0);
  static const silhouette = Color(0xFF0B1120);
  static const legionRed = Color(0xFF8E1B14);
  static const cypress = Color(0xFF16261A);
  static const sail = Color(0xFFE6D8B5);
}
