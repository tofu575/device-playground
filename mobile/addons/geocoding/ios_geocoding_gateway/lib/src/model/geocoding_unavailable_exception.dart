/// OSの逆ジオコーダーが一時的に候補を取得できなかったことを表す。
final class GeocodingUnavailableException implements Exception {
  const GeocodingUnavailableException({required this.cause});

  final Object cause;

  @override
  String toString() => 'Geocoding is temporarily unavailable: $cause';
}
