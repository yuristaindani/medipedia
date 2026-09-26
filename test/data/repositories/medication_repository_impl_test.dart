import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:medipedia/data/datasources/remote/openfda_remote_data_source.dart';
import 'package:medipedia/data/repositories/medication_repository_impl.dart';
import 'package:medipedia/domain/entities/medication_filters.dart';
import 'package:medipedia/domain/entities/medication_search_tier.dart';

void main() {
  test('repository forwards query, tier, filters and pagination to API',
      () async {
    late Uri requestedUri;
    final client = MockClient((request) async {
      requestedUri = request.url;
      return http.Response(
        jsonEncode({
          'results': [
            {
              'set_id': 'repo-test-id',
              'openfda': {
                'brand_name': ['Fungi Care']
              },
            },
          ],
        }),
        200,
      );
    });
    final repository = MedicationRepositoryImpl(
      OpenFdaRemoteDataSource(client: client),
    );
    const filters = MedicationFilters(
      routes: ['ORAL'],
    );

    final results = await repository.getMedications(
      query: 'fungi',
      skip: 20,
      limit: 10,
      filters: filters,
      searchTier: MedicationSearchTier.brandPrefix,
    );

    expect(results.single.id, 'repo-test-id');
    expect(requestedUri.queryParameters['skip'], '20');
    expect(requestedUri.queryParameters['limit'], '10');
    expect(
      requestedUri.queryParameters['search'],
      contains('openfda.brand_name:fungi*'),
    );
    expect(
      requestedUri.queryParameters['search'],
      contains('openfda.route:"ORAL"'),
    );

    client.close();
  });
}
