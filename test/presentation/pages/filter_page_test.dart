import 'package:flutter_test/flutter_test.dart';
import 'package:medipedia/domain/entities/medication_filters.dart';
import 'package:medipedia/presentation/pages/filter_page.dart';

import '../../support/widget_test_helpers.dart';

void main() {
  testWidgets('selects filters, navigates categories, and clears selections',
      (tester) async {
    final medicationCubit = await loadedMedicationCubit(
      repository: MemoryMedicationRepository(const []),
    );
    addTearDown(medicationCubit.close);

    await tester.pumpWidget(
      localizedTestApp(
        home: const FilterPage(),
        medicationCubit: medicationCubit,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Choose preferences'), findsOneWidget);
    expect(find.text('Drug type'), findsNWidgets(2));
    expect(find.text('Dosage form'), findsNWidgets(2));
    expect(find.text('How to use'), findsNWidgets(2));
    expect(find.text('Over the counter'), findsOneWidget);

    await tester.tap(find.text('Over the counter'));
    await tester.pump();
    expect(medicationCubit.state.filters.productTypes, ['HUMAN OTC DRUG']);

    await tester.tap(find.text('How to use').first);
    await tester.pumpAndSettle();
    expect(find.text('Oral'), findsOneWidget);
    await tester.tap(find.text('Oral'));
    await tester.pump();
    expect(medicationCubit.state.filters.routes, ['ORAL']);

    await tester.tap(find.text('Clear'));
    await tester.pump();
    expect(medicationCubit.state.filters, MedicationFilters.empty);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
  });
}
