# コーディング・設計ルール

更新日: 2026-09-26

## 目的

Device Playgroundへ実験を追加するときの配置と検証方針を定める。
このアプリは実機上でデバイス機能を比較するための技術検証ツールであり、
プロダクト向けの汎用APIや完全な抽象化を作ることを目的としない。

## Featureベースの構成

コードは実験対象のFeature単位でまとめる。Clean Architectureの
`domain`、`usecase`、`gateway`、`presentation`という全体レイヤー分割は適用しない。

Feature内は必要に応じて次の責務へ分ける。

```text
feature/
├─ model/          # Feature内で受け渡す値
├─ presentation/   # Page、Section、Provider、Widget
└─ service/        # Flutter・Platform固有APIへのアクセス
```

空のディレクトリや将来用の型は先に作らず、実装が必要になった時点で追加する。

## PageとSection

Pageは`Scaffold`、スクロール領域、サブFeatureの配置を担当する。
Page内へ埋め込む表示単位はPageではなくSectionとし、`Scaffold`やスクロールを重ねない。
Page固有Widgetは、そのPageまたはSectionと同じ`presentation/widgets`へ置く。

## Riverpod

ServiceのDIとFeature内での共有にはRiverpodを使う。アプリのルートに`ProviderScope`を置き、
Service Providerは利用するサブFeatureの`presentation/providers`へ配置する。
Widget内で独自の`InheritedWidget`やService Locatorを作らない。

実行ごとの入力値をService Providerへ保持せず、Serviceメソッドの引数として渡す。本番で必須の
ServiceはProviderから本番実装を返す。設定不足を隠すfallback、nullable化、複数の注入経路は
追加しない。

## Service

ServiceはFlutter API、Platform Channel、ネイティブAPIなど、実際のデバイス機能へのアクセスを
担当する。PageとWidgetからPlatform APIを直接呼び出さない。Method Channelを使う機能は、
Model、Service interface、Channel実装、Swift/Kotlin実装を機能単位のFlutter pluginにまとめる。
アプリ直下の`MainActivity`や`AppDelegate`へ機能別のChannel登録を追加しない。

Common APIとPlatform固有APIは別のサブFeature、別のService interfaceとして扱う。
名前が似ているだけで共通化せず、入力、結果、失敗条件、対応機能の意味が一致する場合だけ
interfaceの共有を検討する。

PlatformによるUIとServiceの選択は親PageなどのFeature境界で一度だけ行い、操作ごとの
Platform分岐をPageやWidgetへ分散させない。同じFeatureの表示中は同じService instanceを使う。

## Hapticsの構成

Hapticsのアプリ側はUIとRiverpod Providerに限定する。Common、Core Haptics、
Android VibratorのModelとService、ネイティブ実装は`packages/device_haptics`へ配置する。

```text
haptics/
└─ presentation/
   ├─ pages/      # Haptics全体を縦に構成するPage
   ├─ sections/   # Common/iOS/Androidの表示単位
   ├─ providers/  # RiverpodによるServiceのDI
   └─ widgets/    # SectionのUI部品

packages/device_haptics/
├─ lib/src/      # Model、Service interface、Channel実装
├─ ios/          # Core Haptics
└─ android/      # Android Vibrator
```

## ファイル分割とコメント

原則として1ファイルに1関数または1オブジェクトを配置する。その関数だけが使うDTO、
private関数、State、独自エラーは同一ファイルに置いてよい。

関数やオブジェクトの冒頭には、処理手順ではなく責務が分かる概要コメントを最大3行で付ける。

## 検証方針

このリポジトリでは、触感、センサー値、端末差など、自動テストでは評価できない結果を
実機で確認する。UIテスト、Widgetテスト、Goldenテスト、単体テストは原則として追加しない。

実装時は次を基本の確認項目とする。

- `flutter analyze`が成功すること
- 対象となるiOS・Androidのビルドが成功すること
- 対象機能を実機で操作し、結果とPlatform差を確認すること

自動テストを追加する必要がある場合は、実装前に理由と検証対象をユーザーへ伝える。

## 依存関係

外部packageは完全なバージョンを指定し、`^`やバージョン範囲を使わない。
更新は内容を確認したうえで明示的に行う。
