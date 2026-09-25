package com.example.deviceplayground

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

/// Device PlaygroundをAndroidのFlutter画面として起動します。
class MainActivity : FlutterActivity() {
    private var androidVibrationService: AndroidVibrationService? = null

    /// Flutter EngineへAndroid固有のデバイス機能を登録します。
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        androidVibrationService = AndroidVibrationService(
            applicationContext,
            flutterEngine.dartExecutor.binaryMessenger,
        )
    }
}
