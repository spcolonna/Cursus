import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Rewarded ads (GDD §6.4). Sin AdMob App ID de producción, usa un diálogo
/// simulado de ~2s para playtests. Cuando haya IDs reales, reemplazar
/// [_showSimulatedAd] por google_mobile_ads RewardedAd.
class RewardedAdsService {
  static const travelSkipCapPerDay = 4;

  /// Muestra un rewarded. Devuelve true si el jugador completó la recompensa.
  Future<bool> showRewarded({
    required BuildContext context,
    required String placement,
  }) async {
    return _showSimulatedAd(context, placement: placement);
  }

  Future<bool> _showSimulatedAd(
    BuildContext context, {
    required String placement,
  }) async {
    if (!context.mounted) return false;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _SimulatedAdDialog(placement: placement),
    );
    return result ?? false;
  }
}

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
