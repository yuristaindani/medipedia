import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medipedia/data/services/medication_translation_service.dart';
import 'package:medipedia/domain/entities/medication.dart';
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
        home: const MedicationDetailPage(medication: testMedication),
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

  testWidgets('shows translated medical sections in Indonesian',
      (tester) async {
    final medicationCubit = await loadedMedicationCubit();
    final favoritesCubit = await loadedFavoritesCubit();
    final localeCubit = await localeCubitFor('id');
    addTearDown(medicationCubit.close);
    addTearDown(favoritesCubit.close);
    addTearDown(localeCubit.close);

    await tester.pumpWidget(
      RepositoryProvider<MedicationContentTranslator>.value(
        value: _FakeMedicationTranslator(),
        child: localizedTestApp(
          home: const MedicationDetailPage(medication: testMedication),
          medicationCubit: medicationCubit,
          favoritesCubit: favoritesCubit,
          localeCubit: localeCubit,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Indikasi'), findsOneWidget);
    expect(find.text('Tujuan Penggunaan'), findsOneWidget);
    expect(find.text('Bahan Aktif'), findsOneWidget);
    expect(find.text('Informasi Dosis'), findsOneWidget);
    expect(find.text('Peringatan'), findsOneWidget);
    expect(find.text('Untuk meredakan nyeri ringan.'), findsOneWidget);
    expect(find.text('Pereda nyeri.'), findsOneWidget);
    expect(find.text('Ibuprofen 200 mg'), findsOneWidget);
    expect(find.text('Minum satu tablet sesuai petunjuk.'), findsOneWidget);
    expect(find.text('Konsultasikan dengan dokter.'), findsOneWidget);
    expect(find.text('Pain relief.'), findsNothing);
    expect(find.text('example brand'), findsNothing);
    expect(find.text('EXAMPLE BRAND'), findsOneWidget);
  });

  testWidgets('keeps original medical content when translation fails',
      (tester) async {
    final medicationCubit = await loadedMedicationCubit();
    final favoritesCubit = await loadedFavoritesCubit();
    final localeCubit = await localeCubitFor('id');
    addTearDown(medicationCubit.close);
    addTearDown(favoritesCubit.close);
    addTearDown(localeCubit.close);

    await tester.pumpWidget(
      RepositoryProvider<MedicationContentTranslator>.value(
        value: _FailingMedicationTranslator(),
        child: localizedTestApp(
          home: const MedicationDetailPage(medication: testMedication),
          medicationCubit: medicationCubit,
          favoritesCubit: favoritesCubit,
          localeCubit: localeCubit,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Beberapa konten ditampilkan dalam bahasa aslinya '
        'karena tidak dapat diterjemahkan.',
      ),
      findsOneWidget,
    );
    expect(find.text('For temporary relief of minor aches.'), findsOneWidget);
    expect(find.text('Pain relief.'), findsOneWidget);
  });
}

class _FakeMedicationTranslator implements MedicationContentTranslator {
  @override
  Future<Map<String, String>> translateToIndonesian(
    Medication medication,
  ) async =>
      {
        'indicationsAndUsage': 'Untuk meredakan nyeri ringan.',
        'purpose': 'Pereda nyeri.',
        'activeIngredient': 'Ibuprofen 200 mg',
        'dosageAndAdministration': 'Minum satu tablet sesuai petunjuk.',
        'warnings': 'Konsultasikan dengan dokter.',
      };
}

class _FailingMedicationTranslator implements MedicationContentTranslator {
  @override
  Future<Map<String, String>> translateToIndonesian(
    Medication medication,
  ) async {
    throw Exception('Translation unavailable');
  }
}
