// ═════════════════════════════════════════════════════════════════════════════
// ContentL10n: el idioma del contenido. El español vive en el código (es la
// fuente); los otros idiomas son una tabla clave → texto que se superpone.
// Una clave que falta cae al texto guardado, así nunca queda un texto vacío.
// El español también tiene su tabla (las mismas fuentes por clave): sin ella,
// lo que se guardó en inglés quedaría en inglés al volver al español.
//
// Claves: `<id>.<campo>` del contenido (evt_x.title, opt_y.success…), y
// `ui.<algo>` para los textos que arma el dominio. La lista completa sale de
// `contentKeys()` en lib/data/localized_content.dart.
// ═════════════════════════════════════════════════════════════════════════════

class ContentL10n {
  ContentL10n._();

  static String _lang = 'es';
  static Map<String, String> _table = const {};
  static int _revision = 0;

  /// Idioma actual ('es' o 'en').
  static String get lang => _lang;

  /// Cambia cada vez que cambia el idioma: sirve para invalidar cachés.
  static int get revision => _revision;

  static void use(String lang, Map<String, String> table) {
    _lang = lang;
    _table = table;
    _revision++;
  }

  /// El texto de [key] en el idioma actual, o [es] (el texto guardado) si no
  /// hay traducción.
  static String t(String key, String es) => _table[key] ?? es;

  /// Lo mismo para un campo opcional.
  static String? tn(String key, String? es) =>
      es == null ? null : (_table[key] ?? es);

  /// Un lugar ("Roma — Foro"). Se traduce solo al mostrarlo: el mapa lo
  /// busca por su nombre en español.
  static String place(String es) => _table['place.$es'] ?? es;
}
