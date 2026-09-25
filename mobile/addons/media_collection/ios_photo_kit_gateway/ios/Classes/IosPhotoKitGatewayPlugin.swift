import Flutter
import Photos
import UIKit

/// PhotoKitへのメディアコレクション操作をDart Gatewayへ提供する。
public final class IosPhotoKitGatewayPlugin: NSObject, FlutterPlugin {
  private static let channelName = "dev.templates.addons/ios_photo_kit"

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: registrar.messenger()
    )
    registrar.addMethodCallDelegate(IosPhotoKitGatewayPlugin(), channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "organizeCollection" else {
      result(FlutterMethodNotImplemented)
      return
    }
    guard let request = CollectionRequest(arguments: call.arguments) else {
      result(FlutterError(
        code: "invalid_request",
        message: "The media collection request is invalid.",
        details: nil
      ))
      return
    }

    authorize { status in
      guard status == .authorized || status == .limited else {
        result(request.failureResult(reason: "permissionDenied"))
        return
      }
      self.organize(request: request, result: result)
    }
  }

  private func authorize(completion: @escaping (PHAuthorizationStatus) -> Void) {
    let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    if status == .notDetermined {
      PHPhotoLibrary.requestAuthorization(for: .readWrite, handler: completion)
    } else {
      completion(status)
    }
  }

  private func organize(request: CollectionRequest, result: @escaping FlutterResult) {
    ensureFolder(named: request.containerName) { folder in
      guard let folder else {
        result(request.failureResult(reason: "unexpected"))
        return
      }

      let accumulator = CollectionAccumulator()
      self.organizeGroups(
        request.groups[...],
        into: folder,
        accumulator: accumulator
      ) {
        result([
          "exportedPhotoAssetIds": accumulator.exported,
          "failures": accumulator.failures,
        ])
      }
    }
  }

  private func organizeGroups(
    _ remaining: ArraySlice<CollectionGroup>,
    into folder: PHCollectionList,
    accumulator: CollectionAccumulator,
    completion: @escaping () -> Void
  ) {
    guard let group = remaining.first else {
      completion()
      return
    }

    ensureAssetCollection(named: group.name, in: folder) { assetCollection in
      guard let assetCollection else {
        accumulator.failures.append(contentsOf: group.assetIds.map {
          ["photoAssetId": $0, "reason": "unexpected"]
        })
        self.organizeGroups(
          remaining.dropFirst(),
          into: folder,
          accumulator: accumulator,
          completion: completion
        )
        return
      }

      var assets = [PHAsset]()
      var availableIds = [String]()
      for assetId in group.assetIds {
        let fetch = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil)
        if let asset = fetch.firstObject {
          assets.append(asset)
          availableIds.append(assetId)
        } else {
          accumulator.failures.append(["photoAssetId": assetId, "reason": "assetNotFound"])
        }
      }

      guard !assets.isEmpty else {
        self.organizeGroups(
          remaining.dropFirst(),
          into: folder,
          accumulator: accumulator,
          completion: completion
        )
        return
      }

      PHPhotoLibrary.shared().performChanges({
        PHAssetCollectionChangeRequest(for: assetCollection)?.addAssets(assets as NSArray)
      }) { success, _ in
        if success {
          accumulator.exported.append(contentsOf: availableIds)
        } else {
          let access = PHPhotoLibrary.authorizationStatus(for: .readWrite)
          let reason = access == .denied || access == .restricted
            ? "permissionDenied"
            : "unexpected"
          accumulator.failures.append(contentsOf: availableIds.map {
            ["photoAssetId": $0, "reason": reason]
          })
        }
        self.organizeGroups(
          remaining.dropFirst(),
          into: folder,
          accumulator: accumulator,
          completion: completion
        )
      }
    }
  }

  private func ensureFolder(
    named name: String,
    completion: @escaping (PHCollectionList?) -> Void
  ) {
    let options = PHFetchOptions()
    options.predicate = NSPredicate(format: "localizedTitle == %@", name)
    if let existing = PHCollectionList.fetchCollectionLists(
      with: .folder,
      subtype: .any,
      options: options
    ).firstObject {
      completion(existing)
      return
    }

    var identifier: String?
    PHPhotoLibrary.shared().performChanges({
      identifier = PHCollectionListChangeRequest
        .creationRequestForCollectionList(withTitle: name)
        .placeholderForCreatedCollectionList
        .localIdentifier
    }) { success, _ in
      guard success, let identifier else {
        completion(nil)
        return
      }
      completion(PHCollectionList.fetchCollectionLists(
        withLocalIdentifiers: [identifier],
        options: nil
      ).firstObject)
    }
  }

  private func ensureAssetCollection(
    named name: String,
    in folder: PHCollectionList,
    completion: @escaping (PHAssetCollection?) -> Void
  ) {
    let options = PHFetchOptions()
    options.predicate = NSPredicate(format: "localizedTitle == %@", name)
    if let existing = PHAssetCollection.fetchAssetCollections(
      in: folder,
      options: options
    ).firstObject {
      completion(existing)
      return
    }

    var identifier: String?
    PHPhotoLibrary.shared().performChanges({
      let create = PHAssetCollectionChangeRequest
        .creationRequestForAssetCollection(withTitle: name)
      let placeholder = create.placeholderForCreatedAssetCollection
      identifier = placeholder.localIdentifier
      PHCollectionListChangeRequest(for: folder)?.addChildCollections(
        [placeholder] as NSArray
      )
    }) { success, _ in
      guard success, let identifier else {
        completion(nil)
        return
      }
      completion(PHAssetCollection.fetchAssetCollections(
        withLocalIdentifiers: [identifier],
        options: nil
      ).firstObject)
    }
  }
}

private struct CollectionGroup {
  let name: String
  let assetIds: [String]
}

private final class CollectionAccumulator {
  var exported = [String]()
  var failures = [[String: String]]()
}

private struct CollectionRequest {
  let containerName: String
  let groups: [CollectionGroup]

  init?(arguments: Any?) {
    guard
      let values = arguments as? [String: Any],
      let containerName = values["containerName"] as? String,
      let rawGroups = values["groups"] as? [[String: Any]]
    else { return nil }

    self.containerName = containerName
    groups = rawGroups.compactMap { raw in
      guard
        let name = raw["name"] as? String,
        let assetIds = raw["photoAssetIds"] as? [String]
      else { return nil }
      return CollectionGroup(name: name, assetIds: assetIds)
    }
    guard groups.count == rawGroups.count else { return nil }
  }

  func failureResult(reason: String) -> [String: Any] {
    [
      "exportedPhotoAssetIds": [String](),
      "failures": groups.flatMap { group in
        group.assetIds.map { ["photoAssetId": $0, "reason": reason] }
      },
    ]
  }
}
