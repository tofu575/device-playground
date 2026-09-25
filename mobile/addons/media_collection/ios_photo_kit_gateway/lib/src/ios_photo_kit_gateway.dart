import 'package:flutter/services.dart';

import 'model/media_collection_capabilities.dart';
import 'model/media_collection_destination.dart';
import 'model/media_collection_effect.dart';
import 'model/media_collection_failure.dart';
import 'model/media_collection_failure_reason.dart';
import 'model/media_collection_request.dart';
import 'model/media_collection_result.dart';

/// PhotoKit上のフォルダと子アルバムへ写真の参照を追加するhandler。
class IosPhotoKitGateway {
  const IosPhotoKitGateway({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(_channelName);

  static const _channelName = 'dev.templates.addons/ios_photo_kit';
  final MethodChannel _channel;

  /// 現在のhandlerが提供する書き出し能力を取得する。
  Future<MediaCollectionCapabilities> getCapabilities() async =>
      const MediaCollectionCapabilities(
        effect: MediaCollectionEffect.addReferences,
        supportsDestinationSelection: false,
        availableDestinations: <MediaCollectionDestination>[],
      );

  /// [request]のコレクション構造をPhotoKitへ反映する。
  Future<MediaCollectionResult> organizeCollection(
    MediaCollectionRequest request,
  ) async {
    final response = await _channel.invokeMapMethod<String, Object?>(
      'organizeCollection',
      _toChannelRequest(request),
    );
    if (response == null) {
      throw const FormatException('PhotoKit operation returned no result.');
    }
    return _fromChannelResult(response);
  }
}

Map<String, Object?> _toChannelRequest(MediaCollectionRequest request) =>
    <String, Object?>{
      'containerName': request.containerName,
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
