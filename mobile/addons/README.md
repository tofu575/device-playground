# Mobile Add-ons

Flutterアプリへ必要なものだけコピーして利用する、Optionalな実装部品のカタログです。
`templates/`から生成したアプリが、このディレクトリをpath dependencyとして直接参照する
構成にはしません。

## 構成

```text
addons/
├─ local_storage/           # アプリ専用の端末内保存領域
├─ photo_library/           # 端末の写真ライブラリ
├─ geocoding/               # OS・Pluginの逆ジオコーディング
└─ media_collection/        # 写真のコレクション・ディレクトリ操作
```

各add-onは単独で依存解決、静的解析、テストを実行できます。公開APIではDomain Modelを
参照せず、導入前の動作確認に使う最小モデルだけをpackage内に持ちます。実際のアプリへ
導入するときは、Usecase側のGateway interfaceとDomain Modelへ接続するMapperを設計してください。

## Add-on一覧

- `local_storage/shared_preferences_storage`: アプリ専用の端末内Key-Value・JSON保存
- `photo_library/photo_manager_gateway`: `photo_manager`による写真と権限の操作
- `geocoding/android_geocoding_gateway`: Android Geocoderによる逆ジオコーディング
- `geocoding/ios_geocoding_gateway`: iOS Core Locationによる逆ジオコーディング
- `media_collection/android_media_store_gateway`: MediaStore上の写真ディレクトリ操作
- `media_collection/ios_photo_kit_gateway`: PhotoKit上のフォルダ・コレクション操作

外部packageのバージョンは完全固定し、`^`やバージョン範囲を使用しません。
