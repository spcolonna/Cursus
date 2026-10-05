import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/entities.dart';
import '../feedback/feedback.dart';
import 'motion.dart';

export 'motion.dart';

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

  // Deshabilitado: el texto usa textSecondary (5.2:1 sobre disabledTop).
  static const disabledTop    = Color(0xFF2A3644);
  static const disabledBottom = Color(0xFF1E2A38);

  // Nota S: naranja propio (antes vivía suelto en GradeBadge y en resultado).
  static const gradeS = Color(0xFFFF8C00);

  // Pergamino claro: prosa sobre fondos rojos/oscuros (9.6:1 sobre eventTop).
  static const parchment = Color(0xFFF7EFDC);

  // Evento: vino oscuro, no rojo chillón — el rojo puro queda para urgencia.
  static const eventTop    = Color(0xFF7F0000);
  static const eventBottom = Color(0xFF4A0E0E);

  // Superficies con tinte
  static const topBar    = Color(0xCC060E1A);  // barra superior translúcida
  static const amberCard = Color(0xDD1A0800);  // panel de evento en ruta
  static const trackDark = Color(0xFF0A1020);  // fondo de barras de progreso

  // Sombras y velos
  static const shadowSoft = Color(0x66000000);
  static const shadowHard = Color(0x88000000);
  static const scrim      = Color(0xB3060E1A);
}

// ─── Notas de misión (S/A/B/C/F) — un solo lugar para color y fondo
Color gradeColor(String grade) => switch (grade) {
      'S' => AppColors.gradeS,
      'A' => AppColors.gold,
      'B' => AppColors.green,
      'C' => AppColors.sky,
      'F' => AppColors.red,
      _ => AppColors.textMuted,
    };

/// Fondo tintado por nota para la pantalla de resultado.
Color gradeBackground(String grade) => switch (grade) {
      'S' => const Color(0xFF1A1400),
      'A' => const Color(0xFF16140A),
      'B' => const Color(0xFF0A1A0E),
      'C' => const Color(0xFF0A1220),
      'F' => const Color(0xFF1A0808),
      _ => AppColors.bgDeep,
    };

// ─── Espaciado y radios — múltiplos de 4, nada de números sueltos
class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

class AppRadii {
  static const sm = 8.0;
  static const md = 14.0;
  static const lg = 20.0;
}

// ─── Gradients — solo 2-3 colores, sin locuras
class AppGradients {
  static const event = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.eventTop, AppColors.eventBottom],
  );

  // Opciones de evento: normal, seleccionada y secreta (callback de historia).
  static const option = LinearGradient(
    colors: [Color(0xFF1A2A4A), Color(0xFF111E36)],
  );
  static const optionSelected = LinearGradient(
    colors: [Color(0xFF1A4E9A), Color(0xFF103060)],
  );
  static const optionSecret = LinearGradient(
    colors: [Color(0xFF2A1A4A), Color(0xFF1A1136)],
  );

  // Epílogo de historia: tinta violeta, el color de lo narrativo.
  static const story = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF241A38), Color(0xFF16101F)],
  );

  static const disabled = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.disabledTop, AppColors.disabledBottom],
  );

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
  /// Piso de legibilidad: ningún texto del juego baja de 12 pt. Los tamaños
  /// menores que quedaron en pantallas viejas se suben acá, en un solo lugar.
  static const double minSize = 12;

  static TextStyle fredoka(
      double size, {
        Color color = AppColors.textPrimary,
        double letterSpacing = 0,
        FontWeight weight = FontWeight.normal,
      }) {
    return GoogleFonts.fredoka(
      fontSize: size < minSize ? minSize : size,
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
    fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600,
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
// Se hunde al tocarlo (la sombra dura se achica y el botón baja), suena y
// vibra. Deshabilitado: gris legible, y si se toca igual vibra suave para que
// el jugador sepa que el toque llegó.
enum GameButtonVariant { primary, secondary, danger }

class GameButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final LinearGradient gradient;
  final Color shadowColor;
  final double fontSize;
  final bool isLoading;
  final IconData? icon;
  final GameButtonVariant variant;

  const GameButton({
    super.key,
    required this.label,
    this.onTap,
    this.gradient = AppGradients.gold,
    this.shadowColor = AppColors.goldShadow,
    this.fontSize = 16,
    this.isLoading = false,
    this.icon,
    this.variant = GameButtonVariant.primary,
  });

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton> {
  static const _depth = 5.0;
  bool _pressed = false;

  bool get _enabled => widget.onTap != null && !widget.isLoading;

  (LinearGradient, Color, Color) get _palette {
    if (!_enabled) {
      return (AppGradients.disabled, AppColors.outline, AppColors.textSecondary);
    }
    return switch (widget.variant) {
      GameButtonVariant.primary =>
        (widget.gradient, widget.shadowColor, AppColors.outline),
      GameButtonVariant.secondary =>
        (AppGradients.card, AppColors.outline, AppColors.gold),
      GameButtonVariant.danger =>
        (AppGradients.red, AppColors.redShadow, AppColors.textPrimary),
    };
  }

  void _setPressed(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final (gradient, shadow, fg) = _palette;
    final down = _pressed && _enabled;
    final duration = AppMotion.of(context, AppMotion.fast);

    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        onTap: () {
          if (!_enabled) {
            if (!widget.isLoading) AppFeedback.denied();
            return;
          }
          AppFeedback.tap();
          widget.onTap!();
        },
        // El hueco de la sombra se reserva siempre: al hundirse, el botón
        // baja sin empujar el layout.
        child: Padding(
          padding: EdgeInsets.only(bottom: down ? 0 : _depth),
          child: AnimatedContainer(
            duration: duration,
            curve: AppMotion.enter,
            margin: EdgeInsets.only(top: down ? _depth - 1 : 0),
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 20),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: AppColors.outline, width: 3),
              boxShadow: [
                BoxShadow(
                  color: shadow,
                  offset: Offset(0, down ? 1 : _depth),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: fg, strokeWidth: 2.5))
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon,
                              size: widget.fontSize + 2, color: fg),
                          const SizedBox(width: AppSpacing.sm),
                        ],
                        Flexible(
                          child: Text(widget.label,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.fredoka(widget.fontSize,
                                  color: fg, weight: FontWeight.bold)),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── GameCard
// Si es tocable, se achica apenas al presionar: el jugador siente el toque.
class GameCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? borderColor;
  final LinearGradient? gradient;
  final EdgeInsets? padding;
  final String? semanticLabel;

  const GameCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderColor,
    this.gradient,
    this.padding,
    this.semanticLabel,
  });

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: widget.padding ?? const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: widget.gradient ?? AppGradients.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.borderColor ?? AppColors.bgLine,
          width: 2.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: widget.child,
    );
    if (widget.onTap == null) return card;

    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        onTap: () {
          AppFeedback.tap();
          widget.onTap!();
        },
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1,
          duration: AppMotion.of(context, AppMotion.fast),
          curve: AppMotion.enter,
          child: card,
        ),
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