import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/medication_model.dart';

class FavoritesLocalDataSource {
  FavoritesLocalDataSource(this._preferences);

  final SharedPreferences _preferences;

  static const _key = 'favorite_medications';

  Future<List<MedicationModel>> getFavorites() async {
    final values = _preferences.getStringList(_key) ?? [];
    final result = <MedicationModel>[];

    for (final value in values) {
      try {
        final json = jsonDecode(value) as Map<String, dynamic>;
        result.add(MedicationModel.fromStoredJson(json));
      } catch (_) {
        // Ignore corrupted favorite entry.
      }
    }

    return result;
  }

  Future<void> saveFavorite(MedicationModel medication) async {
    final current = await getFavorites();
    final exists = current.any((item) => item.id == medication.id);

    if (exists) return;

    current.add(medication);
    await _save(current);
  }

  Future<void> removeFavorite(String id) async {
    final current = await getFavorites();
    current.removeWhere((item) => item.id == id);
    await _save(current);
  }

  Future<void> _save(List<MedicationModel> medications) async {
    final values = medications
        .map((medication) => jsonEncode(medication.toJson()))
        .toList();

    await _preferences.setStringList(_key, values);
  }
}