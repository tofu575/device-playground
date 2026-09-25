# Device Playground

## このリポジトリの役割

このリポジトリは、デバイス機能を実機で比較・検証するFlutterアプリと、
各機能のネイティブアクセスをカプセル化したFlutter pluginを管理する。

- `lib/features/`は、実験ごとの画面とUI状態をFeature単位で管理する。
- `packages/`は、Flutter APIやMethod Channel、Swift/Kotlin実装を機能単位のpluginとして管理する。
- アプリ直下の`ios/`と`android/`は起動設定に留め、機能別のネイティブ実装を置かない。

## Featureとpluginの境界

実験画面はFeature単位で作る。Clean Architectureの共通レイヤー分割は採用せず、
Page、Section、Provider、Widgetを同じFeatureの`presentation`配下にまとめる。

ネイティブAPIへのアクセスが必要な機能は、Model、Service interface、Method Channel、
Swift/Kotlin実装をひとつのFlutter pluginとして`packages/`へ切り出す。
依存方向は次の一方向とする。

```text
FeatureのUI
  → Riverpod Provider
    → 機能別Flutter pluginのService interface
      → Method Channel
        → iOS / AndroidのネイティブAPI
```

pluginからアプリ側のFeatureには依存しない。PageやWidgetからMethod Channelや
ネイティブAPIを直接呼び出さない。

### Hapticsの例

Hapticsでは、アプリ側の`lib/features/haptics`に実験UIだけを配置し、
`packages/device_haptics`がCommon Haptics、iOS Core Haptics、Android Vibratorへのアクセスを担当する。

```text
lib/
├─ app/                      # アプリ全体の設定
├─ features/
│  ├─ home/                 # 実装済み実験への入口
│  └─ haptics/
│     └─ presentation/
│        ├─ pages/          # Haptics全体のPage
│        ├─ sections/       # Common/iOS/Androidの表示単位
│        ├─ providers/      # RiverpodによるServiceのDI
│        └─ widgets/        # Sectionから使うUI部品
└─ main.dart

packages/
└─ device_haptics/              # HapticsのFlutter plugin
   ├─ lib/src/                  # Common/iOS/AndroidのModelとService
   ├─ ios/                      # Core Haptics実装
   └─ android/                  # Vibrator実装
```

Feature内部で共有するServiceはRiverpodのProviderから取得し、Providerは`presentation`へ置く。
機能の実行に値が必要な場合は、Providerへ保持せずServiceメソッドの引数として渡す。
Platform固有のModelとServiceはplugin内の`ios`、`android`へ分け、
意味の異なるService interfaceを無理に共通化しない。

今後Motion、Touch、Location、AudioなどのFeatureを追加する場合も、
Hapticsと同じ境界と依存方向を適用する。ネイティブアクセスが必要なら、
そのFeatureに対応するpluginを`packages/`へ追加する。
