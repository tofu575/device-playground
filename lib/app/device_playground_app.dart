import 'package:flutter/material.dart';

import '../features/home/home_page.dart';

/// Device Playground全体のテーマと初期画面を構成します。
final class DevicePlaygroundApp extends StatelessWidget {
  const DevicePlaygroundApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF3D5AFE),
      brightness: Brightness.light,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Device Playground',
      theme: ThemeData(
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF7F7FC),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
