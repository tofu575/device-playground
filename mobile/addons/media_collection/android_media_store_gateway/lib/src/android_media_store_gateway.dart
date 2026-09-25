import 'package:flutter/services.dart';

import 'model/media_collection_capabilities.dart';
import 'model/media_collection_destination.dart';
import 'model/media_collection_effect.dart';
import 'model/media_collection_failure.dart';
import 'model/media_collection_failure_reason.dart';
import 'model/media_collection_request.dart';
import 'model/media_collection_result.dart';

/// MediaStore上で写真原本を共有ディレクトリへ移動するhandler。
class AndroidMediaStoreGateway {
  const AndroidMediaStoreGateway({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(_channelName);

  static const _channelName = 'dev.templates.addons/android_media_store';
  final MethodChannel _channel;

  /// 現在のhandlerが提供する書き出し能力を取得する。
  Future<MediaCollectionCapabilities> getCapabilities() async =>
      const MediaCollectionCapabilities(
        effect: MediaCollectionEffect.moveOriginalFiles,
        supportsDestinationSelection: true,
        availableDestinations: <MediaCollectionDestination>[
          MediaCollectionDestination.pictures,
          MediaCollectionDestination.dcim,
        ],
      );

  /// [request]のコレクション構造をMediaStoreへ反映する。
  Future<MediaCollectionResult> organizeCollection(
    MediaCollectionRequest request,
  ) async {
    final response = await _channel.invokeMapMethod<String, Object?>(
      'organizeCollection',
      _toChannelRequest(request),
    );
    if (response == null) {
      throw const FormatException('MediaStore operation returned no result.');
    }
    return _fromChannelResult(response);
  }
}

Map<String, Object?> _toChannelRequest(MediaCollectionRequest request) =>
    <String, Object?>{
      'containerName': request.containerName,
      'destination':
          (request.destination ?? MediaCollectionDestination.pictures).name,
      'groups': <Map<String, Object?>>[
        ...request.groups.map(
          (group) => <String, Object?>{
            'name': group.name,
            'photoAssetIds': group.photoAssetIds,
          },
        ),
      ],
    };

MediaCollectionResult _fromChannelResult(Map<String, Object?> response) {
  final exported =
      (response['exportedPhotoAssetIds'] as List<Object?>? ?? const <Object?>[])
          .cast<String>();
  final failures = (response['failures'] as List<Object?>? ?? const <Object?>[])
      .map((value) {
        final failure = (value as Map<Object?, Object?>)
            .cast<String, Object?>();
        final reasonName = failure['reason'] as String? ?? 'unexpected';
        final reason = MediaCollectionFailureReason.values.firstWhere(
          (candidate) => candidate.name == reasonName,
          orElse: () => MediaCollectionFailureReason.unexpected,
        );
        return MediaCollectionFailure(
          photoAssetId: failure['photoAssetId']! as String,
          reason: reason,
        );
      });
  return MediaCollectionResult(
    exportedPhotoAssetIds: exported,
    failures: failures,
  );
}
