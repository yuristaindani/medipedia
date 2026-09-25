import '../entities/medication.dart';
import '../entities/medication_filters.dart';
import '../entities/medication_search_tier.dart';

abstract interface class MedicationRepository {
  Future<List<Medication>> getMedications({
    String query = '',
    int skip = 0,
    int limit = 20,
    MedicationFilters filters = MedicationFilters.empty,
    MedicationSearchTier? searchTier,
  });
}
