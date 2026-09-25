import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';

import 'model/photo_library_access.dart';
import 'model/photo_library_asset.dart';

/// OSのPhoto Library操作を提供するhandler。
class PhotoManagerGateway {
  static const PermissionRequestOption _permissionOption =
      PermissionRequestOption(
        iosAccessLevel: IosAccessLevel.readWrite,
        androidPermission: AndroidPermission(
          type: RequestType.image,
          mediaLocation: true,
        ),
      );

  /// ユーザーへ許可要求を出さず、現在のアクセス状態を取得する。
  Future<PhotoLibraryAccess> getAccess() async {
    final state = await PhotoManager.getPermissionState(
      requestOption: _permissionOption,
    );
    return _mapAccess(state);
  }

  /// Photo Libraryへのアクセスを要求し、その結果を返す。
  Future<PhotoLibraryAccess> requestAccess() async {
    final state = await PhotoManager.requestPermissionExtend(
      requestOption: _permissionOption,
    );
    return _mapAccess(state);
  }

  /// 指定期間に撮影された画像を上限件数内で取得する。
  Future<List<PhotoLibraryAsset>> listImages({
    required DateTime from,
    required DateTime to,
    int limit = 500,
  }) async {
    final safeLimit = limit.clamp(1, 2000);
    final filter = FilterOptionGroup(
      createTimeCond: DateTimeCond(min: from, max: to),
      orders: const <OrderOption>[
        OrderOption(type: OrderOptionType.createDate, asc: true),
      ],
    );
    final paths = await PhotoManager.getAssetPathList(
      onlyAll: true,
      type: RequestType.image,
      filterOption: filter,
    );
    if (paths.isEmpty) {
      return const <PhotoLibraryAsset>[];
    }

    final count = await paths.first.assetCountAsync;
    if (count == 0) {
      return const <PhotoLibraryAsset>[];
    }
    final entities = await paths.first.getAssetListRange(
      start: 0,
      end: count < safeLimit ? count : safeLimit,
      type: RequestType.image,
    );

    return Future.wait(entities.map(_toAsset));
  }

  /// 指定期間に画像が存在する撮影日を取得する。
  Future<Set<DateTime>> listImageDates({
    required DateTime from,
    required DateTime to,
  }) async {
    const pageSize = 200;
    final filter = FilterOptionGroup(
      createTimeCond: DateTimeCond(min: from, max: to),
      orders: const <OrderOption>[
        OrderOption(type: OrderOptionType.createDate, asc: true),
      ],
    );
    final paths = await PhotoManager.getAssetPathList(
      onlyAll: true,
      type: RequestType.image,
      filterOption: filter,
    );
    if (paths.isEmpty) return const <DateTime>{};

    final path = paths.first;
    final count = await path.assetCountAsync;
    final dates = <DateTime>{};
    for (var start = 0; start < count; start += pageSize) {
      final end = start + pageSize < count ? start + pageSize : count;
      final entities = await path.getAssetListRange(
        start: start,
        end: end,
        type: RequestType.image,
      );
      for (final entity in entities) {
        final capturedAt = entity.createDateTime;
        dates.add(DateTime(capturedAt.year, capturedAt.month, capturedAt.day));
      }
    }
    return Set<DateTime>.unmodifiable(dates);
  }

  /// Photo LibraryのエンティティをGateway DTOへ変換する。
  Future<PhotoLibraryAsset> _toAsset(AssetEntity entity) async {
    LatLng? location = entity.latLng;
    if (location == null) {
      try {
        location = await entity.latlngAsync();
      } catch (_) {
        location = null;
      }
    }
    return PhotoLibraryAsset(
      photoLibraryAssetId: entity.id,
      capturedAt: entity.createDateTime,
      latitude: location?.latitude,
      longitude: location?.longitude,
    );
  }

  /// 指定assetのサムネイルを読み込み、参照不能なら`null`を返す。
  Future<Uint8List?> loadThumbnail({
    required String photoLibraryAssetId,
    required int size,
  }) async {
    final entity = await AssetEntity.fromId(photoLibraryAssetId);
    if (entity == null) {
      return null;
    }
    final safeSize = size.clamp(64, 1600);
    return entity.thumbnailDataWithSize(
      ThumbnailSize.square(safeSize),
      quality: 88,
    );
  }

  /// 指定assetが現在の権限下で参照可能かを確認する。
  Future<bool> isAssetAvailable(String photoLibraryAssetId) async {
    return await AssetEntity.fromId(photoLibraryAssetId) != null;
  }

  /// iOSの限定アクセス対象を選び直すOS画面を表示する。
  Future<void> presentLimitedSelection() {
    return PhotoManager.presentLimited(type: RequestType.image);
  }

  /// Photo Library権限を変更するOS設定画面を開く。
  Future<void> openSettings() {
    return PhotoManager.openSetting();
  }

  PhotoLibraryAccess _mapAccess(PermissionState state) {
    if (state == PermissionState.authorized) {
      return PhotoLibraryAccess.authorized;
    }
    if (state == PermissionState.limited) {
      return PhotoLibraryAccess.limited;
    }
    return PhotoLibraryAccess.denied;
  }
}
