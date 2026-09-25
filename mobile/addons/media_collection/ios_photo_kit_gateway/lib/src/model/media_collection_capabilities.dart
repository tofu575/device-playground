import 'media_collection_destination.dart';
import 'media_collection_effect.dart';

/// OS固有handlerが提供する書き出し能力を保持する仮モデル。
final class MediaCollectionCapabilities {
  const MediaCollectionCapabilities({
    required this.effect,
    required this.supportsDestinationSelection,
    required this.availableDestinations,
  });

  final MediaCollectionEffect effect;
  final bool supportsDestinationSelection;
  final List<MediaCollectionDestination> availableDestinations;
}
