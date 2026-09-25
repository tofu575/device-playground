import 'media_collection_failure.dart';

/// 書き出しの成功と部分失敗を保持する仮モデル。
final class MediaCollectionResult {
  MediaCollectionResult({
    required Iterable<String> exportedPhotoAssetIds,
    required Iterable<MediaCollectionFailure> failures,
  }) : exportedPhotoAssetIds = List<String>.unmodifiable(exportedPhotoAssetIds),
       failures = List<MediaCollectionFailure>.unmodifiable(failures);

  final List<String> exportedPhotoAssetIds;
  final List<MediaCollectionFailure> failures;

  bool get isComplete => failures.isEmpty;
}
