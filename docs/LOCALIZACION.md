# Localización: español e inglés

Fase L6 del plan de lanzamiento.

## Cómo está armado

| Qué | Dónde está el español | Dónde va la traducción |
|---|---|---|
| UI (botones, títulos, avisos) | `lib/l10n/app_es.arb` | `lib/l10n/app_en.arb` (gen-l10n → `AppLocalizations`) |
| Contenido (eventos, rutas, capítulos, logros…) | `lib/data/*.dart` (fuente) | `assets/l10n/content_en.json`, clave → texto |
| Textos que arma el dominio (diario, instinto, factores) | `kDomainStrings` en `lib/domain/entities/domain_strings.dart` | la misma tabla `content_en.json` (claves `ui.*`) |

- **Fuente de verdad:** el español del código. Si una clave no tiene traducción, se muestra en español; nunca queda un texto vacío.
- **Idioma:**
  - El jugador lo elige en Ajustes → Idioma (`language_v1`, una clave del teléfono).
  - Si no eligió, se usa el del teléfono: español si lo habla, inglés si no.
- **Claves del contenido:** `contentKeys()` (`lib/data/localized_content.dart`) las enumera todas. Para volcarlas a `build/content_keys_es.json`:

  ```bash
  flutter test tool/content_keys_test.dart
  ```

- **Control:** `test/content_l10n_test.dart` exige que todo tenga inglés, que no sobren claves y que se conserven los `{marcadores}`.
- **Lugares:** `place.<nombre>` se traduce al mostrarlos (`ContentL10n.place`). El mapa los busca por su nombre en español.
- **Partidas guardadas:** una misión guarda sus textos en el idioma en que se creó. Si el jugador cambia de idioma, las misiones en curso terminan en el idioma viejo.

## Contenido nuevo

1. Escribí el español en `lib/data/`.
2. Corré `test/content_l10n_test.dart`: lista las claves sin traducir.
3. Agregá esas claves a `content_en.json`.

## Voz y registro

- **Español:**
  - UI neutra (tienes, mira, elige).
  - El narrador y los personajes conservan su voz rioplatense (vos, tenés), como pidió el usuario: "voseo en voces".
- **Inglés:**
  - Segunda persona y presente, seco y con algo de ironía, como el original.
  - Nada de arcaísmos de cartón ("thee", "thou") ni de modernismos ("OK", "check the map").
  - Varus es parco y paternal; Lucius, socarrón; Claudius, frío y cortés; Aufidio, un soldado cansado.
  - Las frases cortas siguen cortas: respetá el presupuesto de largo del original (±15%).

## Glosario

| Español | English |
|---|---|
| el Gremio (de mensajeros) | the Guild |
| Varus | Varus |
| mensajero / correo | messenger / courier |
| Denarios | denarii (sg. denarius) |
| Aureos | aurei (sg. aureus) |
| Sellos del Gremio | Guild Seals |
| ruta | route |
| misión / encargo | delivery / job |
| encargo semanal | weekly commission |
| contrato diario | daily contract |
| paga del Gremio | Guild pay |
| racha | streak |
| fatiga | fatigue |
| Roma | Rome |
| Foro | the Forum |
| Senado / Curia | the Senate / the Curia |
| las Legiones | the Legions |
| Bajos Fondos | the Underworld |
| Patricios | the Patricians |
| Rubicón | the Rubicon |
| Vía Flaminia / Apia | Via Flaminia / Via Appia |
| centurión | centurion |
| miliario | milestone |
| posta | way station |
| Enemigo / Sospechoso / Desconocido / Conocido / Respetado / Leyenda | Enemy / Suspect / Unknown / Known / Respected / Legend |
| Correo / Mensajero / Courier / Maestro / Leyenda (rangos) | Runner / Messenger / Courier / Master / Legend |
| la Viuda | the Widow |
| la Loba Dorada | the Golden She-Wolf |
| la Taberna del Buey / el Buey | the Ox Tavern / the Ox |
| libro (de cuentas de Lucius) | ledger |
| vigil (vigiles) | watchman |
| calendas / idus | the Kalends / the Ides |
| castra | castra (sin traducir) |

**Nombres de lugar:** las ciudades van en su forma inglesa habitual si existe (Rome, Naples para Neapolis solo si el original no usa la forma latina). Si el original usa la forma latina (Ariminum, Ostia, Capua, Ravenna, Brundisium), queda igual.

**Nombres de personas:** quedan como están (Lucius, Claudius, Aufidio, Petilio…). Excepción: los nombres que en inglés tienen forma latina conocida (Pompeyo → Pompey, César → Caesar).
