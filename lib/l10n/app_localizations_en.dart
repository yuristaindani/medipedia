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
  String get english => 'English';

  @override
  String get indonesian => 'Indonesian';
}
