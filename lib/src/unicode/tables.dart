import 'dart:typed_data';

const int _stage1Len = 0x1100;
const int _stage2Len = 0x10000;

final Uint8List _stage1 = Uint8List(_stage1Len);
final Uint8List _stage2 = Uint8List(_stage2Len);

final bool _initialized = _initTables();

int _prop(int width, bool emoji, bool printable, bool privateUse) {
  return (width & 0x03) |
      (emoji ? 0x04 : 0) |
      (printable ? 0x08 : 0) |
      (privateUse ? 0x10 : 0);
}

const _propN = 0x00; // width 0, not printable
const _prop1 = 0x09; // width 1, printable
const _prop2 = 0x0A; // width 2, printable
const _propE = 0x0E; // width 2, printable, emoji

bool _initTables() {
  for (var i = 0; i < _stage1Len; i++) {
    _stage1[i] = i;
  }
  _stage2.fillRange(0, _stage2Len, _prop1);
  _setRange(0x0000, 0x001F, _propN);
  _setRange(0x007F, 0x009F, _propN);
  _setRange(0x00AD, 0x00AD, _propN);
  _setRange(0x0300, 0x036F, _propN);
  _setRange(0x0483, 0x0489, _propN);
  _setRange(0x0591, 0x05BD, _propN);
  _setRange(0x05BF, 0x05BF, _propN);
  _setRange(0x05C1, 0x05C2, _propN);
  _setRange(0x05C4, 0x05C5, _propN);
  _setRange(0x05C7, 0x05C7, _propN);
  _setRange(0x0610, 0x061A, _propN);
  _setRange(0x064B, 0x065F, _propN);
  _setRange(0x0670, 0x0670, _propN);
  _setRange(0x06D6, 0x06DC, _propN);
  _setRange(0x06DF, 0x06E4, _propN);
  _setRange(0x06E7, 0x06E8, _propN);
  _setRange(0x06EA, 0x06ED, _propN);
  _setRange(0x0711, 0x0711, _propN);
  _setRange(0x0730, 0x074A, _propN);
  _setRange(0x07A6, 0x07B0, _propN);
  _setRange(0x07EB, 0x07F3, _propN);
  _setRange(0x0816, 0x0819, _propN);
  _setRange(0x081B, 0x0823, _propN);
  _setRange(0x0825, 0x0827, _propN);
  _setRange(0x0829, 0x082D, _propN);
  _setRange(0x0859, 0x085B, _propN);
  _setRange(0x08D4, 0x08E1, _propN);
  _setRange(0x08E3, 0x0902, _propN);
  _setRange(0x093A, 0x093A, _propN);
  _setRange(0x093C, 0x093C, _propN);
  _setRange(0x0941, 0x0948, _propN);
  _setRange(0x094D, 0x094D, _propN);
  _setRange(0x0951, 0x0957, _propN);
  _setRange(0x0962, 0x0963, _propN);
  _setRange(0x0981, 0x0981, _propN);
  _setRange(0x09BC, 0x09BC, _propN);
  _setRange(0x09C1, 0x09C4, _propN);
  _setRange(0x09CD, 0x09CD, _propN);
  _setRange(0x09E2, 0x09E3, _propN);
  _setRange(0x0A01, 0x0A02, _propN);
  _setRange(0x0A3C, 0x0A3C, _propN);
  _setRange(0x0A41, 0x0A42, _propN);
  _setRange(0x0A47, 0x0A48, _propN);
  _setRange(0x0A4B, 0x0A4D, _propN);
  _setRange(0x0A70, 0x0A71, _propN);
  _setRange(0x0A81, 0x0A82, _propN);
  _setRange(0x0ABC, 0x0ABC, _propN);
  _setRange(0x0AC1, 0x0AC5, _propN);
  _setRange(0x0AC7, 0x0AC8, _propN);
  _setRange(0x0ACD, 0x0ACD, _propN);
  _setRange(0x0AE2, 0x0AE3, _propN);
  _setRange(0x0B01, 0x0B01, _propN);
  _setRange(0x0B3C, 0x0B3C, _propN);
  _setRange(0x0B3F, 0x0B3F, _propN);
  _setRange(0x0B41, 0x0B44, _propN);
  _setRange(0x0B4D, 0x0B4D, _propN);
  _setRange(0x0B56, 0x0B56, _propN);
  _setRange(0x0B62, 0x0B63, _propN);
  _setRange(0x0B82, 0x0B82, _propN);
  _setRange(0x0BC0, 0x0BC0, _propN);
  _setRange(0x0BCD, 0x0BCD, _propN);
  _setRange(0x0C3E, 0x0C40, _propN);
  _setRange(0x0C46, 0x0C48, _propN);
  _setRange(0x0C4A, 0x0C4D, _propN);
  _setRange(0x0C55, 0x0C56, _propN);
  _setRange(0x0C62, 0x0C63, _propN);
  _setRange(0x0CBC, 0x0CBC, _propN);
  _setRange(0x0CBF, 0x0CBF, _propN);
  _setRange(0x0CC6, 0x0CC6, _propN);
  _setRange(0x0CCC, 0x0CCD, _propN);
  _setRange(0x0CE2, 0x0CE3, _propN);
  _setRange(0x0D41, 0x0D44, _propN);
  _setRange(0x0D4D, 0x0D4D, _propN);
  _setRange(0x0D62, 0x0D63, _propN);
  _setRange(0x0DCA, 0x0DCA, _propN);
  _setRange(0x0DD2, 0x0DD4, _propN);
  _setRange(0x0DD6, 0x0DD6, _propN);
  _setRange(0x0E31, 0x0E31, _propN);
  _setRange(0x0E34, 0x0E3A, _propN);
  _setRange(0x0E47, 0x0E4E, _propN);
  _setRange(0x0EB1, 0x0EB1, _propN);
  _setRange(0x0EB4, 0x0EB9, _propN);
  _setRange(0x0EBB, 0x0EBC, _propN);
  _setRange(0x0EC8, 0x0ECD, _propN);
  _setRange(0x0F18, 0x0F19, _propN);
  _setRange(0x0F35, 0x0F35, _propN);
  _setRange(0x0F37, 0x0F37, _propN);
  _setRange(0x0F39, 0x0F39, _propN);
  _setRange(0x0F71, 0x0F7E, _propN);
  _setRange(0x0F80, 0x0F84, _propN);
  _setRange(0x0F86, 0x0F87, _propN);
  _setRange(0x0F90, 0x0F97, _propN);
  _setRange(0x0F99, 0x0FBC, _propN);
  _setRange(0x0FC6, 0x0FC6, _propN);
  _setRange(0x102D, 0x1030, _propN);
  _setRange(0x1032, 0x1037, _propN);
  _setRange(0x1039, 0x103A, _propN);
  _setRange(0x103D, 0x103E, _propN);
  _setRange(0x1058, 0x1059, _propN);
  _setRange(0x105E, 0x1060, _propN);
  _setRange(0x1071, 0x1074, _propN);
  _setRange(0x1082, 0x1082, _propN);
  _setRange(0x1085, 0x1086, _propN);
  _setRange(0x108D, 0x108D, _propN);
  _setRange(0x109D, 0x109D, _propN);
  _setRange(0x200B, 0x200F, _propN);
  _setRange(0x2028, 0x202E, _propN);
  _setRange(0x2060, 0x2069, _propN);
  _setRange(0xFE00, 0xFE0F, _propN);
  _setRange(0xFE20, 0xFE2F, _propN);
  _setRange(0xE0100, 0xE01EF, _propN);

  _setRange(0x1100, 0x115F, _prop2);
  _setRange(0x2329, 0x232A, _prop2);
  _setRange(0x2E80, 0x2EFF, _prop2);
  _setRange(0x2F00, 0x2FDF, _prop2);
  _setRange(0x3000, 0x303E, _prop2);
  _setRange(0x3041, 0x3096, _prop2);
  _setRange(0x3099, 0x309A, _propN);
  _setRange(0x309B, 0x30FF, _prop2);
  _setRange(0x3105, 0x312D, _prop2);
  _setRange(0x3131, 0x318E, _prop2);
  _setRange(0x3190, 0x31EF, _prop2);
  _setRange(0x31F0, 0x321E, _prop2);
  _setRange(0x3220, 0x3247, _prop2);
  _setRange(0x3250, 0x32FE, _prop2);
  _setRange(0x3300, 0x33FF, _prop2);
  _setRange(0x3400, 0x4DBF, _prop2);
  _setRange(0x4E00, 0x9FFF, _prop2);
  _setRange(0xA000, 0xA4CF, _prop2);
  _setRange(0xA4D0, 0xA4FF, _prop2);
  _setRange(0xA500, 0xA63F, _prop2);
  _setRange(0xA640, 0xA69F, _prop2);
  _setRange(0xA700, 0xA7BF, _prop2);
  _setRange(0xA7C0, 0xA7FF, _prop2);
  _setRange(0xA800, 0xA82F, _prop2);
  _setRange(0xA840, 0xA87F, _prop2);
  _setRange(0xA880, 0xA8DF, _prop2);
  _setRange(0xA8E0, 0xA8FF, _prop2);
  _setRange(0xA900, 0xA92F, _prop2);
  _setRange(0xA930, 0xA95F, _prop2);
  _setRange(0xA960, 0xA97F, _prop2);
  _setRange(0xA980, 0xA9DF, _prop2);
  _setRange(0xAA00, 0xAA5F, _prop2);
  _setRange(0xAA60, 0xAA7F, _prop2);
  _setRange(0xAA80, 0xAAFF, _prop2);
  _setRange(0xAB00, 0xAB2F, _prop2);
  _setRange(0xAB30, 0xAB6F, _prop2);
  _setRange(0xAB70, 0xABFF, _prop2);
  _setRange(0xAC00, 0xD7AF, _prop2);
  _setRange(0xD7B0, 0xD7FF, _prop2);
  _setRange(0xE000, 0xF8FF, _prop(1, false, true, true));
  _setRange(0xF900, 0xFAFF, _prop2);
  _setRange(0xFB00, 0xFB4F, _prop1);
  _setRange(0xFB50, 0xFDFF, _prop1);
  _setRange(0xFE10, 0xFE1F, _prop2);
  _setRange(0xFE30, 0xFE6F, _prop2);
  _setRange(0xFE70, 0xFEFF, _prop2);
  _setRange(0xFF01, 0xFF60, _prop2);
  _setRange(0xFFE0, 0xFFE6, _prop2);

  // Supplementary plane emoji handled in _lookup

  for (var i = 0; i < _stage1Len; i++) {
    _stage1[i] = i;
  }

  return true;
}

void _setRange(int start, int end, int prop) {
  if (start < 0) return;
  for (var cp = start; cp <= end && cp <= 0xFFFF; cp++) {
    final high = cp >> 8;
    final low = cp & 0xFF;
    if (high >= _stage1Len) continue;
    final s2idx = _stage1[high] * 256 + low;
    if (s2idx >= _stage2Len) continue;
    _stage2[s2idx] = prop;
  }
}

int _lookup(int codepoint) {
  if (!_initialized) return _prop1;
  if (codepoint < 0 || codepoint > 0x10FFFF) return 0;
  if (codepoint >= 0x1B000 && codepoint <= 0x1B0FF) return _prop2;
  if (codepoint >= 0x1B100 && codepoint <= 0x1B12F) return _prop2;
  if ((codepoint >= 0x1F004 && codepoint <= 0x1F004) ||
      (codepoint >= 0x1F0CF && codepoint <= 0x1F0CF) ||
      (codepoint >= 0x1F18E && codepoint <= 0x1F19A) ||
      (codepoint >= 0x1F200 && codepoint <= 0x1F251) ||
      (codepoint >= 0x1F300 && codepoint <= 0x1F320) ||
      (codepoint >= 0x1F32D && codepoint <= 0x1F335) ||
      (codepoint >= 0x1F337 && codepoint <= 0x1F37C) ||
      (codepoint >= 0x1F37E && codepoint <= 0x1F393) ||
      (codepoint >= 0x1F3A0 && codepoint <= 0x1F3CA) ||
      (codepoint >= 0x1F3CF && codepoint <= 0x1F3D3) ||
      (codepoint >= 0x1F3E0 && codepoint <= 0x1F3F0) ||
      (codepoint >= 0x1F3F4 && codepoint <= 0x1F3F4) ||
      (codepoint >= 0x1F3F8 && codepoint <= 0x1F43E) ||
      (codepoint >= 0x1F440 && codepoint <= 0x1F440) ||
      (codepoint >= 0x1F442 && codepoint <= 0x1F4FC) ||
      (codepoint >= 0x1F4FF && codepoint <= 0x1F53D) ||
      (codepoint >= 0x1F54B && codepoint <= 0x1F54E) ||
      (codepoint >= 0x1F550 && codepoint <= 0x1F567) ||
      (codepoint >= 0x1F57A && codepoint <= 0x1F57A) ||
      (codepoint >= 0x1F595 && codepoint <= 0x1F596) ||
      (codepoint >= 0x1F5A4 && codepoint <= 0x1F5A4) ||
      (codepoint >= 0x1F5FB && codepoint <= 0x1F64F) ||
      (codepoint >= 0x1F680 && codepoint <= 0x1F6C5) ||
      (codepoint >= 0x1F6CC && codepoint <= 0x1F6CC) ||
      (codepoint >= 0x1F6D0 && codepoint <= 0x1F6D2) ||
      (codepoint >= 0x1F6EB && codepoint <= 0x1F6EC) ||
      (codepoint >= 0x1F6F3 && codepoint <= 0x1F6F8) ||
      (codepoint >= 0x1F910 && codepoint <= 0x1F93A) ||
      (codepoint >= 0x1F93C && codepoint <= 0x1F945) ||
      (codepoint >= 0x1F947 && codepoint <= 0x1F94C) ||
      (codepoint >= 0x1F950 && codepoint <= 0x1F96B) ||
      (codepoint >= 0x1F980 && codepoint <= 0x1F997) ||
      (codepoint >= 0x1F9C0 && codepoint <= 0x1F9C0) ||
      (codepoint >= 0x1F9D0 && codepoint <= 0x1F9E6)) { return _propE; }
  if (codepoint >= 0x20000 && codepoint <= 0x2A6DF) return _prop2;
  if (codepoint >= 0x2A700 && codepoint <= 0x2B73F) return _prop2;
  if (codepoint >= 0x2B740 && codepoint <= 0x2B81F) return _prop2;
  if (codepoint >= 0x2B820 && codepoint <= 0x2CEAF) return _prop2;
  if (codepoint >= 0x2CEB0 && codepoint <= 0x2EBEF) return _prop2;
  if (codepoint >= 0x2F800 && codepoint <= 0x2FA1F) return _prop2;
  if (codepoint >= 0xE0100 && codepoint <= 0xE01EF) return _propN;
  final high = codepoint >> 8;
  if (high >= _stage1Len) return _prop1;
  final low = codepoint & 0xFF;
  final s2idx = _stage1[high] * 256 + low;
  if (s2idx >= _stage2Len) return _prop1;
  return _stage2[s2idx];
}

int charWidthFromTable(int codepoint) {
  final prop = _lookup(codepoint);
  return prop & 0x03;
}

bool isEmojiFromTable(int codepoint) => (_lookup(codepoint) & 0x04) != 0;

bool isPrintableFromTable(int codepoint) => (_lookup(codepoint) & 0x08) != 0;

bool isPrivateUseFromTable(int codepoint) => (_lookup(codepoint) & 0x10) != 0;

bool isAmbiguousWidthFromTable(int codepoint) => (_lookup(codepoint) & 0x03) == 3;
