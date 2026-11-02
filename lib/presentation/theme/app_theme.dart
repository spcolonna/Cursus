import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/entities.dart';
import '../feedback/feedback.dart';
import '../providers/providers.dart';
import 'motion.dart';
import '../../l10n/app_localizations.dart';

export 'motion.dart';

// ═══ Paleta "Fresco al atardecer" ═══════════════════════════════════════════
// Papel sobre cielo vivo: la interfaz es papel y tinta, así el contraste no
// depende de la hora; lo que cambia con el reloj es el cielo (Fase I3).
//
// Roles (uno por pigmento):
//   ocre          acción principal (relleno; como texto, ochreDeep)
//   cinabrio      marca y peligro — el peligro SIEMPRE lleva además ícono
//   azul egipcio  información
//   verdigrís     éxito
//   púrpura Tiro  sigilo y lo secreto
//   siena         atención (no peligro)
//
// Todo par texto/fondo que se usa está en kTextPairs y lo valida
// test/contrast_test.dart (WCAG AA).
class AppColors {
  // ─── Superficies
  static const paperHigh  = Color(0xFFF8F1E3);  // luz del papel (gradientes)
  static const paper      = Color(0xFFF2E8D5);  // cal: cards y hojas
  static const paperDeep  = Color(0xFFE6D8BE);  // fondo de página, pozos
  static const paperNight = Color(0xFFE0D3BA);  // el papel de noche (cielo vivo)
  static const paperShade = Color(0xFFD5C6A6);  // deshabilitado, rieles
  static const paperLine  = Color(0xFFC4AF88);  // bordes finos y divisores

  // ─── Tinta
  static const ink      = Color(0xFF231A16);
  static const inkSoft  = Color(0xFF3E3129);
  static const inkMuted = Color(0xFF5E4F41);  // NUNCA más clara (4.5:1 sobre paperShade)

  // ─── Pigmentos
  static const ochreLight    = Color(0xFFE8BE62);
  static const ochre         = Color(0xFFD9A441);  // relleno de la acción principal
  static const ochreDeep     = Color(0xFF754F10);  // ocre como texto, ícono o borde
  static const sienna        = Color(0xFF8A4614);  // atención
  static const cinnabarLight = Color(0xFFC9483F);
  static const cinnabar      = Color(0xFFA4302B);  // marca y peligro
  static const cinnabarDeep  = Color(0xFF6E1C18);
  static const egyptianBlueLight = Color(0xFF6F93C4);  // rellenos sin texto
  static const egyptianBlue  = Color(0xFF2D5A9A);  // información
  static const verdigrisLight= Color(0xFF3F7F72);  // rellenos sin texto
  static const verdigris     = Color(0xFF2E6357);  // éxito (apto para texto)
  static const tyrianLight   = Color(0xFF8E5A91);  // rellenos sin texto
  static const tyrian        = Color(0xFF6B3E6E);  // sigilo y secreto

  // ─── Sobre el cielo y las escenas pintadas
  // Solo títulos grandes, y siempre con scrimSky debajo.
  static const onSky    = Color(0xFFF7EFDC);
  static const scrimSky = Color(0x99231A16);

  // ─── Sombras y velos: de tinta, no de negro (sombras cálidas)
  static const shadowSoft = Color(0x33231A16);
  static const shadowHard = Color(0x66231A16);
  static const scrim      = Color(0xB3231A16);
  static const transparent = Color(0x00000000);
}

/// Pares texto/fondo que usa la interfaz. `large` = título ≥18 pt (o ≥14 pt
/// bold): alcanza con 3:1. Agregá acá cualquier combinación nueva.
final kTextPairs = <({String name, Color fg, Color bg, bool large})>[
  for (final bg in [
    (n: 'paper', c: AppColors.paper),
    (n: 'paperDeep', c: AppColors.paperDeep),
    (n: 'paperNight', c: AppColors.paperNight),
  ]) ...[
    (name: 'ink/${bg.n}', fg: AppColors.ink, bg: bg.c, large: false),
    (name: 'inkSoft/${bg.n}', fg: AppColors.inkSoft, bg: bg.c, large: false),
    (name: 'inkMuted/${bg.n}', fg: AppColors.inkMuted, bg: bg.c, large: false),
    (name: 'ochreDeep/${bg.n}', fg: AppColors.ochreDeep, bg: bg.c, large: false),
    (name: 'sienna/${bg.n}', fg: AppColors.sienna, bg: bg.c, large: false),
    (name: 'cinnabar/${bg.n}', fg: AppColors.cinnabar, bg: bg.c, large: false),
    (name: 'egyptianBlue/${bg.n}', fg: AppColors.egyptianBlue, bg: bg.c, large: false),
    (name: 'verdigris/${bg.n}', fg: AppColors.verdigris, bg: bg.c, large: false),
    (name: 'tyrian/${bg.n}', fg: AppColors.tyrian, bg: bg.c, large: false),
  ],
  (name: 'inkMuted/paperShade', fg: AppColors.inkMuted, bg: AppColors.paperShade, large: false),
  // Rellenos con texto encima (botones, chips llenos, sellos).
  (name: 'ink/ochre', fg: AppColors.ink, bg: AppColors.ochre, large: false),
  (name: 'ink/ochreLight', fg: AppColors.ink, bg: AppColors.ochreLight, large: false),
  (name: 'paper/cinnabar', fg: AppColors.paper, bg: AppColors.cinnabar, large: false),
  (name: 'paper/cinnabarDeep', fg: AppColors.paper, bg: AppColors.cinnabarDeep, large: false),
  (name: 'paper/egyptianBlue', fg: AppColors.paper, bg: AppColors.egyptianBlue, large: false),
  (name: 'paper/verdigris', fg: AppColors.paper, bg: AppColors.verdigris, large: false),
  (name: 'paper/tyrian', fg: AppColors.paper, bg: AppColors.tyrian, large: false),
  (name: 'paper/sienna', fg: AppColors.paper, bg: AppColors.sienna, large: false),
  (name: 'paper/ink', fg: AppColors.paper, bg: AppColors.ink, large: false),
  (name: 'ochre/ink', fg: AppColors.ochre, bg: AppColors.ink, large: false),
  (name: 'ochreLight/ink', fg: AppColors.ochreLight, bg: AppColors.ink, large: false),
  // Sobre escenas: el peor caso es el velo solo, sin la escena.
  (name: 'onSky/scrimSky+ink', fg: AppColors.onSky, bg: AppColors.ink, large: true),
];

// ─── Notas de misión (S/A/B/C/F) — un solo lugar para color y fondo
// La S es púrpura de Tiro: el color de los emperadores.
Color gradeColor(String grade) => switch (grade) {
      'S' => AppColors.tyrian,
      'A' => AppColors.ochreDeep,
      'B' => AppColors.verdigris,
      'C' => AppColors.egyptianBlue,
      'F' => AppColors.cinnabar,
      _ => AppColors.inkMuted,
    };

/// Papel apenas teñido por un pigmento, y opaco: lo que va encima se lee
/// igual sobre una card que sobre una escena pintada.
Color paperTint(Color c, {double amount = 0.12, Color paper = AppColors.paper}) =>
    Color.alphaBlend(c.withValues(alpha: amount), paper);

/// Fondo de la pantalla de resultado: el papel apenas teñido por la nota.
Color gradeBackground(String grade) =>
    paperTint(gradeColor(grade), amount: 0.06);

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
  static const xs = 6.0;   // botones: borde de estampa, casi recto
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 18.0;
}

// ─── Gradientes: casi planos (fresco, no plástico). Dos tonos del mismo
// pigmento; el texto encima tiene que pasar contra el tono más claro.
class AppGradients {
  static const page = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.paper, AppColors.paperDeep],
  );
  /// La página de noche: el papel baja un punto de brillo.
  static const pageNight = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.paperDeep, AppColors.paperNight],
  );
  static const paper = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.paperHigh, AppColors.paper],
  );
  /// Portada: el arte se ve arriba y se oscurece hacia abajo, donde van la
  /// marca y el botón (onSky ≥4.5:1 desde el 55% del alto).
  static const titleScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.12, 0.38, 0.6, 0.88],
    colors: [
      AppColors.scrimSky,
      AppColors.transparent,
      AppColors.transparent,
      AppColors.scrim,
      AppColors.ink,
    ],
  );
  static const ochre = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.ochreLight, AppColors.ochre],
  );
  static const cinnabar = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.cinnabar, AppColors.cinnabarDeep],
  );
  static const egyptianBlue = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.egyptianBlue, Color(0xFF244B82)],
  );
  static const verdigris = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.verdigris, Color(0xFF234D43)],
  );
  static const tyrian = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.tyrian, Color(0xFF55305A)],
  );
  static const sienna = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.sienna, Color(0xFF733A10)],
  );
  static const disabled = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.paperShade, AppColors.paperShade],
  );

  // Papeles teñidos: la card dice de qué se trata sin perder la tinta.
  static const ochreTint = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF6E7C4), Color(0xFFEEDDB8)],
  );
  static const cinnabarTint = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF5E1D6), Color(0xFFEDD3C6)],
  );
  static const verdigrisTint = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE3E6D6), Color(0xFFD8DCC8)],
  );
  static const tyrianTint = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFEDE0DC), Color(0xFFE3D3D0)],
  );
  static const blueTint = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE2E3E0), Color(0xFFD6D9D8)],
  );

  // Evento: papel con la urgencia en el borde, no en el fondo.
  static const event = cinnabarTint;

  // Opciones de evento: normal, seleccionada y secreta.
  static const option = paper;
  static const optionSelected = ochreTint;
  static const optionSecret = tyrianTint;

  // Epílogo de historia: el papel del púrpura de lo narrativo.
  static const story = tyrianTint;

  // Encabezado de pantalla: la hoja de arriba, con su filete abajo.
  static const header = paper;

  // Portada (login/splash) y escenas: la escena arriba, el velo abajo.
  static const coverScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x00231A16), Color(0x33231A16), Color(0xCC231A16)],
    stops: [0.0, 0.45, 0.85],
  );
}

// ─── Tipografía
// Marcellus (capitales romanas) para títulos · Figtree para la interfaz ·
// Literata para la prosa narrativa (eventos, desenlaces, diario, capítulos).
class AppTextStyles {
  /// Piso de legibilidad: ningún texto del juego baja de 12 pt.
  static const double minSize = 12;

  static double _floor(double size) => size < minSize ? minSize : size;

  /// Interfaz: botones, chips, números, etiquetas.
  static TextStyle ui(
    double size, {
    Color color = AppColors.ink,
    double letterSpacing = 0,
    FontWeight weight = FontWeight.w500,
  }) =>
      TextStyle(
        fontFamily: 'Figtree',
        fontSize: _floor(size),
        color: color,
        letterSpacing: letterSpacing,
        fontWeight: weight,
      );

  /// Títulos: Marcellus tiene un solo peso; el énfasis es tamaño y aire.
  static TextStyle heading(
    double size, {
    Color color = AppColors.ink,
    double letterSpacing = 0.5,
  }) =>
      TextStyle(
        fontFamily: 'Marcellus',
        fontSize: _floor(size),
        color: color,
        height: 1.15,
        letterSpacing: letterSpacing,
      );

  /// Prosa narrativa: lo que se lee como una carta.
  static TextStyle prose({double size = 16, Color color = AppColors.ink}) =>
      TextStyle(
        fontFamily: 'Literata',
        fontSize: _floor(size),
        color: color,
        height: 1.55,
      );

  static TextStyle proseItalic({double size = 16, Color color = AppColors.inkSoft}) =>
      prose(size: size, color: color).copyWith(fontStyle: FontStyle.italic);

  /// Wordmark de la marca: capitales romanas con mucho aire.
  static TextStyle brandWordmark(double size, Color color) => TextStyle(
        fontFamily: 'Marcellus',
        fontSize: size,
        height: 1,
        letterSpacing: size * 0.18,
        color: color,
      );

  /// Bajada de la marca ("CARTAS DE ROMA").
  static TextStyle brandTagline(double size, Color color) => TextStyle(
        fontFamily: 'Figtree',
        fontWeight: FontWeight.w600,
        fontSize: _floor(size),
        letterSpacing: size * 0.27,
        color: color,
      );

  /// Para pintar un ícono Material en un Canvas (TextPainter).
  static TextStyle iconGlyph(IconData icon, double size, Color color) =>
      TextStyle(
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        fontSize: size,
        color: color,
      );

  static TextStyle get displayLarge => heading(32, letterSpacing: 2);
  static TextStyle get titleLarge => heading(22);
  static TextStyle get titleMedium =>
      heading(17, color: AppColors.ochreDeep, letterSpacing: 1);
  static TextStyle get titleSmall =>
      ui(12, color: AppColors.inkSoft, letterSpacing: 1.2, weight: FontWeight.w600);

  static TextStyle get bodyLarge => const TextStyle(
        fontFamily: 'Figtree',
        fontSize: 15, color: AppColors.ink, height: 1.45,
        fontWeight: FontWeight.w500,
      );
  static TextStyle get bodyMedium => const TextStyle(
        fontFamily: 'Figtree',
        fontSize: 13, color: AppColors.inkSoft, height: 1.4,
      );
  static TextStyle get bodySmall => const TextStyle(
        fontFamily: 'Figtree',
        fontSize: 12, color: AppColors.inkMuted, fontWeight: FontWeight.w600,
      );
}

// ─── Theme
class AppTheme {
  static ThemeData get theme => light;
  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.paperDeep,
        colorScheme: const ColorScheme.light(
          primary: AppColors.ochre,
          onPrimary: AppColors.ink,
          secondary: AppColors.egyptianBlue,
          onSecondary: AppColors.paper,
          surface: AppColors.paper,
          onSurface: AppColors.ink,
          error: AppColors.cinnabar,
          onError: AppColors.paper,
        ),
        fontFamily: 'Figtree',
        dividerColor: AppColors.paperLine,
        // Interruptor de estampa: prendido es ocre con la perilla de tinta.
        // La pista vacía en paperLine: sobre papel, la del tema se pierde.
        sliderTheme: const SliderThemeData(
          inactiveTrackColor: AppColors.paperLine,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected) ? AppColors.ink : AppColors.inkMuted),
          trackColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected) ? AppColors.ochre : AppColors.paperShade),
          trackOutlineColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected) ? AppColors.ink : AppColors.inkMuted),
        ),
        progressIndicatorTheme:
            const ProgressIndicatorThemeData(color: AppColors.ochreDeep),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: AppColors.ink,
          selectionColor: AppColors.ochreLight,
        ),
      );
}

// ─── GradientScaffold — la página de papel
// Con [background] (escena de evento) la escena ocupa la parte de arriba y se
// funde con el papel; el contenido va sobre el papel.
class GradientScaffold extends StatelessWidget {
  final Widget body;

  /// Fondo pintado o ilustrado (escena de evento).
  final Widget? background;

  const GradientScaffold({
    super.key,
    required this.body,
    this.background,
  });

  static const _sceneFade = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    // Arriba, el velo de scrimSky: la barra de estado (clara) se lee sobre
    // cualquier cielo, de día, de noche o con tormenta.
    colors: [
      AppColors.scrimSky,
      Color(0x00231A16),
      Color(0x00E6D8BE),
      AppColors.paperDeep,
    ],
    stops: [0.0, 0.16, 0.3, 0.46],
  );

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      backgroundColor: AppColors.paperDeep,
      body: Stack(fit: StackFit.expand, children: [
        const PaperPage(),
        if (background != null) ...[
          background!,
          const DecoratedBox(decoration: BoxDecoration(gradient: _sceneFade)),
        ],
        body,
      ]),
    );
    if (background == null) return scaffold;
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light, child: scaffold);
  }
}

/// El fondo de papel de las pantallas: de noche (según el cielo vivo) baja
/// a `paperNight` para no encandilar.
class PaperPage extends ConsumerWidget {
  const PaperPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final night = ref.watch(skyPaletteProvider.select((s) => s.dimPaper));
    return DecoratedBox(
      decoration: BoxDecoration(
          gradient: night ? AppGradients.pageNight : AppGradients.page),
    );
  }
}

// ─── GameButton — estampa: relleno plano, contorno de tinta y sombra dura
// corta. Se hunde al tocarlo (la sombra se achica y el botón baja), suena y
// vibra. Deshabilitado: papel gris legible, y si se toca igual vibra suave
// para que el jugador sepa que el toque llegó.
//
// Un solo primario (ocre) por vista. El resto según su rol.
enum GameButtonVariant { primary, secondary, ghost, danger, info, success, secret }

class GameButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final double fontSize;
  final bool isLoading;
  final IconData? icon;
  final GameButtonVariant variant;

  const GameButton({
    super.key,
    required this.label,
    this.onTap,
    this.fontSize = 16,
    this.isLoading = false,
    this.icon,
    this.variant = GameButtonVariant.primary,
  });

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton> {
  static const _depth = 3.0;
  bool _pressed = false;

  bool get _enabled => widget.onTap != null && !widget.isLoading;

  /// (relleno, color del texto, con contorno y sombra)
  (Gradient?, Color, bool) get _palette {
    if (!_enabled) return (AppGradients.disabled, AppColors.inkMuted, true);
    return switch (widget.variant) {
      GameButtonVariant.primary => (AppGradients.ochre, AppColors.ink, true),
      GameButtonVariant.secondary => (AppGradients.paper, AppColors.ink, true),
      GameButtonVariant.ghost => (null, AppColors.ink, false),
      GameButtonVariant.danger => (AppGradients.cinnabar, AppColors.paper, true),
      GameButtonVariant.info => (AppGradients.egyptianBlue, AppColors.paper, true),
      GameButtonVariant.success => (AppGradients.verdigris, AppColors.paper, true),
      GameButtonVariant.secret => (AppGradients.tyrian, AppColors.paper, true),
    };
  }

  void _setPressed(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final (gradient, fg, stamped) = _palette;
    final down = _pressed && _enabled && stamped;
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
            margin: EdgeInsets.only(top: down ? _depth : 0),
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(AppRadii.xs),
              border: stamped
                  ? Border.all(
                      color: _enabled ? AppColors.ink : AppColors.inkMuted,
                      width: 2)
                  : null,
              boxShadow: [
                if (stamped)
                  BoxShadow(
                    color: _enabled ? AppColors.ink : AppColors.paperLine,
                    offset: Offset(down ? 0 : _depth, down ? 0 : _depth),
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
                              style: AppTextStyles.ui(widget.fontSize,
                                  color: fg,
                                  weight: FontWeight.w700,
                                  letterSpacing: 0.6)),
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

// ─── GameCard — una hoja de papel
// Borde fino de papel (o de color si la card tiene algo que decir), sombra
// cálida y, opcional, la guarda de un friso pompeyano arriba.
// Si es tocable, se achica apenas al presionar: el jugador siente el toque.
class GameCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? borderColor;
  final LinearGradient? gradient;
  final EdgeInsets? padding;
  final String? semanticLabel;
  final bool frieze;

  const GameCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderColor,
    this.gradient,
    this.padding,
    this.semanticLabel,
    this.frieze = false,
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
    final padding = widget.padding ?? const EdgeInsets.all(AppSpacing.lg);
    final card = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: widget.gradient ?? AppGradients.paper,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: widget.borderColor ?? AppColors.paperLine,
          width: widget.borderColor == null ? 1 : 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: widget.frieze
          ? ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.md - 1),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const PompeianFrieze(),
                Padding(padding: padding, child: widget.child),
              ]),
            )
          : Padding(padding: padding, child: widget.child),
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

// ─── PompeianFrieze — la guarda de las cards destacadas
// Banda cinabrio con un filete ocre y una línea de dentículos, como el borde
// de un fresco. Puramente decorativa.
class PompeianFrieze extends StatelessWidget {
  final double height;
  const PompeianFrieze({super.key, this.height = 10});

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(painter: _FriezePainter()),
        ),
      );
}

class _FriezePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    final band = h * 0.55;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, band),
        Paint()..color = AppColors.cinnabar);
    canvas.drawRect(Rect.fromLTWH(0, band, size.width, h * 0.15),
        Paint()..color = AppColors.ochre);
    // Dentículos: bloquecitos de tinta con aire entre medio.
    final tooth = Paint()..color = AppColors.cinnabarDeep;
    final w = h * 0.4;
    for (var x = w * 0.5; x < size.width; x += w * 2) {
      canvas.drawRect(Rect.fromLTWH(x, h * 0.78, w, h * 0.22), tooth);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
            style: AppTextStyles.ui(13,
                color: color, weight: FontWeight.bold)),
      ]),
      const SizedBox(height: 4),
      ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Stack(children: [
          Container(height: 8, color: AppColors.paperShade),
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
    final l = AppLocalizations.of(context);
    final (label, color) = switch (level) {
      1 => (l.riskEasy,    AppColors.verdigris),
      2 => (l.riskLow,     AppColors.verdigris),
      3 => (l.riskMedium,  AppColors.sienna),
      4 => (l.riskHigh,    AppColors.cinnabar),
      _ => (l.riskExtreme, AppColors.cinnabar),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: paperTint(color),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(label,
          style: AppTextStyles.ui(10,
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
    final arrived = mission.isOverdue;
    final isUrgent = mission.timeRemaining.inMinutes < 10;
    final color = arrived
        ? AppColors.ochreDeep
        : isUrgent
            ? AppColors.sienna
            : AppColors.egyptianBlue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: paperTint(color),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(arrived ? Icons.flag_rounded : Icons.schedule,
            size: 13, color: color),
        const SizedBox(width: 3),
        Text(mission.timeRemainingLabel,
            style: AppTextStyles.ui(12,
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
      PackageState.intact      => (Icons.inventory_2,  AppColors.verdigris),
      PackageState.wetMinor    => (Icons.water_drop,   AppColors.egyptianBlue),
      PackageState.damaged     => (Icons.warning,      AppColors.sienna),
      PackageState.compromised => (Icons.lock_open,    AppColors.cinnabar),
      PackageState.lost        => (Icons.close,        AppColors.cinnabar),
    };
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: color),
      const SizedBox(width: 4),
      Text(state.label,
          style: AppTextStyles.ui(11, color: color)),
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
          color: unlocked ? paperTint(color) : AppColors.paperDeep,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: unlocked ? color.withValues(alpha: 0.5) : AppColors.paperLine,
            width: 2,
          ),
        ),
        child: Center(
          child: Icon(_icon(skill),
              size: size * 0.72,
              color: unlocked ? color : AppColors.inkMuted),
        ),
      ),
      const SizedBox(height: 4),
      Text(AppLocalizations.of(context).skillLevelShort(level),
          style: AppTextStyles.ui(large ? 12 : 10,
              color: level >= 3 ? color : AppColors.inkMuted,
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
  SkillType.speed    => AppColors.egyptianBlue,
  SkillType.stealth  => AppColors.tyrian,
  SkillType.combat   => AppColors.cinnabar,
  SkillType.survival => AppColors.verdigris,
  SkillType.contacts => AppColors.ochreDeep,
};