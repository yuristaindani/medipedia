import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medipedia/domain/entities/medication.dart';
import 'package:medipedia/domain/entities/medication_filters.dart';
import 'package:medipedia/domain/entities/medication_search_tier.dart';
import 'package:medipedia/core/constants/app_constants.dart';
import 'package:medipedia/domain/repositories/medication_repository.dart';
import 'package:medipedia/presentation/cubit/medication_cubit.dart';

void main() {
  const medication = Medication(
    id: 'example-medication',
    brandName: 'Example Brand',
  );

  blocTest<MedicationCubit, MedicationState>(
    'emits loading then success when the repository returns medications',
    build: () => MedicationCubit(
      const _FakeMedicationRepository([medication]),
    ),
    act: (cubit) => cubit.loadInitial(),
    expect: () => [
      const MedicationState(
        status: MedicationStatus.loading,
      ),
      const MedicationState(
        status: MedicationStatus.success,
        medications: [medication],
        hasReachedEnd: true,
      ),
    ],
  );

  test('search keeps field relevance order across paginated results', () async {
    final brandPrefix = List.generate(
      AppConstants.pageSize,
      (index) => Medication(
        id: 'brand-$index',
        brandName: 'Fungi Brand $index',
      ),
    );
    const brandContains = [
      Medication(id: 'brand-contains-1', brandName: 'Care Fungi'),
      Medication(id: 'brand-contains-2', brandName: 'Myco Fungi'),
    ];
    final genericPrefix = List.generate(
      AppConstants.pageSize - brandContains.length,
      (index) => Medication(
        id: 'generic-$index',
        genericName: 'Fungi Generic $index',
      ),
    );
    final repository = _TieredMedicationRepository({
      MedicationSearchTier.brandPrefix: brandPrefix,
      MedicationSearchTier.brandContains: brandContains,
      MedicationSearchTier.genericPrefix: genericPrefix,
    });
    final cubit = MedicationCubit(repository);

    cubit.search('fungi');
    await Future<void>.delayed(
      const Duration(
          milliseconds: AppConstants.searchDebounceMilliseconds + 30),
    );

    expect(cubit.state.status, MedicationStatus.success);
    expect(cubit.state.medications, brandPrefix);

    await cubit.loadMore();

    expect(cubit.state.medications, [
      ...brandPrefix,
      ...brandContains,
      ...genericPrefix,
    ]);
    expect(cubit.state.medications.map((item) => item.id).toSet().length, 40);
    expect(cubit.state.isLoadingMore, isFalse);

    await cubit.close();
  });
}

class _FakeMedicationRepository implements MedicationRepository {
  const _FakeMedicationRepository(this.items);

  final List<Medication> items;

  @override
  Future<List<Medication>> getMedications({
    String query = '',
    int skip = 0,
    int limit = 20,
    MedicationFilters filters = MedicationFilters.empty,
    MedicationSearchTier? searchTier,
  }) async {
    return items.skip(skip).take(limit).toList();
  }
}

class _TieredMedicationRepository implements MedicationRepository {
  const _TieredMedicationRepository(this.itemsByTier);

  final Map<MedicationSearchTier, List<Medication>> itemsByTier;

  @override
  Future<List<Medication>> getMedications({
    String query = '',
    int skip = 0,
    int limit = 20,
    MedicationFilters filters = MedicationFilters.empty,
    MedicationSearchTier? searchTier,
  }) async {
    return (itemsByTier[searchTier] ?? const <Medication>[])
        .skip(skip)
        .take(limit)
        .toList();
  }
}
