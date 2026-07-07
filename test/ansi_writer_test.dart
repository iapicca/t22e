import 'package:riverpod/riverpod.dart';
import 'package:t22e/t22e.dart';
import 'package:test/test.dart';

void main() {
  group('AnsiWriter', () {
    const writer = AnsiWriter();

    test('positions the cursor with a CSI sequence', () {
      final output = writer.write(const [
        DiffOpMove(Offset(2, 1)),
      ], Size(10, 10));

      expect(output, '\x1B[2;3H');
    });

    test('writes characters unchanged', () {
      final output = writer.write(const [
        DiffOpWrite('A'),
        DiffOpWrite('B'),
      ], Size(2, 1));

      expect(output, 'AB');
    });

    test('does not emit reset when the default style is already active', () {
      final output = writer.write(const [DiffOpStyle(Cell.blank)], Size(1, 1));

      expect(output, isEmpty);
    });

    test('emits SGR for style flags and foreground color', () {
      final output = writer.write(const [
        DiffOpStyle(Cell(foreground: Color.red(), styles: {CellStyle.bold})),
      ], Size(1, 1));

      expect(output, '\x1B[1;31m');
    });

    test('emits SGR for background colors', () {
      final output = writer.write(const [
        DiffOpStyle(Cell(background: Color.brightWhite())),
      ], Size(1, 1));

      expect(output, '\x1B[107m');
    });

    test('combines moves, styles, and writes', () {
      final output = writer.write(const [
        DiffOpMove(Offset(1, 0)),
        DiffOpStyle(
          Cell(foreground: Color.blue(), styles: {CellStyle.underline}),
        ),
        DiffOpWrite('X'),
      ], Size(5, 1));

      expect(output, '\x1B[1;2H\x1B[4;34mX');
    });

    test('emits reset when transitioning to the default style', () {
      final output = writer.write(const [
        DiffOpStyle(Cell(foreground: Color.green())),
        DiffOpStyle(Cell.blank),
        DiffOpWrite('A'),
      ], Size(1, 1));

      expect(output, '\x1B[32m\x1B[0mA');
    });

    test('continuation style is never emitted as an SGR code', () {
      final output = writer.write(const [
        DiffOpStyle(Cell(styles: {CellStyle.continuation})),
        DiffOpWrite('A'),
      ], Size(1, 1));

      expect(output, 'A');
    });

    test('provider exposes a default ANSI writer instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final writer = container.read(ansiWriterProvider);

      expect(writer, isA<AnsiWriter>());
    });
  });
}
