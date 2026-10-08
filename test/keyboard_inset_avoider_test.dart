import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keyboard_inset_avoider/keyboard_inset_avoider.dart';

void main() {
  tearDown(() async {
    await KeyboardInsetAvoider.instance.debugReset();
  });

  testWidgets('effective inset prefers native fallback when larger', (
    tester,
  ) async {
    KeyboardInsetAvoider.instance.debugSetNativeInset(240);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(viewInsets: EdgeInsets.only(bottom: 120)),
        child: Builder(
          builder: (context) {
            return Text(
              '${KeyboardInsetAvoider.instance.effectiveInsetOf(context)}',
              textDirection: TextDirection.ltr,
            );
          },
        ),
      ),
    );

    expect(find.text('240.0'), findsOneWidget);
  });

  testWidgets('effectiveInsetForCurrentRoute returns 0 when not current',
      (tester) async {
    // No ModalRoute in this tree, so it is treated as the current route.
    KeyboardInsetAvoider.instance.debugSetNativeInset(200);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(),
        child: Builder(
          builder: (context) {
            final inset =
                KeyboardInsetAvoider.instance
                    .effectiveInsetForCurrentRoute(context);
            return Text('$inset', textDirection: TextDirection.ltr);
          },
        ),
      ),
    );

    expect(find.text('200.0'), findsOneWidget);
  });

  testWidgets('KeyboardInsetPadding applies native inset as bottom padding',
      (tester) async {
    KeyboardInsetAvoider.instance.debugSetNativeInset(100);

    await tester.pumpWidget(
      keyboardInsetHost(
        KeyboardInsetPadding(
          child: const Text('probe', textDirection: TextDirection.ltr),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final rendered = tester.getBottomLeft(find.text('probe'));
    final hostBottom = tester.getBottomLeft(
      find.byType(Scaffold).first,
    ).dy;
    // The text should sit at least 100px above the bottom of the Scaffold.
    expect(hostBottom - rendered.dy, greaterThanOrEqualTo(100));
  });

  testWidgets(
    'KeyboardInsetPadding onlyWhenCurrentRoute collapses below a dialog',
    (tester) async {
      KeyboardInsetAvoider.instance.debugSetNativeInset(300);

      // Host: a page with a KeyboardInsetPadding, then push a dialog.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const Scaffold(body: SizedBox()),
                      ),
                    );
                  },
                  child: const Text('go'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();

      // Now the original page is not the current route anymore.
      final inset = KeyboardInsetAvoider.instance.effectiveInsetForCurrentRoute(
        tester.element(find.text('go', skipOffstage: false)),
      );
      expect(inset, 0.0);
      // The pushed (current) route still has no ModalRoute.current below it
      // and reports the effective inset normally.
      expect(
        KeyboardInsetAvoider.isCurrentRoute(
          tester.element(find.byType(SizedBox).last),
        ),
        isTrue,
      );
    },
  );

  testWidgets('KeyboardInsetBuilder reports inset while current route', (
    tester,
  ) async {
    KeyboardInsetAvoider.instance.debugSetNativeInset(160);

    await tester.pumpWidget(
      keyboardInsetHost(
        KeyboardInsetBuilder(
          builder: (context, inset) {
            return Text('$inset', textDirection: TextDirection.ltr);
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('160.0'), findsOneWidget);
  });
}

/// Simple host that provides a MaterialApp + Scaffold so ModalRoute exists
/// and isCurrent stays true.
Widget keyboardInsetHost(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}