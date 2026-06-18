import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/main.dart';

void main() {
  testWidgets('KickproApp builds', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: KickproApp()));
    await tester.pumpAndSettle();
    expect(find.text('Sign In'), findsOneWidget);
  });
}
