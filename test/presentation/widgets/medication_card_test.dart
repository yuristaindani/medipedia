import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medipedia/presentation/widgets/medication_card.dart';

import '../../support/widget_test_helpers.dart';

void main() {
  testWidgets('shows formatted medication and toggles favorite',
      (tester) async {
    final repository = MemoryFavoritesRepository();
    final favoritesCubit = await loadedFavoritesCubit(repository: repository);
    addTearDown(favoritesCubit.close);

    await tester.pumpWidget(
      localizedTestApp(
        home: Scaffold(body: MedicationCard(medication: testMedication)),
        favoritesCubit: favoritesCubit,
      ),
    );

    expect(find.text('EXAMPLE BRAND'), findsOneWidget);
    expect(find.byTooltip('Add to favorites'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);

    await tester.tap(find.byTooltip('Add to favorites'));
    await tester.pumpAndSettle();

    expect(repository.savedIds, contains(testMedication.id));
    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });
}
