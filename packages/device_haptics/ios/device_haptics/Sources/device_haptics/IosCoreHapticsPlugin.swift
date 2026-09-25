import CoreHaptics
import Flutter

/// Flutterから受け取ったパラメータでCore Hapticsを実行します。
public final class IosCoreHapticsPlugin: NSObject, FlutterPlugin {
  private let channel: FlutterMethodChannel
  private var engine: CHHapticEngine?

  private init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(
      name: "device_haptics/ios_core_haptics",
      binaryMessenger: messenger
    )
    super.init()
  }

  /// Flutter EngineへCore HapticsのMethod Channelを登録します。
  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = IosCoreHapticsPlugin(messenger: registrar.messenger())
    registrar.addMethodCallDelegate(instance, channel: instance.channel)
  }

  /// Method Channelの呼び出しを対応するCore Haptics操作へ振り分けます。
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isSupported":
      result(CHHapticEngine.capabilitiesForHardware().supportsHaptics)
    case "play":
      play(call, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  /// Dart側の入力値を検証し、Core Hapticsイベントとして再生します。
  private func play(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
      result(
        FlutterError(
          code: "ios_core_haptics_unsupported",
          message: "Core Haptics is not supported on this device.",
          details: nil
        )
      )
      return
    }
    guard
      let arguments = call.arguments as? [String: Any],
      let eventTypeValue = arguments["eventType"] as? String,
      let intensity = (arguments["intensity"] as? NSNumber)?.floatValue,
      let sharpness = (arguments["sharpness"] as? NSNumber)?.floatValue,
      let durationMilliseconds =
        (arguments["durationMilliseconds"] as? NSNumber)?.doubleValue,
      (0...1).contains(intensity),
      (0...1).contains(sharpness),
      durationMilliseconds > 0,
      durationMilliseconds <= 30_000
    else {
      result(
        FlutterError(
          code: "invalid_ios_core_haptics_input",
          message: "Intensity and sharpness must be between 0 and 1, and duration must be between 1 and 30000 ms.",
          details: nil
        )
      )
      return
    }

    let parameters = [
      CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
      CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness),
    ]
    let event: CHHapticEvent
    switch eventTypeValue {
    case "transient":
      event = CHHapticEvent(
        eventType: .hapticTransient,
        parameters: parameters,
        relativeTime: 0
      )
    case "continuous":
      event = CHHapticEvent(
        eventType: .hapticContinuous,
        parameters: parameters,
        relativeTime: 0,
        duration: durationMilliseconds / 1000
      )
    default:
      result(
        FlutterError(
          code: "invalid_ios_core_haptics_event_type",
          message: "Unknown Core Haptics event type.",
          details: eventTypeValue
        )
      )
      return
    }

    do {
      if engine == nil {
        engine = try CHHapticEngine()
      }
      try engine?.start()
      let pattern = try CHHapticPattern(events: [event], parameters: [])
      let player = try engine?.makePlayer(with: pattern)
      try player?.start(atTime: CHHapticTimeImmediate)
      result(nil)
    } catch {
      result(
        FlutterError(
          code: "ios_core_haptics_play_failed",
          message: error.localizedDescription,
          details: nil
        )
      )
    }
  }
}
