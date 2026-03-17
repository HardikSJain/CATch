import 'package:flutter_test/flutter_test.dart';
import 'package:catch_app/main.dart';

void main() {
  // Widget tests that depend on DI (get_it) and SQLite require
  // platform channels which aren't available in unit test environment.
  // Full widget tests will use integration_test/ with a real device.
  //
  // For now, verify the app widget can be constructed.
  test('CatchApp can be instantiated', () {
    const app = CatchApp();
    expect(app, isNotNull);
  });
}
