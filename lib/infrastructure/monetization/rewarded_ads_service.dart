import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Resultado de ofrecer un anuncio recompensado.
enum AdOutcome {
  /// Lo vio entero: corresponde la recompensa.
  rewarded,

  /// Lo cerró antes de tiempo.
  dismissed,

  /// No había anuncio (sin red, sin inventario o sin consentimiento).
  unavailable,
}

/// Ids de AdMob. Los de prueba de Google sirven en debug y hasta tener la
/// cuenta; los reales se pasan al compilar:
/// `--dart-define=ADMOB_REWARDED_IOS=ca-app-pub-…/…`
/// `--dart-define=ADMOB_REWARDED_ANDROID=ca-app-pub-…/…`
class AdUnits {
  static const _testIos = 'ca-app-pub-3940256099942544/1712485313';
  static const _testAndroid = 'ca-app-pub-3940256099942544/5224354917';
  static const _prodIos = String.fromEnvironment('ADMOB_REWARDED_IOS');
  static const _prodAndroid = String.fromEnvironment('ADMOB_REWARDED_ANDROID');

  static String rewarded({required bool ios, bool release = kReleaseMode}) {
    final prod = ios ? _prodIos : _prodAndroid;
    if (release && prod.isNotEmpty) return prod;
    return ios ? _testIos : _testAndroid;
  }
}

/// Rewarded ads (GDD §6.4) con AdMob. Pide el consentimiento (UMP, GDPR) al
/// arrancar, deja un anuncio precargado y, si no hay, en debug muestra un
/// diálogo simulado para poder playtestear.
class RewardedAdsService {
  RewardedAd? _ad;
  bool _ready = false;
  Completer<void>? _loading;

  /// Consentimiento, SDK y primer anuncio. No bloquea el arranque.
  Future<void> init() async {
    if (!(Platform.isIOS || Platform.isAndroid)) return;
    try {
      await _gatherConsent();
      if (!await ConsentInformation.instance.canRequestAds()) {
        debugPrint('Ads: sin consentimiento para pedir anuncios');
        return;
      }
      await MobileAds.instance.initialize();
      _ready = true;
      unawaited(_load());
    } catch (e) {
      debugPrint('Ads init failed: $e');
    }
  }

  /// Muestra el formulario de consentimiento si la región lo exige.
  Future<void> _gatherConsent() {
    final done = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () async {
        await ConsentForm.loadAndShowConsentFormIfRequired((error) {
          if (error != null) debugPrint('Ads consent form: ${error.message}');
          if (!done.isCompleted) done.complete();
        });
      },
      (error) {
        debugPrint('Ads consent info: ${error.message}');
        if (!done.isCompleted) done.complete();
      },
    );
    return done.future.timeout(const Duration(seconds: 20), onTimeout: () {});
  }

  /// Para el ítem de Ajustes: el jugador puede cambiar su elección.
  Future<bool> get privacyOptionsRequired async =>
      await ConsentInformation.instance.getPrivacyOptionsRequirementStatus() ==
      PrivacyOptionsRequirementStatus.required;

  Future<void> showPrivacyOptions() {
    final done = Completer<void>();
    ConsentForm.showPrivacyOptionsForm((error) {
      if (error != null) debugPrint('Ads privacy options: ${error.message}');
      done.complete();
    });
    return done.future;
  }

  Future<void> _load() {
    if (_ad != null || !_ready) return Future.value();
    final pending = _loading;
    if (pending != null) return pending.future;
    final c = _loading = Completer<void>();
    RewardedAd.load(
      adUnitId: AdUnits.rewarded(ios: Platform.isIOS),
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('Ads: rewarded listo');
          _ad = ad;
          _loading = null;
          c.complete();
        },
        onAdFailedToLoad: (error) {
          debugPrint('Ads load failed: ${error.message}');
          _loading = null;
          c.complete();
        },
      ),
    );
    return c.future;
  }

  /// Muestra un rewarded y dice cómo terminó.
  Future<AdOutcome> showRewarded({
    required BuildContext context,
    required String placement,
  }) async {
    if (_ready && _ad == null) {
      await _load().timeout(const Duration(seconds: 8), onTimeout: () {});
    }
    final ad = _ad;
    if (ad == null) {
      if (kDebugMode && context.mounted) {
        return await _showSimulatedAd(context, placement: placement)
            ? AdOutcome.rewarded
            : AdOutcome.dismissed;
      }
      return AdOutcome.unavailable;
    }
    _ad = null;
    final closed = Completer<AdOutcome>();
    var earned = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        closed.complete(earned ? AdOutcome.rewarded : AdOutcome.dismissed);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Ads show failed: ${error.message}');
        ad.dispose();
        closed.complete(AdOutcome.unavailable);
      },
    );
    await ad.show(onUserEarnedReward: (_, __) => earned = true);
    final outcome = await closed.future;
    unawaited(_load()); // el próximo, precargado
    return outcome;
  }

  Future<bool> _showSimulatedAd(
    BuildContext context, {
    required String placement,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _SimulatedAdDialog(placement: placement),
    );
    return result ?? false;
  }
}

/// Solo debug: reemplaza al anuncio cuando AdMob no carga.
class _SimulatedAdDialog extends StatefulWidget {
  final String placement;
  const _SimulatedAdDialog({required this.placement});

  @override
  State<_SimulatedAdDialog> createState() => _SimulatedAdDialogState();
}

class _SimulatedAdDialogState extends State<_SimulatedAdDialog> {
  int _seconds = 2;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _tick();
  }

  Future<void> _tick() async {
    while (_seconds > 0 && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _seconds--);
    }
    if (mounted) setState(() => _done = true);
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFD4A84B);
    const card = Color(0xFF132038);
    return Dialog(
      backgroundColor: card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: gold.withValues(alpha: 0.45), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.play_circle_outline, color: gold, size: 40),
          const SizedBox(height: 12),
          const Text('Anuncio recompensado',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            kDebugMode
                ? 'Simulación de AdMob (${widget.placement}).\nEn producción se muestra el video real.'
                : 'Mirá el anuncio para reclamar la recompensa.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
          ),
          const SizedBox(height: 16),
          if (!_done)
            Text('Listo en $_seconds…',
                style: const TextStyle(color: Color(0xFFE0A020), fontSize: 14))
          else
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(backgroundColor: gold),
                child: const Text('RECLAMAR RECOMPENSA'),
              ),
            ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.55))),
          ),
        ]),
      ),
    );
  }
}
