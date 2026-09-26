import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:medipedia/core/error/app_exception.dart';
import 'package:medipedia/data/datasources/remote/openfda_remote_data_source.dart';

void main() {
  group('OpenFdaRemoteDataSource', () {
    test('parses a successful medication response', () async {
      final client = MockClient((_) async {
        return http.Response(
          jsonEncode({
            'results': [
              {
                'set_id': 'test-medication-id',
                'openfda': {
                  'brand_name': ['Example Brand'],
                  'generic_name': ['Example ingredient'],
                  'manufacturer_name': ['Example Manufacturer'],
                },
                'indications_and_usage': ['Example indication'],
              },
            ],
          }),
          200,
        );
      });

      final dataSource = OpenFdaRemoteDataSource(client: client);
      final medications = await dataSource.getMedications(limit: 1);

      expect(medications, hasLength(1));
      expect(medications.single.id, 'test-medication-id');
      expect(medications.single.brandName, 'Example Brand');
      expect(medications.single.genericName, 'Example ingredient');
      expect(medications.single.manufacturerName, 'Example Manufacturer');
      expect(
        medications.single.indicationsAndUsage,
        'Example indication',
      );

      client.close();
    });

    test('maps a server error to an application exception', () async {
      final client = MockClient((_) async => http.Response('{}', 500));
      final dataSource = OpenFdaRemoteDataSource(client: client);

      await expectLater(
        dataSource.getMedications(limit: 1),
        throwsA(
          isA<AppException>().having(
            (error) => error.type,
            'type',
            AppErrorType.server,
          ),
        ),
      );

      client.close();
    });

    test('maps a successful but incomplete response to invalid data', () async {
      final client = MockClient((_) async => http.Response('{}', 200));
      final dataSource = OpenFdaRemoteDataSource(client: client);

      await expectLater(
        dataSource.getMedications(limit: 1),
        throwsA(
          isA<AppException>().having(
            (error) => error.type,
            'type',
            AppErrorType.invalidData,
          ),
        ),
      );

      client.close();
    });

    test('retries a 429 response and succeeds without calling live API',
        () async {
      var requestCount = 0;
      final observedDelays = <Duration>[];
      final client = MockClient((_) async {
        requestCount++;

        if (requestCount == 1) {
          return http.Response(
            '{}',
            429,
            headers: const {'retry-after': '4'},
          );
        }

        if (requestCount == 2) {
          return http.Response('{}', 429);
        }

        return http.Response('{"results":[]}', 200);
      });
      final dataSource = OpenFdaRemoteDataSource(
        client: client,
        delay: (duration) async => observedDelays.add(duration),
      );

      final medications = await dataSource.getMedications(limit: 1);

      expect(medications, isEmpty);
      expect(requestCount, 3);
      expect(
        observedDelays,
        const [Duration(seconds: 4), Duration(seconds: 2)],
      );

      client.close();
    });

    test('maps exhausted 429 retries to a rate-limit exception', () async {
      var requestCount = 0;
      final client = MockClient((_) async {
        requestCount++;
        return http.Response('{}', 429);
      });
      final dataSource = OpenFdaRemoteDataSource(
        client: client,
        delay: (_) async {},
      );

      await expectLater(
        dataSource.getMedications(limit: 1),
        throwsA(
          isA<AppException>().having(
            (error) => error.type,
            'type',
            AppErrorType.rateLimit,
          ),
        ),
      );
      expect(requestCount, 3);

      client.close();
    });
  });
}
