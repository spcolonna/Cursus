// ─────────────────────────────────────────────────────────────────────────────
// CONTENIDO — Pistas de los finales
//
// La galería de finales muestra la pista de cada final que el jugador todavía
// no encontró. Apunta a la decisión que lo abre sin contarla entera.
// ─────────────────────────────────────────────────────────────────────────────

/// endingId → pista (para el jugador que todavía no lo vio).
const Map<String, String> endingHints = {
  'end_varus':
      'Cuando el sello se parta en el puente, corre a contárselo a quien te enseñó el oficio.',
  'end_claudius':
      'Cuando el sello se parta en el puente, olvida lo que leíste: sirves a Claudius.',
  'end_underworld':
      'Lo que se lee en el puente del Tíber vale una fortuna en la Subura.',
  'end_lucius_family':
      'En Aricia, deja el libro de Lucius en manos de su familia.',
  'end_lucius_legion':
      'En Aricia, cambia el libro de Lucius por el perdón de Gaius.',
  'end_lucius_book':
      'En Aricia, recuerda que el libro vale más que la taberna.',
  'end_legion_caesar':
      'En la trastienda de Petilio, vuelve al norte con el legado.',
  'end_legion_senate':
      'En la trastienda de Petilio, el aviso tiene que llegar a la Curia.',
  'end_legion_guild':
      'En la trastienda de Petilio, recuerda que un correo entrega y no decide.',
};
