/// SharedPreferencesが値の変更を完了できなかったことを表す。
final class StorageWriteException implements Exception {
  const StorageWriteException({required this.operation, required this.key});

  final String operation;
  final String key;

  @override
  String toString() => 'Failed to $operation value for key: $key';
}
