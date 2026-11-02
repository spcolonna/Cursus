import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// Título del selector de idioma en Ajustes
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get settingsLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In es, this message translates to:
  /// **'El del teléfono'**
  String get languageSystem;

  /// No description provided for @languageSpanish.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @languageEnglish.
  ///
  /// In es, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @notifChannelName.
  ///
  /// In es, this message translates to:
  /// **'El camino'**
  String get notifChannelName;

  /// No description provided for @notifChannelDescription.
  ///
  /// In es, this message translates to:
  /// **'Avisos de eventos en la ruta y entregas listas.'**
  String get notifChannelDescription;

  /// No description provided for @notifEventTitle.
  ///
  /// In es, this message translates to:
  /// **'Algo pasó en el camino'**
  String get notifEventTitle;

  /// No description provided for @notifEventBody.
  ///
  /// In es, this message translates to:
  /// **'{messenger} necesita una decisión: {event}.'**
  String notifEventBody(String messenger, String event);

  /// No description provided for @notifDeliveryTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu entrega está lista'**
  String get notifDeliveryTitle;

  /// No description provided for @notifDeliveryBody.
  ///
  /// In es, this message translates to:
  /// **'{messenger} llegó a {place}. Entrega el mensaje.'**
  String notifDeliveryBody(String messenger, String place);

  /// No description provided for @notifIdleTitle.
  ///
  /// In es, this message translates to:
  /// **'El camino espera'**
  String get notifIdleTitle;

  /// No description provided for @notifIdleBody.
  ///
  /// In es, this message translates to:
  /// **'{messenger} está sin misión. Hay rutas en el tablón.'**
  String notifIdleBody(String messenger);

  /// No description provided for @notifContractsTitle.
  ///
  /// In es, this message translates to:
  /// **'Contratos del Gremio'**
  String get notifContractsTitle;

  /// No description provided for @notifContractsBody.
  ///
  /// In es, this message translates to:
  /// **'Quedan contratos sin cobrar. Vencen a medianoche.'**
  String get notifContractsBody;

  /// No description provided for @notifTestTitle.
  ///
  /// In es, this message translates to:
  /// **'Prueba del correo'**
  String get notifTestTitle;

  /// No description provided for @notifTestBody.
  ///
  /// In es, this message translates to:
  /// **'Si estás leyendo esto, los avisos llegan bien.'**
  String get notifTestBody;

  /// No description provided for @riskEasy.
  ///
  /// In es, this message translates to:
  /// **'FÁCIL'**
  String get riskEasy;

  /// No description provided for @riskLow.
  ///
  /// In es, this message translates to:
  /// **'BAJO'**
  String get riskLow;

  /// No description provided for @riskMedium.
  ///
  /// In es, this message translates to:
  /// **'MEDIO'**
  String get riskMedium;

  /// No description provided for @riskHigh.
  ///
  /// In es, this message translates to:
  /// **'ALTO'**
  String get riskHigh;

  /// No description provided for @riskExtreme.
  ///
  /// In es, this message translates to:
  /// **'EXTREMO'**
  String get riskExtreme;

  /// No description provided for @skillLevelShort.
  ///
  /// In es, this message translates to:
  /// **'Nv.{level}'**
  String skillLevelShort(int level);

  /// No description provided for @currencyDenarii.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{denario} other{denarios}}'**
  String currencyDenarii(int count);

  /// No description provided for @currencyAurei.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{aureo} other{aureos}}'**
  String currencyAurei(int count);

  /// No description provided for @currencySeals.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Sello del Gremio} other{Sellos}}'**
  String currencySeals(int count);

  /// No description provided for @gradeSemantics.
  ///
  /// In es, this message translates to:
  /// **'Nota {grade}'**
  String gradeSemantics(String grade);

  /// No description provided for @updateTitle.
  ///
  /// In es, this message translates to:
  /// **'Hay una versión nueva'**
  String get updateTitle;

  /// No description provided for @updateBody.
  ///
  /// In es, this message translates to:
  /// **'Para seguir con tus entregas tienes que actualizar Via Imperia. Tu partida queda guardada.'**
  String get updateBody;

  /// No description provided for @updateButton.
  ///
  /// In es, this message translates to:
  /// **'Actualizar'**
  String get updateButton;

  /// No description provided for @achKindRoad.
  ///
  /// In es, this message translates to:
  /// **'El camino'**
  String get achKindRoad;

  /// No description provided for @achKindGrade.
  ///
  /// In es, this message translates to:
  /// **'Entregas perfectas'**
  String get achKindGrade;

  /// No description provided for @achKindGuild.
  ///
  /// In es, this message translates to:
  /// **'El Gremio'**
  String get achKindGuild;

  /// No description provided for @achKindSkill.
  ///
  /// In es, this message translates to:
  /// **'Oficio'**
  String get achKindSkill;

  /// No description provided for @achKindStory.
  ///
  /// In es, this message translates to:
  /// **'Historia'**
  String get achKindStory;

  /// No description provided for @achKindEmpire.
  ///
  /// In es, this message translates to:
  /// **'Fortuna'**
  String get achKindEmpire;

  /// No description provided for @titleEquippedSemantics.
  ///
  /// In es, this message translates to:
  /// **'{title}, equipado'**
  String titleEquippedSemantics(String title);

  /// No description provided for @skillNodeSemantics.
  ///
  /// In es, this message translates to:
  /// **'{skill}, nivel {level} de {max}'**
  String skillNodeSemantics(String skill, int level, int max);

  /// No description provided for @celebAchievementHeader.
  ///
  /// In es, this message translates to:
  /// **'LOGRO CONSEGUIDO'**
  String get celebAchievementHeader;

  /// No description provided for @celebAchievementSemantics.
  ///
  /// In es, this message translates to:
  /// **'Logro conseguido: {name}. Toca para ver tus logros.'**
  String celebAchievementSemantics(String name);

  /// No description provided for @rewardDenarii.
  ///
  /// In es, this message translates to:
  /// **'+{count} Denarios'**
  String rewardDenarii(int count);

  /// No description provided for @rewardSeals.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{+1 Sello} other{+{count} Sellos}}'**
  String rewardSeals(int count);

  /// No description provided for @quotedTitle.
  ///
  /// In es, this message translates to:
  /// **'«{title}»'**
  String quotedTitle(String title);

  /// No description provided for @celebTierHeader.
  ///
  /// In es, this message translates to:
  /// **'NUEVO ESCALÓN'**
  String get celebTierHeader;

  /// No description provided for @celebTierSemantics.
  ///
  /// In es, this message translates to:
  /// **'{faction} ahora te tiene por {tier}. Toca para ver tu reputación.'**
  String celebTierSemantics(String faction, String tier);

  /// No description provided for @celebRankHeader.
  ///
  /// In es, this message translates to:
  /// **'¡NUEVO RANGO!'**
  String get celebRankHeader;

  /// No description provided for @celebContinue.
  ///
  /// In es, this message translates to:
  /// **'SEGUIR'**
  String get celebContinue;

  /// No description provided for @rankBlurb2.
  ///
  /// In es, this message translates to:
  /// **'En el correo ya saben tu nombre.\nSe abren rutas que antes no te daban.'**
  String get rankBlurb2;

  /// No description provided for @rankBlurb3.
  ///
  /// In es, this message translates to:
  /// **'Te confían lo que no se puede perder.\nYa nadie te manda a llevar recados.'**
  String get rankBlurb3;

  /// No description provided for @rankBlurb4.
  ///
  /// In es, this message translates to:
  /// **'Los otros mensajeros te piden consejo.\nRoma empieza a notarte.'**
  String get rankBlurb4;

  /// No description provided for @rankBlurb5.
  ///
  /// In es, this message translates to:
  /// **'Tu nombre se dice en las postas de todo el Imperio.'**
  String get rankBlurb5;

  /// No description provided for @firstStepsRoute.
  ///
  /// In es, this message translates to:
  /// **'Completa tu primera ruta real'**
  String get firstStepsRoute;

  /// No description provided for @firstStepsBuy.
  ///
  /// In es, this message translates to:
  /// **'Compra un objeto en la tienda'**
  String get firstStepsBuy;

  /// No description provided for @firstStepsSkill.
  ///
  /// In es, this message translates to:
  /// **'Sube una habilidad'**
  String get firstStepsSkill;

  /// No description provided for @firstStepsGuild.
  ///
  /// In es, this message translates to:
  /// **'Mira el tablón del Gremio'**
  String get firstStepsGuild;

  /// No description provided for @firstStepsNotifs.
  ///
  /// In es, this message translates to:
  /// **'Activa las notificaciones'**
  String get firstStepsNotifs;

  /// No description provided for @firstStepsTitle.
  ///
  /// In es, this message translates to:
  /// **'PRIMEROS PASOS'**
  String get firstStepsTitle;

  /// No description provided for @firstStepsClaim.
  ///
  /// In es, this message translates to:
  /// **'RECLAMAR · 3 Aureos + 1 Sello'**
  String get firstStepsClaim;

  /// No description provided for @firstStepsHint.
  ///
  /// In es, this message translates to:
  /// **'Completa las 5 tareas y ganas 3 Aureos + 1 Sello.'**
  String get firstStepsHint;

  /// No description provided for @gotIt.
  ///
  /// In es, this message translates to:
  /// **'ENTENDIDO'**
  String get gotIt;

  /// No description provided for @cloudConflictTitle.
  ///
  /// In es, this message translates to:
  /// **'Tienes dos partidas'**
  String get cloudConflictTitle;

  /// No description provided for @cloudUseRemote.
  ///
  /// In es, this message translates to:
  /// **'USAR LA DE LA NUBE'**
  String get cloudUseRemote;

  /// No description provided for @cloudUseLocal.
  ///
  /// In es, this message translates to:
  /// **'Usar la de este teléfono'**
  String get cloudUseLocal;

  /// No description provided for @cloudConflictBody.
  ///
  /// In es, this message translates to:
  /// **'La que no elijas se pierde.'**
  String get cloudConflictBody;

  /// No description provided for @cloudLabel.
  ///
  /// In es, this message translates to:
  /// **'Nube'**
  String get cloudLabel;

  /// No description provided for @cloudThisPhone.
  ///
  /// In es, this message translates to:
  /// **'Este teléfono'**
  String get cloudThisPhone;

  /// No description provided for @cloudDeliveries.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 entrega} other{{count} entregas}}'**
  String cloudDeliveries(int count);

  /// No description provided for @agoNow.
  ///
  /// In es, this message translates to:
  /// **'hace un momento'**
  String get agoNow;

  /// No description provided for @agoMinutes.
  ///
  /// In es, this message translates to:
  /// **'hace {count} min'**
  String agoMinutes(int count);

  /// No description provided for @agoHours.
  ///
  /// In es, this message translates to:
  /// **'hace {count} h'**
  String agoHours(int count);

  /// No description provided for @agoYesterday.
  ///
  /// In es, this message translates to:
  /// **'ayer'**
  String get agoYesterday;

  /// No description provided for @agoDays.
  ///
  /// In es, this message translates to:
  /// **'hace {count} días'**
  String agoDays(int count);

  /// No description provided for @continueWithApple.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Apple'**
  String get continueWithApple;

  /// No description provided for @continueWithGoogle.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Google'**
  String get continueWithGoogle;

  /// No description provided for @cloudLinked.
  ///
  /// In es, this message translates to:
  /// **'Cuenta vinculada. Tu partida queda a salvo.'**
  String get cloudLinked;

  /// No description provided for @cloudLinkFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo vincular. Inténtalo de nuevo.'**
  String get cloudLinkFailed;

  /// No description provided for @cloudDeleteFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo borrar la cuenta. Revisa la conexión e inténtalo de nuevo.'**
  String get cloudDeleteFailed;

  /// No description provided for @cloudLinkedWith.
  ///
  /// In es, this message translates to:
  /// **'Vinculada con {providers}. Puedes recuperar tu partida en otro teléfono.'**
  String cloudLinkedWith(String providers);

  /// No description provided for @listAnd.
  ///
  /// In es, this message translates to:
  /// **' y '**
  String get listAnd;

  /// No description provided for @cloudLinkPrompt.
  ///
  /// In es, this message translates to:
  /// **'Vincula una cuenta para no perder la partida si cambias de teléfono.'**
  String get cloudLinkPrompt;

  /// No description provided for @cloudDeleteAccount.
  ///
  /// In es, this message translates to:
  /// **'Borrar cuenta y datos'**
  String get cloudDeleteAccount;

  /// No description provided for @cloudDeleteLocal.
  ///
  /// In es, this message translates to:
  /// **'Borrar partida'**
  String get cloudDeleteLocal;

  /// No description provided for @cloudDeleteLocalBody.
  ///
  /// In es, this message translates to:
  /// **'Se borran tus mensajeros, tu progreso y las monedas de este teléfono. No se puede deshacer.'**
  String get cloudDeleteLocalBody;

  /// No description provided for @cloudStatusLocal.
  ///
  /// In es, this message translates to:
  /// **'Tu partida se guarda en este teléfono.'**
  String get cloudStatusLocal;

  /// No description provided for @cloudStatusSyncing.
  ///
  /// In es, this message translates to:
  /// **'Guardando en la nube…'**
  String get cloudStatusSyncing;

  /// No description provided for @cloudStatusSynced.
  ///
  /// In es, this message translates to:
  /// **'Partida guardada en la nube.'**
  String get cloudStatusSynced;

  /// No description provided for @cloudStatusSyncedAgo.
  ///
  /// In es, this message translates to:
  /// **'Partida guardada en la nube {ago}.'**
  String cloudStatusSyncedAgo(String ago);

  /// No description provided for @cloudStatusOffline.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión: se guarda en el teléfono y se sube cuando vuelva.'**
  String get cloudStatusOffline;

  /// No description provided for @cloudDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Borrar todo?'**
  String get cloudDeleteTitle;

  /// No description provided for @cloudDeleteConfirm.
  ///
  /// In es, this message translates to:
  /// **'BORRAR PARA SIEMPRE'**
  String get cloudDeleteConfirm;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @cloudDeleteBody.
  ///
  /// In es, this message translates to:
  /// **'Se borran tu cuenta, tus mensajeros, tu progreso y las monedas, en este teléfono y en la nube. No se puede deshacer.'**
  String get cloudDeleteBody;

  /// No description provided for @back.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get back;

  /// No description provided for @close.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get close;

  /// No description provided for @errorGeneric.
  ///
  /// In es, this message translates to:
  /// **'Algo se trabó en el camino. Inténtalo de nuevo en un momento.'**
  String get errorGeneric;

  /// No description provided for @errorLoadTitle.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar esto'**
  String get errorLoadTitle;

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'REINTENTAR'**
  String get retry;

  /// No description provided for @unlocked.
  ///
  /// In es, this message translates to:
  /// **'Desbloqueado'**
  String get unlocked;

  /// No description provided for @requiresTier.
  ///
  /// In es, this message translates to:
  /// **'Pide {tier}'**
  String requiresTier(String tier);

  /// No description provided for @open.
  ///
  /// In es, this message translates to:
  /// **'Abierto'**
  String get open;

  /// No description provided for @brandTagline.
  ///
  /// In es, this message translates to:
  /// **'Cartas de Roma'**
  String get brandTagline;

  /// No description provided for @routeMapSemantics.
  ///
  /// In es, this message translates to:
  /// **'Mapa de la ruta de {origin} a {destination}'**
  String routeMapSemantics(String origin, String destination);

  /// No description provided for @settingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settingsTitle;

  /// No description provided for @settingsAlertsHeader.
  ///
  /// In es, this message translates to:
  /// **'AVISOS DEL CAMINO'**
  String get settingsAlertsHeader;

  /// No description provided for @settingsSoundHeader.
  ///
  /// In es, this message translates to:
  /// **'SONIDO Y MOVIMIENTO'**
  String get settingsSoundHeader;

  /// No description provided for @settingsUsageHeader.
  ///
  /// In es, this message translates to:
  /// **'DATOS DE USO'**
  String get settingsUsageHeader;

  /// No description provided for @settingsAccountHeader.
  ///
  /// In es, this message translates to:
  /// **'CUENTA'**
  String get settingsAccountHeader;

  /// No description provided for @settingsSkyHeader.
  ///
  /// In es, this message translates to:
  /// **'CIELO (SOLO DEBUG)'**
  String get settingsSkyHeader;

  /// No description provided for @settingsDiagnosticsHeader.
  ///
  /// In es, this message translates to:
  /// **'DIAGNÓSTICO'**
  String get settingsDiagnosticsHeader;

  /// No description provided for @settingsAlertsToggle.
  ///
  /// In es, this message translates to:
  /// **'Recibir avisos'**
  String get settingsAlertsToggle;

  /// No description provided for @settingsAlertsToggleHint.
  ///
  /// In es, this message translates to:
  /// **'Nunca entre las 22 y las 8, salvo un evento de una misión que ya está en marcha. Máximo 4 por día.'**
  String get settingsAlertsToggleHint;

  /// No description provided for @permGranted.
  ///
  /// In es, this message translates to:
  /// **'Concedido'**
  String get permGranted;

  /// No description provided for @permDenied.
  ///
  /// In es, this message translates to:
  /// **'Denegado'**
  String get permDenied;

  /// No description provided for @permNotRequested.
  ///
  /// In es, this message translates to:
  /// **'Todavía no se pidió'**
  String get permNotRequested;

  /// No description provided for @permSystemLabel.
  ///
  /// In es, this message translates to:
  /// **'Permiso del sistema: '**
  String get permSystemLabel;

  /// No description provided for @diagScheduled.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 aviso programado} other{{count} avisos programados}}'**
  String diagScheduled(int count);

  /// No description provided for @diagIosLimit.
  ///
  /// In es, this message translates to:
  /// **'iOS descarta lo que pase de 64 pendientes: por eso se programan solo los dos próximos eventos de cada misión.'**
  String get diagIosLimit;

  /// No description provided for @diagQueueEmpty.
  ///
  /// In es, this message translates to:
  /// **'Nada en la cola. Acepta una misión para que se programen.'**
  String get diagQueueEmpty;

  /// No description provided for @diagTest.
  ///
  /// In es, this message translates to:
  /// **'PROBAR EN 10s'**
  String get diagTest;

  /// No description provided for @diagTestNote.
  ///
  /// In es, this message translates to:
  /// **'Cierra la app: el aviso llega en 10 segundos.'**
  String get diagTestNote;

  /// No description provided for @diagReload.
  ///
  /// In es, this message translates to:
  /// **'RECARGAR'**
  String get diagReload;

  /// No description provided for @diagCancelAll.
  ///
  /// In es, this message translates to:
  /// **'Cancelar todos los avisos'**
  String get diagCancelAll;

  /// No description provided for @skyDawn.
  ///
  /// In es, this message translates to:
  /// **'Alba'**
  String get skyDawn;

  /// No description provided for @skyDay.
  ///
  /// In es, this message translates to:
  /// **'Día'**
  String get skyDay;

  /// No description provided for @skyDusk.
  ///
  /// In es, this message translates to:
  /// **'Atardecer'**
  String get skyDusk;

  /// No description provided for @skyNight.
  ///
  /// In es, this message translates to:
  /// **'Noche'**
  String get skyNight;

  /// No description provided for @skyRealClock.
  ///
  /// In es, this message translates to:
  /// **'Reloj real: {time} · {phase}'**
  String skyRealClock(String time, String phase);

  /// No description provided for @skyFixedHour.
  ///
  /// In es, this message translates to:
  /// **'Hora fija: {time} · {phase}'**
  String skyFixedHour(String time, String phase);

  /// No description provided for @skyClock.
  ///
  /// In es, this message translates to:
  /// **'Reloj'**
  String get skyClock;

  /// No description provided for @settingsMusic.
  ///
  /// In es, this message translates to:
  /// **'Música'**
  String get settingsMusic;

  /// No description provided for @settingsMusicHint.
  ///
  /// In es, this message translates to:
  /// **'Lira y aulos: cambia con la hora y en el camino'**
  String get settingsMusicHint;

  /// No description provided for @settingsMusicVolume.
  ///
  /// In es, this message translates to:
  /// **'Volumen de la música {percent}%'**
  String settingsMusicVolume(int percent);

  /// No description provided for @settingsSfx.
  ///
  /// In es, this message translates to:
  /// **'Efectos de sonido'**
  String get settingsSfx;

  /// No description provided for @settingsSfxHint.
  ///
  /// In es, this message translates to:
  /// **'Botones, resultados, entregas y cobros'**
  String get settingsSfxHint;

  /// No description provided for @settingsHaptics.
  ///
  /// In es, this message translates to:
  /// **'Vibración'**
  String get settingsHaptics;

  /// No description provided for @settingsHapticsHint.
  ///
  /// In es, this message translates to:
  /// **'Un golpe suave al tocar y al cobrar'**
  String get settingsHapticsHint;

  /// No description provided for @settingsReduceMotion.
  ///
  /// In es, this message translates to:
  /// **'Animaciones reducidas'**
  String get settingsReduceMotion;

  /// No description provided for @settingsReduceMotionHint.
  ///
  /// In es, this message translates to:
  /// **'Menos movimiento: transiciones cortas y sin sacudidas'**
  String get settingsReduceMotionHint;

  /// No description provided for @usageCopied.
  ///
  /// In es, this message translates to:
  /// **'Datos copiados. Pégalos en un mensaje.'**
  String get usageCopied;

  /// No description provided for @usageShare.
  ///
  /// In es, this message translates to:
  /// **'Compartir estadísticas'**
  String get usageShare;

  /// No description provided for @usageShareHint.
  ///
  /// In es, this message translates to:
  /// **'Qué rutas juegas y cuándo vuelves. Anónimo: sin tu nombre ni nada que te identifique.'**
  String get usageShareHint;

  /// No description provided for @usageSummary.
  ///
  /// In es, this message translates to:
  /// **'Día {day} desde que empezaste · {days, plural, =1{1 día jugado} other{{days} días jugados}} · {sessions, plural, =1{1 sesión} other{{sessions} sesiones}}'**
  String usageSummary(int day, int days, int sessions);

  /// No description provided for @usageCopy.
  ///
  /// In es, this message translates to:
  /// **'Copiar datos para el equipo'**
  String get usageCopy;

  /// No description provided for @usageAdsPrivacy.
  ///
  /// In es, this message translates to:
  /// **'Privacidad de los anuncios'**
  String get usageAdsPrivacy;

  /// No description provided for @achTitle.
  ///
  /// In es, this message translates to:
  /// **'Logros y títulos'**
  String get achTitle;

  /// No description provided for @achYourTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu título'**
  String get achYourTitle;

  /// No description provided for @achNoTitles.
  ///
  /// In es, this message translates to:
  /// **'Todavía no ganaste ninguno. Los títulos salen de los logros y de los finales de la historia.'**
  String get achNoTitles;

  /// No description provided for @achPickTitle.
  ///
  /// In es, this message translates to:
  /// **'Toca uno para llevarlo bajo tu nombre.'**
  String get achPickTitle;

  /// No description provided for @achSecret.
  ///
  /// In es, this message translates to:
  /// **'Logro secreto'**
  String get achSecret;

  /// No description provided for @achDone.
  ///
  /// In es, this message translates to:
  /// **'Conseguido'**
  String get achDone;

  /// No description provided for @achProgress.
  ///
  /// In es, this message translates to:
  /// **'Progreso {progress} de {target}'**
  String achProgress(int progress, int target);

  /// No description provided for @achSecretHint.
  ///
  /// In es, this message translates to:
  /// **'Sigue la historia para descubrirlo.'**
  String get achSecretHint;

  /// No description provided for @sealsCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 Sello} other{{count} Sellos}}'**
  String sealsCount(int count);

  /// No description provided for @charErrorEmpty.
  ///
  /// In es, this message translates to:
  /// **'Ponle un nombre a tu mensajero.'**
  String get charErrorEmpty;

  /// No description provided for @charErrorShort.
  ///
  /// In es, this message translates to:
  /// **'El nombre necesita al menos 2 letras.'**
  String get charErrorShort;

  /// No description provided for @charKicker.
  ///
  /// In es, this message translates to:
  /// **'TU MENSAJERO'**
  String get charKicker;

  /// No description provided for @charTitle.
  ///
  /// In es, this message translates to:
  /// **'Elige quién lleva el mensaje'**
  String get charTitle;

  /// No description provided for @charBody.
  ///
  /// In es, this message translates to:
  /// **'Será tu mensajero principal. Más adelante podrás contratar otros.'**
  String get charBody;

  /// No description provided for @charTypeLabel.
  ///
  /// In es, this message translates to:
  /// **'Tipo de mensajero'**
  String get charTypeLabel;

  /// No description provided for @charNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre del mensajero'**
  String get charNameLabel;

  /// No description provided for @charNameHintMale.
  ///
  /// In es, this message translates to:
  /// **'Ej: Marcus, Lucius...'**
  String get charNameHintMale;

  /// No description provided for @charNameHintFemale.
  ///
  /// In es, this message translates to:
  /// **'Ej: Julia, Livia...'**
  String get charNameHintFemale;

  /// No description provided for @charStarting.
  ///
  /// In es, this message translates to:
  /// **'Comenzando...'**
  String get charStarting;

  /// No description provided for @charStart.
  ///
  /// In es, this message translates to:
  /// **'COMENZAR LA AVENTURA'**
  String get charStart;

  /// No description provided for @charMale.
  ///
  /// In es, this message translates to:
  /// **'HOMBRE'**
  String get charMale;

  /// No description provided for @charFemale.
  ///
  /// In es, this message translates to:
  /// **'MUJER'**
  String get charFemale;

  /// No description provided for @charPreviewLine.
  ///
  /// In es, this message translates to:
  /// **'{gender} · Correo · Rango 1'**
  String charPreviewLine(String gender);

  /// No description provided for @statHealth.
  ///
  /// In es, this message translates to:
  /// **'Salud'**
  String get statHealth;

  /// No description provided for @statFatigue.
  ///
  /// In es, this message translates to:
  /// **'Fatiga'**
  String get statFatigue;

  /// No description provided for @homeSpotlightTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu puesto de correo'**
  String get homeSpotlightTitle;

  /// No description provided for @homeSpotlightBody.
  ///
  /// In es, this message translates to:
  /// **'Aquí ves a tus mensajeros, el progreso de cada misión y el tablón del Gremio. Las rutas cortas caben en una tarde; las largas siguen mientras duermes.'**
  String get homeSpotlightBody;

  /// No description provided for @homeRosterEvent.
  ///
  /// In es, this message translates to:
  /// **'Evento'**
  String get homeRosterEvent;

  /// No description provided for @homeRosterOnRoad.
  ///
  /// In es, this message translates to:
  /// **'En camino'**
  String get homeRosterOnRoad;

  /// No description provided for @homeRosterInjured.
  ///
  /// In es, this message translates to:
  /// **'Herido'**
  String get homeRosterInjured;

  /// No description provided for @homeRosterFree.
  ///
  /// In es, this message translates to:
  /// **'Libre'**
  String get homeRosterFree;

  /// No description provided for @homeAwayHeader.
  ///
  /// In es, this message translates to:
  /// **'PASÓ MIENTRAS NO ESTABAS'**
  String get homeAwayHeader;

  /// No description provided for @homeAwayLine.
  ///
  /// In es, this message translates to:
  /// **'{messenger} no podía esperar en «{event}»: actuó por instinto y {choice}.'**
  String homeAwayLine(String messenger, String event, String choice);

  /// No description provided for @homeAwayHint.
  ///
  /// In es, this message translates to:
  /// **'Responder a tiempo siempre sale mejor.'**
  String get homeAwayHint;

  /// No description provided for @splashSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Imperio Romano, 50 a.C.'**
  String get splashSubtitle;

  /// No description provided for @storyChip.
  ///
  /// In es, this message translates to:
  /// **'HISTORIA'**
  String get storyChip;

  /// No description provided for @storyStart.
  ///
  /// In es, this message translates to:
  /// **'COMENZAR CAPÍTULO'**
  String get storyStart;

  /// No description provided for @storyLockedSemantics.
  ///
  /// In es, this message translates to:
  /// **'Se abre en rango {rank}, {title}.'**
  String storyLockedSemantics(int rank, String title);

  /// No description provided for @storyLocked.
  ///
  /// In es, this message translates to:
  /// **'Se abre en rango {rank} · {title}'**
  String storyLocked(int rank, String title);

  /// No description provided for @hireSemantics.
  ///
  /// In es, this message translates to:
  /// **'Contratar nuevo mensajero por {cost} aureos'**
  String hireSemantics(int cost);

  /// No description provided for @hireNeedAurei.
  ///
  /// In es, this message translates to:
  /// **'Necesitas {cost} aureos (tienes {have}).'**
  String hireNeedAurei(int cost, int have);

  /// No description provided for @hireTitle.
  ///
  /// In es, this message translates to:
  /// **'Contratar nuevo mensajero'**
  String get hireTitle;

  /// No description provided for @hireSkipsTutorial.
  ///
  /// In es, this message translates to:
  /// **'Salta el tutorial: ya conoce el oficio'**
  String get hireSkipsTutorial;

  /// No description provided for @hireJoined.
  ///
  /// In es, this message translates to:
  /// **'{name} se suma al correo.'**
  String hireJoined(String name);

  /// No description provided for @hireDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Nuevo mensajero'**
  String get hireDialogTitle;

  /// No description provided for @hireConfirm.
  ///
  /// In es, this message translates to:
  /// **'CONTRATAR'**
  String get hireConfirm;

  /// No description provided for @hireDialogBody.
  ///
  /// In es, this message translates to:
  /// **'Ya conoce el oficio. Varus confía en este nuevo correo.'**
  String get hireDialogBody;

  /// No description provided for @hireNameError.
  ///
  /// In es, this message translates to:
  /// **'Ponle un nombre'**
  String get hireNameError;

  /// No description provided for @genderMan.
  ///
  /// In es, this message translates to:
  /// **'Hombre'**
  String get genderMan;

  /// No description provided for @genderWoman.
  ///
  /// In es, this message translates to:
  /// **'Mujer'**
  String get genderWoman;

  /// No description provided for @navShop.
  ///
  /// In es, this message translates to:
  /// **'Tienda'**
  String get navShop;

  /// No description provided for @navProfile.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get navProfile;

  /// No description provided for @navMission.
  ///
  /// In es, this message translates to:
  /// **'Misión'**
  String get navMission;

  /// No description provided for @navNoneOnRoad.
  ///
  /// In es, this message translates to:
  /// **'Ningún mensajero está en camino.'**
  String get navNoneOnRoad;

  /// No description provided for @navPaths.
  ///
  /// In es, this message translates to:
  /// **'Caminos'**
  String get navPaths;

  /// No description provided for @navEventWaiting.
  ///
  /// In es, this message translates to:
  /// **'{label}, hay un evento esperando'**
  String navEventWaiting(String label);

  /// No description provided for @navHomeCurrent.
  ///
  /// In es, this message translates to:
  /// **'Inicio, pantalla actual'**
  String get navHomeCurrent;

  /// No description provided for @navHome.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get navHome;

  /// No description provided for @guildBoardSemantics.
  ///
  /// In es, this message translates to:
  /// **'Tablón del Gremio: {claimed} de {total} cobrados'**
  String guildBoardSemantics(int claimed, int total);

  /// No description provided for @guildBoardHeader.
  ///
  /// In es, this message translates to:
  /// **'TABLÓN DEL GREMIO'**
  String get guildBoardHeader;

  /// No description provided for @guildToday.
  ///
  /// In es, this message translates to:
  /// **'{claimed}/{total} hoy'**
  String guildToday(int claimed, int total);

  /// No description provided for @guildTodayWeek.
  ///
  /// In es, this message translates to:
  /// **'{claimed}/{total} hoy · semana {weekClaimed}/{weekTotal}'**
  String guildTodayWeek(int claimed, int total, int weekClaimed, int weekTotal);

  /// No description provided for @guildClaimCount.
  ///
  /// In es, this message translates to:
  /// **'COBRAR {count}'**
  String guildClaimCount(int count);

  /// No description provided for @guildBoardTitle.
  ///
  /// In es, this message translates to:
  /// **'Tablón del Gremio'**
  String get guildBoardTitle;

  /// No description provided for @guildClaimSemantics.
  ///
  /// In es, this message translates to:
  /// **'Cobrar'**
  String get guildClaimSemantics;

  /// No description provided for @guildClaim.
  ///
  /// In es, this message translates to:
  /// **'COBRAR'**
  String get guildClaim;

  /// No description provided for @guildClaimed.
  ///
  /// In es, this message translates to:
  /// **'COBRADO'**
  String get guildClaimed;

  /// No description provided for @weeklyDone.
  ///
  /// In es, this message translates to:
  /// **'Encargo de {npc} cumplido'**
  String weeklyDone(String npc);

  /// No description provided for @weeklyHeader.
  ///
  /// In es, this message translates to:
  /// **'Encargos de la semana'**
  String get weeklyHeader;

  /// No description provided for @weeklyHint.
  ///
  /// In es, this message translates to:
  /// **'Gente que confía en ti. Se renuevan el lunes.'**
  String get weeklyHint;

  /// No description provided for @contractsHeader.
  ///
  /// In es, this message translates to:
  /// **'Contratos del día'**
  String get contractsHeader;

  /// No description provided for @contractsHint.
  ///
  /// In es, this message translates to:
  /// **'Se renuevan a medianoche.'**
  String get contractsHint;

  /// No description provided for @contractReroll.
  ///
  /// In es, this message translates to:
  /// **'Cambiar este contrato por otro'**
  String get contractReroll;

  /// No description provided for @contractRerolled.
  ///
  /// In es, this message translates to:
  /// **'Contrato cambiado. Mañana puedes volver a hacerlo.'**
  String get contractRerolled;

  /// No description provided for @contractClaimed.
  ///
  /// In es, this message translates to:
  /// **'Contrato cobrado'**
  String get contractClaimed;

  /// No description provided for @guildPayTitle.
  ///
  /// In es, this message translates to:
  /// **'PAGA DEL GREMIO'**
  String get guildPayTitle;

  /// No description provided for @guildPayClaim.
  ///
  /// In es, this message translates to:
  /// **'COBRAR PAGA — DÍA {day}'**
  String guildPayClaim(int day);

  /// No description provided for @guildPayHint.
  ///
  /// In es, this message translates to:
  /// **'Varus premia tu constancia.'**
  String get guildPayHint;

  /// No description provided for @guildPayNote.
  ///
  /// In es, this message translates to:
  /// **'Paga del Gremio · día {day} de racha'**
  String guildPayNote(int day);

  /// No description provided for @slotNoMissionsTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin misiones disponibles'**
  String get slotNoMissionsTitle;

  /// No description provided for @slotNoMissionsBody.
  ///
  /// In es, this message translates to:
  /// **'Completa misiones para desbloquear nuevas rutas.'**
  String get slotNoMissionsBody;

  /// No description provided for @slotViewProfile.
  ///
  /// In es, this message translates to:
  /// **'Ver perfil de {name}'**
  String slotViewProfile(String name);

  /// No description provided for @slotRank.
  ///
  /// In es, this message translates to:
  /// **'{title} · Rango {rank}'**
  String slotRank(String title, int rank);

  /// No description provided for @slotTrial.
  ///
  /// In es, this message translates to:
  /// **'Prueba {n}/{total} de Varus'**
  String slotTrial(int n, int total);

  /// No description provided for @slotEventSemantics.
  ///
  /// In es, this message translates to:
  /// **'Evento pendiente: {event}. Decidir.'**
  String slotEventSemantics(String event);

  /// No description provided for @slotEventPending.
  ///
  /// In es, this message translates to:
  /// **'¡EVENTO PENDIENTE!'**
  String get slotEventPending;

  /// No description provided for @slotDecidesAlone.
  ///
  /// In es, this message translates to:
  /// **'Tu mensajero decidirá solo'**
  String get slotDecidesAlone;

  /// No description provided for @slotDecidesIn.
  ///
  /// In es, this message translates to:
  /// **'Decide solo en {minutes} min'**
  String slotDecidesIn(int minutes);

  /// No description provided for @slotDecide.
  ///
  /// In es, this message translates to:
  /// **'DECIDIR'**
  String get slotDecide;

  /// No description provided for @slotMissionSemantics.
  ///
  /// In es, this message translates to:
  /// **'Misión de {origin} a {destination}. Ver viaje.'**
  String slotMissionSemantics(String origin, String destination);

  /// No description provided for @slotArrived.
  ///
  /// In es, this message translates to:
  /// **'¡Llegó a {place}! Toca para entregar'**
  String slotArrived(String place);

  /// No description provided for @slotProgress.
  ///
  /// In es, this message translates to:
  /// **'{pct}% del camino'**
  String slotProgress(int pct);

  /// No description provided for @slotTrialChip.
  ///
  /// In es, this message translates to:
  /// **'PRUEBA {n}/{total}'**
  String slotTrialChip(int n, int total);

  /// No description provided for @slotAcceptTrial.
  ///
  /// In es, this message translates to:
  /// **'¡ACEPTAR PRUEBA!'**
  String get slotAcceptTrial;

  /// No description provided for @slotRoutesHeader.
  ///
  /// In es, this message translates to:
  /// **'RUTAS DISPONIBLES'**
  String get slotRoutesHeader;

  /// No description provided for @slotSeeAllRoutes.
  ///
  /// In es, this message translates to:
  /// **'VER LAS {count} RUTAS'**
  String slotSeeAllRoutes(int count);

  /// No description provided for @slotRoutesFor.
  ///
  /// In es, this message translates to:
  /// **'Rutas para {name}'**
  String slotRoutesFor(String name);

  /// No description provided for @slotInjuredHeal.
  ///
  /// In es, this message translates to:
  /// **'Herido: cúrate en la tienda'**
  String get slotInjuredHeal;

  /// No description provided for @slotBusy.
  ///
  /// In es, this message translates to:
  /// **'Mensajero ocupado'**
  String get slotBusy;

  /// No description provided for @slotPay.
  ///
  /// In es, this message translates to:
  /// **'Paga ~{amount}'**
  String slotPay(int amount);

  /// No description provided for @slotAcceptMission.
  ///
  /// In es, this message translates to:
  /// **'¡ACEPTAR MISIÓN!'**
  String get slotAcceptMission;

  /// No description provided for @slotConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'Confirmar misión'**
  String get slotConfirmTitle;

  /// No description provided for @slotSetOut.
  ///
  /// In es, this message translates to:
  /// **'SALIR AL CAMINO'**
  String get slotSetOut;

  /// No description provided for @slotDuration.
  ///
  /// In es, this message translates to:
  /// **'Duración: {duration} en tiempo real.'**
  String slotDuration(String duration);

  /// No description provided for @slotNotifTitle.
  ///
  /// In es, this message translates to:
  /// **'Varus te alcanza en la puerta'**
  String get slotNotifTitle;

  /// No description provided for @slotNotifYes.
  ///
  /// In es, this message translates to:
  /// **'AVÍSAME'**
  String get slotNotifYes;

  /// No description provided for @slotNotifNo.
  ///
  /// In es, this message translates to:
  /// **'Prefiero mirar yo'**
  String get slotNotifNo;

  /// No description provided for @slotNotifQuote.
  ///
  /// In es, this message translates to:
  /// **'«El camino toma lo que toma. Cierra los ojos si quieres — yo te aviso si pasa algo.»'**
  String get slotNotifQuote;

  /// No description provided for @slotNotifBody.
  ///
  /// In es, this message translates to:
  /// **'Te avisamos cuando tu mensajero necesite una decisión o llegue a destino. Nada entre las 22 y las 8.'**
  String get slotNotifBody;

  /// No description provided for @onboardingTitle1.
  ///
  /// In es, this message translates to:
  /// **'Roma, 50 a.C.'**
  String get onboardingTitle1;

  /// No description provided for @onboardingBody1.
  ///
  /// In es, this message translates to:
  /// **'El Imperio controla el mundo conocido.\nMillones de personas. Incontables rutas.\nY cada decisión que importa viaja en manos de alguien.'**
  String get onboardingBody1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In es, this message translates to:
  /// **'Tú eres ese alguien.'**
  String get onboardingTitle2;

  /// No description provided for @onboardingBody2.
  ///
  /// In es, this message translates to:
  /// **'Un mensajero. El eslabón entre el poder y sus extremos.\nNadie sabe tu nombre. Nadie necesita saberlo.\nSolo importa que el mensaje llegue.'**
  String get onboardingBody2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In es, this message translates to:
  /// **'El camino no perdona.'**
  String get onboardingTitle3;

  /// No description provided for @onboardingBody3.
  ///
  /// In es, this message translates to:
  /// **'Legionarios. Tormentas. Bandidos. Traidores.\nCada viaje es una prueba.\nCada decisión tiene consecuencias.'**
  String get onboardingBody3;

  /// No description provided for @onboardingTitle4.
  ///
  /// In es, this message translates to:
  /// **'El viaje es real.'**
  String get onboardingTitle4;

  /// No description provided for @onboardingBody4.
  ///
  /// In es, this message translates to:
  /// **'Las misiones duran minutos u horas de verdad.\nEnvías a tu mensajero y sigues con tu día:\nte avisamos cuando haya que decidir.'**
  String get onboardingBody4;

  /// No description provided for @onboardingTitle5.
  ///
  /// In es, this message translates to:
  /// **'¿Estás listo?'**
  String get onboardingTitle5;

  /// No description provided for @onboardingBody5.
  ///
  /// In es, this message translates to:
  /// **'Varus, jefe del correo, quiere ponerte a prueba.\nCuatro encargos cortos.\nNo lo decepciones.'**
  String get onboardingBody5;

  /// No description provided for @onboardingSkip.
  ///
  /// In es, this message translates to:
  /// **'Saltar'**
  String get onboardingSkip;

  /// No description provided for @onboardingSlideSemantics.
  ///
  /// In es, this message translates to:
  /// **'Lámina {n} de {total}'**
  String onboardingSlideSemantics(int n, int total);

  /// No description provided for @onboardingStart.
  ///
  /// In es, this message translates to:
  /// **'¡COMENZAR!'**
  String get onboardingStart;

  /// No description provided for @onboardingNext.
  ///
  /// In es, this message translates to:
  /// **'CONTINUAR'**
  String get onboardingNext;

  /// No description provided for @loginError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo entrar. Inténtalo de nuevo.'**
  String get loginError;

  /// No description provided for @loginRestoreError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo recuperar la partida. Inténtalo de nuevo.'**
  String get loginRestoreError;

  /// No description provided for @loginTagline.
  ///
  /// In es, this message translates to:
  /// **'Roma, 50 a.C. El correo te espera.'**
  String get loginTagline;

  /// No description provided for @loginStart.
  ///
  /// In es, this message translates to:
  /// **'EMPEZAR'**
  String get loginStart;

  /// No description provided for @loginHaveSave.
  ///
  /// In es, this message translates to:
  /// **'Ya tengo partida'**
  String get loginHaveSave;

  /// No description provided for @loginHaveSaveWith.
  ///
  /// In es, this message translates to:
  /// **'Ya tengo partida: {provider}'**
  String loginHaveSaveWith(String provider);

  /// No description provided for @loginNoSignup.
  ///
  /// In es, this message translates to:
  /// **'Sin registrarte. Tu partida se guarda sola.'**
  String get loginNoSignup;

  /// No description provided for @loginNoSignupLink.
  ///
  /// In es, this message translates to:
  /// **'Sin registrarte. Tu partida se guarda sola; en Ajustes puedes vincular una cuenta.'**
  String get loginNoSignupLink;

  /// No description provided for @missionTrialOf.
  ///
  /// In es, this message translates to:
  /// **'Prueba de Varus · {name}'**
  String missionTrialOf(String name);

  /// No description provided for @missionOnRoadOf.
  ///
  /// In es, this message translates to:
  /// **'En camino · {name}'**
  String missionOnRoadOf(String name);

  /// No description provided for @missionArrived.
  ///
  /// In es, this message translates to:
  /// **'¡Llegaste!'**
  String get missionArrived;

  /// No description provided for @missionResolvedHeader.
  ///
  /// In es, this message translates to:
  /// **'EVENTOS RESUELTOS'**
  String get missionResolvedHeader;

  /// No description provided for @missionEtaIn.
  ///
  /// In es, this message translates to:
  /// **'en {time}'**
  String missionEtaIn(String time);

  /// No description provided for @missionEtaImminent.
  ///
  /// In es, this message translates to:
  /// **'inminente'**
  String get missionEtaImminent;

  /// No description provided for @missionNextRevealed.
  ///
  /// In es, this message translates to:
  /// **'PRÓXIMO EVENTO REVELADO'**
  String get missionNextRevealed;

  /// No description provided for @missionArrivedAt.
  ///
  /// In es, this message translates to:
  /// **'Llegaste a {place}'**
  String missionArrivedAt(String place);

  /// No description provided for @missionDeliverHint.
  ///
  /// In es, this message translates to:
  /// **'Entrega el mensaje para cobrar.'**
  String get missionDeliverHint;

  /// No description provided for @missionDeliver.
  ///
  /// In es, this message translates to:
  /// **'ENTREGAR MENSAJE'**
  String get missionDeliver;

  /// No description provided for @missionSkipToEvent.
  ///
  /// In es, this message translates to:
  /// **'Adelantar al próximo evento'**
  String get missionSkipToEvent;

  /// No description provided for @missionSkipToEnd.
  ///
  /// In es, this message translates to:
  /// **'Adelantar al final de la misión'**
  String get missionSkipToEnd;

  /// No description provided for @missionSkipSemantics.
  ///
  /// In es, this message translates to:
  /// **'{label} por {cost} denarios'**
  String missionSkipSemantics(String label, int cost);

  /// No description provided for @missionSkipNoFunds.
  ///
  /// In es, this message translates to:
  /// **'Te faltan denarios para adelantar.'**
  String get missionSkipNoFunds;

  /// No description provided for @missionSkipNoFundsLabel.
  ///
  /// In es, this message translates to:
  /// **'Sin denarios suficientes para adelantar'**
  String get missionSkipNoFundsLabel;

  /// No description provided for @missionSkipped.
  ///
  /// In es, this message translates to:
  /// **'Adelantaste el tiempo (−{cost} denarios)'**
  String missionSkipped(int cost);

  /// No description provided for @missionAdsUsed.
  ///
  /// In es, this message translates to:
  /// **'Ya usaste los {count} adelantos de hoy'**
  String missionAdsUsed(int count);

  /// No description provided for @loading.
  ///
  /// In es, this message translates to:
  /// **'Cargando…'**
  String get loading;

  /// No description provided for @missionWatchAd.
  ///
  /// In es, this message translates to:
  /// **'Ver anuncio · −30 min ({count} hoy)'**
  String missionWatchAd(int count);

  /// No description provided for @adsUnavailable.
  ///
  /// In es, this message translates to:
  /// **'No hay anuncios disponibles ahora. Inténtalo en un rato.'**
  String get adsUnavailable;

  /// No description provided for @missionAdSkipped.
  ///
  /// In es, this message translates to:
  /// **'Adelantaste 30 minutos de camino'**
  String get missionAdSkipped;

  /// No description provided for @missionYouChose.
  ///
  /// In es, this message translates to:
  /// **'Decidiste: {choice}'**
  String missionYouChose(String choice);

  /// No description provided for @eventChip.
  ///
  /// In es, this message translates to:
  /// **'EVENTO'**
  String get eventChip;

  /// No description provided for @missionPaused.
  ///
  /// In es, this message translates to:
  /// **'Progreso pausado'**
  String get missionPaused;

  /// No description provided for @gradeS.
  ///
  /// In es, this message translates to:
  /// **'¡LEGENDARIO!'**
  String get gradeS;

  /// No description provided for @gradeA.
  ///
  /// In es, this message translates to:
  /// **'¡EXCELENTE!'**
  String get gradeA;

  /// No description provided for @gradeB.
  ///
  /// In es, this message translates to:
  /// **'BIEN HECHO'**
  String get gradeB;

  /// No description provided for @gradeC.
  ///
  /// In es, this message translates to:
  /// **'PASABLE'**
  String get gradeC;

  /// No description provided for @gradeF.
  ///
  /// In es, this message translates to:
  /// **'FALLIDO'**
  String get gradeF;

  /// No description provided for @resultTrialChip.
  ///
  /// In es, this message translates to:
  /// **'PRUEBA DE VARUS'**
  String get resultTrialChip;

  /// No description provided for @resultEfficacySuffix.
  ///
  /// In es, this message translates to:
  /// **'% de eficacia'**
  String get resultEfficacySuffix;

  /// No description provided for @resultBackToBase.
  ///
  /// In es, this message translates to:
  /// **'VOLVER AL CUARTEL'**
  String get resultBackToBase;

  /// No description provided for @resultStoryContinues.
  ///
  /// In es, this message translates to:
  /// **'LA HISTORIA CONTINÚA'**
  String get resultStoryContinues;

  /// No description provided for @resultBreakdown.
  ///
  /// In es, this message translates to:
  /// **'DESGLOSE'**
  String get resultBreakdown;

  /// No description provided for @resultPunctuality.
  ///
  /// In es, this message translates to:
  /// **'Puntualidad'**
  String get resultPunctuality;

  /// No description provided for @resultOnTime.
  ///
  /// In es, this message translates to:
  /// **'A tiempo'**
  String get resultOnTime;

  /// No description provided for @resultLate.
  ///
  /// In es, this message translates to:
  /// **'Con retraso'**
  String get resultLate;

  /// No description provided for @resultPackage.
  ///
  /// In es, this message translates to:
  /// **'Estado del paquete'**
  String get resultPackage;

  /// No description provided for @resultDecisions.
  ///
  /// In es, this message translates to:
  /// **'Decisiones'**
  String get resultDecisions;

  /// No description provided for @packageIntact.
  ///
  /// In es, this message translates to:
  /// **'Intacto'**
  String get packageIntact;

  /// No description provided for @packageDamp.
  ///
  /// In es, this message translates to:
  /// **'Humedad leve'**
  String get packageDamp;

  /// No description provided for @packageDamaged.
  ///
  /// In es, this message translates to:
  /// **'Dañado'**
  String get packageDamaged;

  /// No description provided for @packageCompromised.
  ///
  /// In es, this message translates to:
  /// **'Comprometido'**
  String get packageCompromised;

  /// No description provided for @packageLost.
  ///
  /// In es, this message translates to:
  /// **'Perdido'**
  String get packageLost;

  /// No description provided for @decisionsPerfect.
  ///
  /// In es, this message translates to:
  /// **'Decisiones perfectas'**
  String get decisionsPerfect;

  /// No description provided for @decisionsGood.
  ///
  /// In es, this message translates to:
  /// **'Buenas decisiones'**
  String get decisionsGood;

  /// No description provided for @decisionsFair.
  ///
  /// In es, this message translates to:
  /// **'Decisiones regulares'**
  String get decisionsFair;

  /// No description provided for @decisionsBad.
  ///
  /// In es, this message translates to:
  /// **'Malas decisiones'**
  String get decisionsBad;

  /// No description provided for @resultWhatChanged.
  ///
  /// In es, this message translates to:
  /// **'LO QUE CAMBIÓ'**
  String get resultWhatChanged;

  /// No description provided for @resultTitleEarned.
  ///
  /// In es, this message translates to:
  /// **'Ganaste el título «{title}»'**
  String resultTitleEarned(String title);

  /// No description provided for @resultFatigueOnArrival.
  ///
  /// In es, this message translates to:
  /// **'{value} de fatiga al llegar'**
  String resultFatigueOnArrival(int value);

  /// No description provided for @resultFatigueRest.
  ///
  /// In es, this message translates to:
  /// **'{value} de fatiga: {stop}'**
  String resultFatigueRest(int value, String stop);

  /// No description provided for @resultInjured.
  ///
  /// In es, this message translates to:
  /// **'Llegaste herido: descansa antes de salir'**
  String get resultInjured;

  /// No description provided for @resultRepUp.
  ///
  /// In es, this message translates to:
  /// **'{faction} te tiene más en cuenta (+{value})'**
  String resultRepUp(String faction, int value);

  /// No description provided for @resultRepDown.
  ///
  /// In es, this message translates to:
  /// **'{faction} desconfía más de ti ({value})'**
  String resultRepDown(String faction, int value);

  /// No description provided for @resultReward.
  ///
  /// In es, this message translates to:
  /// **'RECOMPENSA'**
  String get resultReward;

  /// No description provided for @resultPayFormula.
  ///
  /// In es, this message translates to:
  /// **'Nota {grade}: {base} × ruta {factor}'**
  String resultPayFormula(String grade, int base, String factor);

  /// No description provided for @resultSuccesses.
  ///
  /// In es, this message translates to:
  /// **'{successes}/{total} exitosos'**
  String resultSuccesses(int successes, int total);

  /// No description provided for @profileNoMessenger.
  ///
  /// In es, this message translates to:
  /// **'Sin mensajero'**
  String get profileNoMessenger;

  /// No description provided for @profileTitle.
  ///
  /// In es, this message translates to:
  /// **'Mi mensajero'**
  String get profileTitle;

  /// No description provided for @profileTabMessenger.
  ///
  /// In es, this message translates to:
  /// **'Mensajero'**
  String get profileTabMessenger;

  /// No description provided for @profileTabWorld.
  ///
  /// In es, this message translates to:
  /// **'Mundo'**
  String get profileTabWorld;

  /// No description provided for @profileTabHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get profileTabHistory;

  /// No description provided for @profileSkills.
  ///
  /// In es, this message translates to:
  /// **'Habilidades'**
  String get profileSkills;

  /// No description provided for @profileSeePaths.
  ///
  /// In es, this message translates to:
  /// **'VER CAMINOS DEL MENSAJERO'**
  String get profileSeePaths;

  /// No description provided for @profileSignOut.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get profileSignOut;

  /// No description provided for @profileCompleted.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 misión completada} other{{count} misiones completadas}}'**
  String profileCompleted(int count);

  /// No description provided for @profilePathDone.
  ///
  /// In es, this message translates to:
  /// **'Camino completado'**
  String get profilePathDone;

  /// No description provided for @profileAscendHint.
  ///
  /// In es, this message translates to:
  /// **'Asciende en los Caminos con Sellos'**
  String get profileAscendHint;

  /// No description provided for @profileXpToNext.
  ///
  /// In es, this message translates to:
  /// **'{xp}/{max} XP para Nv.{level}'**
  String profileXpToNext(int xp, int max, int level);

  /// No description provided for @profileAchSemantics.
  ///
  /// In es, this message translates to:
  /// **'Logros: {done} de {total}. Toca para verlos y elegir tu título.'**
  String profileAchSemantics(int done, int total);

  /// No description provided for @profileAchCount.
  ///
  /// In es, this message translates to:
  /// **'{done} de {total} logros'**
  String profileAchCount(int done, int total);

  /// No description provided for @profileAchNext.
  ///
  /// In es, this message translates to:
  /// **'Próximo: {goal}'**
  String profileAchNext(String goal);

  /// No description provided for @profileReputation.
  ///
  /// In es, this message translates to:
  /// **'Reputación'**
  String get profileReputation;

  /// No description provided for @profileJournal.
  ///
  /// In es, this message translates to:
  /// **'Diario del mensajero'**
  String get profileJournal;

  /// No description provided for @profileJournalEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'El diario está en blanco'**
  String get profileJournalEmptyTitle;

  /// No description provided for @profileJournalEmptyBody.
  ///
  /// In es, this message translates to:
  /// **'Lo que decidas en el camino quedará escrito aquí.'**
  String get profileJournalEmptyBody;

  /// No description provided for @repAllOpen.
  ///
  /// In es, this message translates to:
  /// **'Te abrieron todas las puertas.'**
  String get repAllOpen;

  /// No description provided for @repToNextUnlock.
  ///
  /// In es, this message translates to:
  /// **'Faltan {left} para {tier}: {unlock}'**
  String repToNextUnlock(int left, String tier, String unlock);

  /// No description provided for @repToNext.
  ///
  /// In es, this message translates to:
  /// **'Faltan {left} para {tier}'**
  String repToNext(int left, String tier);

  /// No description provided for @repHowToEarn.
  ///
  /// In es, this message translates to:
  /// **'Se gana entregando bien en sus rutas (una vez por día: +1, o +2 con nota S), cumpliendo encargos y con lo que eliges en el camino.'**
  String get repHowToEarn;

  /// No description provided for @historyEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin misiones completadas aún'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptyBody.
  ///
  /// In es, this message translates to:
  /// **'Acepta tu primera misión desde el Inicio.'**
  String get historyEmptyBody;

  /// No description provided for @signOutTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Cerrar sesión?'**
  String get signOutTitle;

  /// No description provided for @signOutConfirm.
  ///
  /// In es, this message translates to:
  /// **'SALIR'**
  String get signOutConfirm;

  /// No description provided for @signOutBody.
  ///
  /// In es, this message translates to:
  /// **'Tu progreso está guardado en el dispositivo.'**
  String get signOutBody;

  /// No description provided for @skillsTitle.
  ///
  /// In es, this message translates to:
  /// **'Caminos del mensajero'**
  String get skillsTitle;

  /// No description provided for @skillsPicks.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Tienes 1 nivel para elegir} other{Tienes {count} niveles para elegir}}'**
  String skillsPicks(int count);

  /// No description provided for @skillsAppliesTo.
  ///
  /// In es, this message translates to:
  /// **'Se aplica a {name}. Hasta nivel {max}.'**
  String skillsAppliesTo(String name, int max);

  /// No description provided for @skillsIntro.
  ///
  /// In es, this message translates to:
  /// **'Los niveles 1-5 se ganan jugando. Los niveles 6-10 se ascienden con Sellos del Gremio: contratos del día, rachas y notas S. Los Sellos son de la cuenta: los comparten todos tus mensajeros.'**
  String get skillsIntro;

  /// No description provided for @skillLevelOf.
  ///
  /// In es, this message translates to:
  /// **'Nv.{level}/{max}'**
  String skillLevelOf(int level, int max);

  /// No description provided for @skillsPathComplete.
  ///
  /// In es, this message translates to:
  /// **'CAMINO COMPLETADO'**
  String get skillsPathComplete;

  /// No description provided for @skillsNext.
  ///
  /// In es, this message translates to:
  /// **'Siguiente: «{name}» — {perk}'**
  String skillsNext(String name, String perk);

  /// No description provided for @skillsAscent.
  ///
  /// In es, this message translates to:
  /// **'Ascenso: «{name}»'**
  String skillsAscent(String name);

  /// No description provided for @skillsXpCapped.
  ///
  /// In es, this message translates to:
  /// **'La experiencia ya no sube este camino: de aquí en adelante van Sellos.'**
  String get skillsXpCapped;

  /// No description provided for @skillsAscend.
  ///
  /// In es, this message translates to:
  /// **'ASCENDER — {cost} SELLOS'**
  String skillsAscend(int cost);

  /// No description provided for @skillsNeedSeals.
  ///
  /// In es, this message translates to:
  /// **'NECESITAS {cost} SELLOS (tienes {have})'**
  String skillsNeedSeals(int cost, int have);

  /// No description provided for @skillsWhatYouGain.
  ///
  /// In es, this message translates to:
  /// **'QUÉ GANAS'**
  String get skillsWhatYouGain;

  /// No description provided for @skillsLevelUp.
  ///
  /// In es, this message translates to:
  /// **'¡SUBISTE DE NIVEL!'**
  String get skillsLevelUp;

  /// No description provided for @skillsLevelUpLine.
  ///
  /// In es, this message translates to:
  /// **'{skill} Nv.{level} — «{name}»'**
  String skillsLevelUpLine(String skill, int level, String name);

  /// No description provided for @eventSpotlightTitle.
  ///
  /// In es, this message translates to:
  /// **'Una decisión en el camino'**
  String get eventSpotlightTitle;

  /// No description provided for @eventSpotlightBody.
  ///
  /// In es, this message translates to:
  /// **'Cada opción tiene riesgo, costo de tiempo y a veces pide una habilidad. El pronóstico te muestra las probabilidades antes de confirmar.'**
  String get eventSpotlightBody;

  /// No description provided for @eventNoneTitle.
  ///
  /// In es, this message translates to:
  /// **'No hay eventos pendientes'**
  String get eventNoneTitle;

  /// No description provided for @eventNoneBody.
  ///
  /// In es, this message translates to:
  /// **'El camino está tranquilo por ahora.'**
  String get eventNoneBody;

  /// No description provided for @eventBack.
  ///
  /// In es, this message translates to:
  /// **'VOLVER'**
  String get eventBack;

  /// No description provided for @eventWhatDoYouDo.
  ///
  /// In es, this message translates to:
  /// **'¿QUÉ HACES?'**
  String get eventWhatDoYouDo;

  /// No description provided for @eventCritical.
  ///
  /// In es, this message translates to:
  /// **'EVENTO CRÍTICO'**
  String get eventCritical;

  /// No description provided for @eventResolving.
  ///
  /// In es, this message translates to:
  /// **'Resolviendo...'**
  String get eventResolving;

  /// No description provided for @eventPickOption.
  ///
  /// In es, this message translates to:
  /// **'ELIGE UNA OPCIÓN'**
  String get eventPickOption;

  /// No description provided for @eventConfirm.
  ///
  /// In es, this message translates to:
  /// **'CONFIRMAR DECISIÓN'**
  String get eventConfirm;

  /// No description provided for @eventTimeUp.
  ///
  /// In es, this message translates to:
  /// **'SE TE PASÓ'**
  String get eventTimeUp;

  /// No description provided for @eventTimeToDecide.
  ///
  /// In es, this message translates to:
  /// **'Tiempo para decidir: {time}'**
  String eventTimeToDecide(String time);

  /// No description provided for @eventLockedHint.
  ///
  /// In es, this message translates to:
  /// **'Te falta habilidad para esto.'**
  String get eventLockedHint;

  /// No description provided for @eventStoryOpened.
  ///
  /// In es, this message translates to:
  /// **'Tu historia abrió este camino'**
  String get eventStoryOpened;

  /// No description provided for @outcomeSuccess.
  ///
  /// In es, this message translates to:
  /// **'¡ÉXITO!'**
  String get outcomeSuccess;

  /// No description provided for @outcomePartial.
  ///
  /// In es, this message translates to:
  /// **'ÉXITO PARCIAL'**
  String get outcomePartial;

  /// No description provided for @outcomeFail.
  ///
  /// In es, this message translates to:
  /// **'FALLASTE'**
  String get outcomeFail;

  /// No description provided for @outcomeTrialDone.
  ///
  /// In es, this message translates to:
  /// **'¡Varus está satisfecho! Siguiente prueba desbloqueada.'**
  String get outcomeTrialDone;

  /// No description provided for @outcomeMissionDone.
  ///
  /// In es, this message translates to:
  /// **'¡Misión completada! Resultado disponible en tu perfil.'**
  String get outcomeMissionDone;

  /// No description provided for @outcomeHealth.
  ///
  /// In es, this message translates to:
  /// **'{delta} salud'**
  String outcomeHealth(String delta);

  /// No description provided for @outcomeTravelTime.
  ///
  /// In es, this message translates to:
  /// **'+{minutes}m de viaje'**
  String outcomeTravelTime(int minutes);

  /// No description provided for @outcomeXp.
  ///
  /// In es, this message translates to:
  /// **'+{xp} XP de {skill}'**
  String outcomeXp(int xp, String skill);

  /// No description provided for @outcomeJournaled.
  ///
  /// In es, this message translates to:
  /// **'Quedó anotado en tu diario'**
  String get outcomeJournaled;

  /// No description provided for @outcomeRomeRemembers.
  ///
  /// In es, this message translates to:
  /// **'Roma no se olvida de esto'**
  String get outcomeRomeRemembers;

  /// No description provided for @outcomeGoHome.
  ///
  /// In es, this message translates to:
  /// **'IR AL INICIO'**
  String get outcomeGoHome;

  /// No description provided for @whyHeader.
  ///
  /// In es, this message translates to:
  /// **'POR QUÉ PASÓ'**
  String get whyHeader;

  /// No description provided for @whyRoll.
  ///
  /// In es, this message translates to:
  /// **'Tu tirada'**
  String get whyRoll;

  /// No description provided for @whySuccess.
  ///
  /// In es, this message translates to:
  /// **'Con 55 alcanzaba para salir bien parado.'**
  String get whySuccess;

  /// No description provided for @whyPartial.
  ///
  /// In es, this message translates to:
  /// **'Con 55 salía redondo: te faltaron {count}.'**
  String whyPartial(int count);

  /// No description provided for @whyFail.
  ///
  /// In es, this message translates to:
  /// **'Desde 30 era un éxito parcial: te faltaron {count}.'**
  String whyFail(int count);

  /// No description provided for @shopCatBoosters.
  ///
  /// In es, this message translates to:
  /// **'Potenciadores'**
  String get shopCatBoosters;

  /// No description provided for @shopCatSkills.
  ///
  /// In es, this message translates to:
  /// **'Habilidades'**
  String get shopCatSkills;

  /// No description provided for @shopCatAurei.
  ///
  /// In es, this message translates to:
  /// **'Aureos'**
  String get shopCatAurei;

  /// No description provided for @shopCatBundles.
  ///
  /// In es, this message translates to:
  /// **'Paquetes'**
  String get shopCatBundles;

  /// No description provided for @shopItemBoostHealthSmallName.
  ///
  /// In es, this message translates to:
  /// **'Poción de salud'**
  String get shopItemBoostHealthSmallName;

  /// No description provided for @shopItemBoostHealthSmallDesc.
  ///
  /// In es, this message translates to:
  /// **'Restaura 30 puntos de salud al instante.'**
  String get shopItemBoostHealthSmallDesc;

  /// No description provided for @shopItemBoostHealthFullName.
  ///
  /// In es, this message translates to:
  /// **'Curación completa'**
  String get shopItemBoostHealthFullName;

  /// No description provided for @shopItemBoostHealthFullDesc.
  ///
  /// In es, this message translates to:
  /// **'Salud al 100%. Ideal antes de una misión larga.'**
  String get shopItemBoostHealthFullDesc;

  /// No description provided for @shopItemBoostFatigueName.
  ///
  /// In es, this message translates to:
  /// **'Descanso rápido'**
  String get shopItemBoostFatigueName;

  /// No description provided for @shopItemBoostFatigueDesc.
  ///
  /// In es, this message translates to:
  /// **'Elimina toda la fatiga acumulada.'**
  String get shopItemBoostFatigueDesc;

  /// No description provided for @shopItemBoostSpeedName.
  ///
  /// In es, this message translates to:
  /// **'Sandalias de Mercurio'**
  String get shopItemBoostSpeedName;

  /// No description provided for @shopItemBoostSpeedDesc.
  ///
  /// In es, this message translates to:
  /// **'Reduce el tiempo de tu próxima misión un 20%.'**
  String get shopItemBoostSpeedDesc;

  /// No description provided for @shopItemBoostEventsName.
  ///
  /// In es, this message translates to:
  /// **'Mapa del explorador'**
  String get shopItemBoostEventsName;

  /// No description provided for @shopItemBoostEventsDesc.
  ///
  /// In es, this message translates to:
  /// **'Revela el próximo evento de la misión antes de que ocurra.'**
  String get shopItemBoostEventsDesc;

  /// No description provided for @shopItemBoostEventsBlackName.
  ///
  /// In es, this message translates to:
  /// **'Mapa del contrabandista'**
  String get shopItemBoostEventsBlackName;

  /// No description provided for @shopItemBoostEventsBlackDesc.
  ///
  /// In es, this message translates to:
  /// **'El mapa de la Viuda: revela el próximo evento de tu próxima misión.'**
  String get shopItemBoostEventsBlackDesc;

  /// No description provided for @shopItemSkillSpeed1Name.
  ///
  /// In es, this message translates to:
  /// **'Manual de velocidad I'**
  String get shopItemSkillSpeed1Name;

  /// No description provided for @shopItemSkillSpeed1Desc.
  ///
  /// In es, this message translates to:
  /// **'Sube Velocidad un nivel (hasta 5). Más rápido en el camino.'**
  String get shopItemSkillSpeed1Desc;

  /// No description provided for @shopItemSkillStealth1Name.
  ///
  /// In es, this message translates to:
  /// **'Tratado de sigilo I'**
  String get shopItemSkillStealth1Name;

  /// No description provided for @shopItemSkillStealth1Desc.
  ///
  /// In es, this message translates to:
  /// **'Sube Sigilo un nivel (hasta 5). Evita controles y patrullas.'**
  String get shopItemSkillStealth1Desc;

  /// No description provided for @shopItemSkillCombat1Name.
  ///
  /// In es, this message translates to:
  /// **'Adiestramiento de combate I'**
  String get shopItemSkillCombat1Name;

  /// No description provided for @shopItemSkillCombat1Desc.
  ///
  /// In es, this message translates to:
  /// **'Sube Combate un nivel (hasta 5). Mejora en enfrentamientos.'**
  String get shopItemSkillCombat1Desc;

  /// No description provided for @shopItemSkillSurvival1Name.
  ///
  /// In es, this message translates to:
  /// **'Conocimiento del campo I'**
  String get shopItemSkillSurvival1Name;

  /// No description provided for @shopItemSkillSurvival1Desc.
  ///
  /// In es, this message translates to:
  /// **'Sube Supervivencia un nivel (hasta 5). Aguanta más en ruta.'**
  String get shopItemSkillSurvival1Desc;

  /// No description provided for @shopItemSkillContacts1Name.
  ///
  /// In es, this message translates to:
  /// **'Red de contactos I'**
  String get shopItemSkillContacts1Name;

  /// No description provided for @shopItemSkillContacts1Desc.
  ///
  /// In es, this message translates to:
  /// **'Sube Contactos un nivel (hasta 5). Mejores opciones diplomáticas.'**
  String get shopItemSkillContacts1Desc;

  /// No description provided for @shopItemAureosSmallName.
  ///
  /// In es, this message translates to:
  /// **'Bolsa de Aureos'**
  String get shopItemAureosSmallName;

  /// No description provided for @shopItemAureosSmallDesc.
  ///
  /// In es, this message translates to:
  /// **'50 Aureos para gastar en la tienda.'**
  String get shopItemAureosSmallDesc;

  /// No description provided for @shopItemAureosMediumName.
  ///
  /// In es, this message translates to:
  /// **'Cofre de Aureos'**
  String get shopItemAureosMediumName;

  /// No description provided for @shopItemAureosMediumDesc.
  ///
  /// In es, this message translates to:
  /// **'120 Aureos. El preferido del mensajero veterano.'**
  String get shopItemAureosMediumDesc;

  /// No description provided for @shopItemAureosLargeName.
  ///
  /// In es, this message translates to:
  /// **'Tesoro del Imperio'**
  String get shopItemAureosLargeName;

  /// No description provided for @shopItemAureosLargeDesc.
  ///
  /// In es, this message translates to:
  /// **'300 Aureos. El mejor valor disponible.'**
  String get shopItemAureosLargeDesc;

  /// No description provided for @shopItemAureosMegaName.
  ///
  /// In es, this message translates to:
  /// **'Bóveda Imperial'**
  String get shopItemAureosMegaName;

  /// No description provided for @shopItemAureosMegaDesc.
  ///
  /// In es, this message translates to:
  /// **'800 Aureos + 500 Denarios de bonus.'**
  String get shopItemAureosMegaDesc;

  /// No description provided for @shopItemBundleStarterName.
  ///
  /// In es, this message translates to:
  /// **'Pack del Correo'**
  String get shopItemBundleStarterName;

  /// No description provided for @shopItemBundleStarterDesc.
  ///
  /// In es, this message translates to:
  /// **'30 Aureos + 2.º espacio de mensajero + 2 Sellos. Para empezar con ventaja.'**
  String get shopItemBundleStarterDesc;

  /// No description provided for @shopItemBundleWarriorName.
  ///
  /// In es, this message translates to:
  /// **'Pack del Guerrero'**
  String get shopItemBundleWarriorName;

  /// No description provided for @shopItemBundleWarriorDesc.
  ///
  /// In es, this message translates to:
  /// **'Sube 2 niveles de habilidad a tu elección + 50 Aureos.'**
  String get shopItemBundleWarriorDesc;

  /// No description provided for @shopItemSealSingleName.
  ///
  /// In es, this message translates to:
  /// **'Sello del Gremio'**
  String get shopItemSealSingleName;

  /// No description provided for @shopItemSealSingleDesc.
  ///
  /// In es, this message translates to:
  /// **'1 Sello para subir nodos élite del árbol (niveles 6-10).'**
  String get shopItemSealSingleDesc;

  /// No description provided for @shopItemSealPack10Name.
  ///
  /// In es, this message translates to:
  /// **'Paquete de 10 Sellos'**
  String get shopItemSealPack10Name;

  /// No description provided for @shopItemSealPack10Desc.
  ///
  /// In es, this message translates to:
  /// **'10 Sellos del Gremio. Ahorras 30 Aureos frente a comprarlos de uno en uno.'**
  String get shopItemSealPack10Desc;

  /// No description provided for @shopPending.
  ///
  /// In es, this message translates to:
  /// **'La compra quedó pendiente. Se acredita sola cuando la tienda la confirme.'**
  String get shopPending;

  /// No description provided for @shopCanceled.
  ///
  /// In es, this message translates to:
  /// **'Compra cancelada.'**
  String get shopCanceled;

  /// No description provided for @shopStartFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo iniciar la compra.'**
  String get shopStartFailed;

  /// No description provided for @shopNoResponse.
  ///
  /// In es, this message translates to:
  /// **'La tienda no respondió. Prueba de nuevo en un rato.'**
  String get shopNoResponse;

  /// No description provided for @shopStoreUnavailable.
  ///
  /// In es, this message translates to:
  /// **'La tienda no está disponible ahora. Prueba de nuevo en un rato.'**
  String get shopStoreUnavailable;

  /// No description provided for @shopFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo completar la compra. Si se cobró, se acredita sola la próxima vez que abras el juego.'**
  String get shopFailed;

  /// No description provided for @shopSpotlightTitle.
  ///
  /// In es, this message translates to:
  /// **'La tienda del Gremio'**
  String get shopSpotlightTitle;

  /// No description provided for @shopSpotlightBody.
  ///
  /// In es, this message translates to:
  /// **'Denarios para el día a día. Aureos para acelerar. Sellos para el árbol élite. Nada es pay-to-win destructivo: pagar acelera, no reemplaza jugar.'**
  String get shopSpotlightBody;

  /// No description provided for @shopEffectHealthSmall.
  ///
  /// In es, this message translates to:
  /// **'+30 de salud'**
  String get shopEffectHealthSmall;

  /// No description provided for @shopEffectHealthFull.
  ///
  /// In es, this message translates to:
  /// **'Salud restaurada al 100%'**
  String get shopEffectHealthFull;

  /// No description provided for @shopEffectFatigue.
  ///
  /// In es, this message translates to:
  /// **'Fatiga eliminada'**
  String get shopEffectFatigue;

  /// No description provided for @shopEffectSpeed.
  ///
  /// In es, this message translates to:
  /// **'Sandalias listas: tu próxima misión durará 20% menos'**
  String get shopEffectSpeed;

  /// No description provided for @shopEffectMap.
  ///
  /// In es, this message translates to:
  /// **'Mapa listo: tu próxima misión revelará el evento por venir'**
  String get shopEffectMap;

  /// No description provided for @shopEffectSkill.
  ///
  /// In es, this message translates to:
  /// **'¡Habilidad mejorada!'**
  String get shopEffectSkill;

  /// No description provided for @shopEffectApplied.
  ///
  /// In es, this message translates to:
  /// **'Compra aplicada'**
  String get shopEffectApplied;

  /// No description provided for @shopUnavailable.
  ///
  /// In es, this message translates to:
  /// **'Este producto todavía no está disponible.'**
  String get shopUnavailable;

  /// No description provided for @shopSandbox.
  ///
  /// In es, this message translates to:
  /// **'{name} (sandbox de prueba)'**
  String shopSandbox(String name);

  /// No description provided for @shopNoDenarii.
  ///
  /// In es, this message translates to:
  /// **'No te alcanzan los Denarios.'**
  String get shopNoDenarii;

  /// No description provided for @shopNoAurei.
  ///
  /// In es, this message translates to:
  /// **'No te alcanzan los Aureos.'**
  String get shopNoAurei;

  /// No description provided for @shopManualAureosTitle.
  ///
  /// In es, this message translates to:
  /// **'Te faltan Denarios'**
  String get shopManualAureosTitle;

  /// No description provided for @shopManualAureosBody.
  ///
  /// In es, this message translates to:
  /// **'Este manual cuesta {denarios} Denarios. Puedes pagarlo ahora con {aureos} Aureos (tienes {have}).'**
  String shopManualAureosBody(int denarios, int aureos, int have);

  /// No description provided for @shopManualAureosPay.
  ///
  /// In es, this message translates to:
  /// **'Pagar {aureos} Aureos'**
  String shopManualAureosPay(int aureos);

  /// No description provided for @shopTitle.
  ///
  /// In es, this message translates to:
  /// **'TIENDA'**
  String get shopTitle;

  /// No description provided for @shopFor.
  ///
  /// In es, this message translates to:
  /// **'Para:'**
  String get shopFor;

  /// No description provided for @shopMax.
  ///
  /// In es, this message translates to:
  /// **'MÁX'**
  String get shopMax;

  /// No description provided for @shopPlusAurei.
  ///
  /// In es, this message translates to:
  /// **'+{count} Aureos'**
  String shopPlusAurei(int count);

  /// No description provided for @shopLimited.
  ///
  /// In es, this message translates to:
  /// **'TIEMPO LIMITADO'**
  String get shopLimited;

  /// No description provided for @shopTagPopular.
  ///
  /// In es, this message translates to:
  /// **'POPULAR'**
  String get shopTagPopular;

  /// No description provided for @shopTagBestValue.
  ///
  /// In es, this message translates to:
  /// **'MEJOR VALOR'**
  String get shopTagBestValue;

  /// No description provided for @shopTagVip.
  ///
  /// In es, this message translates to:
  /// **'VIP'**
  String get shopTagVip;

  /// No description provided for @shopTagOffer.
  ///
  /// In es, this message translates to:
  /// **'OFERTA'**
  String get shopTagOffer;

  /// No description provided for @shopTagPremium.
  ///
  /// In es, this message translates to:
  /// **'PREMIUM'**
  String get shopTagPremium;

  /// No description provided for @shopTagBlackMarket.
  ///
  /// In es, this message translates to:
  /// **'MERCADO NEGRO'**
  String get shopTagBlackMarket;

  /// No description provided for @shopTagElite.
  ///
  /// In es, this message translates to:
  /// **'ÉLITE'**
  String get shopTagElite;

  /// No description provided for @shopTagPack.
  ///
  /// In es, this message translates to:
  /// **'PACK'**
  String get shopTagPack;

  /// No description provided for @shopBought.
  ///
  /// In es, this message translates to:
  /// **'COMPRADO'**
  String get shopBought;

  /// No description provided for @shopBuyFor.
  ///
  /// In es, this message translates to:
  /// **'Comprar por {price}'**
  String shopBuyFor(String price);

  /// No description provided for @shopBuyButton.
  ///
  /// In es, this message translates to:
  /// **'COMPRAR · {price}'**
  String shopBuyButton(String price);

  /// No description provided for @shopRewardSecondMessenger.
  ///
  /// In es, this message translates to:
  /// **'+2.º mensajero'**
  String get shopRewardSecondMessenger;

  /// No description provided for @shopRewardSkillLevels.
  ///
  /// In es, this message translates to:
  /// **'+2 niveles de habilidad a elección (en Caminos)'**
  String get shopRewardSkillLevels;

  /// No description provided for @settingsLegal.
  ///
  /// In es, this message translates to:
  /// **'Legal'**
  String get settingsLegal;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In es, this message translates to:
  /// **'Política de privacidad'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsTerms.
  ///
  /// In es, this message translates to:
  /// **'Términos de uso'**
  String get settingsTerms;

  /// No description provided for @settingsLinkError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo abrir el enlace.'**
  String get settingsLinkError;

  /// No description provided for @endingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Finales'**
  String get endingsTitle;

  /// No description provided for @endingsCount.
  ///
  /// In es, this message translates to:
  /// **'{found} de {total} finales'**
  String endingsCount(int found, int total);

  /// No description provided for @endingsExplainer.
  ///
  /// In es, this message translates to:
  /// **'Cada arco tiene tres finales. Vuelve a recorrer un arco terminado para buscar los que faltan: tu partida no cambia.'**
  String get endingsExplainer;

  /// No description provided for @endingsArcLocked.
  ///
  /// In es, this message translates to:
  /// **'Termina este arco para ver sus finales.'**
  String get endingsArcLocked;

  /// No description provided for @endingsUnknown.
  ///
  /// In es, this message translates to:
  /// **'Final sin descubrir'**
  String get endingsUnknown;

  /// No description provided for @endingsFoundLabel.
  ///
  /// In es, this message translates to:
  /// **'Encontrado'**
  String get endingsFoundLabel;

  /// No description provided for @endingsReplay.
  ///
  /// In es, this message translates to:
  /// **'Volver a recorrer'**
  String get endingsReplay;

  /// No description provided for @endingsReplayStarted.
  ///
  /// In es, this message translates to:
  /// **'El arco vuelve a empezar: su capítulo te espera en el inicio.'**
  String get endingsReplayStarted;

  /// No description provided for @endingsReplayActive.
  ///
  /// In es, this message translates to:
  /// **'Recorriéndolo de nuevo: capítulo {chapter} de 5.'**
  String endingsReplayActive(int chapter);

  /// No description provided for @endingsAbandon.
  ///
  /// In es, this message translates to:
  /// **'Dejar el recorrido'**
  String get endingsAbandon;

  /// No description provided for @endingsAbandoned.
  ///
  /// In es, this message translates to:
  /// **'Dejaste el recorrido. Puedes empezarlo otra vez cuando quieras.'**
  String get endingsAbandoned;

  /// No description provided for @achSeeEndings.
  ///
  /// In es, this message translates to:
  /// **'Ver los finales'**
  String get achSeeEndings;

  /// No description provided for @storyReplayTag.
  ///
  /// In es, this message translates to:
  /// **'Nuevo recorrido'**
  String get storyReplayTag;

  /// No description provided for @resultEndingNew.
  ///
  /// In es, this message translates to:
  /// **'Final nuevo'**
  String get resultEndingNew;

  /// No description provided for @resultSeeEndings.
  ///
  /// In es, this message translates to:
  /// **'Ver los finales'**
  String get resultSeeEndings;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
