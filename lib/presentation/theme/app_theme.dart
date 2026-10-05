import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/entities.dart';

// ─── Paleta principal: Navy · Oro · Marrón/Ámbar · Rojo (solo peligro)
// Máx. 4 colores. Sin neón, sin gradientes locos.
class AppColors {
  // Fondos
  static const bgDeep   = Color(0xFF0A1628);
  static const bgDark   = Color(0xFF0F1E36);
  static const bgCard   = Color(0xDD142040);  // semitransparente
  static const bgCard2  = Color(0xCC0D1830);
  static const bgLine   = Color(0xFF2A3E5C);

  // Primario: Oro/Ámbar — TODOS los botones de acción
  static const gold       = Color(0xFFFFCC00);
  static const goldDark   = Color(0xFFCC9900);
  static const goldShadow = Color(0xFF886600);
  static const amber      = Color(0xFFE8920A);
  static const amberDark  = Color(0xFF7A4C00);

  // Secundario: Marrón cálido — cards de misión/tutorial
  static const brown      = Color(0xFF3D1F00);
  static const brownCard  = Color(0xDD2A1500);
  static const brownBorder= Color(0xFFAA6600);

  // Acento: Azul cielo — solo chips/info pasiva
  static const sky        = Color(0xFF4A9EBF);
  static const skyDark    = Color(0xFF1A5A78);
  static const blue    = Color(0xFF1A5A78);

  // Peligro: Rojo — solo eventos urgentes
  static const red        = Color(0xFFCC2200);
  static const redDark    = Color(0xFF881100);
  static const redShadow  = Color(0xFF550800);

  // Riesgo semáforo
  static const riskLow    = Color(0xFF44AA55);
  static const riskMed    = Color(0xFFCC8800);
  static const riskHigh   = Color(0xFFCC2200);

  // Habilidades — reutiliza paleta principal
  static const skillSpeed    = Color(0xFF4A9EBF);  // cielo
  static const skillStealth  = Color(0xFF7744BB);  // violeta suave
  static const skillCombat   = Color(0xFFCC2200);  // rojo
  static const skillSurvival = Color(0xFF44AA55);  // verde
  static const skillContacts = Color(0xFFCC8800);  // ámbar

  // Texto — regla: todo texto sobre fondos navy debe cumplir WCAG AA (≥4.5:1).
  static const white         = Color(0xFFFFFFFF);
  static const textPrimary   = Color(0xFFEEDDAA);  // pergamino
  static const textSecondary = Color(0xFFB5A87E);  // tan cálido, legible
  static const textMuted     = Color(0xFF9C9484);  // gris cálido — NUNCA más oscuro
  static const outline       = Color(0xFF080F1C);

  static const green       = Color(0xFF44AA55);
  static const greenDark   = Color(0xFF226633);
  static const greenShadow = Color(0xFF113322);
  static const purple      = Color(0xFF7744BB);
}

// ─── Gradients — solo 2-3 colores, sin locuras
class AppGradients {
  static const background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A1628), Color(0xFF060E1A)],
  );

  static const header = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xEE060E1A), Color(0x88060E1A)],
  );

  static const card = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xDD142040), Color(0xCC0D1830)],
  );

  // El gradiente dorado — para botones y acentos
  static const gold = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFDD44), Color(0xFFCC8800)],
  );

  // Misión tutorial — cálido marrón
  static const tutorialCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xDD2E1800), Color(0xDD1A0E00)],
  );

  static const green = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF55BB66), Color(0xFF226633)],
  );

  static const red = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFDD3311), Color(0xFF881100)],
  );

  static const sky = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF5AAECC), Color(0xFF1A6688)],
  );

  static const blue = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A3A6E), Color(0xFF0A1E3C)],
  );

  static const amber = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFAA22), Color(0xFFAA5500)],
  );

  static const purple = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF8855CC), Color(0xFF441888)],
  );
}

// ─── Tipografía — Fredoka + Nunito, sin locura de tamaños
class AppTextStyles {
  static TextStyle fredoka(
      double size, {
        Color color = AppColors.textPrimary,
        double letterSpacing = 0,
        FontWeight weight = FontWeight.normal,
      }) {
    return GoogleFonts.fredoka(
      fontSize: size,
      color: color,
      letterSpacing: letterSpacing,
      fontWeight: weight,
    );
  }

  static TextStyle get displayLarge =>
      fredoka(32, color: AppColors.gold, weight: FontWeight.bold, letterSpacing: 1);
  static TextStyle get titleLarge  =>
      fredoka(20, color: AppColors.textPrimary, weight: FontWeight.bold);
  static TextStyle get titleMedium =>
      fredoka(15, color: AppColors.gold, weight: FontWeight.bold, letterSpacing: 0.5);
  static TextStyle get titleSmall  =>
      fredoka(12, color: AppColors.textSecondary, letterSpacing: 1);

  static TextStyle get bodyLarge => GoogleFonts.nunito(
    fontSize: 14, color: AppColors.textPrimary, height: 1.5,
    fontWeight: FontWeight.w600,
  );
  static TextStyle get bodyMedium => GoogleFonts.nunito(
    fontSize: 12, color: AppColors.textSecondary, height: 1.4,
    fontWeight: FontWeight.w500,
  );
  static TextStyle get bodySmall => GoogleFonts.nunito(
    fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600,
  );
}

// ─── Theme
class AppTheme {
  static ThemeData get theme => dark;
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bgDeep,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.gold,
      secondary: AppColors.sky,
      surface: AppColors.bgCard,
    ),
    textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme),
  );
}

// ─── Helpers
bool get isDay {
  final hour = DateTime.now().hour;
  return hour >= 6 && hour < 20;
}

// ─── GradientScaffold — overlay muy ligero para que se vea el fondo
class GradientScaffold extends StatelessWidget {
  final Widget body;
  final String? bgAsset;
  final bool useHomeBg;
  final bool useEventBg;

  const GradientScaffold({
    super.key,
    required this.body,
    this.bgAsset,
    this.useHomeBg = false,
    this.useEventBg = false,
  });

  String? get _resolvedAsset {
    if (bgAsset != null) return bgAsset;
    if (useHomeBg) {
      return isDay
          ? 'assets/images/bg_home_day.jpg'
          : 'assets/images/bg_home_night.jpg';
    }
    if (useEventBg) return 'assets/images/bg_event.jpg';
    return null;
  }

  LinearGradient get _overlay => useEventBg
      ? const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xEE060E1A), Color(0x55060E1A), Color(0xF0060E1A)],
    stops: [0.0, 0.5, 1.0],
  )
      : const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    // Overlay muy suave en el medio — imagen muy visible
    colors: [Color(0xCC060E1A), Color(0x1A060E1A), Color(0xEE060E1A)],
    stops: [0.0, 0.4, 1.0],
  );

  @override
  Widget build(BuildContext context) {
    final asset = _resolvedAsset;
    return Scaffold(
      body: Stack(fit: StackFit.expand, children: [
        const DecoratedBox(
            decoration: BoxDecoration(gradient: AppGradients.background)),
        if (asset != null)
          Image.asset(asset, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink()),
        if (asset != null)
          DecoratedBox(decoration: BoxDecoration(gradient: _overlay)),
        body,
      ]),
    );
  }
}

// ─── GameButton — SIEMPRE dorado (el color del juego), grueso y con sombra offset
class GameButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final LinearGradient gradient;
  final Color shadowColor;
  final double fontSize;
  final bool isLoading;
  final IconData? icon;

  const GameButton({
    super.key,
    required this.label,
    this.onTap,
    this.gradient = AppGradients.gold,
    this.shadowColor = AppColors.goldShadow,
    this.fontSize = 16,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !isLoading;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          gradient: enabled
              ? gradient
              : const LinearGradient(
              colors: [Color(0xFF334455), Color(0xFF223344)]),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outline, width: 3),
          boxShadow: [
            BoxShadow(
              color: enabled ? shadowColor : Colors.black54,
              offset: const Offset(0, 5),
              blurRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
              width: 22, height: 22,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2.5))
              : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon,
                    size: fontSize + 2,
                    color: enabled
                        ? AppColors.outline
                        : Colors.white38),
                const SizedBox(width: 8),
              ],
              Text(label,
                  style: AppTextStyles.fredoka(fontSize,
                      color: enabled
                          ? AppColors.outline
                          : Colors.white38,
                      weight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── GameCard
class GameCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? borderColor;
  final LinearGradient? gradient;
  final EdgeInsets? padding;

  const GameCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderColor,
    this.gradient,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient ?? AppGradients.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor ?? AppColors.bgLine,
            width: 2.5,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

// ─── StatBar
class StatBar extends StatelessWidget {
  final String label;
  final int value;
  final int maxValue;
  final Color color;

  const StatBar({
    super.key,
    required this.label,
    required this.value,
    required this.maxValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: AppTextStyles.bodySmall),
        Text('$value',
            style: AppTextStyles.fredoka(13,
                color: color, weight: FontWeight.bold)),
      ]),
      const SizedBox(height: 4),
      ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Stack(children: [
          Container(height: 8, color: AppColors.outline),
          FractionallySizedBox(
            widthFactor: (value / maxValue).clamp(0.0, 1.0),
            child: Container(height: 8, color: color),
          ),
        ]),
      ),
    ]);
  }
}

// ─── RiskChip
class RiskChip extends StatelessWidget {
  final int level;
  const RiskChip({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (level) {
      1 => ('FÁCIL',   AppColors.riskLow),
      2 => ('BAJO',    AppColors.riskLow),
      3 => ('MEDIO',   AppColors.riskMed),
      4 => ('ALTO',    AppColors.riskHigh),
      _ => ('EXTREMO', AppColors.riskHigh),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(label,
          style: AppTextStyles.fredoka(10,
              color: color, weight: FontWeight.bold, letterSpacing: 0.5)),
    );
  }
}

// ─── DeadlineChip
class DeadlineChip extends StatelessWidget {
  final Mission mission;
  const DeadlineChip({super.key, required this.mission});

  @override
  Widget build(BuildContext context) {
    final isUrgent = mission.timeRemaining.inHours < 2;
    final color = mission.isOverdue
        ? AppColors.red
        : isUrgent
        ? AppColors.amber
        : AppColors.sky;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.schedule, size: 11, color: color),
        const SizedBox(width: 3),
        Text(mission.timeRemainingLabel,
            style: AppTextStyles.fredoka(11,
                color: color, weight: FontWeight.bold)),
      ]),
    );
  }
}

// ─── PackageBadge
class PackageBadge extends StatelessWidget {
  final PackageState state;
  const PackageBadge({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (state) {
      PackageState.intact      => (Icons.inventory_2,  AppColors.green),
      PackageState.wetMinor    => (Icons.water_drop,   AppColors.sky),
      PackageState.damaged     => (Icons.warning,      AppColors.amber),
      PackageState.compromised => (Icons.lock_open,    AppColors.riskHigh),
      PackageState.lost        => (Icons.close,        AppColors.red),
    };
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: color),
      const SizedBox(width: 4),
      Text(state.label,
          style: AppTextStyles.fredoka(11, color: color)),
    ]);
  }
}

// ─── SkillIcon
class SkillIcon extends StatelessWidget {
  final SkillType skill;
  final int level;
  final bool large;
  const SkillIcon({
    super.key,
    required this.skill,
    required this.level,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final color    = _color(skill);
    final size     = large ? 28.0 : 20.0;
    final unlocked = level >= 1;

    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: size + 12,
        height: size + 12,
        decoration: BoxDecoration(
          color: unlocked ? color.withValues(alpha: 0.15) : AppColors.bgCard2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: unlocked ? color.withValues(alpha: 0.5) : AppColors.bgLine,
            width: 2,
          ),
        ),
        child: Center(
          child: Icon(_icon(skill),
              size: size * 0.72,
              color: unlocked ? color : AppColors.textMuted),
        ),
      ),
      const SizedBox(height: 4),
      Text('Nv.$level',
          style: AppTextStyles.fredoka(large ? 12 : 10,
              color: level >= 3 ? color : AppColors.textMuted,
              weight: FontWeight.bold)),
    ]);
  }

  IconData _icon(SkillType s) => skillIconData(s);
  Color _color(SkillType s) => skillColor(s);
}

/// Ícono Material de cada skill (reemplaza a los emojis de SkillTypeX.icon).
IconData skillIconData(SkillType s) => switch (s) {
  SkillType.speed    => Icons.bolt,
  SkillType.stealth  => Icons.visibility_off,
  SkillType.combat   => Icons.shield,
  SkillType.survival => Icons.eco,
  SkillType.contacts => Icons.people,
};

Color skillColor(SkillType s) => switch (s) {
  SkillType.speed    => AppColors.skillSpeed,
  SkillType.stealth  => AppColors.skillStealth,
  SkillType.combat   => AppColors.skillCombat,
  SkillType.survival => AppColors.skillSurvival,
  SkillType.contacts => AppColors.skillContacts,
};