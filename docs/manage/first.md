# Haptics Lab 初期実装指示書

## 目的

Device Playground の最初の実験ページとして、Flutter標準APIで提供されるHapticsを実機で比較できるページを実装する。

今回の目的は、ハプティクスを抽象化してプロダクト向けAPIを作ることではない。

**「この端末で、このAPIを呼ぶと、実際にどう感じるか」**

を素早く確認できる実験環境を作る。

---

# 今回のスコープ

実装対象は以下のみ。

```text
Home
 └─ Haptics
      └─ Common Haptics
```

ネイティブのCore Haptics / Android Vibrator APIは今回実装しない。

将来的に追加できる構造にはしておくが、先回りして複雑な抽象化は作らない。

---

# 使用API

Flutter標準の以下をすべて試せるようにする。

```dart
HapticFeedback.selectionClick();

HapticFeedback.lightImpact();
HapticFeedback.mediumImpact();
HapticFeedback.heavyImpact();

HapticFeedback.successNotification();
HapticFeedback.warningNotification();
HapticFeedback.errorNotification();

HapticFeedback.vibrate();
```

現行Flutterでは `HapticFeedback` はプラットフォーム既定の触覚フィードバックを呼び出すAPIであり、強度や波形を精密制御する用途ではない。

その差も含めて観察する。

---

# Home

## 目的

実装済みDevice Labへの入口。

現時点では `Haptics` のみ表示する。

### UIイメージ

```text
Device Playground

Experiments

┌────────────────────────────┐
│ Haptics                  › │
│ Tactile feedback            │
└────────────────────────────┘
```

カテゴリを先回りして大量に表示しない。

今後、MotionやLocation等を実装したタイミングで追加する。

---

# Hapticsページ

ページタイトル：

```text
Haptics
```

説明文：

```text
Compare the haptic feedback provided by this device.
Actual behavior may differ between platforms and devices.
```

UIは技術検証ツールとしてシンプルにする。

装飾より、

- 押しやすい
- 連続比較しやすい
- 何を呼んでいるか分かる

ことを優先する。

---

# セクション構成

以下の4グループに分ける。

## Selection

```text
Selection
────────────────

[ Selection Click ]

Discrete selection changes.
```

実行：

```dart
HapticFeedback.selectionClick();
```

---

## Impact

```text
Impact
────────────────

[ Light ]
[ Medium ]
[ Heavy ]
```

実行：

```dart
HapticFeedback.lightImpact();
HapticFeedback.mediumImpact();
HapticFeedback.heavyImpact();
```

3種類を連続して比較しやすい配置にする。

可能であれば横並び。

狭い画面では折り返してよい。

---

## Notification

```text
Notification
────────────────

[ Success ]
[ Warning ]
[ Error ]
```

実行：

```dart
HapticFeedback.successNotification();
HapticFeedback.warningNotification();
HapticFeedback.errorNotification();
```

ここも連続比較できることを優先する。

---

## Vibration

```text
Vibration
────────────────

[ Vibrate ]

Platform-default vibration.
```

実行：

```dart
HapticFeedback.vibrate();
```

---

# API名の表示

各実験について、ユーザー向けラベルだけでなく、実際に呼んでいるFlutter APIも確認できるようにする。

例：

```text
Light

HapticFeedback.lightImpact()
```

コード全文を表示する必要はない。

目的は、

「さっき良かったのはどのAPIだったか」

を後から判別できるようにすること。

---

# Last Played

ページ下部に直近で実行したHapticを表示する。

例：

```text
Last played

Heavy Impact
HapticFeedback.heavyImpact()
```

初期状態：

```text
Nothing played yet.
```

これは将来的にHapticsが増えた際の比較にも利用する。

---

# 実行回数表示

各Hapticについて、アプリ起動中だけ実行回数を保持してもよい。

例：

```text
Heavy
Played 4 times
```

ただし永続化は不要。

`setState` 等のローカルStateで十分。

この機能によって実装が煩雑になるなら省略してよい。

---

# エラー処理

HapticFeedbackの呼び出しは `Future<void>` なので、UIからは非同期実行する。

ハプティクス非対応端末やプラットフォーム差によって、

「呼び出しに成功したが体感できない」

可能性がある。

そのため、

```text
Played successfully
```

のような表現は使わない。

アプリが保証できるのは、

```text
Requested
```

まで。

例：

```text
Last requested

Light Impact
```

という表現にする。

---

# Platform表示

Hapticsページ上部に最低限の実行環境情報を表示する。

例：

```text
Platform
iOS
```

または

```text
Platform
Android
```

今回は端末モデルやOSバージョン取得のためだけに依存ライブラリを追加しなくてよい。

Flutter標準で簡単に取得できない情報については後回し。

将来的に、

```text
Device
iPhone ...

OS
iOS ...

Haptic capabilities
...
```

へ拡張する。

---

# UI方針

開発者向け実験アプリなので、過度なデザインは不要。

ただし「雑なデバッグ画面」にはしない。

以下を守る。

- Material 3ベース
- 十分な余白
- タップ領域は大きめ
- 同カテゴリの操作は近くに配置
- API名はmonospace風の表示でもよい
- Light / Medium / Heavyを視覚的に比較しやすくする
- ダークモードでも破綻しない
- 固定色を多用しない

---

# ファイル構成

既存プロジェクト構成がほぼ空の場合、過剰なレイヤリングは不要。

例：

```text
lib/
├─ main.dart
├─ app.dart
│
├─ features/
│   └─ haptics/
│       ├─ haptics_page.dart
│       └─ haptic_action.dart
│
└─ home/
    └─ home_page.dart
```

`HapticFeedback`を呼ぶためだけのRepositoryやUseCaseは作らない。

今回の規模では不要。

---

# HapticAction

UI内にAPI定義をベタ書きしすぎないため、必要であれば小さなモデルを作る。

例：

```dart
class HapticAction {
  const HapticAction({
    required this.label,
    required this.apiName,
    required this.execute,
  });

  final String label;
  final String apiName;
  final Future<void> Function() execute;
}
```

定義例：

```dart
HapticAction(
  label: 'Light',
  apiName: 'HapticFeedback.lightImpact()',
  execute: HapticFeedback.lightImpact,
)
```

ただし、抽象化によってコードが逆に読みにくくなるならWidgetから直接呼んでもよい。

**このアプリはAPIを観察するためのものなので、コードから何を呼んでいるか分かりやすいことを優先する。**

---

# テスト

## Widget Test

最低限、以下を確認する。

- Hapticsページが表示できる
- Selection / Light / Medium / Heavyが存在する
- Success / Warning / Errorが存在する
- Vibrateが存在する
- ボタン操作後にLast Requested表示が変化する

---

## Haptic API自体はテストしない

実際に振動したかどうかはWidget Testでは確認しない。

今回の目的は実機検証なので、

**ハプティクスそのものの正しさは実機で確認する。**

---

# 実機確認項目

iOS / Androidそれぞれで以下を触る。

```text
[ ] Selection Click

[ ] Light Impact
[ ] Medium Impact
[ ] Heavy Impact

[ ] Success Notification
[ ] Warning Notification
[ ] Error Notification

[ ] Vibrate
```

特に、

```text
Light
Medium
Heavy
```

で体感差があるか確認する。

またNotification系について、

```text
Success
Warning
Error
```

が、

- 単発なのか
- 複数回なのか
- リズムが違うのか
- 強度が違うのか

を観察する。

---

# 今回やらないこと

以下は別PRとする。

## Core Haptics

まだ実装しない。

将来的にはiOSで、

- Transient
- Continuous
- Intensity
- Sharpness
- Duration
- Dynamic Parameter
- Parameter Curve

などを試せるページを追加する。

Core Hapticsでは、transient / continuousイベントに加え、intensityやsharpnessなどを使ったカスタムパターンを生成できる。リアルタイムでパラメータを変更することも可能。

---

## Android Native Haptics

まだ実装しない。

将来的に、

- amplitude
- duration
- waveform
- predefined effects
- capabilities

などを検証する。

---

## Custom Pattern

今回作らない。

例：

```text
トトトトト

ドン → トト → ドン

回転速度に応じたTick
```

などはCore Haptics / AndroidネイティブAPI導入後に追加する。

---

## Preset保存

不要。

---

## ユーザーメモ

不要。

---

## 設定共有

不要。

---

# 次のPR候補

Common Hapticsが動いたら、次は以下。

## Haptics / iOS Core Haptics

まず、

```text
Transient

Intensity
[────────●──]

Sharpness
[────●──────]

[ Play ]
```

を作る。

その次に、

```text
Continuous

Intensity
Sharpness
Duration

[ Play ]
```

を追加する。

この時点で初めてSwift + Platform Channelを導入する。

---

# 完了条件

以下を満たしたら今回の実装は完了。

- HomeからHapticsページへ遷移できる
- Flutter標準HapticFeedbackをすべて実行できる
- Selection / Impact / Notification / Vibrationで分類されている
- 呼び出しているAPI名が分かる
- Last Requestedが確認できる
- iOS実機で操作できる
- Android実機またはAndroid端末でも実行可能な構造になっている
- Core Haptics等のネイティブAPIにはまだ手を出していない

---

# 実装上の思想

このプロジェクトでは、

> プラットフォーム差を抽象化して消す

ことを目的にしない。

むしろ、

> 同じFlutter APIを呼んだとき、iOS / Android / 端末ごとに何が起こるのか観察する

ことを目的とする。

したがって将来的に、

```text
Common
iOS
Android
```

という実験が同じHapticsカテゴリ内に並んでも問題ない。

Device Playgroundそのものを、スマートフォン固有機能の「実機仕様書」として育てていく。
