import '../../domain/entities/medication.dart';
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
  }) {
    return _remoteDataSource.getMedications(
      query: query,
      skip: skip,
      limit: limit,
    );
  }
}