import 'package:android_geocoding_gateway/android_geocoding_gateway.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geocoding/geocoding.dart';

void main() {
  test(
    'formats Android locality fields when a POI name is unavailable',
    () async {
      final gateway = AndroidGeocodingGateway(
        isPresent: () async => true,
        lookup: (_, __) async => const <Placemark>[
          Placemark(name: '123', subLocality: '上野公園', locality: '台東区'),
        ],
      );

      final result = await gateway.findDisplayName(
        const Coordinates(latitude: 35, longitude: 139),
      );

      expect(result, '上野公園 台東区');
    },
  );

  test('distinguishes Android geocoder IO errors from no candidate', () async {
    final gateway = AndroidGeocodingGateway(
      isPresent: () async => true,
      lookup: (_, __) => throw PlatformException(code: 'IO_ERROR'),
    );

    await expectLater(
      gateway.findDisplayName(const Coordinates(latitude: 35, longitude: 139)),
      throwsA(isA<GeocodingUnavailableException>()),
    );
  });
}
