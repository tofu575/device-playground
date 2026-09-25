import 'dart:convert';

import 'shared_preferences_storage.dart';

typedef JsonDecoder<T> = T Function(Object? json);
typedef JsonEncoder<T> = Object? Function(T value);

/// SharedPreferences上の文字列へ任意のJSON値を保存するStorage。
final class JsonStorage<T> {
  const JsonStorage({
    required this.key,
    required this.decode,
    required this.encode,
    this.storage = const SharedPreferencesStorage(),
  });

  final String key;
  final JsonDecoder<T> decode;
  final JsonEncoder<T> encode;
  final SharedPreferencesStorage storage;

  /// 保存済みJSONを[T]へ復元し、未保存ならnullを返す。
  Future<T?> read() async {
    final raw = await storage.readString(key);
    return raw == null ? null : decode(jsonDecode(raw));
  }

  /// [value]をJSON文字列へ変換して保存する。
  Future<void> write(T value) {
    return storage.writeString(key, jsonEncode(encode(value)));
  }

  /// 保存済みJSONを削除する。
  Future<void> remove() => storage.remove(key);
}
