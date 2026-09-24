import 'app_localizations.dart';

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'MediPedia';

  @override
  String get tagline => 'Find. Check. Verify.';

  @override
  String get searchHint => 'Search...';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get brandName => 'Brand Name';

  @override
  String get genericName => 'Generic Name';

  @override
  String get manufacturer => 'Manufacturer';

  @override
  String get favorites => 'Favorites';

  @override
  String get details => 'Details';

  @override
  String get purpose => 'Purpose';

  @override
  String get indications => 'Indications';

  @override
  String get dosage => 'Dosage';

  @override
  String get warnings => 'Warnings';

  @override
  String get activeIngredients => 'Active Ingredients';

  @override
  String get retry => 'Retry';

  @override
  String get emptyMedications => 'No medications found';

  @override
  String get emptyFavorites => 'No favorite medications yet';

  @override
  String get searchTooShort => 'Type at least 2 characters to search';

  @override
  String get unknown => 'Not available';

  @override
  String get networkError => 'Unable to connect. Please check your internet connection.';

  @override
  String get serverError => 'The service is temporarily unavailable.';

  @override
  String get rateLimitError => 'Too many requests. Please try again later.';

  @override
  String get invalidDataError => 'The medication data could not be read.';

  @override
  String get unknownError => 'Something went wrong. Please try again.';

  @override
  String get favoriteAdded => 'Added to favorites';

  @override
  String get favoriteRemoved => 'Removed from favorites';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get loadMore => 'Loading more...';

  @override
  String get disclaimer => 'Information is provided for reference only and is not medical advice.';

  @override
  String get language => 'Language';

  @override
  String get english => 'ENG';

  @override
  String get indonesian => 'IDN';

  @override
  String get filter => 'Filter';

  @override
  String get filterTitle => 'Choose preferences';

  @override
  String get close => 'Close';

  @override
  String get drugType => 'Drug type';

  @override
  String get dosageForm => 'Dosage form';

  @override
  String get overTheCounter => 'Over the counter';

  @override
  String get prescription => 'Prescription';

  @override
  String get tablet => 'Tablet';

  @override
  String get capsule => 'Capsule';

  @override
  String get cream => 'Cream';

  @override
  String get machineTranslationNotice => 'Machine translated medical content. Switch to ENG to view the original.';

  @override
  String get translationUnavailable => 'Translation is unavailable. Showing the original English text.';
}
