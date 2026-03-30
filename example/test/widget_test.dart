import 'package:flutter_test/flutter_test.dart';
import 'package:keyboard_inset_avoider_example/main.dart';

void main() {
  testWidgets('renders plugin example page', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('keyboard_inset_avoider example'), findsOneWidget);
    expect(find.text('This example uses the plugin without editing MainActivity.'), findsOneWidget);
  });
}
