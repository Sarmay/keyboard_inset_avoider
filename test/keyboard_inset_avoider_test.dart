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
}
