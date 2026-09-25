import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';

import 'model/coordinates.dart';
import 'model/geocoding_unavailable_exception.dart';

typedef IosPlacemarkLookup =
    Future<List<Placemark>> Function(double latitude, double longitude);

/// Core Locationの逆ジオコーディング応答を場所表示候補へ変換するhandler。
class IosGeocodingGateway {
  IosGeocodingGateway({IosPlacemarkLookup? lookup})
    : _lookup = lookup ?? _defaultLookup;

  final IosPlacemarkLookup _lookup;

  /// [location]に対応する表示候補を返し、存在しなければ`null`を返す。
  Future<String?> findDisplayName(Coordinates location) async {
    try {
      final placemarks = await _lookup(location.latitude, location.longitude);
      if (placemarks.isEmpty) return null;
      return _formatIosPlacemark(placemarks.first);
    } on PlatformException catch (error, stackTrace) {
      if (error.code == 'IO_ERROR') {
        Error.throwWithStackTrace(
          GeocodingUnavailableException(cause: error),
          stackTrace,
        );
      }
      rethrow;
    }
  }
}

Future<List<Placemark>> _defaultLookup(double latitude, double longitude) {
  return Geocoding().placemarkFromCoordinates(latitude, longitude);
}

String? _formatIosPlacemark(Placemark placemark) {
  return _firstNonEmpty(<String?>[
    _normalized(placemark.name),
    _joinUnique(<String?>[placemark.subLocality, placemark.locality]),
    _joinUnique(<String?>[placemark.locality, placemark.administrativeArea]),
    _joinUnique(<String?>[
      placemark.street,
      placemark.locality,
      placemark.administrativeArea,
    ]),
    _joinUnique(<String?>[placemark.administrativeArea, placemark.country]),
  ]);
}

String? _normalized(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}

String? _joinUnique(Iterable<String?> values) {
  final parts = values
      .map((value) => value?.trim())
      .whereType<String>()
      .where((value) => value.isNotEmpty)
      .toSet();
  return parts.isEmpty ? null : parts.join(' ');
}

String? _firstNonEmpty(Iterable<String?> values) =>
    values.whereType<String>().firstOrNull;
