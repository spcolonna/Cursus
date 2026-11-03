// ═════════════════════════════════════════════════════════════════════════════
// Textos que arma el dominio (diario, resultados por instinto, factores de
// la tirada, errores que ve el jugador…). El español vive acá; la traducción
// sale de la tabla de ContentL10n con la misma clave (`ui.*`).
//
// Uso: ds('ui.instinct.option', {'option': texto}) reemplaza {option}.
// ═════════════════════════════════════════════════════════════════════════════

import 'content_l10n.dart';

const Map<String, String> kDomainStrings = {
  'ui.rank.1': 'Correo',
  'ui.rank.2': 'Mensajero',
  'ui.rank.3': 'Courier',
  'ui.rank.4': 'Maestro',
  'ui.rank.5': 'Leyenda',
  'ui.skill.speed': 'Velocidad',
  'ui.skill.stealth': 'Sigilo',
  'ui.skill.combat': 'Combate',
  'ui.skill.survival': 'Supervivencia',
  'ui.skill.contacts': 'Contactos',
  'ui.gender.male': 'Hombre',
  'ui.gender.female': 'Mujer',
  'ui.status.idle': 'Disponible',
  'ui.status.onMission': 'En misión',
  'ui.status.resting': 'Descansando',
  'ui.status.injured': 'Herido',
  'ui.messenger.yours': 'Tu mensajero',
  'ui.messenger.second_name': 'Mensajero II',
  'ui.messenger.default_name': 'Mensajero',
  'ui.package.intact': 'Intacto',
  'ui.package.wetMinor': 'Humedad leve',
  'ui.package.damaged': 'Dañado',
  'ui.package.compromised': 'Comprometido',
  'ui.package.lost': 'Perdido',
  'ui.mission.arrived': 'LLEGÓ',
  'ui.faction.guild.label': 'El Gremio',
  'ui.faction.guild.lore': 'La red de mensajeros de Varus. Tu casa.',
  'ui.faction.legions.label': 'Las Legiones',
  'ui.faction.legions.lore': 'Centuriones y patrullas. Respetan el protocolo.',
  'ui.faction.underworld.label': 'Bajos Fondos',
  'ui.faction.underworld.lore': 'Bandidos, contrabandistas y oídos del foro.',
  'ui.faction.patricians.label': 'Patricios',
  'ui.faction.patricians.lore':
      'Senadores y villas. Pagan bien, olvidan rápido.',
  'ui.tier.enemy': 'Enemigo',
  'ui.tier.suspect': 'Sospechoso',
  'ui.tier.unknown': 'Desconocido',
  'ui.tier.known': 'Conocido',
  'ui.tier.respected': 'Respetado',
  'ui.tier.legend': 'Leyenda',
  'ui.journal.faction_tier': '{faction} ahora te tiene por {tier}.',
  'ui.journal.arc_repaired':
      'Las cosas se acomodaron solas mientras no mirabas. El camino siguió por donde siguió.',
  'ui.instinct.narrative':
      'No estabas ahí para decidir. Tu mensajero actuó por instinto: {option}. Salió del paso, pero perdió tiempo.',
  'ui.instinct.option': '{option} (por instinto)',
  'ui.instinct.journal': 'No estabas: tu mensajero decidió por ti. {note}',
  'ui.outcome.success.0':
      'Tu instinto no te falló. Sales del paso sin contratiempos.',
  'ui.outcome.success.1':
      'Una decisión precisa en el momento exacto. El camino queda libre.',
  'ui.outcome.success.2':
      'Lo lograste. Cada obstáculo superado te hace más fuerte.',
  'ui.outcome.partial.0':
      'No salió perfecto, pero sobreviviste. El mensaje sigue en camino.',
  'ui.outcome.partial.1':
      'Fue más difícil de lo esperado. Llegaste al otro lado, pero no sin costo.',
  'ui.outcome.partial.2':
      'Una victoria amarga. El paquete está bien, pero perdiste tiempo.',
  'ui.outcome.fail.0':
      'Las cosas no salieron como planeabas. Perdiste tiempo valioso.',
  'ui.outcome.fail.1':
      'Una decisión equivocada. Ahora vas más lento y el tiempo corre.',
  'ui.outcome.fail.2': 'El camino te venció esta vez. Pero sigues en pie.',
  'ui.factor.craft': 'Oficio de mensajero',
  'ui.factor.skill': '{skill} Nv.{level}',
  'ui.factor.perks': 'Perks de {skill}',
  'ui.factor.perks_generic': 'Perks de tu camino',
  'ui.factor.risk': 'Riesgo {level}',
  'ui.factor.fatigue': 'Fatiga {value}',
  'ui.factor.road': 'El camino',
  'ui.factor.mishap': 'Imprevisto',
  'ui.factor.lucky': 'Golpe de suerte',
  'ui.risk.minimal': 'mínimo',
  'ui.risk.low': 'bajo',
  'ui.risk.medium': 'medio',
  'ui.risk.high': 'alto',
  'ui.risk.extreme': 'extremo',
  'ui.error.injured':
      'Tu mensajero está herido. Cúralo en la tienda antes de salir.',
  'ui.error.chapter_rank': 'Este capítulo pide rango {rank}.',
  'ui.error.primary_busy': 'Tu mensajero principal está ocupado.',
  'ui.error.messenger_busy': 'Ese mensajero ya está de viaje.',
  'ui.error.event_gone': 'Ese evento ya se resolvió.',
  'ui.error.replay_unavailable':
      'Para volver a recorrer un arco, termínalo y espera a que no haya un capítulo en viaje.',
  'ui.error.replay_in_progress':
      'Hay un capítulo de este recorrido en viaje: espera a que llegue.',
  'ui.error.manual_maxed':
      '{name} ya tiene {skill} en nivel {level}. Un manual no le enseña nada nuevo.',
  'ui.error.no_denarios':
      'Denarios insuficientes (necesitas {cost}, tienes {have})',
  'ui.error.no_aureos':
      'Aureos insuficientes (necesitas {cost}, tienes {have})',
  'ui.error.no_seals':
      'Sellos insuficientes (necesitas {cost}, tienes {have})',
  'ui.error.no_skill_picks': 'No te quedan niveles para elegir.',
  'ui.error.skill_pick_maxed':
      'Esa habilidad ya está en nivel {level}. Elige otra.',
  'ui.error.slot_needs_trials':
      'Necesitas completar las pruebas de Varus primero',
  'ui.error.option_locked': 'Tu mensajero no puede tomar esa opción todavía.',
  'ui.error.messenger_gone': 'Ese mensajero ya no está disponible',
  'ui.error.ascend_needs_xp':
      'Primero alcanza el nivel {level} con experiencia',
  'ui.error.ascend_maxed': '{skill} ya está en el nivel máximo',
  'ui.error.pay_claimed': 'Ya cobraste la paga de hoy',
  'ui.error.contract_missing': 'Contrato inexistente',
  'ui.error.contract_incomplete': 'Contrato incompleto',
  'ui.error.contract_claimed': 'Contrato ya cobrado',
  'ui.error.contract_no_reroll': 'Hoy no puedes cambiar este contrato',
  'ui.error.weekly_missing': 'Encargo inexistente',
  'ui.error.weekly_claimed': 'Encargo ya cobrado',
  'ui.error.weekly_incomplete': 'Encargo incompleto',
  'ui.forecast.band.assured': 'Lo tienes dominado',
  'ui.forecast.band.favourable': 'Buenas chances',
  'ui.forecast.band.uncertain': 'Incierto',
  'ui.forecast.band.risky': 'Arriesgado',
  'ui.forecast.band.reckless': 'Temerario',
  'ui.forecast.exhausted': 'Vas agotado: cualquier cosa te puede salir mal.',
  'ui.forecast.tired': 'El cansancio te está pesando en las manos.',
  'ui.forecast.noskill.assured': 'Es la opción prudente. Lenta, pero segura.',
  'ui.forecast.noskill.favourable':
      'No necesitas nada especial para intentarlo.',
  'ui.forecast.noskill.uncertain':
      'Sales del paso, pero sin oficio no sale redondo.',
  'ui.forecast.noskill.risky': 'Puro pulso y suerte. Puede salir feo.',
  'ui.forecast.noskill.reckless':
      'Esto es tirarse al vacío y esperar lo mejor.',
  'ui.forecast.perk': 'Tu camino de {skill} te da una ventaja aquí.',
  'ui.forecast.craft': 'oficio',
  'ui.forecast.your_craft': 'tu oficio',
  'ui.forecast.skill.assured': '{skill} Nv.{level} te sobra para esto.',
  'ui.forecast.skill.favourable': '{skill} Nv.{level} debería alcanzar.',
  'ui.forecast.skill.uncertain_danger':
      'Tu {skill} ayuda, pero el peligro es alto.',
  'ui.forecast.skill.uncertain': 'Puedes lograrlo, aunque no está garantizado.',
  'ui.forecast.skill.risky': 'Con {skill} Nv.{level}, esto es una apuesta.',
  'ui.forecast.skill.reckless':
      'Te falta {skill} para algo así. Sería un milagro.',
  'ui.effect.roll_bonus': 'Suma a tus tiradas',
  'ui.effect.options': 'Opciones que puedes elegir',
  'ui.effect.options_value': 'hasta Nv.{level}',
  'ui.effect.duration': 'Duración de las misiones',
  'ui.effect.unchanged': 'sin cambios',
  'ui.effect.grade_s': 'Bonus por nota S',
  'ui.effect.denarios_value': '+{n} denarios',
  'ui.effect.stealth_bonus': 'Bonus de sigilo',
  'ui.effect.combat_bonus': 'Bonus de combate',
  'ui.effect.roll_value': '+{n} a la tirada',
  'ui.effect.risk': 'Riesgo efectivo',
  'ui.effect.stealth_req': 'Requisitos de sigilo',
  'ui.effect.one_level_less': '1 nivel menos',
  'ui.effect.on_fail': 'Al fallar',
  'ui.effect.package_safe': 'el paquete no se daña',
  'ui.effect.fail_health': 'Salud al fallar',
  'ui.effect.instead_of': '{value} en vez de {base}',
  'ui.effect.fatigue_per_event': 'Fatiga por evento',
  'ui.effect.fatigue_penalty': 'Castigo por fatiga alta',
  'ui.effect.none': 'ninguno',
  'ui.effect.partial_health': 'Salud en parciales',
  'ui.effect.pay': 'Paga de las entregas',
  'ui.effect.normal': 'normal',
  'ui.skill_node.speed.1.name': 'Paso firme',
  'ui.skill_node.speed.1.perk': 'Desbloquea opciones de Velocidad Nv.1',
  'ui.skill_node.speed.2.name': 'Trote sostenido',
  'ui.skill_node.speed.2.perk':
      '+30 a tus tiradas · opciones de Velocidad Nv.2',
  'ui.skill_node.speed.3.name': 'Zancada larga',
  'ui.skill_node.speed.3.perk':
      '+45 a tus tiradas · opciones de Velocidad Nv.3',
  'ui.skill_node.speed.4.name': 'Pies de viento',
  'ui.skill_node.speed.4.perk':
      '+60 a tus tiradas · opciones de Velocidad Nv.4',
  'ui.skill_node.speed.5.name': 'Corredor de postas',
  'ui.skill_node.speed.5.perk':
      '+75 a tus tiradas · todas las opciones de Velocidad',
  'ui.skill_node.speed.6.name': 'Atajos del Imperio',
  'ui.skill_node.speed.6.perk': 'Misiones -3% de duración',
  'ui.skill_node.speed.7.name': 'Ritmo de campaña',
  'ui.skill_node.speed.7.perk': 'Misiones -5% de duración',
  'ui.skill_node.speed.8.name': 'Viento del norte',
  'ui.skill_node.speed.8.perk': 'Misiones -7% de duración',
  'ui.skill_node.speed.9.name': 'Sombra en el camino',
  'ui.skill_node.speed.9.perk': 'Misiones -9% de duración',
  'ui.skill_node.speed.10.name': 'Correo del César',
  'ui.skill_node.speed.10.perk':
      'Misiones -12% y las notas S pagan +25 denarios',
  'ui.skill_node.stealth.1.name': 'Pisada suave',
  'ui.skill_node.stealth.1.perk': 'Desbloquea opciones de Sigilo Nv.1',
  'ui.skill_node.stealth.2.name': 'Entre las sombras',
  'ui.skill_node.stealth.2.perk':
      '+30 a tus tiradas · opciones de Sigilo Nv.2',
  'ui.skill_node.stealth.3.name': 'Rostro anónimo',
  'ui.skill_node.stealth.3.perk':
      '+45 a tus tiradas · opciones de Sigilo Nv.3',
  'ui.skill_node.stealth.4.name': 'Manto gris',
  'ui.skill_node.stealth.4.perk':
      '+60 a tus tiradas · opciones de Sigilo Nv.4',
  'ui.skill_node.stealth.5.name': 'Fantasma del foro',
  'ui.skill_node.stealth.5.perk':
      '+75 a tus tiradas · todas las opciones de Sigilo',
  'ui.skill_node.stealth.6.name': 'Callejones conocidos',
  'ui.skill_node.stealth.6.perk':
      'Las opciones de Sigilo exigen 1 nivel menos',
  'ui.skill_node.stealth.7.name': 'Paso de gato',
  'ui.skill_node.stealth.7.perk': '+5 a tus tiradas de Sigilo',
  'ui.skill_node.stealth.8.name': 'Niebla romana',
  'ui.skill_node.stealth.8.perk':
      'Las opciones de Sigilo tienen 1 punto menos de riesgo',
  'ui.skill_node.stealth.9.name': 'Nadie te vio',
  'ui.skill_node.stealth.9.perk': '+10 extra a tus tiradas de Sigilo',
  'ui.skill_node.stealth.10.name': 'Invisible',
  'ui.skill_node.stealth.10.perk':
      'Riesgo -2 y +10 extra en opciones de Sigilo',
  'ui.skill_node.combat.1.name': 'Guardia alzada',
  'ui.skill_node.combat.1.perk': 'Desbloquea opciones de Combate Nv.1',
  'ui.skill_node.combat.2.name': 'Puño del camino',
  'ui.skill_node.combat.2.perk':
      '+30 a tus tiradas · opciones de Combate Nv.2',
  'ui.skill_node.combat.3.name': 'Reflejos de legión',
  'ui.skill_node.combat.3.perk':
      '+45 a tus tiradas · opciones de Combate Nv.3',
  'ui.skill_node.combat.4.name': 'Acero prestado',
  'ui.skill_node.combat.4.perk':
      '+60 a tus tiradas · opciones de Combate Nv.4',
  'ui.skill_node.combat.5.name': 'Veterano de riñas',
  'ui.skill_node.combat.5.perk':
      '+75 a tus tiradas · todas las opciones de Combate',
  'ui.skill_node.combat.6.name': 'Postura firme',
  'ui.skill_node.combat.6.perk': '+5 a tus tiradas de Combate',
  'ui.skill_node.combat.7.name': 'Contragolpe',
  'ui.skill_node.combat.7.perk': '+10 a tus tiradas de Combate',
  'ui.skill_node.combat.8.name': 'Escudo del correo',
  'ui.skill_node.combat.8.perk': 'Los fallos en Combate no dañan el paquete',
  'ui.skill_node.combat.9.name': 'Furia controlada',
  'ui.skill_node.combat.9.perk': '+10 extra a tus tiradas de Combate',
  'ui.skill_node.combat.10.name': 'Gladiador',
  'ui.skill_node.combat.10.perk':
      'Los fallos en Combate te cuestan la mitad de salud',
  'ui.skill_node.survival.1.name': 'Ojo del terreno',
  'ui.skill_node.survival.1.perk': 'Desbloquea opciones de Supervivencia Nv.1',
  'ui.skill_node.survival.2.name': 'Piel curtida',
  'ui.skill_node.survival.2.perk':
      '+30 a tus tiradas · opciones de Supervivencia Nv.2',
  'ui.skill_node.survival.3.name': 'Aguas y raíces',
  'ui.skill_node.survival.3.perk':
      '+45 a tus tiradas · opciones de Supervivencia Nv.3',
  'ui.skill_node.survival.4.name': 'Refugio rápido',
  'ui.skill_node.survival.4.perk':
      '+60 a tus tiradas · opciones de Supervivencia Nv.4',
  'ui.skill_node.survival.5.name': 'Hijo del camino',
  'ui.skill_node.survival.5.perk':
      '+75 a tus tiradas · todas las opciones de Supervivencia',
  'ui.skill_node.survival.6.name': 'Segundo aliento',
  'ui.skill_node.survival.6.perk': 'Los eventos te fatigan menos (8 → 6)',
  'ui.skill_node.survival.7.name': 'Sangre dura',
  'ui.skill_node.survival.7.perk':
      'Los resultados parciales te cuestan menos salud',
  'ui.skill_node.survival.8.name': 'Temple de hierro',
  'ui.skill_node.survival.8.perk':
      'Los eventos te fatigan mucho menos (6 → 4)',
  'ui.skill_node.survival.9.name': 'Marcha forzada',
  'ui.skill_node.survival.9.perk': 'La fatiga alta te penaliza la mitad',
  'ui.skill_node.survival.10.name': 'Incansable',
  'ui.skill_node.survival.10.perk': 'La fatiga nunca penaliza tus tiradas',
  'ui.skill_node.contacts.1.name': 'Cara conocida',
  'ui.skill_node.contacts.1.perk': 'Desbloquea opciones de Contactos Nv.1',
  'ui.skill_node.contacts.2.name': 'Amigo del tabernero',
  'ui.skill_node.contacts.2.perk':
      '+30 a tus tiradas · opciones de Contactos Nv.2',
  'ui.skill_node.contacts.3.name': 'Deudas y favores',
  'ui.skill_node.contacts.3.perk':
      '+45 a tus tiradas · opciones de Contactos Nv.3',
  'ui.skill_node.contacts.4.name': 'Oído en el foro',
  'ui.skill_node.contacts.4.perk':
      '+60 a tus tiradas · opciones de Contactos Nv.4',
  'ui.skill_node.contacts.5.name': 'Red de porteros',
  'ui.skill_node.contacts.5.perk':
      '+75 a tus tiradas · todas las opciones de Contactos',
  'ui.skill_node.contacts.6.name': 'Comisión del gremio',
  'ui.skill_node.contacts.6.perk': 'Las entregas pagan +5% de denarios',
  'ui.skill_node.contacts.7.name': 'Cliente frecuente',
  'ui.skill_node.contacts.7.perk': 'Las entregas pagan +8% de denarios',
  'ui.skill_node.contacts.8.name': 'Palabra del Senado',
  'ui.skill_node.contacts.8.perk': 'Las entregas pagan +12% de denarios',
  'ui.skill_node.contacts.9.name': 'Mano derecha de Varus',
  'ui.skill_node.contacts.9.perk': 'Las entregas pagan +16% de denarios',
  'ui.skill_node.contacts.10.name': 'Red imperial',
  'ui.skill_node.contacts.10.perk': 'Las entregas pagan +20% de denarios',
  'ui.contract.c_deliver1': 'Entrega 1 paquete',
  'ui.contract.c_events2': 'Resuelve 2 eventos en el camino',
  'ui.contract.c_stealth': 'Usa una opción de Sigilo',
  'ui.contract.c_contacts': 'Usa una opción de Contactos',
  'ui.contract.c_survival': 'Usa una opción de Supervivencia',
  'ui.contract.c_deliver2': 'Entrega 2 paquetes',
  'ui.contract.c_events3': 'Resuelve 3 eventos en el camino',
  'ui.contract.c_success2': 'Supera 2 eventos con éxito',
  'ui.contract.c_seal_gradeA': 'Entrega con nota A o mejor',
  'ui.contract.c_seal_success3': 'Supera 3 eventos con éxito',
  'ui.contract.c_seal_deliver2': 'Entrega 2 paquetes en el día',
  'ui.notification.event.label': 'Algo pasa en el camino',
  'ui.notification.event.description':
      'Te avisamos cuando tu mensajero necesita una decisión.',
  'ui.notification.delivery.label': 'Entrega lista',
  'ui.notification.delivery.description':
      'Cuando la misión llega a destino y falta entregar.',
  'ui.notification.idle.label': 'Mensajero ocioso',
  'ui.notification.idle.description':
      'Si tu mensajero pasa horas sin salir a la ruta.',
  'ui.notification.contracts.label': 'Contratos del día',
  'ui.notification.contracts.description':
      'Un recordatorio antes de que venzan los contratos del día.',
};

/// El texto de [key] en el idioma actual, con los {marcadores} reemplazados.
String ds(String key, [Map<String, Object> args = const {}]) {
  final es = kDomainStrings[key];
  assert(es != null, 'Falta $key en kDomainStrings');
  var text = ContentL10n.t(key, es ?? key);
  args.forEach((k, v) => text = text.replaceAll('{$k}', '$v'));
  return text;
}
