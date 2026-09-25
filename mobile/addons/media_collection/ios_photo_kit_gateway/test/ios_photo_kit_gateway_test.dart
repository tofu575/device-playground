import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_photo_kit_gateway/ios_photo_kit_gateway.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('test/ios_media_collection');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test(
    'sends the whole collection in one call and preserves missing assets',
    () async {
      var callCount = 0;
      MethodCall? captured;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            callCount += 1;
            captured = call;
            return <String, Object?>{
              'exportedPhotoAssetIds': <String>['asset-1'],
              'failures': <Map<String, String>>[
                <String, String>{
                  'photoAssetId': 'asset-2',
                  'reason': 'assetNotFound',
                },
              ],
            };
          });
      const gateway = IosPhotoKitGateway(channel: channel);

      final result = await gateway.organizeCollection(
        MediaCollectionRequest(
          containerName: '旅行',
          groups: <MediaCollectionGroup>[
            MediaCollectionGroup(
              name: 'グループ 1',
              photoAssetIds: const <String>['asset-1'],
            ),
            MediaCollectionGroup(
              name: 'グループ 2',
              photoAssetIds: const <String>['asset-2'],
            ),
          ],
        ),
      );

      expect(callCount, 1);
      expect(captured!.method, 'organizeCollection');
      final arguments = (captured!.arguments as Map<Object?, Object?>)
          .cast<String, Object?>();
      expect((arguments['groups'] as List<Object?>).length, 2);
      expect(
        result.failures.single.reason,
        MediaCollectionFailureReason.assetNotFound,
      );
    },
  );
}
