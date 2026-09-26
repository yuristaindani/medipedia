import 'package:flutter_test/flutter_test.dart';
import 'package:medipedia/presentation/pages/medication_detail_page.dart';

import '../../support/widget_test_helpers.dart';

void main() {
  testWidgets('shows available detail sections and omits missing sections',
      (tester) async {
    final medicationCubit = await loadedMedicationCubit();
    final favoritesCubit = await loadedFavoritesCubit();
    final localeCubit = await englishLocaleCubit();
    addTearDown(medicationCubit.close);
    addTearDown(favoritesCubit.close);
    addTearDown(localeCubit.close);

    await tester.pumpWidget(
      localizedTestApp(
        home: MedicationDetailPage(medication: testMedication),
        medicationCubit: medicationCubit,
        favoritesCubit: favoritesCubit,
        localeCubit: localeCubit,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('EXAMPLE BRAND'), findsOneWidget);
    expect(find.text('Indications'), findsOneWidget);
    expect(find.text('Purpose'), findsOneWidget);
    expect(find.text('Active Ingredients'), findsOneWidget);
    expect(find.text('Dosage'), findsOneWidget);
    expect(find.text('Warnings'), findsOneWidget);
    expect(find.text('Pain relief.'), findsOneWidget);
  });
}
