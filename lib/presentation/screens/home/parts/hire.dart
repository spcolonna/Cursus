part of '../home_screen.dart';

// ─── Botón de desbloqueo de nuevo slot ───────────────────────────────────────
class _UnlockSlotButton extends ConsumerStatefulWidget {
  final HomeState state;
  const _UnlockSlotButton({required this.state});

  @override
  ConsumerState<_UnlockSlotButton> createState() => _UnlockSlotButtonState();
}

class _UnlockSlotButtonState extends ConsumerState<_UnlockSlotButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final cost = widget.state.nextSlotCost;
    final payer = widget.state.messenger!;
    final canAfford = payer.aureos >= cost;
    final accent = canAfford ? AppColors.gold : AppColors.textMuted;

    return GameCard(
      borderColor:
          canAfford ? AppColors.gold.withValues(alpha: 0.6) : AppColors.bgLine,
      semanticLabel: 'Contratar nuevo mensajero por $cost aureos',
      onTap: _loading
          ? null
          : canAfford
              ? () => _showUnlockDialog(context)
              : () => showGameSnack(context,
                  'Necesitás $cost aureos (tenés ${payer.aureos}).',
                  isError: true),
      child: Row(children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: canAfford
                ? AppColors.gold.withValues(alpha: 0.15)
                : AppColors.bgCard2,
            borderRadius: BorderRadius.circular(AppRadii.md - 2),
            border: Border.all(
                color: canAfford ? AppColors.gold : AppColors.bgLine, width: 2),
          ),
          child: _loading
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: AppColors.gold))
              : Icon(Icons.person_add, color: accent, size: 24),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Contratar nuevo mensajero',
                style: AppTextStyles.fredoka(14,
                    color: accent, weight: FontWeight.bold)),
            const SizedBox(height: 3),
            Text(
                canAfford
                    ? 'Salta el tutorial — ya conoce el oficio'
                    : 'Necesitás $cost aureos (tenés ${payer.aureos})',
                style: AppTextStyles.bodySmall.copyWith(
                    color: canAfford
                        ? AppColors.textSecondary
                        : AppColors.textMuted)),
          ]),
        ),
        const SizedBox(width: AppSpacing.sm),
        RewardAmount(
            type: CurrencyType.aureos,
            amount: -cost,
            fontSize: 13,
            withLabel: false),
      ]),
    );
  }

  Future<void> _showUnlockDialog(BuildContext context) async {
    final result =
        await showGameDialog<({String name, MessengerGender gender})>(
      context,
      builder: (_) => _NewMessengerDialog(slotIndex: widget.state.slots.length),
    );
    if (result == null || !mounted) return;

    setState(() => _loading = true);
    try {
      await ref.read(homeProvider.notifier).unlockMessengerSlot(
            payer: widget.state.messenger!,
            newName: result.name,
            gender: result.gender,
          );
      AppFeedback.reward();
      if (mounted) {
        showGameSnack(this.context, '${result.name} se suma al correo.');
      }
    } catch (e) {
      if (mounted) showErrorSnack(this.context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

// ─── Dialog para nombrar el nuevo mensajero ───────────────────────────────────
class _NewMessengerDialog extends StatefulWidget {
  /// Slot que va a ocupar: define el color de túnica del retrato.
  final int slotIndex;
  const _NewMessengerDialog({required this.slotIndex});

  @override
  State<_NewMessengerDialog> createState() => _NewMessengerDialogState();
}

class _NewMessengerDialogState extends State<_NewMessengerDialog> {
  final _ctrl = TextEditingController();
  MessengerGender _gender = MessengerGender.male;
  bool _showError = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.sm + 2),
        borderSide: const BorderSide(color: AppColors.bgLine));
    return GameDialog(
      title: 'Nuevo mensajero',
      actions: [
        SizedBox(
          width: double.infinity,
          child: GameButton(
            label: 'CONTRATAR',
            fontSize: 15,
            onTap: () {
              final name = _ctrl.text.trim();
              if (name.isEmpty) {
                setState(() => _showError = true);
                AppFeedback.denied();
                return;
              }
              Navigator.pop(context, (name: name, gender: _gender));
            },
          ),
        ),
        GameButton(
          label: 'Cancelar',
          fontSize: 14,
          variant: GameButtonVariant.secondary,
          onTap: () => Navigator.pop(context),
        ),
      ],
      child: Column(children: [
        AnimatedSwitcher(
          duration: AppMotion.of(context, AppMotion.base),
          transitionBuilder: (child, anim) =>
              ScaleTransition(scale: anim, child: child),
          child: MessengerAvatar(
            key: ValueKey(_gender),
            gender: _gender,
            slotIndex: widget.slotIndex,
            size: 56,
            highlighted: true,
          ),
        ),
        const SizedBox(height: 10),
        Text('Ya conoce el oficio. Varus confía en este nuevo correo.',
            style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.lg),
        TextField(
          controller: _ctrl,
          textCapitalization: TextCapitalization.words,
          style: AppTextStyles.fredoka(15),
          onChanged: (_) {
            if (_showError) setState(() => _showError = false);
          },
          decoration: InputDecoration(
            hintText: 'Nombre del mensajero',
            hintStyle: AppTextStyles.fredoka(14, color: AppColors.textMuted),
            errorText: _showError ? 'Ponele un nombre' : null,
            filled: true,
            fillColor: AppColors.bgCard2,
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(
                borderSide: const BorderSide(color: AppColors.gold, width: 2)),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(children: [
          Expanded(
              child: _GenderOption(
            label: 'Hombre',
            gender: MessengerGender.male,
            slotIndex: widget.slotIndex,
            selected: _gender == MessengerGender.male,
            onTap: () => setState(() => _gender = MessengerGender.male),
          )),
          const SizedBox(width: 10),
          Expanded(
              child: _GenderOption(
            label: 'Mujer',
            gender: MessengerGender.female,
            slotIndex: widget.slotIndex,
            selected: _gender == MessengerGender.female,
            onTap: () => setState(() => _gender = MessengerGender.female),
          )),
        ]),
      ]),
    );
  }
}

class _GenderOption extends StatelessWidget {
  final String label;
  final MessengerGender gender;
  final int slotIndex;
  final bool selected;
  final VoidCallback onTap;
  const _GenderOption(
      {required this.label,
      required this.gender,
      required this.slotIndex,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: selected,
        label: label,
        child: GestureDetector(
          onTap: () {
            AppFeedback.tap();
            onTap();
          },
          child: AnimatedContainer(
            duration: AppMotion.of(context, AppMotion.base),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.gold.withValues(alpha: 0.15)
                  : AppColors.bgCard2,
              borderRadius: BorderRadius.circular(AppRadii.sm + 2),
              border: Border.all(
                  color: selected ? AppColors.gold : AppColors.bgLine,
                  width: selected ? 2 : 1.5),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              MessengerAvatar(gender: gender, slotIndex: slotIndex, size: 34),
              const SizedBox(height: 6),
              Text(label,
                  style: AppTextStyles.fredoka(13,
                      color: selected ? AppColors.gold : AppColors.textMuted,
                      weight: selected ? FontWeight.bold : FontWeight.normal)),
            ]),
          ),
        ),
      );
}
