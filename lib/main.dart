import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'data/datasources/local/favorites_local_data_source.dart';
import 'data/datasources/remote/openfda_remote_data_source.dart';
import 'data/repositories/favorites_repository_impl.dart';
import 'data/repositories/medication_repository_impl.dart';
import 'data/services/medication_translation_service.dart';
import 'domain/repositories/favorites_repository.dart';
import 'domain/repositories/medication_repository.dart';
import 'l10n/app_localizations.dart';
import 'presentation/cubit/favorites_cubit.dart';
import 'presentation/cubit/locale_cubit.dart';
import 'presentation/cubit/medication_cubit.dart';
import 'presentation/pages/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final httpClient = http.Client();
  final remoteDataSource = OpenFdaRemoteDataSource(
    client: httpClient,
  );
  final medicationRepository = MedicationRepositoryImpl(
    remoteDataSource,
  );

  final preferences = await SharedPreferences.getInstance();
  final favoritesLocalDataSource = FavoritesLocalDataSource(
    preferences,
  );
  final favoritesRepository = FavoritesRepositoryImpl(
    favoritesLocalDataSource,
  );

  runApp(
    MediPediaApp(
      medicationRepository: medicationRepository,
      favoritesRepository: favoritesRepository,
      preferences: preferences,
    ),
  );
}

class MediPediaApp extends StatelessWidget {
  const MediPediaApp({
    super.key,
    required this.medicationRepository,
    required this.favoritesRepository,
    required this.preferences,
  });

  final MedicationRepository medicationRepository;
  final FavoritesRepository favoritesRepository;
  final SharedPreferences preferences;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<MedicationTranslationService>(
      create: (_) => MedicationTranslationService(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => MedicationCubit(
              medicationRepository,
            )..loadInitial(),
          ),
          BlocProvider(
            create: (_) => FavoritesCubit(
              favoritesRepository,
            )..load(),
          ),
          BlocProvider(
            create: (_) => LocaleCubit(preferences),
          ),
        ],
        child: BlocBuilder<LocaleCubit, Locale>(
          builder: (context, locale) {
            return MaterialApp(
              locale: locale,
              debugShowCheckedModeBanner: false,
              title: 'MediPedia',
              theme: AppTheme.light(),
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              home: const SplashPage(),
            );
          },
        ),
      ),
    );
  }
}
