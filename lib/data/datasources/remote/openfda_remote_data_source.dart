import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/app_constants.dart';
import '../../../core/error/app_exception.dart';
import '../../models/medication_model.dart';

class OpenFdaRemoteDataSource {
  OpenFdaRemoteDataSource({
    required http.Client client,
    this.apiKey,
  }) : _client = client;

  final http.Client _client;
  final String? apiKey;

  Future<List<MedicationModel>> getMedications({
    String query = '',
    int skip = 0,
    int limit = AppConstants.pageSize,
  }) async {
    final queryParameters = <String, String>{
      'limit': '$limit',
      'skip': '$skip',
    };

    final normalizedQuery = query.trim();

    if (normalizedQuery.isEmpty) {
      queryParameters['sort'] = 'effective_time:desc';
    } else {
       final safeQuery = normalizedQuery
          .replaceAll('"', '')
          .trim()
          .toLowerCase();

      queryParameters['search'] =
          'openfda.brand_name:$safeQuery* OR '
          'openfda.generic_name:$safeQuery* OR '
          'openfda.brand_name:*$safeQuery* OR '
          'openfda.generic_name:*$safeQuery* OR '
          'indications_and_usage:$safeQuery* OR '
          'indications_and_usage:*$safeQuery* OR '
          'indications_and_usage:"$safeQuery"';
          // 'openfda.brand_name:$safeQuery*'
          // '+openfda.generic_name:$safeQuery*'
          // '+openfda.brand_name:*$safeQuery*'
          // '+openfda.generic_name:*$safeQuery*'
          // '+indications_and_usage:"$safeQuery"';
    }

    if (apiKey != null && apiKey!.isNotEmpty) {
      queryParameters['api_key'] = apiKey!;
    }

    final uri = Uri.https(
      'api.fda.gov',
      AppConstants.labelPath,
      queryParameters,
    );

    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final response = await _client
            .get(
              uri,
              headers: const {
                'Accept': 'application/json',
              },
            )
            .timeout(
              const Duration(
                seconds: AppConstants.requestTimeoutSeconds,
              ),
            );

        if (response.statusCode == 200) {
          return _parseResponse(response.body);
        }

        if (response.statusCode == 404 &&
            normalizedQuery.isNotEmpty) {
          return [];
        }

        if (response.statusCode == 429) {
          if (attempt == 2) {
            throw const AppException(
              AppErrorType.rateLimit,
            );
          }

          final retryAfter =
              int.tryParse(
                response.headers['retry-after'] ?? '',
              ) ??
                  (attempt + 1);

          await Future<void>.delayed(
            Duration(seconds: retryAfter.clamp(1, 5)),
          );

          continue;
        }

        if (response.statusCode >= 500) {
          throw const AppException(
            AppErrorType.server,
          );
        }

        throw const AppException(
          AppErrorType.unknown,
        );
      } on TimeoutException {
        throw const AppException(
          AppErrorType.network,
        );
      } on http.ClientException {
        throw const AppException(
          AppErrorType.network,
        );
      } on AppException {
        rethrow;
      } catch (_) {
        throw const AppException(
          AppErrorType.unknown,
        );
      }
    }

    throw const AppException(
      AppErrorType.unknown,
    );
  }

  List<MedicationModel> _parseResponse(String body) {
    try {
      final decoded = jsonDecode(body);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException();
      }

      final rawResults = decoded['results'];

      if (rawResults == null) {
        return [];
      }

      if (rawResults is! List) {
        throw const FormatException();
      }

      final medications = <MedicationModel>[];

      for (final item in rawResults) {
        if (item is! Map) {
          continue;
        }

        try {
          medications.add(
            MedicationModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        } on FormatException {
          // Skip malformed individual records.
        }
      }

      return medications;
    } catch (_) {
      throw const AppException(
        AppErrorType.invalidData,
      );
    }
  }
}