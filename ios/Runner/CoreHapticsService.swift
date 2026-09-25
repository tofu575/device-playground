import CoreHaptics
import Flutter

/// Flutterから受け取ったパラメータでCore Hapticsを実行します。
final class CoreHapticsService {
  private let channel: FlutterMethodChannel
  private var engine: CHHapticEngine?

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(
      name: "device_playground/core_haptics",
      binaryMessenger: messenger
    )
    channel.setMethodCallHandler { [weak self] call, result in
      self?.handleMethodCall(call, result: result)
    }
  }

  /// Method Channelの呼び出しを対応するCore Haptics操作へ振り分けます。
  private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
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
          code: "core_haptics_unsupported",
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
          code: "invalid_core_haptics_input",
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
          code: "invalid_core_haptics_event_type",
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
          code: "core_haptics_play_failed",
          message: error.localizedDescription,
          details: nil
        )
      )
    }
  }
}
