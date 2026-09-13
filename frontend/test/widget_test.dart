import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vier_frontend/app.dart';

void main() {
  testWidgets('Muestra la pantalla de login por defecto', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ProviderScope(child: VierApp()));
    await tester.pumpAndSettle();

    expect(find.text('Vier'), findsOneWidget);
    expect(find.text('Ingresar'), findsOneWidget);
  });
}
