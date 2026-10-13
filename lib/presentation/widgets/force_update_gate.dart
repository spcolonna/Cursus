import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/remote_flags.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

/// La versión instalada (pubspec `version`, sin el número de build).
final appVersionProvider = FutureProvider<String>(
    (_) async => (await PackageInfo.fromPlatform()).version);

/// Si la versión instalada es más vieja que `min_supported_version` (Remote
/// Config), tapa la app con un pedido de actualizar. Sirve para cortar una
/// versión con un bug grave o un cambio de guardado incompatible.
class ForceUpdateGate extends ConsumerWidget {
  final Widget child;
  const ForceUpdateGate({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flags = ref.watch(remoteFlagsProvider);
    final version = ref.watch(appVersionProvider).valueOrNull;
    if (version == null || !flags.requiresUpdate(version)) return child;
    return ForceUpdateScreen(storeUrl: storeUrlFor(flags));
  }
}

String storeUrlFor(RemoteFlags flags) {
  try {
    return Platform.isIOS ? flags.storeUrlIos : flags.storeUrlAndroid;
  } catch (_) {
    return '';
  }
}

class ForceUpdateScreen extends StatelessWidget {
  final String storeUrl;
  const ForceUpdateScreen({super.key, required this.storeUrl});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: GameCard(
              frieze: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.system_update_alt,
                      size: 28, color: AppColors.ink),
                  const SizedBox(height: 12),
                  Text('Hay una versión nueva',
                      style: AppTextStyles.titleLarge,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(
                    'Para seguir con tus entregas necesitás actualizar '
                    'Cursus. Tu partida queda guardada.',
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  if (storeUrl.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    GameButton(
                      label: 'Actualizar',
                      icon: Icons.open_in_new,
                      onTap: () => launchUrl(Uri.parse(storeUrl),
                          mode: LaunchMode.externalApplication),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
