import 'package:android_media_store_gateway/android_media_store_gateway.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('test/android_media_collection');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('defaults to Pictures and preserves native partial failures', () async {
    MethodCall? captured;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          captured = call;
          return <String, Object?>{
            'exportedPhotoAssetIds': <String>['1'],
            'failures': <Map<String, String>>[
              <String, String>{
                'photoAssetId': '2',
                'reason': 'permissionDenied',
              },
            ],
          };
        });
    const gateway = AndroidMediaStoreGateway(channel: channel);

    final result = await gateway.organizeCollection(
      MediaCollectionRequest(
        containerName: '旅行',
        groups: <MediaCollectionGroup>[
          MediaCollectionGroup(name: '朝', photoAssetIds: const <String>['1']),
          MediaCollectionGroup(name: 'その他', photoAssetIds: const <String>['2']),
        ],
      ),
    );

    final arguments = (captured!.arguments as Map<Object?, Object?>)
        .cast<String, Object?>();
    expect(arguments['destination'], 'pictures');
    expect((arguments['groups'] as List<Object?>).length, 2);
    expect(result.exportedPhotoAssetIds, <String>['1']);
    expect(
      result.failures.single.reason,
      MediaCollectionFailureReason.permissionDenied,
    );
  });
}
