# Patrones de pantalla

## Esqueleto de pantalla nueva

```dart
class XScreen extends ConsumerWidget {
  const XScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(xProvider);
    return GradientScaffold(
      body: SafeArea(
        child: state.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
          error: (e, _) => _ErrorView(message: '$e'),
          data: (data) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              SectionHeader(title: 'TÍTULO'),
              // …
            ],
          ),
        ),
      ),
    );
  }
}
```

Registrala en `router.dart` reusando las transiciones custom que ya están definidas ahí.

## Jerarquía visual por pantalla

Cada pantalla responde **una** pregunta y ofrece **una** acción primaria dorada:

| Pantalla | Pregunta | Acción primaria |
|---|---|---|
| Home | ¿Qué pasa ahora? | Evento pendiente (rojo, pulsante) > Entregar > Aceptar ruta |
| Mission | ¿Cómo va el viaje? | Ver evento / Entregar al 100% |
| Event | ¿Qué hago? | Las 2-4 opciones (cards, no botones) |
| Result | ¿Cómo me fue? | Volver al Home |
| Profile / Skills | ¿Qué tan bueno soy? | Ascender skill |
| Shop | ¿Qué me falta? | Comprar |

Orden en el Home: **urgente → en curso → disponible → informativo**. El evento pendiente siempre arriba y en rojo; nunca dos elementos rojos a la vez.

## Espaciado y forma

- Padding de pantalla: `16` horizontal, `12` arriba, `32` abajo.
- Separación entre cards: `12`; entre secciones: `20-24`.
- Radios: botones `14`, cards `16`, chips `7-10`.
- Bordes: cards `2.5` px, botones `3` px (`AppColors.outline`), chips `1.5` px.
- Sombra de botón: offset `(0, 5)`, `blurRadius: 0` — la sombra dura es parte de la identidad, no la difumines.

## Densidad de información

Una card muestra como máximo: título + 1 línea de lore + 3 chips (riesgo, duración, paga). Todo lo demás va en el detalle. Si una card necesita scroll interno, está mal.

## Animación

`flutter_animate` ya es dependencia. Reglas:

- Entrada de listas: `.fadeIn(duration: 200.ms).slideY(begin: 0.1)`, stagger de 40 ms, máximo 6 elementos.
- Progreso de misión: transición suave, **nunca** re-animar en cada tick de 1 s.
- `PulsingDot` solo para lo que exige atención ahora (evento activo).
- Sin animaciones >400 ms en el camino crítico: el jugador tiene 90 segundos.
- Nada de parallax, blur pesado ni partículas: los fondos ya son costosos.

## Estados obligatorios

Toda pantalla cubre: **cargando** (spinner dorado), **vacío** (una línea narrativa, no "no hay datos": *"Tu mensajero descansa. El camino puede esperar."*), **error**, y **ya-hecho** (contrato reclamado, paga cobrada) con el control deshabilitado, no oculto.

`GameButton` con `onTap: null` ya se dibuja gris deshabilitado; usá eso en lugar de esconder el botón.

## Diálogos

Fondo `bgCard`, borde `bgLine` 2.5, título `titleMedium`, cuerpo `bodyMedium`. Botón primario dorado a la derecha; "Cancelar" como texto en `textSecondary` (nunca `textMuted` con opacity). Máximo 2 acciones.

## Feedback de recompensa

Denarios/Aureos/Sellos siempre con su ícono Material + cantidad en Fredoka bold del color del recurso (oro para Aureos, `textPrimary` para Denarios, `sky` para Sellos). Nunca solo un número suelto.

## Antipatrones vistos en este repo

- Emojis sueltos (📜 splash, 🏃 perfil, ✅⚡❌ outcomes) → reemplazar por íconos Material.
- Hints de input con `textMuted` + `opacity 0.5` → usar `textSecondary` sin opacity.
- `SectionHeader` no es `const` (acepta strings dinámicos): no le pongas `const` al construirlo.
- Pantallas de 1.000+ líneas (`home_screen.dart`): al tocarlas, extraé el bloque que edites a un widget privado en vez de agrandar el archivo.
