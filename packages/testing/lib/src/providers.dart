import 'package:protocol/protocol.dart' show Defaults;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'virtual_terminal.dart';
import 'widget_tester.dart';

part 'providers.g.dart';

/// Factory provider that creates a [VirtualTerminal] managed by Riverpod.
///
/// Example:
/// ```dart
/// final container = ProviderContainer();
/// final terminal = container.read(virtualTerminalProvider);
/// terminal.write('Hello');
/// container.dispose();
/// ```
@riverpod
VirtualTerminal virtualTerminal(Ref ref) {
  return VirtualTerminal();
}

/// Factory provider that creates a [VirtualTerminal] with custom dimensions.
///
/// Example:
/// ```dart
/// final container = ProviderContainer();
/// final terminal = container.read(
///   virtualTerminalWithSizeProvider(width: 80, height: 24),
/// );
/// container.dispose();
/// ```
@riverpod
VirtualTerminal virtualTerminalWithSize(
  Ref ref, {
  int width = Defaults.defaultTerminalWidth,
  int height = Defaults.defaultTerminalHeight,
}) {
  return VirtualTerminal(width: width, height: height);
}

/// Factory provider that creates a [WidgetTester] managed by Riverpod.
///
/// Example:
/// ```dart
/// final container = ProviderContainer();
/// final tester = container.read(widgetTesterProvider);
/// tester.pumpWidget(MyWidget());
/// tester.expectCell(0, 0, char: 'H');
/// container.dispose();
/// ```
@riverpod
WidgetTester widgetTester(Ref ref) {
  return WidgetTester();
}
