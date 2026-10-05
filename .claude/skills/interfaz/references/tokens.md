# Tokens y contraste

Todo en `lib/presentation/theme/app_theme.dart`.

## Colores

| Grupo | Tokens | Uso |
|---|---|---|
| Fondos | `bgDeep #0A1628` · `bgDark #0F1E36` · `bgCard #142040` (semitransp.) · `bgCard2 #0D1830` · `bgLine #2A3E5C` | Scaffold, cards, separadores |
| Primario | `gold #FFCC00` · `goldDark` · `goldShadow` · `amber` · `amberDark` | **Todos** los botones de acción |
| Secundario | `brown` · `brownCard` · `brownBorder` | Cards de misión/tutorial |
| Acento | `sky #4A9EBF` · `skyDark` | Chips e info pasiva |
| Peligro | `red #CC2200` · `redDark` · `redShadow` | Solo urgencia real |
| Riesgo | `riskLow #44AA55` · `riskMed #CC8800` · `riskHigh #CC2200` | Semáforo de `RiskChip` |
| Skills | `skillSpeed` cielo · `skillStealth` violeta · `skillCombat` rojo · `skillSurvival` verde · `skillContacts` ámbar | Identidad de cada camino |
| Texto | `textPrimary #EEDDAA` pergamino · `textSecondary #B5A87E` · `textMuted #9C9484` · `outline #080F1C` | `textMuted` **nunca más oscuro** |

## Contraste medido (ratio sobre los fondos del juego)

| Color de texto | bgDeep | bgDark | bgCard | Veredicto |
|---|---|---|---|---|
| `textPrimary` | 13.4 | 12.4 | 11.9 | ✅ cualquier tamaño |
| `gold` | 12.0 | 11.0 | 10.6 | ✅ cualquier tamaño |
| `textSecondary` | 7.7 | 7.0 | 6.8 | ✅ |
| `amber` | 7.4 | 6.8 | 6.5 | ✅ |
| `green` / `riskMed` | 6.1 | 5.6 | 5.4 | ✅ |
| `textMuted` | 6.0 | 5.5 | 5.3 | ✅ (piso: no lo oscurezcas) |
| `sky` | 6.0 | 5.5 | 5.3 | ✅ |
| `red` | 3.3 | 3.0 | 2.9 | ⚠️ **solo ≥18pt bold, bordes, fills e íconos** |
| `purple` / `skillStealth` | 2.9 | 2.6 | 2.5 | ❌ **nunca como texto** — solo borde/fill |

Sobre `gold` como fondo, el texto va en `outline #080F1C` (12.7:1) — es lo que hace `GameButton`.

Al agregar un color, verificalo antes de commitear:

```bash
python3 -c "
def L(h):
    h=h.lstrip('#'); c=[int(h[i:i+2],16)/255 for i in (0,2,4)]
    c=[(x/12.92 if x<=0.03928 else ((x+0.055)/1.055)**2.4) for x in c]
    return 0.2126*c[0]+0.7152*c[1]+0.0722*c[2]
def r(a,b):
    la,lb=L(a),L(b); hi,lo=max(la,lb),min(la,lb); return round((hi+0.05)/(lo+0.05),2)
print(r('NUEVO','0F1E36'))"
```

## Tipografía

| Estilo | Fuente / tamaño | Uso |
|---|---|---|
| `displayLarge` | Fredoka 32 bold, gold | Títulos de pantalla hero |
| `titleLarge` | Fredoka 20 bold, textPrimary | Títulos de pantalla |
| `titleMedium` | Fredoka 15 bold, gold | Encabezado de sección (`SectionHeader`) |
| `titleSmall` | Fredoka 12, textSecondary | Etiquetas, overlines |
| `bodyLarge` | Nunito 14 w600, textPrimary | **Prosa narrativa** (line-height 1.5) |
| `bodyMedium` | Nunito 12 w500, textSecondary | Descripciones, subtítulos |
| `bodySmall` | Nunito 11 w600, textMuted | Metadatos, labels de stats |

Helper: `AppTextStyles.fredoka(size, color:, weight:, letterSpacing:)` para casos puntuales. Sin tamaños fuera de esta escala.

## Gradientes

`background` · `header` · `card` · `gold` (botones) · `tutorialCard` (marrón) · `green` · `red` · `sky` · `blue` · `amber` · `purple`. Siempre 2-3 stops. Sin neón.

## Fondos por pantalla

`GradientScaffold(useHomeBg: true)` alterna día/noche con el helper `isDay` (6-20 h del dispositivo). `useEventBg: true` para eventos (scrim más fuerte). Sin asset, cae al gradiente `background`.

Los PNG de fondo pesan 8-9 MB: deuda conocida, objetivo WebP < 500 KB (roadmap 0.4). No agregues assets pesados nuevos.
