import 'media_collection_failure_reason.dart';

/// 書き出せなかった写真と理由を保持する仮モデル。
final class MediaCollectionFailure {
  const MediaCollectionFailure({
    required this.photoAssetId,
    required this.reason,
  });

  final String photoAssetId;
  final MediaCollectionFailureReason reason;
}
