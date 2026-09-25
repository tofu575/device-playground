import 'package:shared_preferences/shared_preferences.dart';

import 'storage_write_exception.dart';

/// アプリ専用の端末内領域へプリミティブ値を保存するStorage。
final class SharedPreferencesStorage {
  const SharedPreferencesStorage();

  Future<SharedPreferences> get _preferences => SharedPreferences.getInstance();

  /// [key]に保存された文字列を取得する。
  Future<String?> readString(String key) async =>
      (await _preferences).getString(key);

  /// [value]を文字列として[key]へ保存する。
  Future<void> writeString(String key, String value) => _write(
    key: key,
    operation: 'writeString',
    write: (preferences) {
      return preferences.setString(key, value);
    },
  );

  /// [key]に保存された真偽値を取得する。
  Future<bool?> readBool(String key) async => (await _preferences).getBool(key);

  /// [value]を真偽値として[key]へ保存する。
  Future<void> writeBool(String key, bool value) => _write(
    key: key,
    operation: 'writeBool',
    write: (preferences) {
      return preferences.setBool(key, value);
    },
  );

  /// [key]に保存された整数を取得する。
  Future<int?> readInt(String key) async => (await _preferences).getInt(key);

  /// [value]を整数として[key]へ保存する。
  Future<void> writeInt(String key, int value) => _write(
    key: key,
    operation: 'writeInt',
    write: (preferences) {
      return preferences.setInt(key, value);
    },
  );

  /// [key]に保存された小数を取得する。
  Future<double?> readDouble(String key) async =>
      (await _preferences).getDouble(key);

  /// [value]を小数として[key]へ保存する。
  Future<void> writeDouble(String key, double value) => _write(
    key: key,
    operation: 'writeDouble',
    write: (preferences) {
      return preferences.setDouble(key, value);
    },
  );

  /// [key]に保存された文字列一覧を取得する。
  Future<List<String>?> readStringList(String key) async =>
      (await _preferences).getStringList(key);

  /// [value]を文字列一覧として[key]へ保存する。
  Future<void> writeStringList(String key, List<String> value) => _write(
    key: key,
    operation: 'writeStringList',
    write: (preferences) {
      return preferences.setStringList(key, value);
    },
  );

  /// [key]に保存された値を削除する。
  Future<void> remove(String key) => _write(
    key: key,
    operation: 'remove',
    write: (preferences) {
      return preferences.remove(key);
    },
  );

  /// 変更処理の戻り値を検査し、失敗を例外へ変換する。
  Future<void> _write({
    required String key,
    required String operation,
    required Future<bool> Function(SharedPreferences preferences) write,
  }) async {
    final succeeded = await write(await _preferences);
    if (!succeeded) {
      throw StorageWriteException(operation: operation, key: key);
    }
  }
}
