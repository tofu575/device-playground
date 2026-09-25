# Device Playground 構想メモ

## 概要

スマートフォン固有の機能を、実機上で直接触りながら検証するためのDeveloper Playground。

アプリごとに小さなPoCを作るのではなく、1つのアプリに実験ページを追加していく。

最初は **Haptics** から開始し、必要になった機能を順次追加する。

主目的は「完成されたプロダクトを作ること」ではなく、

> スマートフォンの機能を、実機で触って理解・比較できる実験場を作る

こと。

---

## 想定用途

- 個人開発前の技術検証
- iOS / Androidの挙動差の確認
- Flutter標準APIでできることの確認
- ネイティブAPIまで降りた場合の比較
- UI / UX表現の研究
- 実装サンプルの蓄積
- GitHubでの技術アウトプット
- Zenn等の記事ネタ
- 転職時の技術ポートフォリオ

自分用ツールとして使いつつ、公開して他の開発者も触れる形を目指す。

---

# 基本方針

## Featureベースのアーキテクチャ

このリポジトリでは、実験を素早く追加・削除できるよう、Feature単位でコードをまとめる。
以前のテンプレートにあったClean Architectureの `domain` / `usecase` / `gateway` /
`presentation` 分割は採用しない。各実験で必要なコードは同じFeature配下へ配置しつつ、
Pageとデバイス機能へのアクセスは分離する。

```text
lib/
├─ app/                      # アプリ全体の設定
├─ features/
│  ├─ home/                 # 実装済み実験への入口
│  └─ haptics/
│     ├─ context/           # Serviceの共有とFeatureの組み立て
│     ├─ model/             # Haptics Featureで扱う値
│     ├─ presentation/      # Pageとページ固有Widget
│     └─ service/           # Flutter・ネイティブのデバイス機能アクセス
└─ main.dart
```

Feature内部で共有するServiceはContextから取得する。機能の実行に値が必要な場合は、
Contextへ状態として保持せず、アクセスメソッドの引数として渡す。複数Featureで実際に共有する
ものが生まれた時点で共通化を検討し、将来用途を予測したレイヤーは先に作らない。

## Flutterを共通シェルとして使う

UIやナビゲーション、共通処理はFlutterで実装する。

ただし、

> iOS / Androidの差を無理に吸収しない。

このアプリでは、プラットフォーム差そのものも検証対象とする。

```text
Flutter
  │
  ├─ Common API
  │
  ├─ iOS
  │   └─ Swift / Native API
  │
  └─ Android
      └─ Kotlin / Native API
```

Flutter標準APIで不足した場合のみPlatform Channel等を利用する。

---

# ページ構成

ホーム画面には、**実装済みの実験だけを並べる**。

最初から大量の未実装メニューは作らない。

例：

```text
Device Playground

Haptics
Motion
Touch
Location
Audio
...
```

必要になったものから順番に増やしていく。

---

# 最初の実装：Haptics

最初はHapticsだけ実装する。

## 目的

iPhone / Android端末の振動・触覚フィードバックを実際に触り、

- どんな種類があるか
- 何を制御できるか
- どの程度違いを感じられるか
- UI表現としてどう使えそうか

を確認する。

将来的にはハンドスピナーなどの触覚UIの検証にも利用する。

---

## Phase 1：Flutter標準Haptics

まずFlutter標準APIだけを試す。

例：

- Selection
- Light Impact
- Medium Impact
- Heavy Impact
- Vibrate

ボタンを押すだけで、それぞれ比較できる。

---

## Phase 2：iOS / Android固有API

Flutter標準では触れない機能を追加する。

### iOS

Core Haptics等を利用。

検証候補：

- Transient
- Continuous
- Intensity
- Sharpness
- Duration
- Pattern
- Dynamic Parameter

### Android

AndroidのVibrator系APIを利用。

検証候補：

- Amplitude
- Duration
- Waveform
- Predefined Effect
- Amplitude Control対応状況

---

# Haptics LabのUI案

実験ページは、

```text
入力
↓
パラメータ
↓
実行
↓
結果 / メモ
```

という共通構造にする。

例：

```text
Haptics

Type
[ Transient ▼ ]

Intensity
────●────
0.65

Sharpness
──●──────
0.30

Duration
[ 500 ms ]

[ Play ]
```

その場で値を変更して実機で確認できる。

---

## 開発者向け情報

可能なら以下も表示する。

```text
Platform
iOS

Device
iPhone xx

OS
iOS xx.x

Core Haptics
Supported

Intensity
0.65

Sharpness
0.30
```

気に入った設定を別プロジェクトへ移植しやすくする。

将来的には設定値コピーもあり。

---

# 将来追加したい実験

## Motion

- Accelerometer
- Gyroscope
- Device Orientation
- Rotation Rate

## Touch / Gesture

- Tap
- Long Press
- Drag
- Flick
- Velocity
- Multi Touch

## Display

- Refresh Rate
- 60Hz / 120Hz
- Frame Time
- Animation

## Audio

- SE
- 音量
- Hapticsとの同期
- Audio Session

## Location

- GPS
- Accuracy
- Update Interval
- Permission

## Sensors

- Compass
- Proximity
- 利用可能なその他センサー

## System

- App Lifecycle
- Background / Foreground
- Battery
- Network
- Permissions

---

# 設計上の重要ポイント

## 「全部入り」を目標にしない

Device APIを網羅すること自体をゴールにしない。

必要になった機能を追加する。

そのため、

> 未実装カテゴリを最初から大量に作らない。

---

## 差分を隠さない

通常のクロスプラットフォームアプリでは、

> iOS / Android差分を吸収する

ことが多い。

このアプリでは逆に、

> iOS / Android差分を観察できるようにする。

ここをプロジェクトの特徴とする。

---

## UIより検証速度を優先

初期は最低限のUIでよい。

重要なのは、

> 値を変える
> ↓
> 実行する
> ↓
> 実機で感じる

までが速いこと。

---

# 最初の完成条件

最初のバージョンは、

```text
Home
  ↓
Haptics
  ↓
Flutter標準Hapticsを比較
```

だけでよい。

ここまでできたらGitHubへ公開。

その後Core Hapticsなどを追加する。

---

# ハンドスピナーへの応用

Device PlaygroundでHapticsを検証したあと、

- 回転速度
- 摩擦
- 角速度
- 減速
- ベアリング感

などをHapticsへマッピングする。

例えば、

```text
高速
ﾄﾄﾄﾄﾄﾄﾄ

中速
ﾄ ﾄ ﾄ ﾄ

低速
ﾄｯ   ﾄｯ    ﾄｯ
```

のように、物理状態からリアルタイムに触覚を生成する。

---

# リポジトリ名候補

## 分かりやすさ重視

### `device-playground`

一番おすすめ。

何をするリポジトリなのか一目で分かる。

---

### `mobile-device-lab`

より技術検証ツール感が強い。

少し固め。

---

### `device-lab`

短くて分かりやすい。

ただし名前としてはかなり一般的。

---

### `mobile-playground`

用途は伝わりやすいが、スマホ固有機能の意味はやや薄い。

---

## 少し固有名寄り

### `PocketLab`

「ポケットに入っているデバイスを実験する」という意味が出せる。

公開アプリ名にも使いやすい。

---

### `TouchLab`

Hapticsにはかなり合うが、GPSやMotionまで広がったときに少し狭い。

---

### `DeviceScope`

デバイスの中身を観察するニュアンス。

技術ツールっぽさがある。

---

### `MobileScope`

Mobile + Scope。

センサーや端末機能を観測する意味にも取れる。
