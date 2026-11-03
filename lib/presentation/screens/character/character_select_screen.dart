import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../feedback/feedback.dart';
import '../../theme/app_theme.dart';
import '../../widgets/components.dart';
import '../../widgets/messenger_avatar.dart';
import '../../providers/providers.dart';
import '../../../domain/entities/entities.dart';
import '../../../l10n/app_localizations.dart';

class CharacterSelectScreen extends ConsumerStatefulWidget {
  const CharacterSelectScreen({super.key});

  @override
  ConsumerState<CharacterSelectScreen> createState() =>
      _CharacterSelectScreenState();
}

class _CharacterSelectScreenState
    extends ConsumerState<CharacterSelectScreen> {
  final _nameController = TextEditingController();
  MessengerGender _gender = MessengerGender.male;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = AppLocalizations.of(context).charErrorEmpty);
      AppFeedback.denied();
      return;
    }
    if (name.length < 2) {
      setState(() => _error = AppLocalizations.of(context).charErrorShort);
      AppFeedback.denied();
      return;
    }
    setState(() { _saving = true; _error = null; });
    try {
      await ref.read(authProvider.notifier).markOnboardingDone();
      final repo = ref.read(messengerRepositoryProvider);
      // Si ya hay mensajero (se volvió acá por error), no se crea otro.
      if ((await repo.getAllMessengers()).isEmpty) {
        await repo.createDefaultWithGender(name, _gender);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        showErrorSnack(context, e);
      }
      return;
    }
    // El home pudo quedar cacheado sin mensajero (p. ej. tras reiniciar la
    // partida): sin esto vuelve a mandar acá.
    ref.invalidate(homeProvider);
    ref.read(cloudSyncProvider).markDirty();
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return GradientScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                l.charKicker,
                style: AppTextStyles.ui(13,
                    color: AppColors.ochreDeep, letterSpacing: 2),
              )
                  .animate().fadeIn(duration: 300.ms),
              const SizedBox(height: 6),
              Text(
                l.charTitle,
                style: AppTextStyles.heading(28),
              ).animate(delay: 100.ms).fadeIn(),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l.charBody,
                style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.inkSoft, fontSize: 15),
              ).animate(delay: 150.ms).fadeIn(),

              const SizedBox(height: 36),

              // Gender selection
              Text(l.charTypeLabel,
                  style: AppTextStyles.ui(14, color: AppColors.inkMuted)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: _GenderCard(
                    gender: MessengerGender.male,
                    selected: _gender == MessengerGender.male,
                    onTap: () => setState(() => _gender = MessengerGender.male),
                  ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.15, end: 0),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _GenderCard(
                    gender: MessengerGender.female,
                    selected: _gender == MessengerGender.female,
                    onTap: () => setState(() => _gender = MessengerGender.female),
                  ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.15, end: 0),
                ),
              ]),

              const SizedBox(height: 32),

              // Name input
              Text(l.charNameLabel,
                  style: AppTextStyles.ui(14, color: AppColors.inkMuted))
                  .animate(delay: 400.ms).fadeIn(),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.paper,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _error != null
                        ? AppColors.cinnabar.withValues(alpha: 0.6)
                        : AppColors.paperLine,
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: _nameController,
                  style: AppTextStyles.heading(18),
                  textCapitalization: TextCapitalization.words,
                  maxLength: 20,
                  decoration: InputDecoration(
                    hintText: _gender == MessengerGender.male
                        ? l.charNameHintMale
                        : l.charNameHintFemale,
                    hintStyle: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.inkMuted),
                    counterText: '',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 12, right: 8),
                      child: MessengerAvatar(gender: _gender, size: 30),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                        minWidth: 52, minHeight: 52),
                  ),
                  // La tarjeta de abajo muestra el nombre mientras se escribe.
                  onChanged: (_) => setState(() => _error = null),
                ),
              )
                  .animate(delay: 450.ms).fadeIn(),

              if (_error != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.cinnabar, size: 16),
                  const SizedBox(width: 6),
                  Text(_error!, style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.ink)),
                ]).animate().shakeX(hz: 4, amount: 3, duration: 300.ms),
              ],

              const SizedBox(height: 32),

              // Preview card
              _PreviewCard(
                name: _nameController.text.trim().isEmpty
                    ? '???'
                    : _nameController.text.trim(),
                gender: _gender,
              )
                  .animate(delay: 500.ms).fadeIn(),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: GameButton(
                  label: _saving
                      ? l.charStarting
                      : l.charStart,
                  fontSize: 18,
                  isLoading: _saving,
                  onTap: _saving ? null : _confirm,
                ),
              )
                  .animate(delay: 600.ms).fadeIn().slideY(begin: 0.1, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Gender Card ──────────────────────────────────────────────────────────────
class _GenderCard extends StatelessWidget {
  final MessengerGender gender;
  final bool selected;
  final VoidCallback onTap;
  const _GenderCard({
    required this.gender,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMale = gender == MessengerGender.male;
    const accentColor = AppColors.ochreDeep;

    return GestureDetector(
      onTap: () {
        AppFeedback.tap();
        onTap();
      },
      child: AnimatedContainer(
        duration: AppMotion.of(context, AppMotion.base),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: selected ? AppGradients.ochreTint : AppGradients.paper,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.ink
                : AppColors.paperLine,
            width: selected ? 2.5 : 1,
          ),
          boxShadow: selected
              ? const [BoxShadow(
              color: AppColors.ink, offset: Offset(3, 3))]
              : const [BoxShadow(
              color: AppColors.shadowSoft, blurRadius: 10, offset: Offset(0, 3))],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          MessengerAvatar(gender: gender, size: 72),
          const SizedBox(height: 12),
          Text(
            isMale
                ? AppLocalizations.of(context).charMale
                : AppLocalizations.of(context).charFemale,
            style: AppTextStyles.ui(13,
                color: selected ? accentColor : AppColors.inkMuted,
                letterSpacing: 1),
          ),
          const SizedBox(height: 4),
          Text(
            gender.label,
            style: AppTextStyles.bodyMedium,
          ),
          if (selected) ...[
            const SizedBox(height: 8),
            Container(
              width: 8, height: 8,
              decoration: const BoxDecoration(
                  color: accentColor, shape: BoxShape.circle),
            ),
          ],
        ]),
      ),
    );
  }
}

// ─── Preview Card ─────────────────────────────────────────────────────────────
class _PreviewCard extends StatelessWidget {
  final String name;
  final MessengerGender gender;
  const _PreviewCard({required this.name, required this.gender});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.paperDeep,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.paperLine, width: 2),
      ),
      child: Row(children: [
        MessengerAvatar(gender: gender, size: 56),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: AppTextStyles.heading(20),
              ),
              const SizedBox(height: 4),
              Text(
                AppLocalizations.of(context).charPreviewLine(gender.label),
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 6),
              Row(children: [
                _miniStat(AppLocalizations.of(context).statHealth, '100',
                    AppColors.verdigris),
                const SizedBox(width: 10),
                _miniStat(AppLocalizations.of(context).statFatigue, '0',
                    AppColors.inkMuted),
              ]),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _miniStat(String label, String value, Color color) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('$label: ', style: AppTextStyles.bodyMedium),
      Text(value, style: AppTextStyles.ui(12, color: color)),
    ],
  );
}
