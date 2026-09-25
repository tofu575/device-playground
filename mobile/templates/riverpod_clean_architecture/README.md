# Mobile Multi-Package Template

Flutterアプリを複数のローカルPackageに分割するための、最小構成テンプレートです。

## 構成

```text
lib/
├─ domain/
│  ├─ model/                 # Entity / Value Object
│  └─ usecase/               # Interactor / Gateway interface
├─ gateway/
│  └─ dummy_gateway/         # 開発・テスト用のダミー実装
├─ presentation/             # Flutter UI
├─ wire/                     # DI
└─ main.dart
```

Gatewayは最初から細分化せず、ダミーの1 Packageだけを置いています。外部API、
永続化、プラットフォーム機能が必要になった時点で、責務ごとのPackageを追加してください。

## はじめ方

1. 下記の手順でBundle IDと表示名をプロジェクト用に変更します。
2. `TemplateItem`を実際のDomain Modelへ置き換えます。
3. `DummyGateway`を実サービスへ置き換えるか、責務ごとのGateway Packageを追加します。
4. `TemplateApp`へ画面とProviderを追加します。

```sh
flutter pub get
flutter analyze
flutter test
```

## アプリ名とIDの変更

AndroidとiOSの表示名、AndroidのApplication ID、iOSのBundle IDは
[`package_rename`](https://pub.dev/packages/package_rename)でまとめて変更できます。

1. `package_rename_config.yaml`の`app_name`、`bundle_name`、`package_name`を
   アプリ用の値へ変更します。
2. プロジェクトルートで次のコマンドを実行します。

```sh
flutter pub get
dart run package_rename
```

`override_old_package`には変更前のAndroid package名を指定します。テンプレートから
初めて変更するときは`com.example.mobile_template`のままで構いません。

なお、ルート`pubspec.yaml`の`name: mobile_template`はDart package名であり、上記の
Application ID / Bundle IDとは別の値です。Dart package名も変更する場合は`name`と
`package:mobile_template/...`形式のimportを同時に変更してください。
