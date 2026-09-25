/// 子アルバムまたは子ディレクトリへ書き出す写真群を保持する仮モデル。
final class MediaCollectionGroup {
  MediaCollectionGroup({
    required this.name,
    required Iterable<String> photoAssetIds,
  }) : photoAssetIds = List<String>.unmodifiable(photoAssetIds);

  final String name;
  final List<String> photoAssetIds;
}
