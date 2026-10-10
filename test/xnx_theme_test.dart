import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xaneo/models/xnx_theme.dart';

void main() {
  test('parses dark and light colors independently', () {
    final theme = XnxTheme.parse('''
# portable theme
{
  meta = { name = "Nightheart"; };
  default-mode = "light";
  schemes = {
    dark = { colors = { bg = "#10121b"; text = "#f5f3ee"; }; };
    light = { colors = { bg = "#f3f2f7"; text = "#202231"; }; };
  };
}
''');
    expect(theme.name, 'Nightheart');
    expect(theme.defaultMode, 'light');
    expect(theme.color('bg', true)?.value, 0xFF10121B);
    expect(theme.color('bg', false)?.value, 0xFFF3F2F7);
  });

  test('rejects malformed and oversized files', () {
    expect(() => XnxTheme.parse('{ colors = { bg = "#fff" }; }'),
        throwsFormatException);
    expect(() => XnxTheme.parse('x' * 65537), throwsFormatException);
  });

  test('ignores unsafe color values', () {
    final theme = XnxTheme.parse(
        '{ colors = { bg = "url(javascript:evil)"; text = "#fff"; }; }');
    expect(theme.color('bg', true), isNull);
  });

  test('accepts rgba and transparent values', () {
    final theme = XnxTheme.parse(
        '{ colors = { bg = "rgba(16, 32, 48, 0.5)"; surface = "transparent"; }; }');
    expect(theme.color('bg', true)?.value, 0x80102030);
    expect(theme.color('surface', true)?.value, 0x00000000);
  });

  test('exports edited light and dark palettes without losing imported fields',
      () {
    final imported = XnxTheme.parse('''
{
  meta = { name = "Custom"; author = "Alice"; };
  default-mode = "dark";
  schemes = {
    dark = { colors = { bg = "#101010"; accent = "#ff0000"; }; };
    light = { colors = { bg = "#ffffff"; accent = "#0000ff"; }; };
  };
  geometry = { radius = "12px"; };
}
''');
    final edited = imported
        .withColor('accent', const Color(0xFF123456), false)
        .withName('Edited')
        .withMode(false)
        .withRadius(18);
    final roundTrip = XnxTheme.parse(edited.toSource());
    expect(roundTrip.name, 'Edited');
    expect(roundTrip.author, 'Alice');
    expect(roundTrip.defaultMode, 'light');
    expect(roundTrip.radius, 18);
    expect(roundTrip.color('accent', false)?.value, 0xFF123456);
    expect(roundTrip.color('accent', true)?.value, 0xFFFF0000);
  });

  test('message colors follow XC fallback rules and explicit overrides', () {
    final theme = XnxTheme.parse('''
{
  colors = {
    surface = "#112233"; text = "#ffffff";
    btn-primary-bg = "#445566"; btn-primary-text = "#000000";
  };
}
''');
    expect(theme.messageColor(outgoing: false, text: false, dark: true)?.value,
        0xFF112233);
    expect(theme.messageColor(outgoing: true, text: false, dark: true)?.value,
        0xFF445566);
    expect(theme.messageColor(outgoing: true, text: true, dark: true)?.value,
        0xFF000000);
    final edited =
        theme.withColor('message-outgoing-bg', const Color(0xFF778899), true);
    expect(edited.messageColor(outgoing: true, text: false, dark: true)?.value,
        0xFF778899);
  });

  test('blur imports from XNX and exports as CSS pixels', () {
    final base = XnxTheme.preset('Default');
    expect(base.blurPercent, 0);
    final edited = base.withBlurPercent(50);
    expect(edited.blurPercent, 50);
    expect(edited.toSource(), contains('blur = "12.0px"'));
    expect(XnxTheme.parse(edited.toSource()).blurPercent, 50);
    expect(edited.withBlurPercent(0).blurPercent, 0);
    expect(edited.withBlurPercent(100).blurPercent, 100);
  });
}
