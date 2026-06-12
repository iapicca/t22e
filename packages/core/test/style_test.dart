import 'package:test/test.dart';
import 'package:core/core.dart';

void main() {
  group('TextStyle', () {
    test('empty has all defaults', () {
      const s = TextStyle.empty;
      expect(s.foreground, isNull);
      expect(s.background, isNull);
      expect(s.bold, isNull);
      expect(s.isClear, isTrue);
    });

    test('copyWith overrides field', () {
      const base = TextStyle(bold: true, italic: true);
      final result = base.copyWith(bold: false);
      expect(result.bold, isFalse);
      expect(result.italic, isTrue);
    });

    test('copyWith with empty unchanged returns equal style', () {
      const s = TextStyle(bold: true);
      expect(s.copyWith(), equals(s));
    });

    test('copyWith from empty sets field', () {
      final result = TextStyle.empty.copyWith(bold: true);
      expect(result.bold, isTrue);
    });

    test('resolveColor noColor clears colors', () {
      const s = TextStyle(foreground: Color(red: 255, green: 0, blue: 0));
      final resolved = s.resolveColor(ColorProfile.noColor);
      expect(resolved.foreground, isNull);
    });

    test('resolveColor ansi16 keeps color (sgrSequence handles format)', () {
      const s = TextStyle(foreground: Color(red: 255, green: 0, blue: 0));
      final resolved = s.resolveColor(ColorProfile.ansi16);
      expect(identical(resolved, s), isTrue);
    });

    test('resolveColor with null colors returns self', () {
      const s = TextStyle(bold: true);
      final resolved = s.resolveColor(ColorProfile.noColor);
      expect(identical(resolved, s), isTrue);
    });

    test('resolveColor with null colors returns self for ansi16', () {
      const s = TextStyle(bold: true);
      final resolved = s.resolveColor(ColorProfile.ansi16);
      expect(identical(resolved, s), isTrue);
    });

    test('inherit fills null fields from parent', () {
      final parent = TextStyle(foreground: AnsiColor(1).toColor(), bold: true);
      const child = TextStyle(italic: true);
      final inherited = child.inherit(parent);
      expect(inherited.foreground, parent.foreground);
      expect(inherited.bold, isTrue);
      expect(inherited.italic, isTrue);
    });

    test('inherit preserves child non-null fields', () {
      final parent = TextStyle(foreground: AnsiColor(1).toColor());
      final child = TextStyle(foreground: AnsiColor(2).toColor(), italic: true);
      final inherited = child.inherit(parent);
      expect(inherited.foreground, AnsiColor(2).toColor());
    });

    test('inherit from empty returns child unchanged', () {
      const child = TextStyle(bold: true);
      final inherited = child.inherit(TextStyle.empty);
      expect(inherited.bold, isTrue);
    });

    test('empty.inherit(parent) returns parent', () {
      const parent = TextStyle(bold: true);
      final inherited = TextStyle.empty.inherit(parent);
      expect(inherited.bold, isTrue);
    });

    test('deep nesting: child.inherit(parent).inherit(grandparent)', () {
      final grandparent = TextStyle(foreground: AnsiColor(1).toColor());
      final parent = TextStyle(foreground: AnsiColor(2).toColor(), bold: true);
      const child = TextStyle(italic: true);
      final inherited = child.inherit(parent).inherit(grandparent);
      expect(inherited.foreground, AnsiColor(2).toColor());
      expect(inherited.bold, isTrue);
      expect(inherited.italic, isTrue);
    });

    test('equality', () {
      const a = TextStyle(bold: true, italic: true);
      const b = TextStyle(bold: true, italic: true);
      const c = TextStyle(bold: true, italic: false);
      expect(a == b, isTrue);
      expect(a == c, isFalse);
    });

    test('hashCode consistent with equality', () {
      const a = TextStyle(bold: true);
      const b = TextStyle(bold: true);
      expect(a.hashCode, b.hashCode);
    });
  });
}
