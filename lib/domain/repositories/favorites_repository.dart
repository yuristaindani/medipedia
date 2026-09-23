import '../entities/medication.dart';

abstract interface class FavoritesRepository {
  Future<List<Medication>> getFavorites();

  Future<void> saveFavorite(Medication medication);

  Future<void> removeFavorite(String id);
}