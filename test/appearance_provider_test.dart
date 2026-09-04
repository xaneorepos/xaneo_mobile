import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xaneo/providers/appearance_provider.dart';

Future<void> _waitUntilLoaded(AppearanceProvider provider) async {
  if (provider.isLoaded) return;

  final completer = Completer<void>();
  void listener() {
    if (provider.isLoaded && !completer.isCompleted) completer.complete();
  }

  provider.addListener(listener);
  await completer.future;
  provider.removeListener(listener);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads persisted theme and animation settings', () async {
    SharedPreferences.setMockInitialValues({
      'mobile_dark_mode': false,
      'mobile_animations': false,
    });

    final provider = AppearanceProvider();
    await _waitUntilLoaded(provider);

    expect(provider.isDarkMode, isFalse);
    expect(provider.animationsEnabled, isFalse);
  });

  test('updates and persists theme and animation settings', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = AppearanceProvider();
    await _waitUntilLoaded(provider);

    await provider.setDarkMode(false);
    await provider.setAnimationsEnabled(false);

    expect(provider.isDarkMode, isFalse);
    expect(provider.animationsEnabled, isFalse);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool('mobile_dark_mode'), isFalse);
    expect(preferences.getBool('mobile_animations'), isFalse);
  });
}
