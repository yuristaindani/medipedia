import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medipedia/presentation/pages/favorites_page.dart';

import '../../support/widget_test_helpers.dart';

void main() {
  testWidgets('shows saved favorites', (tester) async {
    final favoritesCubit = await loadedFavoritesCubit(
      initial: const [testMedication],
    );
    addTearDown(favoritesCubit.close);

    await tester.pumpWidget(
      localizedTestApp(
        home: const FavoritesPage(),
        favoritesCubit: favoritesCubit,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('EXAMPLE BRAND'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });

  testWidgets('shows an empty message when there are no favorites',
      (tester) async {
    final favoritesCubit = await loadedFavoritesCubit();
    addTearDown(favoritesCubit.close);

    await tester.pumpWidget(
      localizedTestApp(
        home: const FavoritesPage(),
        favoritesCubit: favoritesCubit,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No favorite medications yet'), findsOneWidget);
  });
}
