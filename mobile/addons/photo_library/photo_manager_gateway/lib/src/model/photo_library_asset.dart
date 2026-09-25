/// Photo Libraryから読み出した写真情報を保持する仮モデル。
final class PhotoLibraryAsset {
  const PhotoLibraryAsset({
    required this.photoLibraryAssetId,
    required this.capturedAt,
    this.latitude,
    this.longitude,
  });

  final String photoLibraryAssetId;
  final DateTime capturedAt;
  final double? latitude;
  final double? longitude;
}
