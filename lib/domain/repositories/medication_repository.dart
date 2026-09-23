import '../entities/medication.dart';

abstract interface class MedicationRepository {
  Future<List<Medication>> getMedications({
    String query = '',
    int skip = 0,
    int limit = 20,
  });
}