import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';

import 'model/coordinates.dart';
import 'model/geocoding_unavailable_exception.dart';

typedef AndroidPlacemarkLookup =
    Future<List<Placemark>> Function(double latitude, double longitude);

/// Android標準Geocoderの有無を確認する関数。
typedef AndroidGeocoderAvailability = Future<bool> Function();

/// Android標準Geocoderの応答を場所表示候補へ変換するhandler。
class AndroidGeocodingGateway {
  AndroidGeocodingGateway({
    AndroidPlacemarkLookup? lookup,
    AndroidGeocoderAvailability? isPresent,
  }) : _lookup = lookup ?? _defaultLookup,
       _isPresent = isPresent ?? _defaultIsPresent;

  final AndroidPlacemarkLookup _lookup;
  final AndroidGeocoderAvailability _isPresent;

  /// [location]に対応する表示候補を返し、存在しなければ`null`を返す。
  Future<String?> findDisplayName(Coordinates location) async {
    if (!await _isPresent()) return null;
    try {
      final placemarks = await _lookup(location.latitude, location.longitude);
      if (placemarks.isEmpty) return null;
      return _formatAndroidPlacemark(placemarks.first);
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

Future<bool> _defaultIsPresent() => Geocoding().isPresent();

String? _formatAndroidPlacemark(Placemark placemark) {
  return _firstNonEmpty(<String?>[
    _nonNumericName(placemark.name),
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

String? _nonNumericName(String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) return null;
  return RegExp(r'^\d+$').hasMatch(normalized) ? null : normalized;
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
