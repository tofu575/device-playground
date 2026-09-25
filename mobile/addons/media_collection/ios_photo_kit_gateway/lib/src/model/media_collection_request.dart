import 'media_collection_destination.dart';
import 'media_collection_group.dart';

/// PhotoKitへ渡すコレクション構造を保持する仮モデル。
final class MediaCollectionRequest {
  MediaCollectionRequest({
    required this.containerName,
    required Iterable<MediaCollectionGroup> groups,
    this.destination,
  }) : groups = List<MediaCollectionGroup>.unmodifiable(groups);

  final String containerName;
  final List<MediaCollectionGroup> groups;
  final MediaCollectionDestination? destination;
}
