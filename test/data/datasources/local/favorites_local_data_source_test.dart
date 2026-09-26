import 'package:flutter_test/flutter_test.dart';
import 'package:medipedia/data/datasources/local/favorites_local_data_source.dart';
import 'package:medipedia/data/models/medication_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('favorites persist between data source instances and can be removed',
      () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final firstInstance = FavoritesLocalDataSource(preferences);
    const medication = MedicationModel(
      id: 'persistent-favorite',
      brandName: 'Example medicine',
    );

    await firstInstance.saveFavorite(medication);

    await preferences.reload();
    final reopenedInstance = FavoritesLocalDataSource(preferences);
    final restored = await reopenedInstance.getFavorites();
    expect(restored.map((item) => item.id).toList(), ['persistent-favorite']);

    await reopenedInstance.removeFavorite('persistent-favorite');
    expect(await firstInstance.getFavorites(), isEmpty);
  });
}
