enum AppErrorType {
  network,
  server,
  rateLimit,
  invalidData,
  unknown,
}

class AppException implements Exception {
  const AppException(
    this.type, {
    this.message,
  });

  final AppErrorType type;
  final String? message;
}