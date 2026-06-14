import 'package:test/test.dart';
import 'package:protocol/protocol.dart';

void main() {
  group('Defaults', () {
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

    test('CSI final bytes', () {
      expect(CsiFinals.csiFinalUp, 0x41);
      expect(CsiFinals.csiFinalDown, 0x42);
      expect(CsiFinals.csiFinalRight, 0x43);
      expect(CsiFinals.csiFinalLeft, 0x44);
      expect(CsiFinals.csiFinalCup, 0x48);
      expect(CsiFinals.csiFinalEd, 0x4A);
      expect(CsiFinals.csiFinalEl, 0x4B);
    });

    test('DEC private modes', () {
      expect(DecModes.decModeMouseNormal, 1000);
      expect(DecModes.decModeMouseSgr, 1006);
      expect(DecModes.decModeBracketedPaste, 2004);
      expect(DecModes.decModeSync, 2026);
      expect(DecModes.decModeAltScreen, 1049);
    });

    test('DA1 attributes', () {
      expect(Da1Codes.da1AttrIndexed256, 22);
      expect(Da1Codes.da1AttrTrueColor, 28);
    });

    test('modifier bit masks', () {
      expect(Modifiers.modShift, 1);
      expect(Modifiers.modAlt, 2);
      expect(Modifiers.modCtrl, 4);
      expect(Modifiers.modMeta, 8);
    });

    test('termios constants', () {
      expect(Termios.termiosEcho, 0x00000008);
      expect(Termios.termiosICanon, 0x00000002);
      expect(Termios.termiosISig, 0x00000001);
      expect(Termios.termiosIExten, 0x00008000);
    });

    test('default sizes', () {
      expect(SizeDefaults.defaultTerminalWidth, 80);
      expect(SizeDefaults.defaultTerminalHeight, 24);
    });

    test('spinner frames', () {
      expect(SpinnerFrames.spinnerFrames, isNotEmpty);
      expect(SpinnerFrames.spinnerFrames.length, 10);
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
