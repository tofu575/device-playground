import 'package:flutter_test/flutter_test.dart';
import 'package:geocoding/geocoding.dart';
import 'package:ios_geocoding_gateway/ios_geocoding_gateway.dart';

void main() {
  test('prefers the iOS placemark name as a location suggestion', () async {
    final gateway = IosGeocodingGateway(
      lookup: (_, __) async => const <Placemark>[
        Placemark(name: '東京国立博物館', subLocality: '上野公園', locality: '台東区'),
      ],
    );

    final result = await gateway.findDisplayName(
      const Coordinates(latitude: 35, longitude: 139),
    );

    expect(result, '東京国立博物館');
  });

  test('returns no iOS suggestion for an empty geocoder result', () async {
    final gateway = IosGeocodingGateway(
      lookup: (_, __) async => const <Placemark>[],
    );

    final result = await gateway.findDisplayName(
      const Coordinates(latitude: 35, longitude: 139),
    );

    expect(result, isNull);
  });
}
