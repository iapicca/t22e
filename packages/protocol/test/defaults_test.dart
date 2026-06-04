import 'package:test/test.dart';
import 'package:protocol/protocol.dart';

void main() {
  group('Defaults', () {
    test('escape strings', () {
      expect(Defaults.esc, '\x1b');
      expect(Defaults.csi, '\x1b[');
      expect(Defaults.osc, '\x1b]');
      expect(Defaults.dcs, '\x1bP');
      expect(Defaults.st, '\x1b\\');
      expect(Defaults.bel, '\x07');
    });

    test('control bytes', () {
      expect(Defaults.escapeByte, 0x1B);
      expect(Defaults.bellByte, 0x07);
      expect(Defaults.carriageReturnByte, 0x0D);
      expect(Defaults.lineFeedByte, 0x0A);
    });

    test('SGR codes', () {
      expect(Defaults.sgrReset, 0);
      expect(Defaults.sgrBold, 1);
      expect(Defaults.sgrFaint, 2);
      expect(Defaults.sgrItalic, 3);
      expect(Defaults.sgrUnderline, 4);
      expect(Defaults.sgrBlink, 5);
      expect(Defaults.sgrReverse, 7);
      expect(Defaults.sgrStrikethrough, 9);
      expect(Defaults.sgrOverline, 53);
    });

    test('ANSI color base codes', () {
      expect(Defaults.sgrFgAnsiBase, 30);
      expect(Defaults.sgrBgAnsiBase, 40);
      expect(Defaults.sgrFgBrightBase, 90);
      expect(Defaults.sgrBgBrightBase, 100);
      expect(Defaults.sgrFgExtended, 38);
      expect(Defaults.sgrBgExtended, 48);
    });

    test('CSI final bytes', () {
      expect(Defaults.csiFinalUp, 0x41);
      expect(Defaults.csiFinalDown, 0x42);
      expect(Defaults.csiFinalRight, 0x43);
      expect(Defaults.csiFinalLeft, 0x44);
      expect(Defaults.csiFinalCup, 0x48);
      expect(Defaults.csiFinalEd, 0x4A);
      expect(Defaults.csiFinalEl, 0x4B);
    });

    test('DEC private modes', () {
      expect(Defaults.decModeMouseNormal, 1000);
      expect(Defaults.decModeMouseSgr, 1006);
      expect(Defaults.decModeBracketedPaste, 2004);
      expect(Defaults.decModeSync, 2026);
      expect(Defaults.decModeAltScreen, 1049);
    });

    test('DA1 attributes', () {
      expect(Defaults.da1AttrIndexed256, 22);
      expect(Defaults.da1AttrTrueColor, 28);
    });

    test('modifier bit masks', () {
      expect(Defaults.modShift, 1);
      expect(Defaults.modAlt, 2);
      expect(Defaults.modCtrl, 4);
      expect(Defaults.modMeta, 8);
    });

    test('termios constants', () {
      expect(Defaults.termiosEcho, 0x00000008);
      expect(Defaults.termiosICanon, 0x00000002);
      expect(Defaults.termiosISig, 0x00000001);
      expect(Defaults.termiosIExten, 0x00008000);
    });

    test('default sizes', () {
      expect(Defaults.defaultTerminalWidth, 80);
      expect(Defaults.defaultTerminalHeight, 24);
    });

    test('spinner frames', () {
      expect(Defaults.spinnerFrames, isNotEmpty);
      expect(Defaults.spinnerFrames.length, 10);
    });

    test('border glyph sets', () {
      expect(Defaults.borderSingle.length, 6);
      expect(Defaults.borderDouble.length, 6);
      expect(Defaults.borderRounded.length, 6);
      expect(Defaults.borderThick.length, 6);
    });

    test('cursor styles', () {
      expect(Defaults.cursorStyleBlinkingBlock, 1);
      expect(Defaults.cursorStyleSteadyBlock, 2);
      expect(Defaults.cursorStyleBlinkingUnderline, 3);
      expect(Defaults.cursorStyleSteadyUnderline, 4);
      expect(Defaults.cursorStyleBlinkingBar, 5);
      expect(Defaults.cursorStyleSteadyBar, 6);
    });
  });
}
