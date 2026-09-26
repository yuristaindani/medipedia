import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medipedia/presentation/pages/splash_page.dart';

import '../../support/widget_test_helpers.dart';

void main() {
  testWidgets('shows MediPedia splash branding and tagline', (tester) async {
    await tester.pumpWidget(localizedTestApp(home: const SplashPage()));
    await tester.pump();

    expect(find.text('Find. Check. Verify.'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });
}
