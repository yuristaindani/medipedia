import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:medipedia/core/theme/app_theme.dart';
import 'package:medipedia/domain/entities/medication.dart';
import 'package:medipedia/domain/entities/medication_filters.dart';
import 'package:medipedia/domain/entities/medication_search_tier.dart';
import 'package:medipedia/domain/repositories/favorites_repository.dart';
import 'package:medipedia/domain/repositories/medication_repository.dart';
import 'package:medipedia/l10n/app_localizations.dart';
import 'package:medipedia/presentation/cubit/favorites_cubit.dart';
import 'package:medipedia/presentation/cubit/locale_cubit.dart';
import 'package:medipedia/presentation/cubit/medication_cubit.dart';

const testMedication = Medication(
  id: 'widget-medication',
  brandName: 'example brand',
  genericName: 'ibuprofen',
  manufacturerName: 'acme labs',
  purpose: 'Pain relief.',
  indicationsAndUsage: 'For temporary relief of minor aches.',
  activeIngredient: 'Ibuprofen 200 mg',
  dosageAndAdministration: 'Take one tablet as directed.',
  warnings: 'Ask a doctor before use.',
);

class MemoryMedicationRepository implements MedicationRepository {
  MemoryMedicationRepository([this.items = const [testMedication]]);

  final List<Medication> items;
  int requestCount = 0;

  @override
  Future<List<Medication>> getMedications({
    String query = '',
    int skip = 0,
    int limit = 20,
    MedicationFilters filters = MedicationFilters.empty,
    MedicationSearchTier? searchTier,
  }) async {
    requestCount++;
    return items.skip(skip).take(limit).toList();
  }
}

class MemoryFavoritesRepository implements FavoritesRepository {
  MemoryFavoritesRepository([List<Medication> initial = const []])
      : _favorites = List.of(initial);

  final List<Medication> _favorites;

  List<String> get savedIds => _favorites.map((item) => item.id).toList();

  @override
  Future<List<Medication>> getFavorites() async => List.of(_favorites);

  @override
  Future<void> saveFavorite(Medication medication) async {
    _favorites.add(medication);
  }

  @override
  Future<void> removeFavorite(String id) async {
    _favorites.removeWhere((item) => item.id == id);
  }
}

Future<MedicationCubit> loadedMedicationCubit({
  MemoryMedicationRepository? repository,
}) async {
  final cubit = MedicationCubit(repository ?? MemoryMedicationRepository());
  await cubit.loadInitial();
  return cubit;
}

Future<FavoritesCubit> loadedFavoritesCubit({
  MemoryFavoritesRepository? repository,
  List<Medication> initial = const [],
}) async {
  final cubit =
      FavoritesCubit(repository ?? MemoryFavoritesRepository(initial));
  await cubit.load();
  return cubit;
}

Future<LocaleCubit> englishLocaleCubit() async {
  SharedPreferences.setMockInitialValues({});
  return LocaleCubit(await SharedPreferences.getInstance());
}

Widget localizedTestApp({
  required Widget home,
  MedicationCubit? medicationCubit,
  FavoritesCubit? favoritesCubit,
  LocaleCubit? localeCubit,
}) {
  Widget child = MaterialApp(
    locale: const Locale('en'),
    theme: AppTheme.light(),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );

  if (localeCubit != null) {
    child = BlocProvider<LocaleCubit>.value(value: localeCubit, child: child);
  }
  if (favoritesCubit != null) {
    child = BlocProvider<FavoritesCubit>.value(
      value: favoritesCubit,
      child: child,
    );
  }
  if (medicationCubit != null) {
    child = BlocProvider<MedicationCubit>.value(
      value: medicationCubit,
      child: child,
    );
  }

  return child;
}
