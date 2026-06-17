import 'package:test/test.dart';
import 'package:protocol/protocol.dart';

void main() {
  group('Protocol', () {
    test('escape strings', () {
      expect(ControlBytes.esc, '\x1b');
      expect(ControlBytes.csi, '\x1b[');
      expect(ControlBytes.osc, '\x1b]');
      expect(ControlBytes.dcs, '\x1bP');
      expect(ControlBytes.st, '\x1b\\');
      expect(ControlBytes.bel, '\x07');
    });

    test('control bytes', () {
      expect(ControlBytes.escapeByte, 0x1B);
      expect(ControlBytes.bellByte, 0x07);
      expect(ControlBytes.carriageReturnByte, 0x0D);
    });

    test('SGR codes', () {
      expect(SgrCodes.sgrReset, 0);
      expect(SgrCodes.sgrBold, 1);
      expect(SgrCodes.sgrFaint, 2);
      expect(SgrCodes.sgrItalic, 3);
      expect(SgrCodes.sgrUnderline, 4);
      expect(SgrCodes.sgrBlink, 5);
      expect(SgrCodes.sgrReverse, 7);
      expect(SgrCodes.sgrStrikethrough, 9);
      expect(SgrCodes.sgrOverline, 53);
    });

    test('ANSI color base codes', () {
      expect(SgrCodes.sgrFgAnsiBase, 30);
      expect(SgrCodes.sgrBgAnsiBase, 40);
      expect(SgrCodes.sgrFgBrightBase, 90);
      expect(SgrCodes.sgrBgBrightBase, 100);
      expect(SgrCodes.sgrFgExtended, 38);
      expect(SgrCodes.sgrBgExtended, 48);
    });

    test('DEC private modes', () {
      expect(DecModes.decModeMouseNormal, 1000);
      expect(DecModes.decModeMouseSgr, 1006);
      expect(DecModes.decModeBracketedPaste, 2004);
      expect(DecModes.decModeSync, 2026);
      expect(DecModes.decModeAltScreen, 1049);
    });

    test('default sizes', () {
      expect(SizeDefaults.defaultTerminalWidth, 80);
      expect(SizeDefaults.defaultTerminalHeight, 24);
    });

    test('border glyph sets', () {
      expect(WidgetChars.borderSingle.length, 6);
      expect(WidgetChars.borderDouble.length, 6);
      expect(WidgetChars.borderRounded.length, 6);
      expect(WidgetChars.borderThick.length, 6);
    });

    test('cursor styles', () {
      expect(DecModes.cursorStyleBlinkingBlock, 1);
      expect(DecModes.cursorStyleSteadyBlock, 2);
      expect(DecModes.cursorStyleBlinkingUnderline, 3);
      expect(DecModes.cursorStyleSteadyUnderline, 4);
      expect(DecModes.cursorStyleBlinkingBar, 5);
      expect(DecModes.cursorStyleSteadyBar, 6);
    });
  });
}
