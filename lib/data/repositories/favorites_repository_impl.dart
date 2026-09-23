import '../../domain/entities/medication.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/local/favorites_local_data_source.dart';
import '../models/medication_model.dart';

class FavoritesRepositoryImpl
    implements FavoritesRepository {
  FavoritesRepositoryImpl(this._localDataSource);

  final FavoritesLocalDataSource _localDataSource;

  @override
  Future<List<Medication>> getFavorites() {
    return _localDataSource.getFavorites();
  }

  @override
  Future<void> saveFavorite(
    Medication medication,
  ) {
    return _localDataSource.saveFavorite(
      MedicationModel.fromEntity(medication),
    );
  }

  @override
  Future<void> removeFavorite(String id) {
    return _localDataSource.removeFavorite(id);
  }
}