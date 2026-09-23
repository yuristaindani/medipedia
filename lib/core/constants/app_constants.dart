class AppConstants {
  const AppConstants._();

  static const baseUrl = 'https://api.fda.gov';
  static const labelPath = '/drug/label.json';

  static const pageSize = 20;
  static const searchDebounceMilliseconds = 450;
  static const requestTimeoutSeconds = 15;
}