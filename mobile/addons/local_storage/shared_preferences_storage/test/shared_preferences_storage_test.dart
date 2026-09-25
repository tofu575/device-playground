import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_storage/shared_preferences_storage.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  test('stores primitive values independently', () async {
    const storage = SharedPreferencesStorage();

    await storage.writeString('text', 'value');
    await storage.writeBool('enabled', true);
    await storage.writeInt('count', 3);
    await storage.writeDouble('ratio', 0.5);
    await storage.writeStringList('items', <String>['a', 'b']);

    expect(await storage.readString('text'), 'value');
    expect(await storage.readBool('enabled'), isTrue);
    expect(await storage.readInt('count'), 3);
    expect(await storage.readDouble('ratio'), 0.5);
    expect(await storage.readStringList('items'), <String>['a', 'b']);
  });

  test('stores and restores an arbitrary JSON value', () async {
    final storage = JsonStorage<List<String>>(
      key: 'sample.json',
      decode: (json) => (json! as List<Object?>).cast<String>(),
      encode: (value) => value,
    );

    await storage.write(<String>['first', 'second']);

    expect(await storage.read(), <String>['first', 'second']);
  });

  test('removes a stored value', () async {
    const storage = SharedPreferencesStorage();
    await storage.writeString('key', 'value');

    await storage.remove('key');

    expect(await storage.readString('key'), isNull);
  });
}
