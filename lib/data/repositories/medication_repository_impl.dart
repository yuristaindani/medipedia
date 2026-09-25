import '../../domain/entities/medication.dart';
import '../../domain/entities/medication_filters.dart';
import '../../domain/entities/medication_search_tier.dart';
import '../../domain/repositories/medication_repository.dart';
import '../datasources/remote/openfda_remote_data_source.dart';

class MedicationRepositoryImpl
    implements MedicationRepository {
  MedicationRepositoryImpl(this._remoteDataSource);

  final OpenFdaRemoteDataSource _remoteDataSource;

  @override
  Future<List<Medication>> getMedications({
    String query = '',
    int skip = 0,
    int limit = 20,
    MedicationFilters filters = MedicationFilters.empty,
    MedicationSearchTier? searchTier,
  }) {
    return _remoteDataSource.getMedications(
      query: query,
      skip: skip,
      limit: limit,
      filters: filters,
      searchTier: searchTier,
    );
  }
}
