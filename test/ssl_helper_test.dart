import 'package:flutter_test/flutter_test.dart';
import 'package:xaneo/utils/ssl_helper.dart';

void main() {
  test('invalid certificates are limited to the configured private host', () {
    expect(isConfiguredPrivateDevelopmentHost('192.168.1.42'), isTrue);
    expect(isConfiguredPrivateDevelopmentHost('192.168.1.43'), isFalse);
    expect(isConfiguredPrivateDevelopmentHost('xaneo.ru'), isFalse);
    expect(isConfiguredPrivateDevelopmentHost('example.com'), isFalse);
  });
}
