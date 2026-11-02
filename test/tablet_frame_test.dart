import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_messenger/presentation/widgets/widgets.dart';

Widget _app(Widget home) => MaterialApp(
      builder: (context, child) => TabletFrame(child: child!),
      home: home,
    );

class _Form extends StatefulWidget {
  const _Form();
  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  final ctrl = TextEditingController();
  String saved = '';
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Column(children: [
          TextField(key: const Key('name'), controller: ctrl),
          ElevatedButton(
              onPressed: () => setState(() => saved = ctrl.text),
              child: const Text('OK')),
          Text('saved:$saved'),
          Text('w:${MediaQuery.sizeOf(context).width.round()}'),
        ]),
      );
}

void main() {
  testWidgets('en teléfono no cambia nada', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(const _Form()));
    expect(find.text('w:390'), findsOneWidget);
  });

  testWidgets('en iPad agranda, limita el ancho y los toques llegan',
      (tester) async {
    tester.view.physicalSize = const Size(2064, 2752);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(const _Form()));
    expect(find.text('w:600'), findsOneWidget);

    await tester.tap(find.byKey(const Key('name')));
    await tester.pump();
    tester.view.viewInsets = const FakeViewPadding(bottom: 800);
    await tester.pump();
    await tester.enterText(find.byKey(const Key('name')), 'Marco');
    tester.view.resetViewInsets();
    await tester.pump();
    await tester.tap(find.text('OK'));
    await tester.pump();
    expect(find.text('saved:Marco'), findsOneWidget);
  });
}
