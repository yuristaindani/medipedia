import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medipedia/domain/entities/medication.dart';
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
      _FakeMedicationRepository([medication]),
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
}

class _FakeMedicationRepository implements MedicationRepository {
  const _FakeMedicationRepository(this.items);

  final List<Medication> items;

  @override
  Future<List<Medication>> getMedications({
    String query = '',
    int skip = 0,
    int limit = 20,
  }) async {
    return items.skip(skip).take(limit).toList();
  }
}
