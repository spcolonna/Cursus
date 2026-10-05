import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../feedback/feedback.dart';
import '../../theme/app_theme.dart';
import '../../widgets/messenger_avatar.dart';
import '../../providers/providers.dart';
import '../../../domain/entities/entities.dart';

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
      setState(() => _error = 'Ponele un nombre a tu mensajero.');
      AppFeedback.denied();
      return;
    }
    if (name.length < 2) {
      setState(() => _error = 'El nombre necesita al menos 2 letras.');
      AppFeedback.denied();
      return;
    }
    setState(() { _saving = true; _error = null; });
    await ref.read(authProvider.notifier).markOnboardingDone();
    await ref.read(messengerRepositoryProvider).createDefaultWithGender(name, _gender);
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'TU MENSAJERO',
                style: AppTextStyles.fredoka(13,
                    color: AppColors.gold, letterSpacing: 2),
              )
                  .animate().fadeIn(duration: 300.ms),
              const SizedBox(height: 6),
              Text(
                'Elegí quién lleva el mensaje',
                style: AppTextStyles.fredoka(28, weight: FontWeight.bold),
              ).animate(delay: 100.ms).fadeIn(),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Va a ser tu mensajero principal. Más adelante vas a poder '
                'contratar otros.',
                style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary, fontSize: 15),
              ).animate(delay: 150.ms).fadeIn(),

              const SizedBox(height: 36),

              // Gender selection
              Text('Tipo de mensajero',
                  style: AppTextStyles.fredoka(14, color: AppColors.textMuted)),
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
              Text('Nombre del mensajero',
                  style: AppTextStyles.fredoka(14, color: AppColors.textMuted))
                  .animate(delay: 400.ms).fadeIn(),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _error != null
                        ? AppColors.red.withValues(alpha: 0.6)
                        : AppColors.gold.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: TextField(
                  controller: _nameController,
                  style: AppTextStyles.fredoka(18),
                  textCapitalization: TextCapitalization.words,
                  maxLength: 20,
                  decoration: InputDecoration(
                    hintText: _gender == MessengerGender.male
                        ? 'Ej: Marcus, Lucius...'
                        : 'Ej: Julia, Livia...',
                    hintStyle: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textMuted),
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
                      color: AppColors.red, size: 16),
                  const SizedBox(width: 6),
                  Text(_error!, style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textPrimary)),
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
                      ? 'Comenzando...'
                      : 'COMENZAR LA AVENTURA',
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
    const accentColor = AppColors.gold;

    return GestureDetector(
      onTap: () {
        AppFeedback.tap();
        onTap();
      },
      child: AnimatedContainer(
        duration: AppMotion.of(context, AppMotion.base),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
            colors: [
              accentColor.withValues(alpha: 0.3),
              accentColor.withValues(alpha: 0.1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
              : const LinearGradient(
              colors: [AppColors.bgCard, AppColors.bgCard2]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? accentColor
                : AppColors.bgLine,
            width: selected ? 3 : 2,
          ),
          boxShadow: selected
              ? [BoxShadow(
              color: accentColor.withValues(alpha: 0.3),
              blurRadius: 16, spreadRadius: 1)]
              : [],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          MessengerAvatar(gender: gender, size: 72),
          const SizedBox(height: 12),
          Text(
            isMale ? 'HOMBRE' : 'MUJER',
            style: AppTextStyles.fredoka(13,
                color: selected ? accentColor : AppColors.textMuted,
                letterSpacing: 1),
          ),
          const SizedBox(height: 4),
          Text(
            isMale ? 'Mensajero' : 'Mensajera',
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
        color: AppColors.bgCard2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bgLine, width: 2),
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
                style: AppTextStyles.fredoka(20, weight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '${gender.label} · Correo · Rank 1',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 6),
              Row(children: [
                _miniStat('Salud', '100', AppColors.green),
                const SizedBox(width: 10),
                _miniStat('Fatiga', '0', AppColors.textMuted),
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
      Text(value, style: AppTextStyles.fredoka(12, color: color)),
    ],
  );
}
