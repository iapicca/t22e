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

    test('merge overrides non-null fields', () {
      const base = TextStyle(bold: true, italic: true);
      const override = TextStyle(bold: false);
      final merged = base.merge(override);
      expect(merged.bold, isFalse);
      expect(merged.italic, isTrue);
    });

    test('merge with empty returns self', () {
      const s = TextStyle(bold: true);
      expect(identical(s.merge(TextStyle.empty), s), isTrue);
    });

    test('merge empty with non-empty returns non-empty', () {
      const s = TextStyle(bold: true);
      final merged = TextStyle.empty.merge(s);
      expect(merged.bold, isTrue);
    });

    test('resolveColor noColor clears colors', () {
      const s = TextStyle(
        foreground: Color(red: 255, green: 0, blue: 0),
      );
      final resolved = s.resolveColor(ColorProfile.noColor);
      expect(resolved.foreground, isNull);
    });

    test('resolveColor ansi16 keeps color (sgrSequence handles format)', () {
      const s = TextStyle(
        foreground: Color(red: 255, green: 0, blue: 0),
      );
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
      final parent = TextStyle(
        foreground: Color.fromAnsi(AnsiColor(1)),
        bold: true,
      );
      const child = TextStyle(italic: true);
      final inherited = child.inherit(parent);
      expect(inherited.foreground, parent.foreground);
      expect(inherited.bold, isTrue);
      expect(inherited.italic, isTrue);
    });

    test('inherit preserves child non-null fields', () {
      final parent = TextStyle(
        foreground: Color.fromAnsi(AnsiColor(1)),
      );
      final child = TextStyle(
        foreground: Color.fromAnsi(AnsiColor(2)),
        italic: true,
      );
      final inherited = child.inherit(parent);
      expect(inherited.foreground, Color.fromAnsi(AnsiColor(2)));
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
      final grandparent = TextStyle(
        foreground: Color.fromAnsi(AnsiColor(1)),
      );
      final parent = TextStyle(
        foreground: Color.fromAnsi(AnsiColor(2)),
        bold: true,
      );
      const child = TextStyle(italic: true);
      final inherited = child.inherit(parent).inherit(grandparent);
      expect(inherited.foreground, Color.fromAnsi(AnsiColor(2)));
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
