// lib/data/npc_content.dart
//
// Personajes con retrato. El `id` es el nombre del archivo en
// `assets/art/npcs/<id>.png` y lo que usan `RealEventConfig.npcId` y los
// encargos semanales (por nombre, vía `NpcDef.idFromName`).
// `look` alimenta el prompt del retrato en docs/ART_PROMPTS.md.

import '../domain/entities/content.dart';
import '../domain/entities/world.dart';

const List<NpcDef> allNpcs = [
  NpcDef(
    id: 'varus',
    name: 'Varus',
    role: 'jefe de la casa de postas',
    faction: Faction.guild,
    look: 'man in his fifties, broad shoulders, close-cropped grey hair, '
        'old scar across the chin, plain dark wool tunic, ink-stained fingers',
  ),
  NpcDef(
    id: 'decimo',
    name: 'Décimo',
    role: 'escriba del Gremio',
    faction: Faction.guild,
    look: 'thin young man, narrow face, tired eyes, wax tablet under the arm, '
        'stylus behind the ear, faded blue tunic',
  ),
  NpcDef(
    id: 'marco',
    name: 'Marco',
    role: 'mensajero de la casa',
    faction: Faction.guild,
    look: 'wiry man in his twenties, cocky half smile, sunburnt, curly black '
        'hair, travel cloak thrown over one shoulder, worn sandals',
  ),
  NpcDef(
    id: 'sexto',
    name: 'Sexto',
    role: 'centurión de la Puerta Capena',
    faction: Faction.legions,
    look: 'stern centurion in his forties, transverse red crest on the helmet, '
        'chain mail, vine staff, heavy jaw, broken nose',
  ),
  NpcDef(
    id: 'fulvia',
    name: 'Fulvia',
    role: 'matrona de una villa del Palatino',
    faction: Faction.patricians,
    look: 'patrician woman in her forties, elaborate braided hair with pins, '
        'deep violet palla, gold earrings, measuring gaze',
  ),
  NpcDef(
    id: 'rufo',
    name: 'Rufo',
    role: 'barquero del Muelle Viejo',
    faction: Faction.underworld,
    look: 'heavy-set boatman, red beard, missing tooth, rope coiled on the '
        'shoulder, wet linen tunic, lantern light on the face',
  ),
  NpcDef(
    id: 'atia',
    name: 'Atia',
    role: 'sacerdotisa del templo de Mercurio',
    faction: Faction.patricians,
    look: 'young priestess, calm face, white veil over dark hair, '
        'small caduceus pendant, incense smoke drifting',
  ),
  NpcDef(
    id: 'cornelia',
    name: 'Cornelia',
    role: 'viuda de un mensajero',
    faction: Faction.underworld,
    look: 'woman in her thirties, mourning grey stola, sharp eyes, '
        "a messenger's bronze badge worn as a necklace",
  ),
  NpcDef(
    id: 'claudius',
    name: 'Claudius',
    role: 'senador',
    faction: Faction.patricians,
    look: 'senator in his sixties, toga with broad purple stripe, thin smile, '
        'heavy signet ring, receding white hair',
  ),
  NpcDef(
    id: 'lucius',
    name: 'Lucius',
    role: 'tabernero del Buey',
    look: 'innkeeper in his fifties, bald, thick forearms, leather apron, '
        'suspicious squint, clay cup in hand',
  ),
  NpcDef(
    id: 'petro',
    name: 'Petro',
    role: 'senador rival de Claudius',
    faction: Faction.patricians,
    look: 'plump senator, rosy cheeks, rings on every finger, '
        'laurel-patterned toga border, politician smile',
  ),
  NpcDef(
    id: 'viuda',
    name: 'la Viuda',
    role: 'dueña de La Loba Dorada',
    faction: Faction.underworld,
    look: 'older woman, silver hair in a severe bun, black stola, '
        'gold she-wolf brooch, candlelit tavern behind',
  ),
];

NpcDef? npcById(String id) => allNpcs.where((n) => n.id == id).firstOrNull;
