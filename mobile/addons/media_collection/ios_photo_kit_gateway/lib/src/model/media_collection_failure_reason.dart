/// 仮実装で写真単位に報告する書き出し失敗理由を表す。
enum MediaCollectionFailureReason {
  assetNotFound,
  permissionDenied,
  unavailable,
  userCancelled,
  unexpected,
}
