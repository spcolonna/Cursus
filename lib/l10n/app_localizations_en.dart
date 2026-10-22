// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystem => 'Phone default';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageEnglish => 'English';

  @override
  String get notifChannelName => 'The road';

  @override
  String get notifChannelDescription =>
      'Alerts for road events and finished deliveries.';

  @override
  String get notifEventTitle => 'Something happened on the road';

  @override
  String notifEventBody(String messenger, String event) {
    return '$messenger needs a decision: $event.';
  }

  @override
  String get notifDeliveryTitle => 'Your delivery is ready';

  @override
  String notifDeliveryBody(String messenger, String place) {
    return '$messenger has reached $place. Hand over the message.';
  }

  @override
  String get notifIdleTitle => 'The road is waiting';

  @override
  String notifIdleBody(String messenger) {
    return '$messenger has no job. There are routes on the board.';
  }

  @override
  String get notifContractsTitle => 'Guild contracts';

  @override
  String get notifContractsBody =>
      'Some contracts are still unclaimed. They expire at midnight.';

  @override
  String get notifTestTitle => 'Courier test';

  @override
  String get notifTestBody => 'If you can read this, alerts are working.';

  @override
  String get riskEasy => 'EASY';

  @override
  String get riskLow => 'LOW';

  @override
  String get riskMedium => 'MEDIUM';

  @override
  String get riskHigh => 'HIGH';

  @override
  String get riskExtreme => 'EXTREME';

  @override
  String skillLevelShort(int level) {
    return 'Lv.$level';
  }

  @override
  String currencyDenarii(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'denarii',
      one: 'denarius',
    );
    return '$_temp0';
  }

  @override
  String currencyAurei(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'aurei',
      one: 'aureus',
    );
    return '$_temp0';
  }

  @override
  String currencySeals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Seals',
      one: 'Guild Seal',
    );
    return '$_temp0';
  }

  @override
  String gradeSemantics(String grade) {
    return 'Grade $grade';
  }

  @override
  String get updateTitle => 'A new version is out';

  @override
  String get updateBody =>
      'Update Cursus to keep making deliveries. Your game is saved.';

  @override
  String get updateButton => 'Update';

  @override
  String get achKindRoad => 'The road';

  @override
  String get achKindGrade => 'Perfect deliveries';

  @override
  String get achKindGuild => 'The Guild';

  @override
  String get achKindSkill => 'Craft';

  @override
  String get achKindStory => 'Story';

  @override
  String get achKindEmpire => 'Fortune';

  @override
  String titleEquippedSemantics(String title) {
    return '$title, equipped';
  }

  @override
  String skillNodeSemantics(String skill, int level, int max) {
    return '$skill, level $level of $max';
  }

  @override
  String get celebAchievementHeader => 'ACHIEVEMENT UNLOCKED';

  @override
  String celebAchievementSemantics(String name) {
    return 'Achievement unlocked: $name. Tap to see your achievements.';
  }

  @override
  String rewardDenarii(int count) {
    return '+$count denarii';
  }

  @override
  String rewardSeals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count Seals',
      one: '+1 Seal',
    );
    return '$_temp0';
  }

  @override
  String quotedTitle(String title) {
    return '“$title”';
  }

  @override
  String get celebTierHeader => 'NEW STANDING';

  @override
  String celebTierSemantics(String faction, String tier) {
    return '$faction now sees you as $tier. Tap to see your reputation.';
  }

  @override
  String get celebRankHeader => 'NEW RANK!';

  @override
  String get celebContinue => 'CONTINUE';

  @override
  String get rankBlurb2 =>
      'The post office knows your name now.\nRoutes they kept from you are opening up.';

  @override
  String get rankBlurb3 =>
      'They trust you with what can\'t be lost.\nNo one sends you on errands anymore.';

  @override
  String get rankBlurb4 =>
      'Other messengers ask for your advice.\nRome is starting to notice you.';

  @override
  String get rankBlurb5 =>
      'Your name is spoken at way stations across the Empire.';

  @override
  String get firstStepsRoute => 'Finish your first real route';

  @override
  String get firstStepsBuy => 'Buy an item in the shop';

  @override
  String get firstStepsSkill => 'Level up a skill';

  @override
  String get firstStepsGuild => 'Check the Guild board';

  @override
  String get firstStepsNotifs => 'Turn on notifications';

  @override
  String get firstStepsTitle => 'FIRST STEPS';

  @override
  String get firstStepsClaim => 'CLAIM · 3 aurei + 1 Seal';

  @override
  String get firstStepsHint => 'Finish all 5 tasks to earn 3 aurei + 1 Seal.';

  @override
  String get gotIt => 'GOT IT';

  @override
  String get cloudConflictTitle => 'You have two saves';

  @override
  String get cloudUseRemote => 'USE THE CLOUD SAVE';

  @override
  String get cloudUseLocal => 'Use this phone\'s save';

  @override
  String get cloudConflictBody => 'The one you don\'t pick is lost.';

  @override
  String get cloudLabel => 'Cloud';

  @override
  String get cloudThisPhone => 'This phone';

  @override
  String cloudDeliveries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count deliveries',
      one: '1 delivery',
    );
    return '$_temp0';
  }

  @override
  String get agoNow => 'just now';

  @override
  String agoMinutes(int count) {
    return '$count min ago';
  }

  @override
  String agoHours(int count) {
    return '$count h ago';
  }

  @override
  String get agoYesterday => 'yesterday';

  @override
  String agoDays(int count) {
    return '$count days ago';
  }

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get cloudLinked => 'Account linked. Your game is safe.';

  @override
  String get cloudLinkFailed => 'Couldn\'t link. Try again.';

  @override
  String get cloudDeleteFailed =>
      'Couldn\'t delete the account. Check your connection and try again.';

  @override
  String cloudLinkedWith(String providers) {
    return 'Linked with $providers. You can recover your game on another phone.';
  }

  @override
  String get listAnd => ' and ';

  @override
  String get cloudLinkPrompt =>
      'Link an account so you keep your game if you change phones.';

  @override
  String get cloudDeleteAccount => 'Delete account and data';

  @override
  String get cloudStatusLocal => 'Your game is saved on this phone.';

  @override
  String get cloudStatusSyncing => 'Saving to the cloud…';

  @override
  String get cloudStatusSynced => 'Game saved to the cloud.';

  @override
  String cloudStatusSyncedAgo(String ago) {
    return 'Game saved to the cloud $ago.';
  }

  @override
  String get cloudStatusOffline =>
      'Offline: saved on the phone, uploaded when you\'re back online.';

  @override
  String get cloudDeleteTitle => 'Delete everything?';

  @override
  String get cloudDeleteConfirm => 'DELETE FOREVER';

  @override
  String get cancel => 'Cancel';

  @override
  String get cloudDeleteBody =>
      'Your account, messengers, progress and coins are deleted, on this phone and in the cloud. This can\'t be undone.';

  @override
  String get back => 'Back';

  @override
  String get close => 'Close';

  @override
  String get errorGeneric =>
      'Something got stuck on the road. Try again in a moment.';

  @override
  String get errorLoadTitle => 'We couldn\'t load this';

  @override
  String get retry => 'RETRY';

  @override
  String get unlocked => 'Unlocked';

  @override
  String requiresTier(String tier) {
    return 'Needs $tier';
  }

  @override
  String get open => 'Open';

  @override
  String get brandTagline => 'Letters from Rome';

  @override
  String routeMapSemantics(String origin, String destination) {
    return 'Route map from $origin to $destination';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAlertsHeader => 'ROAD ALERTS';

  @override
  String get settingsSoundHeader => 'SOUND AND MOTION';

  @override
  String get settingsUsageHeader => 'USAGE DATA';

  @override
  String get settingsAccountHeader => 'ACCOUNT';

  @override
  String get settingsSkyHeader => 'SKY (DEBUG ONLY)';

  @override
  String get settingsDiagnosticsHeader => 'DIAGNOSTICS';

  @override
  String get settingsAlertsToggle => 'Get alerts';

  @override
  String get settingsAlertsToggleHint =>
      'Never between 10 p.m. and 8 a.m., except for an event on a delivery already underway. 4 a day at most.';

  @override
  String get permGranted => 'Granted';

  @override
  String get permDenied => 'Denied';

  @override
  String get permNotRequested => 'Not asked yet';

  @override
  String get permSystemLabel => 'System permission: ';

  @override
  String diagScheduled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alerts scheduled',
      one: '1 alert scheduled',
    );
    return '$_temp0';
  }

  @override
  String get diagIosLimit =>
      'iOS drops anything past 64 pending alerts, so only the next two events of each delivery are scheduled.';

  @override
  String get diagQueueEmpty =>
      'Nothing queued. Accept a delivery to schedule some.';

  @override
  String get diagTest => 'TEST IN 10s';

  @override
  String get diagTestNote => 'Close the app: the alert arrives in 10 seconds.';

  @override
  String get diagReload => 'RELOAD';

  @override
  String get diagCancelAll => 'Cancel all alerts';

  @override
  String get skyDawn => 'Dawn';

  @override
  String get skyDay => 'Day';

  @override
  String get skyDusk => 'Dusk';

  @override
  String get skyNight => 'Night';

  @override
  String skyRealClock(String time, String phase) {
    return 'Real clock: $time · $phase';
  }

  @override
  String skyFixedHour(String time, String phase) {
    return 'Fixed hour: $time · $phase';
  }

  @override
  String get skyClock => 'Clock';

  @override
  String get settingsMusic => 'Music';

  @override
  String get settingsMusicHint =>
      'Lyre and aulos: changes with the hour and on the road';

  @override
  String settingsMusicVolume(int percent) {
    return 'Music volume $percent%';
  }

  @override
  String get settingsSfx => 'Sound effects';

  @override
  String get settingsSfxHint => 'Buttons, results, deliveries and payouts';

  @override
  String get settingsHaptics => 'Vibration';

  @override
  String get settingsHapticsHint => 'A soft tap when you touch and collect';

  @override
  String get settingsReduceMotion => 'Reduced motion';

  @override
  String get settingsReduceMotionHint =>
      'Less motion: short transitions, no shaking';

  @override
  String get usageCopied => 'Data copied. Paste it into a message.';

  @override
  String get usageShare => 'Share statistics';

  @override
  String get usageShareHint =>
      'Which routes you play and when you come back. Anonymous: no name, nothing that identifies you.';

  @override
  String usageSummary(int day, int days, int sessions) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days played',
      one: '1 day played',
    );
    String _temp1 = intl.Intl.pluralLogic(
      sessions,
      locale: localeName,
      other: '$sessions sessions',
      one: '1 session',
    );
    return 'Day $day since you started · $_temp0 · $_temp1';
  }

  @override
  String get usageCopy => 'Copy data for the team';

  @override
  String get usageAdsPrivacy => 'Ad privacy';

  @override
  String get achTitle => 'Achievements & titles';

  @override
  String get achYourTitle => 'Your title';

  @override
  String get achNoTitles =>
      'You haven\'t earned any yet. Titles come from achievements and story endings.';

  @override
  String get achPickTitle => 'Tap one to wear it under your name.';

  @override
  String get achSecret => 'Secret achievement';

  @override
  String get achDone => 'Unlocked';

  @override
  String achProgress(int progress, int target) {
    return 'Progress $progress of $target';
  }

  @override
  String get achSecretHint => 'Follow the story to find it.';

  @override
  String sealsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Seals',
      one: '1 Seal',
    );
    return '$_temp0';
  }

  @override
  String get charErrorEmpty => 'Give your messenger a name.';

  @override
  String get charErrorShort => 'The name needs at least 2 letters.';

  @override
  String get charKicker => 'YOUR MESSENGER';

  @override
  String get charTitle => 'Choose who carries the message';

  @override
  String get charBody =>
      'This is your main messenger. Later on you can hire others.';

  @override
  String get charTypeLabel => 'Messenger type';

  @override
  String get charNameLabel => 'Messenger\'s name';

  @override
  String get charNameHintMale => 'E.g. Marcus, Lucius...';

  @override
  String get charNameHintFemale => 'E.g. Julia, Livia...';

  @override
  String get charStarting => 'Starting...';

  @override
  String get charStart => 'BEGIN THE JOURNEY';

  @override
  String get charMale => 'MAN';

  @override
  String get charFemale => 'WOMAN';

  @override
  String charPreviewLine(String gender) {
    return '$gender · Runner · Rank 1';
  }

  @override
  String get statHealth => 'Health';

  @override
  String get statFatigue => 'Fatigue';

  @override
  String get homeSpotlightTitle => 'Your courier post';

  @override
  String get homeSpotlightBody =>
      'Here you see your messengers, each delivery\'s progress and the Guild board. Short routes fit in an afternoon; long ones keep going while you sleep.';

  @override
  String get homeRosterEvent => 'Event';

  @override
  String get homeRosterOnRoad => 'On the road';

  @override
  String get homeRosterInjured => 'Injured';

  @override
  String get homeRosterFree => 'Free';

  @override
  String get homeAwayHeader => 'WHILE YOU WERE AWAY';

  @override
  String homeAwayLine(String messenger, String event, String choice) {
    return '$messenger couldn\'t wait at “$event”: acted on instinct and chose to $choice.';
  }

  @override
  String get homeAwayHint => 'Answering in time always goes better.';

  @override
  String get splashSubtitle => 'Roman Empire, 50 BC';

  @override
  String get storyChip => 'STORY';

  @override
  String get storyStart => 'START CHAPTER';

  @override
  String storyLockedSemantics(int rank, String title) {
    return 'Opens at rank $rank, $title.';
  }

  @override
  String storyLocked(int rank, String title) {
    return 'Opens at rank $rank · $title';
  }

  @override
  String hireSemantics(int cost) {
    return 'Hire a new messenger for $cost aurei';
  }

  @override
  String hireNeedAurei(int cost, int have) {
    return 'You need $cost aurei (you have $have).';
  }

  @override
  String get hireTitle => 'Hire a new messenger';

  @override
  String get hireSkipsTutorial => 'Skips the tutorial: knows the trade';

  @override
  String hireJoined(String name) {
    return '$name joins the post.';
  }

  @override
  String get hireDialogTitle => 'New messenger';

  @override
  String get hireConfirm => 'HIRE';

  @override
  String get hireDialogBody =>
      'Already knows the trade. Varus trusts this new courier.';

  @override
  String get hireNameError => 'Give them a name';

  @override
  String get genderMan => 'Man';

  @override
  String get genderWoman => 'Woman';

  @override
  String get navShop => 'Shop';

  @override
  String get navProfile => 'Profile';

  @override
  String get navMission => 'Delivery';

  @override
  String get navNoneOnRoad => 'No messenger is on the road.';

  @override
  String get navPaths => 'Paths';

  @override
  String navEventWaiting(String label) {
    return '$label, an event is waiting';
  }

  @override
  String get navHomeCurrent => 'Home, current screen';

  @override
  String get navHome => 'Home';

  @override
  String guildBoardSemantics(int claimed, int total) {
    return 'Guild board: $claimed of $total claimed';
  }

  @override
  String get guildBoardHeader => 'GUILD BOARD';

  @override
  String guildToday(int claimed, int total) {
    return '$claimed/$total today';
  }

  @override
  String guildTodayWeek(
      int claimed, int total, int weekClaimed, int weekTotal) {
    return '$claimed/$total today · week $weekClaimed/$weekTotal';
  }

  @override
  String guildClaimCount(int count) {
    return 'CLAIM $count';
  }

  @override
  String get guildBoardTitle => 'Guild board';

  @override
  String get guildClaimSemantics => 'Claim';

  @override
  String get guildClaim => 'CLAIM';

  @override
  String get guildClaimed => 'CLAIMED';

  @override
  String weeklyDone(String npc) {
    return '$npc\'s commission done';
  }

  @override
  String get weeklyHeader => 'This week\'s commissions';

  @override
  String get weeklyHint => 'People who trust you. New ones on Monday.';

  @override
  String get contractsHeader => 'Today\'s contracts';

  @override
  String get contractsHint => 'New ones at midnight.';

  @override
  String get contractReroll => 'Swap this contract for another';

  @override
  String get contractRerolled =>
      'Contract swapped. You can do it again tomorrow.';

  @override
  String get contractClaimed => 'Contract claimed';

  @override
  String get guildPayTitle => 'GUILD PAY';

  @override
  String guildPayClaim(int day) {
    return 'COLLECT PAY — DAY $day';
  }

  @override
  String get guildPayHint => 'Varus rewards your persistence.';

  @override
  String guildPayNote(int day) {
    return 'Guild pay · day $day of your streak';
  }

  @override
  String get slotNoMissionsTitle => 'No deliveries available';

  @override
  String get slotNoMissionsBody => 'Finish deliveries to unlock new routes.';

  @override
  String slotViewProfile(String name) {
    return 'View $name\'s profile';
  }

  @override
  String slotRank(String title, int rank) {
    return '$title · Rank $rank';
  }

  @override
  String slotTrial(int n, int total) {
    return 'Varus\'s trial $n/$total';
  }

  @override
  String slotEventSemantics(String event) {
    return 'Pending event: $event. Decide.';
  }

  @override
  String get slotEventPending => 'EVENT PENDING!';

  @override
  String get slotDecidesAlone => 'Your messenger will decide alone';

  @override
  String slotDecidesIn(int minutes) {
    return 'Decides alone in $minutes min';
  }

  @override
  String get slotDecide => 'DECIDE';

  @override
  String slotMissionSemantics(String origin, String destination) {
    return 'Delivery from $origin to $destination. View journey.';
  }

  @override
  String slotArrived(String place) {
    return 'Reached $place! Tap to deliver';
  }

  @override
  String slotProgress(int pct) {
    return '$pct% of the way';
  }

  @override
  String slotTrialChip(int n, int total) {
    return 'TRIAL $n/$total';
  }

  @override
  String get slotAcceptTrial => 'ACCEPT TRIAL!';

  @override
  String get slotRoutesHeader => 'AVAILABLE ROUTES';

  @override
  String slotSeeAllRoutes(int count) {
    return 'SEE ALL $count ROUTES';
  }

  @override
  String slotRoutesFor(String name) {
    return 'Routes for $name';
  }

  @override
  String get slotInjuredHeal => 'Injured: heal at the shop';

  @override
  String get slotBusy => 'Messenger busy';

  @override
  String slotPay(int amount) {
    return 'Pays ~$amount';
  }

  @override
  String get slotAcceptMission => 'ACCEPT DELIVERY!';

  @override
  String get slotConfirmTitle => 'Confirm delivery';

  @override
  String get slotSetOut => 'HIT THE ROAD';

  @override
  String slotDuration(String duration) {
    return 'Duration: $duration in real time.';
  }

  @override
  String get slotNotifTitle => 'Varus catches you at the door';

  @override
  String get slotNotifYes => 'LET ME KNOW';

  @override
  String get slotNotifNo => 'I\'ll keep watch myself';

  @override
  String get slotNotifQuote =>
      '“The road takes what it takes. Close your eyes if you like — I\'ll tell you if anything happens.”';

  @override
  String get slotNotifBody =>
      'We\'ll alert you when your messenger needs a decision or arrives. Nothing between 10 p.m. and 8 a.m.';

  @override
  String get onboardingTitle1 => 'Rome, 50 BC';

  @override
  String get onboardingBody1 =>
      'The Empire rules the known world.\nMillions of people. Countless routes.\nAnd every decision that matters travels in someone\'s hands.';

  @override
  String get onboardingTitle2 => 'You are that someone.';

  @override
  String get onboardingBody2 =>
      'A messenger. The link between power and its far reaches.\nNo one knows your name. No one needs to.\nAll that matters is that the message arrives.';

  @override
  String get onboardingTitle3 => 'The road is unforgiving.';

  @override
  String get onboardingBody3 =>
      'Legionaries. Storms. Bandits. Traitors.\nEvery journey is a test.\nEvery decision has consequences.';

  @override
  String get onboardingTitle4 => 'The journey is real.';

  @override
  String get onboardingBody4 =>
      'Deliveries take real minutes or hours.\nSend your messenger off and get on with your day:\nwe\'ll tell you when there\'s a decision to make.';

  @override
  String get onboardingTitle5 => 'Are you ready?';

  @override
  String get onboardingBody5 =>
      'Varus, head of the post, wants to test you.\nFour short jobs.\nDon\'t let him down.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String onboardingSlideSemantics(int n, int total) {
    return 'Slide $n of $total';
  }

  @override
  String get onboardingStart => 'BEGIN!';

  @override
  String get onboardingNext => 'CONTINUE';

  @override
  String get loginError => 'Couldn\'t sign in. Try again.';

  @override
  String get loginRestoreError => 'Couldn\'t restore your game. Try again.';

  @override
  String get loginTagline => 'Rome, 50 BC. The post awaits you.';

  @override
  String get loginStart => 'START';

  @override
  String get loginHaveSave => 'I already have a game';

  @override
  String loginHaveSaveWith(String provider) {
    return 'I have a game: $provider';
  }

  @override
  String get loginNoSignup => 'No sign-up. Your game saves itself.';

  @override
  String get loginNoSignupLink =>
      'No sign-up. Your game saves itself; you can link an account in Settings.';

  @override
  String missionTrialOf(String name) {
    return 'Varus\'s trial · $name';
  }

  @override
  String missionOnRoadOf(String name) {
    return 'On the road · $name';
  }

  @override
  String get missionArrived => 'You made it!';

  @override
  String get missionResolvedHeader => 'RESOLVED EVENTS';

  @override
  String missionEtaIn(String time) {
    return 'in $time';
  }

  @override
  String get missionEtaImminent => 'imminent';

  @override
  String get missionNextRevealed => 'NEXT EVENT REVEALED';

  @override
  String missionArrivedAt(String place) {
    return 'You reached $place';
  }

  @override
  String get missionDeliverHint => 'Hand over the message to get paid.';

  @override
  String get missionDeliver => 'DELIVER MESSAGE';

  @override
  String get missionSkipToEvent => 'Skip to the next event';

  @override
  String get missionSkipToEnd => 'Skip to the end of the journey';

  @override
  String missionSkipSemantics(String label, int cost) {
    return '$label for $cost denarii';
  }

  @override
  String get missionSkipNoFunds => 'Not enough denarii to skip ahead.';

  @override
  String get missionSkipNoFundsLabel => 'Not enough denarii to skip ahead';

  @override
  String missionSkipped(int cost) {
    return 'Time skipped (−$cost denarii)';
  }

  @override
  String missionAdsUsed(int count) {
    return 'You\'ve used all $count skips today';
  }

  @override
  String get loading => 'Loading…';

  @override
  String missionWatchAd(int count) {
    return 'Watch ad · −30 min ($count today)';
  }

  @override
  String get adsUnavailable =>
      'No ads available right now. Try again in a while.';

  @override
  String get missionAdSkipped => 'You skipped 30 minutes of road';

  @override
  String missionYouChose(String choice) {
    return 'You chose: $choice';
  }

  @override
  String get eventChip => 'EVENT';

  @override
  String get missionPaused => 'Progress paused';

  @override
  String get gradeS => 'LEGENDARY!';

  @override
  String get gradeA => 'EXCELLENT!';

  @override
  String get gradeB => 'WELL DONE';

  @override
  String get gradeC => 'PASSABLE';

  @override
  String get gradeF => 'FAILED';

  @override
  String get resultTrialChip => 'VARUS\'S TRIAL';

  @override
  String get resultEfficacySuffix => '% efficiency';

  @override
  String get resultBackToBase => 'BACK TO HEADQUARTERS';

  @override
  String get resultStoryContinues => 'THE STORY CONTINUES';

  @override
  String get resultBreakdown => 'BREAKDOWN';

  @override
  String get resultPunctuality => 'Punctuality';

  @override
  String get resultOnTime => 'On time';

  @override
  String get resultLate => 'Late';

  @override
  String get resultPackage => 'Package condition';

  @override
  String get resultDecisions => 'Decisions';

  @override
  String get packageIntact => 'Intact';

  @override
  String get packageDamp => 'Slightly damp';

  @override
  String get packageDamaged => 'Damaged';

  @override
  String get packageCompromised => 'Compromised';

  @override
  String get packageLost => 'Lost';

  @override
  String get decisionsPerfect => 'Perfect decisions';

  @override
  String get decisionsGood => 'Good decisions';

  @override
  String get decisionsFair => 'Fair decisions';

  @override
  String get decisionsBad => 'Bad decisions';

  @override
  String get resultWhatChanged => 'WHAT CHANGED';

  @override
  String resultTitleEarned(String title) {
    return 'You earned the title “$title”';
  }

  @override
  String resultFatigueOnArrival(int value) {
    return '$value fatigue on arrival';
  }

  @override
  String resultFatigueRest(int value, String stop) {
    return '$value fatigue: $stop';
  }

  @override
  String get resultInjured => 'You arrived injured: rest before heading out';

  @override
  String resultRepUp(String faction, int value) {
    return '$faction thinks more of you (+$value)';
  }

  @override
  String resultRepDown(String faction, int value) {
    return '$faction trusts you less ($value)';
  }

  @override
  String get resultReward => 'REWARD';

  @override
  String resultPayFormula(String grade, int base, String factor) {
    return 'Grade $grade: $base × route $factor';
  }

  @override
  String resultSuccesses(int successes, int total) {
    return '$successes/$total successful';
  }

  @override
  String get profileNoMessenger => 'No messenger';

  @override
  String get profileTitle => 'My messenger';

  @override
  String get profileTabMessenger => 'Messenger';

  @override
  String get profileTabWorld => 'World';

  @override
  String get profileTabHistory => 'History';

  @override
  String get profileSkills => 'Skills';

  @override
  String get profileSeePaths => 'SEE MESSENGER PATHS';

  @override
  String get profileSignOut => 'Sign out';

  @override
  String profileCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count deliveries completed',
      one: '1 delivery completed',
    );
    return '$_temp0';
  }

  @override
  String get profilePathDone => 'Path complete';

  @override
  String get profileAscendHint => 'Ascend in the Paths with Seals';

  @override
  String profileXpToNext(int xp, int max, int level) {
    return '$xp/$max XP to Lv.$level';
  }

  @override
  String profileAchSemantics(int done, int total) {
    return 'Achievements: $done of $total. Tap to see them and pick your title.';
  }

  @override
  String profileAchCount(int done, int total) {
    return '$done of $total achievements';
  }

  @override
  String profileAchNext(String goal) {
    return 'Next: $goal';
  }

  @override
  String get profileReputation => 'Reputation';

  @override
  String get profileJournal => 'Messenger\'s journal';

  @override
  String get profileJournalEmptyTitle => 'The journal is blank';

  @override
  String get profileJournalEmptyBody =>
      'What you decide on the road will be written here.';

  @override
  String get repAllOpen => 'Every door is open to you.';

  @override
  String repToNextUnlock(int left, String tier, String unlock) {
    return '$left more to $tier: $unlock';
  }

  @override
  String repToNext(int left, String tier) {
    return '$left more to $tier';
  }

  @override
  String get repHowToEarn =>
      'Earned by delivering well on their routes (once a day: +1, or +2 with an S), completing commissions, and through your choices on the road.';

  @override
  String get historyEmptyTitle => 'No deliveries completed yet';

  @override
  String get historyEmptyBody => 'Accept your first delivery from Home.';

  @override
  String get signOutTitle => 'Sign out?';

  @override
  String get signOutConfirm => 'SIGN OUT';

  @override
  String get signOutBody => 'Your progress is saved on the device.';

  @override
  String get skillsTitle => 'Messenger paths';

  @override
  String skillsPicks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You have $count levels to assign',
      one: 'You have 1 level to assign',
    );
    return '$_temp0';
  }

  @override
  String skillsAppliesTo(String name, int max) {
    return 'Applies to $name. Up to level $max.';
  }

  @override
  String get skillsIntro =>
      'Levels 1-5 are earned by playing. Levels 6-10 are ascended with Guild Seals: daily contracts, streaks and S grades. Seals belong to your account: all your messengers share them.';

  @override
  String skillLevelOf(int level, int max) {
    return 'Lv.$level/$max';
  }

  @override
  String get skillsPathComplete => 'PATH COMPLETE';

  @override
  String skillsNext(String name, String perk) {
    return 'Next: “$name” — $perk';
  }

  @override
  String skillsAscent(String name) {
    return 'Ascent: “$name”';
  }

  @override
  String get skillsXpCapped =>
      'Experience no longer raises this path: from here on it takes Seals.';

  @override
  String skillsAscend(int cost) {
    return 'ASCEND — $cost SEALS';
  }

  @override
  String skillsNeedSeals(int cost, int have) {
    return 'NEED $cost SEALS (YOU HAVE $have)';
  }

  @override
  String get skillsWhatYouGain => 'WHAT YOU GET';

  @override
  String get skillsLevelUp => 'LEVEL UP!';

  @override
  String skillsLevelUpLine(String skill, int level, String name) {
    return '$skill Lv.$level — “$name”';
  }

  @override
  String get eventSpotlightTitle => 'A decision on the road';

  @override
  String get eventSpotlightBody =>
      'Each option has a risk, a time cost and sometimes needs a skill. The forecast shows your odds before you confirm.';

  @override
  String get eventNoneTitle => 'No pending events';

  @override
  String get eventNoneBody => 'The road is quiet for now.';

  @override
  String get eventBack => 'BACK';

  @override
  String get eventWhatDoYouDo => 'WHAT DO YOU DO?';

  @override
  String get eventCritical => 'CRITICAL EVENT';

  @override
  String get eventResolving => 'Resolving...';

  @override
  String get eventPickOption => 'PICK AN OPTION';

  @override
  String get eventConfirm => 'CONFIRM DECISION';

  @override
  String get eventTimeUp => 'TIME\'S UP';

  @override
  String eventTimeToDecide(String time) {
    return 'Time to decide: $time';
  }

  @override
  String get eventLockedHint => 'You lack the skill for this.';

  @override
  String get eventStoryOpened => 'Your story opened this path';

  @override
  String get outcomeSuccess => 'SUCCESS!';

  @override
  String get outcomePartial => 'PARTIAL SUCCESS';

  @override
  String get outcomeFail => 'YOU FAILED';

  @override
  String get outcomeTrialDone => 'Varus is satisfied! Next trial unlocked.';

  @override
  String get outcomeMissionDone =>
      'Delivery complete! See the result in your profile.';

  @override
  String outcomeHealth(String delta) {
    return '$delta health';
  }

  @override
  String outcomeTravelTime(int minutes) {
    return '+${minutes}m of travel';
  }

  @override
  String outcomeXp(int xp, String skill) {
    return '+$xp $skill XP';
  }

  @override
  String get outcomeJournaled => 'Written in your journal';

  @override
  String get outcomeRomeRemembers => 'Rome won\'t forget this';

  @override
  String get outcomeGoHome => 'GO HOME';

  @override
  String get whyHeader => 'WHY IT HAPPENED';

  @override
  String get whyRoll => 'Your roll';

  @override
  String get whySuccess => '55 was enough to come out well.';

  @override
  String whyPartial(int count) {
    return '55 would have been clean: you were $count short.';
  }

  @override
  String whyFail(int count) {
    return '30 and up was a partial success: you were $count short.';
  }

  @override
  String get shopCatBoosters => 'Boosters';

  @override
  String get shopCatSkills => 'Skills';

  @override
  String get shopCatAurei => 'Aurei';

  @override
  String get shopCatBundles => 'Bundles';

  @override
  String get shopItemBoostHealthSmallName => 'Health potion';

  @override
  String get shopItemBoostHealthSmallDesc => 'Restores 30 health instantly.';

  @override
  String get shopItemBoostHealthFullName => 'Full healing';

  @override
  String get shopItemBoostHealthFullDesc =>
      'Health to 100%. Ideal before a long delivery.';

  @override
  String get shopItemBoostFatigueName => 'Quick rest';

  @override
  String get shopItemBoostFatigueDesc => 'Clears all built-up fatigue.';

  @override
  String get shopItemBoostSpeedName => 'Sandals of Mercury';

  @override
  String get shopItemBoostSpeedDesc =>
      'Cuts your next delivery\'s time by 20%.';

  @override
  String get shopItemBoostEventsName => 'Explorer\'s map';

  @override
  String get shopItemBoostEventsDesc =>
      'Reveals the delivery\'s next event before it happens.';

  @override
  String get shopItemBoostEventsBlackName => 'Smuggler\'s map';

  @override
  String get shopItemBoostEventsBlackDesc =>
      'The Widow\'s map: reveals the next event of your next delivery.';

  @override
  String get shopItemSkillSpeed1Name => 'Speed manual I';

  @override
  String get shopItemSkillSpeed1Desc =>
      'Raises Speed one level (up to 5). Faster on the road.';

  @override
  String get shopItemSkillStealth1Name => 'Stealth treatise I';

  @override
  String get shopItemSkillStealth1Desc =>
      'Raises Stealth one level (up to 5). Slip past checkpoints and patrols.';

  @override
  String get shopItemSkillCombat1Name => 'Combat training I';

  @override
  String get shopItemSkillCombat1Desc =>
      'Raises Combat one level (up to 5). Better in a fight.';

  @override
  String get shopItemSkillSurvival1Name => 'Fieldcraft I';

  @override
  String get shopItemSkillSurvival1Desc =>
      'Raises Survival one level (up to 5). Lasts longer on the route.';

  @override
  String get shopItemSkillContacts1Name => 'Network of contacts I';

  @override
  String get shopItemSkillContacts1Desc =>
      'Raises Contacts one level (up to 5). Better diplomatic options.';

  @override
  String get shopItemAureosSmallName => 'Purse of aurei';

  @override
  String get shopItemAureosSmallDesc => '50 aurei to spend in the shop.';

  @override
  String get shopItemAureosMediumName => 'Chest of aurei';

  @override
  String get shopItemAureosMediumDesc =>
      '120 aurei. The veteran messenger\'s favorite.';

  @override
  String get shopItemAureosLargeName => 'Treasure of the Empire';

  @override
  String get shopItemAureosLargeDesc => '300 aurei. The best value available.';

  @override
  String get shopItemAureosMegaName => 'Imperial vault';

  @override
  String get shopItemAureosMegaDesc => '800 aurei + 500 bonus denarii.';

  @override
  String get shopItemBundleStarterName => 'Courier pack';

  @override
  String get shopItemBundleStarterDesc =>
      '30 aurei + a 2nd messenger slot + 2 Seals. A head start.';

  @override
  String get shopItemBundleWarriorName => 'Warrior pack';

  @override
  String get shopItemBundleWarriorDesc =>
      'Raise 2 skill levels of your choice + 50 aurei.';

  @override
  String get shopItemSealSingleName => 'Guild Seal';

  @override
  String get shopItemSealSingleDesc =>
      '1 Seal to raise elite tree nodes (levels 6-10).';

  @override
  String get shopItemSealPack10Name => 'Pack of 10 Seals';

  @override
  String get shopItemSealPack10Desc =>
      '10 Guild Seals. Save 30 aurei over buying them one at a time.';

  @override
  String get shopPending =>
      'Purchase pending. It will be credited once the store confirms it.';

  @override
  String get shopCanceled => 'Purchase canceled.';

  @override
  String get shopFailed =>
      'The purchase couldn\'t be completed. If you were charged, it will be credited next time you open the game.';

  @override
  String get shopSpotlightTitle => 'The Guild shop';

  @override
  String get shopSpotlightBody =>
      'Denarii for everyday needs. Aurei to speed things up. Seals for the elite tree. Nothing here is pay-to-win: paying speeds you up, it doesn\'t replace playing.';

  @override
  String get shopEffectHealthSmall => '+30 health';

  @override
  String get shopEffectHealthFull => 'Health restored to 100%';

  @override
  String get shopEffectFatigue => 'Fatigue cleared';

  @override
  String get shopEffectSpeed =>
      'Sandals on: your next delivery takes 20% less time';

  @override
  String get shopEffectMap =>
      'Map ready: your next delivery will reveal the coming event';

  @override
  String get shopEffectSkill => 'Skill improved!';

  @override
  String get shopEffectApplied => 'Purchase applied';

  @override
  String get shopUnavailable => 'This product isn\'t available yet.';

  @override
  String shopSandbox(String name) {
    return '$name (test sandbox)';
  }

  @override
  String get shopNoDenarii => 'Not enough denarii.';

  @override
  String get shopNoAurei => 'Not enough aurei.';

  @override
  String get shopManualAureosTitle => 'Not enough denarii';

  @override
  String shopManualAureosBody(int denarios, int aureos, int have) {
    return 'This manual costs $denarios denarii. You can pay $aureos aurei for it now (you have $have).';
  }

  @override
  String shopManualAureosPay(int aureos) {
    return 'Pay $aureos aurei';
  }

  @override
  String get shopTitle => 'SHOP';

  @override
  String get shopFor => 'For:';

  @override
  String get shopMax => 'MAX';

  @override
  String shopPlusAurei(int count) {
    return '+$count aurei';
  }

  @override
  String get shopLimited => 'LIMITED TIME';

  @override
  String get shopTagPopular => 'POPULAR';

  @override
  String get shopTagBestValue => 'BEST VALUE';

  @override
  String get shopTagVip => 'VIP';

  @override
  String get shopTagOffer => 'OFFER';

  @override
  String get shopTagPremium => 'PREMIUM';

  @override
  String get shopTagBlackMarket => 'BLACK MARKET';

  @override
  String get shopTagElite => 'ELITE';

  @override
  String get shopTagPack => 'PACK';

  @override
  String get shopBought => 'BOUGHT';

  @override
  String shopBuyFor(String price) {
    return 'Buy for $price';
  }

  @override
  String shopBuyButton(String price) {
    return 'BUY · $price';
  }

  @override
  String get shopRewardSecondMessenger => '+2nd messenger';

  @override
  String get shopRewardSkillLevels =>
      '+2 skill levels of your choice (in Paths)';

  @override
  String get settingsLegal => 'Legal';

  @override
  String get settingsPrivacyPolicy => 'Privacy policy';

  @override
  String get settingsTerms => 'Terms of use';

  @override
  String get settingsLinkError => 'Couldn\'t open the link.';

  @override
  String get endingsTitle => 'Endings';

  @override
  String endingsCount(int found, int total) {
    return '$found of $total endings';
  }

  @override
  String get endingsExplainer =>
      'Each arc has three endings. Replay a finished arc to find the ones you are missing: your game does not change.';

  @override
  String get endingsArcLocked => 'Finish this arc to see its endings.';

  @override
  String get endingsUnknown => 'Undiscovered ending';

  @override
  String get endingsFoundLabel => 'Found';

  @override
  String get endingsReplay => 'Replay arc';

  @override
  String get endingsReplayStarted =>
      'The arc starts over: its chapter is waiting on the home screen.';

  @override
  String endingsReplayActive(int chapter) {
    return 'Replaying: chapter $chapter of 5.';
  }

  @override
  String get endingsAbandon => 'Leave the replay';

  @override
  String get endingsAbandoned =>
      'You left the replay. You can start it again whenever you like.';

  @override
  String get achSeeEndings => 'See the endings';

  @override
  String get storyReplayTag => 'Replay';

  @override
  String get resultEndingNew => 'New ending';

  @override
  String get resultSeeEndings => 'See the endings';
}
