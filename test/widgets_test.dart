// Smoke tests de los widgets compartidos nuevos.
// No validan estética: validan que pinten sin romper en los casos borde
// (los 4 slots, herido, fatigado, rango 5) y que el contador anime.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:the_messenger/domain/entities/entities.dart';
import 'package:the_messenger/presentation/widgets/messenger_avatar.dart';
import 'package:the_messenger/presentation/widgets/widgets.dart';

Messenger _messenger({
  int slotIndex = 0,
  MessengerGender gender = MessengerGender.male,
  int health = 100,
  int fatigue = 0,
  MessengerStatus status = MessengerStatus.idle,
  Map<SkillType, int>? skills,
}) =>
    Messenger(
      id: 'm$slotIndex',
      name: 'Marcus',
      gender: gender,
      health: health,
      fatigue: fatigue,
      status: status,
      skills: skills ?? {for (final s in SkillType.values) s: 1},
      skillXp: const {},
      completedMissionIds: const [],
      tutorialPhase: 0,
      tutorialMissionIndex: 0,
      tutorialComplete: false,
      slotIndex: slotIndex,
    );

Widget _host(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  group('MessengerAvatar', () {
    testWidgets('pinta los 4 slots sin romper', (tester) async {
      for (var slot = 0; slot < 4; slot++) {
        await tester.pumpWidget(
            _host(MessengerAvatar.from(_messenger(slotIndex: slot), size: 48)));
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('pinta estados extremos: herido, fatigado y rango máximo',
        (tester) async {
      final casos = [
        _messenger(status: MessengerStatus.injured, health: 0),
        _messenger(fatigue: 95),
        _messenger(
            gender: MessengerGender.female,
            skills: {for (final s in SkillType.values) s: 10}),
      ];
      for (final m in casos) {
        await tester.pumpWidget(_host(MessengerAvatar.from(m, size: 64)));
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('un slot fuera de rango cae en una paleta válida',
        (tester) async {
      await tester.pumpWidget(
          _host(MessengerAvatar.from(_messenger(slotIndex: 99), size: 32)));
      expect(tester.takeException(), isNull);
      expect(messengerAccent(99), messengerAccent(3));
    });

    testWidgets('respeta la proporción 1 : 1.2', (tester) async {
      await tester.pumpWidget(_host(
          const MessengerAvatar(gender: MessengerGender.male, size: 50)));
      final box = tester.getSize(find.byType(MessengerAvatar));
      expect(box.width, 50);
      expect(box.height, 60);
    });
  });

  group('CurrencyChip', () {
    testWidgets('cuenta desde el valor anterior al cambiar', (tester) async {
      await tester.pumpWidget(
          _host(const CurrencyChip(type: CurrencyType.denarios, value: 100)));
      expect(find.text('100'), findsOneWidget);

      // Nuevo valor: durante la animación pasa por valores intermedios.
      await tester.pumpWidget(
          _host(const CurrencyChip(type: CurrencyType.denarios, value: 200)));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('200'), findsNothing);
      await tester.pumpAndSettle();
      expect(find.text('200'), findsOneWidget);
    });

    testWidgets('sin animar muestra el valor exacto', (tester) async {
      await tester.pumpWidget(_host(const CurrencyChip(
          type: CurrencyType.seals, value: 7, animate: false)));
      expect(find.text('7'), findsOneWidget);
    });
  });

  group('RewardAmount', () {
    testWidgets('pluraliza y marca el signo', (tester) async {
      await tester.pumpWidget(_host(const Column(children: [
        RewardAmount(type: CurrencyType.denarios, amount: 1),
        RewardAmount(type: CurrencyType.denarios, amount: 50),
        RewardAmount(type: CurrencyType.aureos, amount: -3),
      ])));
      expect(find.text('+1 denario'), findsOneWidget);
      expect(find.text('+50 denarios'), findsOneWidget);
      expect(find.text('−3 aureos'), findsOneWidget);
    });
  });

  group('showRewardToast', () {
    testWidgets('muestra las recompensas y se va solo', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: Builder(builder: (c) {
          ctx = c;
          return const SizedBox();
        })),
      ));

      showRewardToast(
        ctx,
        [
          (type: CurrencyType.denarios, amount: 120),
          (type: CurrencyType.seals, amount: 0), // se ignora
        ],
        note: 'Contrato cobrado',
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('+120 denarios'), findsOneWidget);
      expect(find.text('Contrato cobrado'), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));
      expect(find.text('+120 denarios'), findsNothing);
    });

    testWidgets('sin recompensas ni nota no hace nada', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: Builder(builder: (c) {
          ctx = c;
          return const SizedBox();
        })),
      ));
      showRewardToast(ctx, [(type: CurrencyType.aureos, amount: 0)]);
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
