// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get languageSystem => 'El del teléfono';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageEnglish => 'English';

  @override
  String get notifChannelName => 'El camino';

  @override
  String get notifChannelDescription =>
      'Avisos de eventos en la ruta y entregas listas.';

  @override
  String get notifEventTitle => 'Algo pasó en el camino';

  @override
  String notifEventBody(String messenger, String event) {
    return '$messenger necesita una decisión: $event.';
  }

  @override
  String get notifDeliveryTitle => 'Tu entrega está lista';

  @override
  String notifDeliveryBody(String messenger, String place) {
    return '$messenger llegó a $place. Entrega el mensaje.';
  }

  @override
  String get notifIdleTitle => 'El camino espera';

  @override
  String notifIdleBody(String messenger) {
    return '$messenger está sin misión. Hay rutas en el tablón.';
  }

  @override
  String get notifContractsTitle => 'Contratos del Gremio';

  @override
  String get notifContractsBody =>
      'Quedan contratos sin cobrar. Vencen a medianoche.';

  @override
  String get notifTestTitle => 'Prueba del correo';

  @override
  String get notifTestBody => 'Si estás leyendo esto, los avisos llegan bien.';

  @override
  String get riskEasy => 'FÁCIL';

  @override
  String get riskLow => 'BAJO';

  @override
  String get riskMedium => 'MEDIO';

  @override
  String get riskHigh => 'ALTO';

  @override
  String get riskExtreme => 'EXTREMO';

  @override
  String skillLevelShort(int level) {
    return 'Nv.$level';
  }

  @override
  String currencyDenarii(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'denarios',
      one: 'denario',
    );
    return '$_temp0';
  }

  @override
  String currencyAurei(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'aureos',
      one: 'aureo',
    );
    return '$_temp0';
  }

  @override
  String currencySeals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sellos',
      one: 'Sello del Gremio',
    );
    return '$_temp0';
  }

  @override
  String gradeSemantics(String grade) {
    return 'Nota $grade';
  }

  @override
  String get updateTitle => 'Hay una versión nueva';

  @override
  String get updateBody =>
      'Para seguir con tus entregas tienes que actualizar Cursus. Tu partida queda guardada.';

  @override
  String get updateButton => 'Actualizar';

  @override
  String get achKindRoad => 'El camino';

  @override
  String get achKindGrade => 'Entregas perfectas';

  @override
  String get achKindGuild => 'El Gremio';

  @override
  String get achKindSkill => 'Oficio';

  @override
  String get achKindStory => 'Historia';

  @override
  String get achKindEmpire => 'Fortuna';

  @override
  String titleEquippedSemantics(String title) {
    return '$title, equipado';
  }

  @override
  String skillNodeSemantics(String skill, int level, int max) {
    return '$skill, nivel $level de $max';
  }

  @override
  String get celebAchievementHeader => 'LOGRO CONSEGUIDO';

  @override
  String celebAchievementSemantics(String name) {
    return 'Logro conseguido: $name. Toca para ver tus logros.';
  }

  @override
  String rewardDenarii(int count) {
    return '+$count Denarios';
  }

  @override
  String rewardSeals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count Sellos',
      one: '+1 Sello',
    );
    return '$_temp0';
  }

  @override
  String quotedTitle(String title) {
    return '«$title»';
  }

  @override
  String get celebTierHeader => 'NUEVO ESCALÓN';

  @override
  String celebTierSemantics(String faction, String tier) {
    return '$faction ahora te tiene por $tier. Toca para ver tu reputación.';
  }

  @override
  String get celebRankHeader => '¡NUEVO RANGO!';

  @override
  String get celebContinue => 'SEGUIR';

  @override
  String get rankBlurb2 =>
      'En el correo ya saben tu nombre.\nSe abren rutas que antes no te daban.';

  @override
  String get rankBlurb3 =>
      'Te confían lo que no se puede perder.\nYa nadie te manda a llevar recados.';

  @override
  String get rankBlurb4 =>
      'Los otros mensajeros te piden consejo.\nRoma empieza a notarte.';

  @override
  String get rankBlurb5 =>
      'Tu nombre se dice en las postas de todo el Imperio.';

  @override
  String get firstStepsRoute => 'Completa tu primera ruta real';

  @override
  String get firstStepsBuy => 'Compra un objeto en la tienda';

  @override
  String get firstStepsSkill => 'Sube una habilidad';

  @override
  String get firstStepsGuild => 'Mira el tablón del Gremio';

  @override
  String get firstStepsNotifs => 'Activa las notificaciones';

  @override
  String get firstStepsTitle => 'PRIMEROS PASOS';

  @override
  String get firstStepsClaim => 'RECLAMAR · 3 Aureos + 1 Sello';

  @override
  String get firstStepsHint =>
      'Completa las 5 tareas y ganas 3 Aureos + 1 Sello.';

  @override
  String get gotIt => 'ENTENDIDO';

  @override
  String get cloudConflictTitle => 'Tienes dos partidas';

  @override
  String get cloudUseRemote => 'USAR LA DE LA NUBE';

  @override
  String get cloudUseLocal => 'Usar la de este teléfono';

  @override
  String get cloudConflictBody => 'La que no elijas se pierde.';

  @override
  String get cloudLabel => 'Nube';

  @override
  String get cloudThisPhone => 'Este teléfono';

  @override
  String cloudDeliveries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entregas',
      one: '1 entrega',
    );
    return '$_temp0';
  }

  @override
  String get agoNow => 'hace un momento';

  @override
  String agoMinutes(int count) {
    return 'hace $count min';
  }

  @override
  String agoHours(int count) {
    return 'hace $count h';
  }

  @override
  String get agoYesterday => 'ayer';

  @override
  String agoDays(int count) {
    return 'hace $count días';
  }

  @override
  String get continueWithApple => 'Continuar con Apple';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get cloudLinked => 'Cuenta vinculada. Tu partida queda a salvo.';

  @override
  String get cloudLinkFailed => 'No se pudo vincular. Inténtalo de nuevo.';

  @override
  String get cloudDeleteFailed =>
      'No se pudo borrar la cuenta. Revisa la conexión e inténtalo de nuevo.';

  @override
  String cloudLinkedWith(String providers) {
    return 'Vinculada con $providers. Puedes recuperar tu partida en otro teléfono.';
  }

  @override
  String get listAnd => ' y ';

  @override
  String get cloudLinkPrompt =>
      'Vincula una cuenta para no perder la partida si cambias de teléfono.';

  @override
  String get cloudDeleteAccount => 'Borrar cuenta y datos';

  @override
  String get cloudStatusLocal => 'Tu partida se guarda en este teléfono.';

  @override
  String get cloudStatusSyncing => 'Guardando en la nube…';

  @override
  String get cloudStatusSynced => 'Partida guardada en la nube.';

  @override
  String cloudStatusSyncedAgo(String ago) {
    return 'Partida guardada en la nube $ago.';
  }

  @override
  String get cloudStatusOffline =>
      'Sin conexión: se guarda en el teléfono y se sube cuando vuelva.';

  @override
  String get cloudDeleteTitle => '¿Borrar todo?';

  @override
  String get cloudDeleteConfirm => 'BORRAR PARA SIEMPRE';

  @override
  String get cancel => 'Cancelar';

  @override
  String get cloudDeleteBody =>
      'Se borran tu cuenta, tus mensajeros, tu progreso y las monedas, en este teléfono y en la nube. No se puede deshacer.';

  @override
  String get back => 'Volver';

  @override
  String get close => 'Cerrar';

  @override
  String get errorGeneric =>
      'Algo se trabó en el camino. Inténtalo de nuevo en un momento.';

  @override
  String get errorLoadTitle => 'No pudimos cargar esto';

  @override
  String get retry => 'REINTENTAR';

  @override
  String get unlocked => 'Desbloqueado';

  @override
  String requiresTier(String tier) {
    return 'Pide $tier';
  }

  @override
  String get open => 'Abierto';

  @override
  String get brandTagline => 'Cartas de Roma';

  @override
  String routeMapSemantics(String origin, String destination) {
    return 'Mapa de la ruta de $origin a $destination';
  }

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsAlertsHeader => 'AVISOS DEL CAMINO';

  @override
  String get settingsSoundHeader => 'SONIDO Y MOVIMIENTO';

  @override
  String get settingsUsageHeader => 'DATOS DE USO';

  @override
  String get settingsAccountHeader => 'CUENTA';

  @override
  String get settingsSkyHeader => 'CIELO (SOLO DEBUG)';

  @override
  String get settingsDiagnosticsHeader => 'DIAGNÓSTICO';

  @override
  String get settingsAlertsToggle => 'Recibir avisos';

  @override
  String get settingsAlertsToggleHint =>
      'Nunca entre las 22 y las 8, salvo un evento de una misión que ya está en marcha. Máximo 4 por día.';

  @override
  String get permGranted => 'Concedido';

  @override
  String get permDenied => 'Denegado';

  @override
  String get permNotRequested => 'Todavía no se pidió';

  @override
  String get permSystemLabel => 'Permiso del sistema: ';

  @override
  String diagScheduled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count avisos programados',
      one: '1 aviso programado',
    );
    return '$_temp0';
  }

  @override
  String get diagIosLimit =>
      'iOS descarta lo que pase de 64 pendientes: por eso se programan solo los dos próximos eventos de cada misión.';

  @override
  String get diagQueueEmpty =>
      'Nada en la cola. Acepta una misión para que se programen.';

  @override
  String get diagTest => 'PROBAR EN 10s';

  @override
  String get diagTestNote => 'Cierra la app: el aviso llega en 10 segundos.';

  @override
  String get diagReload => 'RECARGAR';

  @override
  String get diagCancelAll => 'Cancelar todos los avisos';

  @override
  String get skyDawn => 'Alba';

  @override
  String get skyDay => 'Día';

  @override
  String get skyDusk => 'Atardecer';

  @override
  String get skyNight => 'Noche';

  @override
  String skyRealClock(String time, String phase) {
    return 'Reloj real: $time · $phase';
  }

  @override
  String skyFixedHour(String time, String phase) {
    return 'Hora fija: $time · $phase';
  }

  @override
  String get skyClock => 'Reloj';

  @override
  String get settingsMusic => 'Música';

  @override
  String get settingsMusicHint =>
      'Lira y aulos: cambia con la hora y en el camino';

  @override
  String settingsMusicVolume(int percent) {
    return 'Volumen de la música $percent%';
  }

  @override
  String get settingsSfx => 'Efectos de sonido';

  @override
  String get settingsSfxHint => 'Botones, resultados, entregas y cobros';

  @override
  String get settingsHaptics => 'Vibración';

  @override
  String get settingsHapticsHint => 'Un golpe suave al tocar y al cobrar';

  @override
  String get settingsReduceMotion => 'Animaciones reducidas';

  @override
  String get settingsReduceMotionHint =>
      'Menos movimiento: transiciones cortas y sin sacudidas';

  @override
  String get usageCopied => 'Datos copiados. Pégalos en un mensaje.';

  @override
  String get usageShare => 'Compartir estadísticas';

  @override
  String get usageShareHint =>
      'Qué rutas juegas y cuándo vuelves. Anónimo: sin tu nombre ni nada que te identifique.';

  @override
  String usageSummary(int day, int days, int sessions) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días jugados',
      one: '1 día jugado',
    );
    String _temp1 = intl.Intl.pluralLogic(
      sessions,
      locale: localeName,
      other: '$sessions sesiones',
      one: '1 sesión',
    );
    return 'Día $day desde que empezaste · $_temp0 · $_temp1';
  }

  @override
  String get usageCopy => 'Copiar datos para el equipo';

  @override
  String get usageAdsPrivacy => 'Privacidad de los anuncios';

  @override
  String get achTitle => 'Logros y títulos';

  @override
  String get achYourTitle => 'Tu título';

  @override
  String get achNoTitles =>
      'Todavía no ganaste ninguno. Los títulos salen de los logros y de los finales de la historia.';

  @override
  String get achPickTitle => 'Toca uno para llevarlo bajo tu nombre.';

  @override
  String get achSecret => 'Logro secreto';

  @override
  String get achDone => 'Conseguido';

  @override
  String achProgress(int progress, int target) {
    return 'Progreso $progress de $target';
  }

  @override
  String get achSecretHint => 'Sigue la historia para descubrirlo.';

  @override
  String sealsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Sellos',
      one: '1 Sello',
    );
    return '$_temp0';
  }

  @override
  String get charErrorEmpty => 'Ponle un nombre a tu mensajero.';

  @override
  String get charErrorShort => 'El nombre necesita al menos 2 letras.';

  @override
  String get charKicker => 'TU MENSAJERO';

  @override
  String get charTitle => 'Elige quién lleva el mensaje';

  @override
  String get charBody =>
      'Será tu mensajero principal. Más adelante podrás contratar otros.';

  @override
  String get charTypeLabel => 'Tipo de mensajero';

  @override
  String get charNameLabel => 'Nombre del mensajero';

  @override
  String get charNameHintMale => 'Ej: Marcus, Lucius...';

  @override
  String get charNameHintFemale => 'Ej: Julia, Livia...';

  @override
  String get charStarting => 'Comenzando...';

  @override
  String get charStart => 'COMENZAR LA AVENTURA';

  @override
  String get charMale => 'HOMBRE';

  @override
  String get charFemale => 'MUJER';

  @override
  String charPreviewLine(String gender) {
    return '$gender · Correo · Rango 1';
  }

  @override
  String get statHealth => 'Salud';

  @override
  String get statFatigue => 'Fatiga';

  @override
  String get homeSpotlightTitle => 'Tu puesto de correo';

  @override
  String get homeSpotlightBody =>
      'Aquí ves a tus mensajeros, el progreso de cada misión y el tablón del Gremio. Las rutas cortas caben en una tarde; las largas siguen mientras duermes.';

  @override
  String get homeRosterEvent => 'Evento';

  @override
  String get homeRosterOnRoad => 'En camino';

  @override
  String get homeRosterInjured => 'Herido';

  @override
  String get homeRosterFree => 'Libre';

  @override
  String get homeAwayHeader => 'PASÓ MIENTRAS NO ESTABAS';

  @override
  String homeAwayLine(String messenger, String event, String choice) {
    return '$messenger no podía esperar en «$event»: actuó por instinto y $choice.';
  }

  @override
  String get homeAwayHint => 'Responder a tiempo siempre sale mejor.';

  @override
  String get splashSubtitle => 'Imperio Romano, 50 a.C.';

  @override
  String get storyChip => 'HISTORIA';

  @override
  String get storyStart => 'COMENZAR CAPÍTULO';

  @override
  String storyLockedSemantics(int rank, String title) {
    return 'Se abre en rango $rank, $title.';
  }

  @override
  String storyLocked(int rank, String title) {
    return 'Se abre en rango $rank · $title';
  }

  @override
  String hireSemantics(int cost) {
    return 'Contratar nuevo mensajero por $cost aureos';
  }

  @override
  String hireNeedAurei(int cost, int have) {
    return 'Necesitas $cost aureos (tienes $have).';
  }

  @override
  String get hireTitle => 'Contratar nuevo mensajero';

  @override
  String get hireSkipsTutorial => 'Salta el tutorial: ya conoce el oficio';

  @override
  String hireJoined(String name) {
    return '$name se suma al correo.';
  }

  @override
  String get hireDialogTitle => 'Nuevo mensajero';

  @override
  String get hireConfirm => 'CONTRATAR';

  @override
  String get hireDialogBody =>
      'Ya conoce el oficio. Varus confía en este nuevo correo.';

  @override
  String get hireNameError => 'Ponle un nombre';

  @override
  String get genderMan => 'Hombre';

  @override
  String get genderWoman => 'Mujer';

  @override
  String get navShop => 'Tienda';

  @override
  String get navProfile => 'Perfil';

  @override
  String get navMission => 'Misión';

  @override
  String get navNoneOnRoad => 'Ningún mensajero está en camino.';

  @override
  String get navPaths => 'Caminos';

  @override
  String navEventWaiting(String label) {
    return '$label, hay un evento esperando';
  }

  @override
  String get navHomeCurrent => 'Inicio, pantalla actual';

  @override
  String get navHome => 'Inicio';

  @override
  String guildBoardSemantics(int claimed, int total) {
    return 'Tablón del Gremio: $claimed de $total cobrados';
  }

  @override
  String get guildBoardHeader => 'TABLÓN DEL GREMIO';

  @override
  String guildToday(int claimed, int total) {
    return '$claimed/$total hoy';
  }

  @override
  String guildTodayWeek(
      int claimed, int total, int weekClaimed, int weekTotal) {
    return '$claimed/$total hoy · semana $weekClaimed/$weekTotal';
  }

  @override
  String guildClaimCount(int count) {
    return 'COBRAR $count';
  }

  @override
  String get guildBoardTitle => 'Tablón del Gremio';

  @override
  String get guildClaimSemantics => 'Cobrar';

  @override
  String get guildClaim => 'COBRAR';

  @override
  String get guildClaimed => 'COBRADO';

  @override
  String weeklyDone(String npc) {
    return 'Encargo de $npc cumplido';
  }

  @override
  String get weeklyHeader => 'Encargos de la semana';

  @override
  String get weeklyHint => 'Gente que confía en ti. Se renuevan el lunes.';

  @override
  String get contractsHeader => 'Contratos del día';

  @override
  String get contractsHint => 'Se renuevan a medianoche.';

  @override
  String get contractReroll => 'Cambiar este contrato por otro';

  @override
  String get contractRerolled =>
      'Contrato cambiado. Mañana puedes volver a hacerlo.';

  @override
  String get contractClaimed => 'Contrato cobrado';

  @override
  String get guildPayTitle => 'PAGA DEL GREMIO';

  @override
  String guildPayClaim(int day) {
    return 'COBRAR PAGA — DÍA $day';
  }

  @override
  String get guildPayHint => 'Varus premia tu constancia.';

  @override
  String guildPayNote(int day) {
    return 'Paga del Gremio · día $day de racha';
  }

  @override
  String get slotNoMissionsTitle => 'Sin misiones disponibles';

  @override
  String get slotNoMissionsBody =>
      'Completa misiones para desbloquear nuevas rutas.';

  @override
  String slotViewProfile(String name) {
    return 'Ver perfil de $name';
  }

  @override
  String slotRank(String title, int rank) {
    return '$title · Rango $rank';
  }

  @override
  String slotTrial(int n, int total) {
    return 'Prueba $n/$total de Varus';
  }

  @override
  String slotEventSemantics(String event) {
    return 'Evento pendiente: $event. Decidir.';
  }

  @override
  String get slotEventPending => '¡EVENTO PENDIENTE!';

  @override
  String get slotDecidesAlone => 'Tu mensajero decidirá solo';

  @override
  String slotDecidesIn(int minutes) {
    return 'Decide solo en $minutes min';
  }

  @override
  String get slotDecide => 'DECIDIR';

  @override
  String slotMissionSemantics(String origin, String destination) {
    return 'Misión de $origin a $destination. Ver viaje.';
  }

  @override
  String slotArrived(String place) {
    return '¡Llegó a $place! Toca para entregar';
  }

  @override
  String slotProgress(int pct) {
    return '$pct% del camino';
  }

  @override
  String slotTrialChip(int n, int total) {
    return 'PRUEBA $n/$total';
  }

  @override
  String get slotAcceptTrial => '¡ACEPTAR PRUEBA!';

  @override
  String get slotRoutesHeader => 'RUTAS DISPONIBLES';

  @override
  String slotSeeAllRoutes(int count) {
    return 'VER LAS $count RUTAS';
  }

  @override
  String slotRoutesFor(String name) {
    return 'Rutas para $name';
  }

  @override
  String get slotInjuredHeal => 'Herido: cúrate en la tienda';

  @override
  String get slotBusy => 'Mensajero ocupado';

  @override
  String slotPay(int amount) {
    return 'Paga ~$amount';
  }

  @override
  String get slotAcceptMission => '¡ACEPTAR MISIÓN!';

  @override
  String get slotConfirmTitle => 'Confirmar misión';

  @override
  String get slotSetOut => 'SALIR AL CAMINO';

  @override
  String slotDuration(String duration) {
    return 'Duración: $duration en tiempo real.';
  }

  @override
  String get slotNotifTitle => 'Varus te alcanza en la puerta';

  @override
  String get slotNotifYes => 'AVÍSAME';

  @override
  String get slotNotifNo => 'Prefiero mirar yo';

  @override
  String get slotNotifQuote =>
      '«El camino toma lo que toma. Cierra los ojos si quieres — yo te aviso si pasa algo.»';

  @override
  String get slotNotifBody =>
      'Te avisamos cuando tu mensajero necesite una decisión o llegue a destino. Nada entre las 22 y las 8.';

  @override
  String get onboardingTitle1 => 'Roma, 50 a.C.';

  @override
  String get onboardingBody1 =>
      'El Imperio controla el mundo conocido.\nMillones de personas. Incontables rutas.\nY cada decisión que importa viaja en manos de alguien.';

  @override
  String get onboardingTitle2 => 'Tú eres ese alguien.';

  @override
  String get onboardingBody2 =>
      'Un mensajero. El eslabón entre el poder y sus extremos.\nNadie sabe tu nombre. Nadie necesita saberlo.\nSolo importa que el mensaje llegue.';

  @override
  String get onboardingTitle3 => 'El camino no perdona.';

  @override
  String get onboardingBody3 =>
      'Legionarios. Tormentas. Bandidos. Traidores.\nCada viaje es una prueba.\nCada decisión tiene consecuencias.';

  @override
  String get onboardingTitle4 => 'El viaje es real.';

  @override
  String get onboardingBody4 =>
      'Las misiones duran minutos u horas de verdad.\nEnvías a tu mensajero y sigues con tu día:\nte avisamos cuando haya que decidir.';

  @override
  String get onboardingTitle5 => '¿Estás listo?';

  @override
  String get onboardingBody5 =>
      'Varus, jefe del correo, quiere ponerte a prueba.\nCuatro encargos cortos.\nNo lo decepciones.';

  @override
  String get onboardingSkip => 'Saltar';

  @override
  String onboardingSlideSemantics(int n, int total) {
    return 'Lámina $n de $total';
  }

  @override
  String get onboardingStart => '¡COMENZAR!';

  @override
  String get onboardingNext => 'CONTINUAR';

  @override
  String get loginError => 'No se pudo entrar. Inténtalo de nuevo.';

  @override
  String get loginRestoreError =>
      'No se pudo recuperar la partida. Inténtalo de nuevo.';

  @override
  String get loginTagline => 'Roma, 50 a.C. El correo te espera.';

  @override
  String get loginStart => 'EMPEZAR';

  @override
  String get loginHaveSave => 'Ya tengo partida';

  @override
  String loginHaveSaveWith(String provider) {
    return 'Ya tengo partida: $provider';
  }

  @override
  String get loginNoSignup => 'Sin registrarte. Tu partida se guarda sola.';

  @override
  String get loginNoSignupLink =>
      'Sin registrarte. Tu partida se guarda sola; en Ajustes puedes vincular una cuenta.';

  @override
  String missionTrialOf(String name) {
    return 'Prueba de Varus · $name';
  }

  @override
  String missionOnRoadOf(String name) {
    return 'En camino · $name';
  }

  @override
  String get missionArrived => '¡Llegaste!';

  @override
  String get missionResolvedHeader => 'EVENTOS RESUELTOS';

  @override
  String missionEtaIn(String time) {
    return 'en $time';
  }

  @override
  String get missionEtaImminent => 'inminente';

  @override
  String get missionNextRevealed => 'PRÓXIMO EVENTO REVELADO';

  @override
  String missionArrivedAt(String place) {
    return 'Llegaste a $place';
  }

  @override
  String get missionDeliverHint => 'Entrega el mensaje para cobrar.';

  @override
  String get missionDeliver => 'ENTREGAR MENSAJE';

  @override
  String get missionSkipToEvent => 'Adelantar al próximo evento';

  @override
  String get missionSkipToEnd => 'Adelantar al final de la misión';

  @override
  String missionSkipSemantics(String label, int cost) {
    return '$label por $cost denarios';
  }

  @override
  String get missionSkipNoFunds => 'Te faltan denarios para adelantar.';

  @override
  String get missionSkipNoFundsLabel =>
      'Sin denarios suficientes para adelantar';

  @override
  String missionSkipped(int cost) {
    return 'Adelantaste el tiempo (−$cost denarios)';
  }

  @override
  String missionAdsUsed(int count) {
    return 'Ya usaste los $count adelantos de hoy';
  }

  @override
  String get loading => 'Cargando…';

  @override
  String missionWatchAd(int count) {
    return 'Ver anuncio · −30 min ($count hoy)';
  }

  @override
  String get adsUnavailable =>
      'No hay anuncios disponibles ahora. Inténtalo en un rato.';

  @override
  String get missionAdSkipped => 'Adelantaste 30 minutos de camino';

  @override
  String missionYouChose(String choice) {
    return 'Decidiste: $choice';
  }

  @override
  String get eventChip => 'EVENTO';

  @override
  String get missionPaused => 'Progreso pausado';

  @override
  String get gradeS => '¡LEGENDARIO!';

  @override
  String get gradeA => '¡EXCELENTE!';

  @override
  String get gradeB => 'BIEN HECHO';

  @override
  String get gradeC => 'PASABLE';

  @override
  String get gradeF => 'FALLIDO';

  @override
  String get resultTrialChip => 'PRUEBA DE VARUS';

  @override
  String get resultEfficacySuffix => '% de eficacia';

  @override
  String get resultBackToBase => 'VOLVER AL CUARTEL';

  @override
  String get resultStoryContinues => 'LA HISTORIA CONTINÚA';

  @override
  String get resultBreakdown => 'DESGLOSE';

  @override
  String get resultPunctuality => 'Puntualidad';

  @override
  String get resultOnTime => 'A tiempo';

  @override
  String get resultLate => 'Con retraso';

  @override
  String get resultPackage => 'Estado del paquete';

  @override
  String get resultDecisions => 'Decisiones';

  @override
  String get packageIntact => 'Intacto';

  @override
  String get packageDamp => 'Humedad leve';

  @override
  String get packageDamaged => 'Dañado';

  @override
  String get packageCompromised => 'Comprometido';

  @override
  String get packageLost => 'Perdido';

  @override
  String get decisionsPerfect => 'Decisiones perfectas';

  @override
  String get decisionsGood => 'Buenas decisiones';

  @override
  String get decisionsFair => 'Decisiones regulares';

  @override
  String get decisionsBad => 'Malas decisiones';

  @override
  String get resultWhatChanged => 'LO QUE CAMBIÓ';

  @override
  String resultTitleEarned(String title) {
    return 'Ganaste el título «$title»';
  }

  @override
  String resultFatigueOnArrival(int value) {
    return '$value de fatiga al llegar';
  }

  @override
  String resultFatigueRest(int value, String stop) {
    return '$value de fatiga: $stop';
  }

  @override
  String get resultInjured => 'Llegaste herido: descansa antes de salir';

  @override
  String resultRepUp(String faction, int value) {
    return '$faction te tiene más en cuenta (+$value)';
  }

  @override
  String resultRepDown(String faction, int value) {
    return '$faction desconfía más de ti ($value)';
  }

  @override
  String get resultReward => 'RECOMPENSA';

  @override
  String resultPayFormula(String grade, int base, String factor) {
    return 'Nota $grade: $base × ruta $factor';
  }

  @override
  String resultSuccesses(int successes, int total) {
    return '$successes/$total exitosos';
  }

  @override
  String get profileNoMessenger => 'Sin mensajero';

  @override
  String get profileTitle => 'Mi mensajero';

  @override
  String get profileTabMessenger => 'Mensajero';

  @override
  String get profileTabWorld => 'Mundo';

  @override
  String get profileTabHistory => 'Historial';

  @override
  String get profileSkills => 'Habilidades';

  @override
  String get profileSeePaths => 'VER CAMINOS DEL MENSAJERO';

  @override
  String get profileSignOut => 'Cerrar sesión';

  @override
  String profileCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count misiones completadas',
      one: '1 misión completada',
    );
    return '$_temp0';
  }

  @override
  String get profilePathDone => 'Camino completado';

  @override
  String get profileAscendHint => 'Asciende en los Caminos con Sellos';

  @override
  String profileXpToNext(int xp, int max, int level) {
    return '$xp/$max XP para Nv.$level';
  }

  @override
  String profileAchSemantics(int done, int total) {
    return 'Logros: $done de $total. Toca para verlos y elegir tu título.';
  }

  @override
  String profileAchCount(int done, int total) {
    return '$done de $total logros';
  }

  @override
  String profileAchNext(String goal) {
    return 'Próximo: $goal';
  }

  @override
  String get profileReputation => 'Reputación';

  @override
  String get profileJournal => 'Diario del mensajero';

  @override
  String get profileJournalEmptyTitle => 'El diario está en blanco';

  @override
  String get profileJournalEmptyBody =>
      'Lo que decidas en el camino quedará escrito aquí.';

  @override
  String get repAllOpen => 'Te abrieron todas las puertas.';

  @override
  String repToNextUnlock(int left, String tier, String unlock) {
    return 'Faltan $left para $tier: $unlock';
  }

  @override
  String repToNext(int left, String tier) {
    return 'Faltan $left para $tier';
  }

  @override
  String get repHowToEarn =>
      'Se gana entregando bien en sus rutas (una vez por día: +1, o +2 con nota S), cumpliendo encargos y con lo que eliges en el camino.';

  @override
  String get historyEmptyTitle => 'Sin misiones completadas aún';

  @override
  String get historyEmptyBody => 'Acepta tu primera misión desde el Inicio.';

  @override
  String get signOutTitle => '¿Cerrar sesión?';

  @override
  String get signOutConfirm => 'SALIR';

  @override
  String get signOutBody => 'Tu progreso está guardado en el dispositivo.';

  @override
  String get skillsTitle => 'Caminos del mensajero';

  @override
  String skillsPicks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tienes $count niveles para elegir',
      one: 'Tienes 1 nivel para elegir',
    );
    return '$_temp0';
  }

  @override
  String skillsAppliesTo(String name, int max) {
    return 'Se aplica a $name. Hasta nivel $max.';
  }

  @override
  String get skillsIntro =>
      'Los niveles 1-5 se ganan jugando. Los niveles 6-10 se ascienden con Sellos del Gremio: contratos del día, rachas y notas S. Los Sellos son de la cuenta: los comparten todos tus mensajeros.';

  @override
  String skillLevelOf(int level, int max) {
    return 'Nv.$level/$max';
  }

  @override
  String get skillsPathComplete => 'CAMINO COMPLETADO';

  @override
  String skillsNext(String name, String perk) {
    return 'Siguiente: «$name» — $perk';
  }

  @override
  String skillsAscent(String name) {
    return 'Ascenso: «$name»';
  }

  @override
  String get skillsXpCapped =>
      'La experiencia ya no sube este camino: de aquí en adelante van Sellos.';

  @override
  String skillsAscend(int cost) {
    return 'ASCENDER — $cost SELLOS';
  }

  @override
  String skillsNeedSeals(int cost, int have) {
    return 'NECESITAS $cost SELLOS (tienes $have)';
  }

  @override
  String get skillsWhatYouGain => 'QUÉ GANAS';

  @override
  String get skillsLevelUp => '¡SUBISTE DE NIVEL!';

  @override
  String skillsLevelUpLine(String skill, int level, String name) {
    return '$skill Nv.$level — «$name»';
  }

  @override
  String get eventSpotlightTitle => 'Una decisión en el camino';

  @override
  String get eventSpotlightBody =>
      'Cada opción tiene riesgo, costo de tiempo y a veces pide una habilidad. El pronóstico te muestra las probabilidades antes de confirmar.';

  @override
  String get eventNoneTitle => 'No hay eventos pendientes';

  @override
  String get eventNoneBody => 'El camino está tranquilo por ahora.';

  @override
  String get eventBack => 'VOLVER';

  @override
  String get eventWhatDoYouDo => '¿QUÉ HACES?';

  @override
  String get eventCritical => 'EVENTO CRÍTICO';

  @override
  String get eventResolving => 'Resolviendo...';

  @override
  String get eventPickOption => 'ELIGE UNA OPCIÓN';

  @override
  String get eventConfirm => 'CONFIRMAR DECISIÓN';

  @override
  String get eventTimeUp => 'SE TE PASÓ';

  @override
  String eventTimeToDecide(String time) {
    return 'Tiempo para decidir: $time';
  }

  @override
  String get eventLockedHint => 'Te falta habilidad para esto.';

  @override
  String get eventStoryOpened => 'Tu historia abrió este camino';

  @override
  String get outcomeSuccess => '¡ÉXITO!';

  @override
  String get outcomePartial => 'ÉXITO PARCIAL';

  @override
  String get outcomeFail => 'FALLASTE';

  @override
  String get outcomeTrialDone =>
      '¡Varus está satisfecho! Siguiente prueba desbloqueada.';

  @override
  String get outcomeMissionDone =>
      '¡Misión completada! Resultado disponible en tu perfil.';

  @override
  String outcomeHealth(String delta) {
    return '$delta salud';
  }

  @override
  String outcomeTravelTime(int minutes) {
    return '+${minutes}m de viaje';
  }

  @override
  String outcomeXp(int xp, String skill) {
    return '+$xp XP de $skill';
  }

  @override
  String get outcomeJournaled => 'Quedó anotado en tu diario';

  @override
  String get outcomeRomeRemembers => 'Roma no se olvida de esto';

  @override
  String get outcomeGoHome => 'IR AL INICIO';

  @override
  String get whyHeader => 'POR QUÉ PASÓ';

  @override
  String get whyRoll => 'Tu tirada';

  @override
  String get whySuccess => 'Con 55 alcanzaba para salir bien parado.';

  @override
  String whyPartial(int count) {
    return 'Con 55 salía redondo: te faltaron $count.';
  }

  @override
  String whyFail(int count) {
    return 'Desde 30 era un éxito parcial: te faltaron $count.';
  }

  @override
  String get shopCatBoosters => 'Potenciadores';

  @override
  String get shopCatSkills => 'Habilidades';

  @override
  String get shopCatAurei => 'Aureos';

  @override
  String get shopCatBundles => 'Paquetes';

  @override
  String get shopItemBoostHealthSmallName => 'Poción de salud';

  @override
  String get shopItemBoostHealthSmallDesc =>
      'Restaura 30 puntos de salud al instante.';

  @override
  String get shopItemBoostHealthFullName => 'Curación completa';

  @override
  String get shopItemBoostHealthFullDesc =>
      'Salud al 100%. Ideal antes de una misión larga.';

  @override
  String get shopItemBoostFatigueName => 'Descanso rápido';

  @override
  String get shopItemBoostFatigueDesc => 'Elimina toda la fatiga acumulada.';

  @override
  String get shopItemBoostSpeedName => 'Sandalias de Mercurio';

  @override
  String get shopItemBoostSpeedDesc =>
      'Reduce el tiempo de tu próxima misión un 20%.';

  @override
  String get shopItemBoostEventsName => 'Mapa del explorador';

  @override
  String get shopItemBoostEventsDesc =>
      'Revela el próximo evento de la misión antes de que ocurra.';

  @override
  String get shopItemBoostEventsBlackName => 'Mapa del contrabandista';

  @override
  String get shopItemBoostEventsBlackDesc =>
      'El mapa de la Viuda: revela el próximo evento de tu próxima misión.';

  @override
  String get shopItemSkillSpeed1Name => 'Manual de velocidad I';

  @override
  String get shopItemSkillSpeed1Desc =>
      'Sube Velocidad un nivel (hasta 5). Más rápido en el camino.';

  @override
  String get shopItemSkillStealth1Name => 'Tratado de sigilo I';

  @override
  String get shopItemSkillStealth1Desc =>
      'Sube Sigilo un nivel (hasta 5). Evita controles y patrullas.';

  @override
  String get shopItemSkillCombat1Name => 'Adiestramiento de combate I';

  @override
  String get shopItemSkillCombat1Desc =>
      'Sube Combate un nivel (hasta 5). Mejora en enfrentamientos.';

  @override
  String get shopItemSkillSurvival1Name => 'Conocimiento del campo I';

  @override
  String get shopItemSkillSurvival1Desc =>
      'Sube Supervivencia un nivel (hasta 5). Aguanta más en ruta.';

  @override
  String get shopItemSkillContacts1Name => 'Red de contactos I';

  @override
  String get shopItemSkillContacts1Desc =>
      'Sube Contactos un nivel (hasta 5). Mejores opciones diplomáticas.';

  @override
  String get shopItemAureosSmallName => 'Bolsa de Aureos';

  @override
  String get shopItemAureosSmallDesc => '50 Aureos para gastar en la tienda.';

  @override
  String get shopItemAureosMediumName => 'Cofre de Aureos';

  @override
  String get shopItemAureosMediumDesc =>
      '120 Aureos. El preferido del mensajero veterano.';

  @override
  String get shopItemAureosLargeName => 'Tesoro del Imperio';

  @override
  String get shopItemAureosLargeDesc =>
      '300 Aureos. El mejor valor disponible.';

  @override
  String get shopItemAureosMegaName => 'Bóveda Imperial';

  @override
  String get shopItemAureosMegaDesc => '800 Aureos + 500 Denarios de bonus.';

  @override
  String get shopItemBundleStarterName => 'Pack del Correo';

  @override
  String get shopItemBundleStarterDesc =>
      '30 Aureos + 2.º espacio de mensajero + 2 Sellos. Para empezar con ventaja.';

  @override
  String get shopItemBundleWarriorName => 'Pack del Guerrero';

  @override
  String get shopItemBundleWarriorDesc =>
      'Sube 2 niveles de habilidad a tu elección + 50 Aureos.';

  @override
  String get shopItemSealSingleName => 'Sello del Gremio';

  @override
  String get shopItemSealSingleDesc =>
      '1 Sello para subir nodos élite del árbol (niveles 6-10).';

  @override
  String get shopItemSealPack10Name => 'Paquete de 10 Sellos';

  @override
  String get shopItemSealPack10Desc =>
      '10 Sellos del Gremio. Ahorras 30 Aureos frente a comprarlos de uno en uno.';

  @override
  String get shopPending =>
      'La compra quedó pendiente. Se acredita sola cuando la tienda la confirme.';

  @override
  String get shopCanceled => 'Compra cancelada.';

  @override
  String get shopFailed =>
      'No se pudo completar la compra. Si se cobró, se acredita sola la próxima vez que abras el juego.';

  @override
  String get shopSpotlightTitle => 'La tienda del Gremio';

  @override
  String get shopSpotlightBody =>
      'Denarios para el día a día. Aureos para acelerar. Sellos para el árbol élite. Nada es pay-to-win destructivo: pagar acelera, no reemplaza jugar.';

  @override
  String get shopEffectHealthSmall => '+30 de salud';

  @override
  String get shopEffectHealthFull => 'Salud restaurada al 100%';

  @override
  String get shopEffectFatigue => 'Fatiga eliminada';

  @override
  String get shopEffectSpeed =>
      'Sandalias listas: tu próxima misión durará 20% menos';

  @override
  String get shopEffectMap =>
      'Mapa listo: tu próxima misión revelará el evento por venir';

  @override
  String get shopEffectSkill => '¡Habilidad mejorada!';

  @override
  String get shopEffectApplied => 'Compra aplicada';

  @override
  String get shopUnavailable => 'Este producto todavía no está disponible.';

  @override
  String shopSandbox(String name) {
    return '$name (sandbox de prueba)';
  }

  @override
  String get shopNoDenarii => 'No te alcanzan los Denarios.';

  @override
  String get shopNoAurei => 'No te alcanzan los Aureos.';

  @override
  String get shopTitle => 'TIENDA';

  @override
  String get shopFor => 'Para:';

  @override
  String get shopMax => 'MÁX';

  @override
  String shopPlusAurei(int count) {
    return '+$count Aureos';
  }

  @override
  String get shopLimited => 'TIEMPO LIMITADO';

  @override
  String get shopTagPopular => 'POPULAR';

  @override
  String get shopTagBestValue => 'MEJOR VALOR';

  @override
  String get shopTagVip => 'VIP';

  @override
  String get shopTagOffer => 'OFERTA';

  @override
  String get shopTagPremium => 'PREMIUM';

  @override
  String get shopTagBlackMarket => 'MERCADO NEGRO';

  @override
  String get shopTagElite => 'ÉLITE';

  @override
  String get shopTagPack => 'PACK';

  @override
  String get shopBought => 'COMPRADO';

  @override
  String shopBuyFor(String price) {
    return 'Comprar por $price';
  }

  @override
  String shopBuyButton(String price) {
    return 'COMPRAR · $price';
  }

  @override
  String get shopRewardSecondMessenger => '+2.º mensajero';

  @override
  String get shopRewardSkillLevels =>
      '+2 niveles de habilidad a elección (en Caminos)';

  @override
  String get settingsLegal => 'Legal';

  @override
  String get settingsPrivacyPolicy => 'Política de privacidad';

  @override
  String get settingsTerms => 'Términos de uso';

  @override
  String get settingsLinkError => 'No se pudo abrir el enlace.';

  @override
  String get endingsTitle => 'Finales';

  @override
  String endingsCount(int found, int total) {
    return '$found de $total finales';
  }

  @override
  String get endingsExplainer =>
      'Cada arco tiene tres finales. Vuelve a recorrer un arco terminado para buscar los que faltan: tu partida no cambia.';

  @override
  String get endingsArcLocked => 'Termina este arco para ver sus finales.';

  @override
  String get endingsUnknown => 'Final sin descubrir';

  @override
  String get endingsFoundLabel => 'Encontrado';

  @override
  String get endingsReplay => 'Volver a recorrer';

  @override
  String get endingsReplayStarted =>
      'El arco vuelve a empezar: su capítulo te espera en el inicio.';

  @override
  String endingsReplayActive(int chapter) {
    return 'Recorriéndolo de nuevo: capítulo $chapter de 5.';
  }

  @override
  String get endingsAbandon => 'Dejar el recorrido';

  @override
  String get endingsAbandoned =>
      'Dejaste el recorrido. Puedes empezarlo otra vez cuando quieras.';

  @override
  String get achSeeEndings => 'Ver los finales';

  @override
  String get storyReplayTag => 'Nuevo recorrido';

  @override
  String get resultEndingNew => 'Final nuevo';

  @override
  String get resultSeeEndings => 'Ver los finales';
}
