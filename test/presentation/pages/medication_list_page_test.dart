import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medipedia/presentation/pages/medication_list_page.dart';

import '../../support/widget_test_helpers.dart';

void main() {
  testWidgets('shows medicine results and clears a search', (tester) async {
    final repository = MemoryMedicationRepository();
    final medicationCubit = await loadedMedicationCubit(repository: repository);
    final favoritesCubit = await loadedFavoritesCubit();
    final localeCubit = await englishLocaleCubit();
    addTearDown(medicationCubit.close);
    addTearDown(favoritesCubit.close);
    addTearDown(localeCubit.close);

    await tester.pumpWidget(
      localizedTestApp(
        home: const MedicationListPage(),
        medicationCubit: medicationCubit,
        favoritesCubit: favoritesCubit,
        localeCubit: localeCubit,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('EXAMPLE BRAND'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'ibuprofen');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(medicationCubit.state.query, 'ibuprofen');

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump();
    expect(find.byType(TextField), findsOneWidget);
    expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text, '');
    expect(medicationCubit.state.query, '');
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pumpAndSettle();
  });
}
