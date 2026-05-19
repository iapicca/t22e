# Private Named Parameters — TerminalRunner limitation

`TerminalRunner._backends` cannot use `this._backends` with a const default
because `FfiRawModeBackend()` is not a const constructor.

## Why FfiRawModeBackend can't be const

The constructor chain:
```
FfiRawModeBackend()
  → TermiosBindingsImpl.fromPlatformService(_io)
    → PlatformService(io: io).library
      → DynamicLibrary.open(...)  // FFI — inherently runtime
```

`DynamicLibrary.open` is a runtime FFI call. There's no way to make it const.

## What was done instead

- Removed the unused `io` parameter from `TerminalRunner` (no callers ever passed it)
- Inlined `FfiRawModeBackend()` and `IoRawModeBackend()` with their own defaults
- Removed the `SystemIo` import from runner.dart

The constructor remains in initializer-list form:
```dart
TerminalRunner({List<RawModeBackend>? backends})
  : _backends = backends ?? [FfiRawModeBackend(), IoRawModeBackend()];
```

#######

lifiecycle package sucks!

ProbePipeline non const

unicode tables need to be reworked


```dart

import 'dart:typed_data';
import 'package:protocol/protocol.dart' show Defaults;

/// Constants for Unicode character properties and table sizes.
final class UnicodeTable {
  const UnicodeTable._();

  // MARK: - Table Sizes
  static const int stage1Length = 0x1100; // 2,752 entries
  static const int stage2Length = 0x10000; // 65,536 entries

  // MARK: - Property Masks
  static const int widthMask = 0x03; // 2 bits for width
  static const int emojiFlag = 0x04;
  static const int printableFlag = 0x08;
  static const int privateUseFlag = 0x10;

  // MARK: - Common Property Combinations
  static const int width0NotPrintable = 0x00;
  static const int width1Printable = 0x09; // 1 + printable
  static const int width2Printable = 0x0A; // 2 + printable
  static const int width2PrintableEmoji = 0x0E; // 2 + printable + emoji
  static const int width1PrintablePrivateUse = 0x19; // 1 + printable + private use

  // MARK: - Well-Known Unicode Ranges
  static const List<(int start, int end, int property)> wellKnownCodepointRanges = [
    // Control characters
    (0x0000, 0x001F, width0NotPrintable),
    (0x007F, 0x007F, width0NotPrintable),
    (0x00AD, 0x00AD, width0NotPrintable),

    // Combining diacritical marks
    (Defaults.codepointCombiningDiacriticalStart, Defaults.codepointCombiningDiacriticalEnd, width0NotPrintable),
    (0x0483, 0x0489, width0NotPrintable),
    (0x0591, 0x05BD, width0NotPrintable),
    // ... (add more as needed)

    // CJK and wide characters
    (0x1100, 0x115F, width2Printable),
    (0x2E80, 0x2EFF, width2Printable),
    (0x3000, 0x303E, width2Printable),
    (0xAC00, 0xD7AF, width2Printable),
    // ... (add more as needed)

    // Emoji
    (0x1F004, 0x1F004, width2PrintableEmoji),
    (0x1F300, 0x1F320, width2PrintableEmoji),
    (0xFE00, 0xFE0F, width2PrintableEmoji),
    // ... (add more as needed)

    // Default: width1, printable (applied last)
    (0x0000, 0x10FFFF, width1Printable),
  ];
}

/// Two-stage lookup table for Unicode character properties.
final class UnicodeLookup {
  const UnicodeLookup._();

  static final Uint8List _stage1 = _initStage1();
  static final Uint8List _stage2 = _initStage2();
  static final bool _initialized = _initTables();

  /// Initializes the stage1 table: direct mapping.
  static Uint8List _initStage1() {
    final stage1 = Uint8List(UnicodeTable.stage1Length);
    for (var i = 0; i < UnicodeTable.stage1Length; i++) {
      stage1[i] = i;
    }
    return stage1;
  }

  /// Initializes the stage2 table using well-known ranges.
  static Uint8List _initStage2() {
    final stage2 = Uint8List(UnicodeTable.stage2Length);
    for (final range in UnicodeTable.wellKnownCodepointRanges) {
      final (start, end, property) = range;
      _setCodepointRange(
        start: start,
        end: end,
        property: property,
        stage1: _stage1,
        stage2: stage2,
      );
    }
    return stage2;
  }

  /// Sets the properties for a range of codepoints.
  static void _setCodepointRange({
    required int start,
    required int end,
    required int property,
    required Uint8List stage1,
    required Uint8List stage2,
  }) {
    if (start < 0) return;
    for (var cp = start; cp <= end && cp <= 0xFFFF; cp++) {
      final high = cp >> 8;
      final low = cp & 0xFF;
      if (high >= UnicodeTable.stage1Length) continue;
      final s2idx = stage1[high] * 256 + low;
      if (s2idx >= UnicodeTable.stage2Length) continue;
      stage2[s2idx] = property;
    }
  }

  /// Initializes the lookup tables.
  static bool _initTables() {
    // No need to fill with zeros; _initStage2 already sets all values.
    return true;
  }

  /// Looks up the properties for a codepoint.
  static int _lookupProperties(int codepoint) {
    if (!_initialized) return UnicodeTable.width1Printable;
    if (codepoint < 0 || codepoint > 0x10FFFF) return 0;

    // Special emoji blocks
    if ((codepoint >= 0x1F004 && codepoint <= 0x1F004) ||
        (codepoint >= 0x1F0CF && codepoint <= 0x1F0CF) ||
        (codepoint >= 0x1F300 && codepoint <= 0x1F320) ||
        // ... (add more emoji blocks as needed)
        (codepoint >= 0x1F9D0 && codepoint <= 0x1F9E6)) {
      return UnicodeTable.width2PrintableEmoji;
    }

    final high = codepoint >> 8;
    if (high >= UnicodeTable.stage1Length) return UnicodeTable.width1Printable;
    final low = codepoint & 0xFF;
    final s2idx = _stage1[high] * 256 + low;
    if (s2idx >= UnicodeTable.stage2Length) return UnicodeTable.width1Printable;
    return _stage2[s2idx];
  }

  // MARK: - Public API

  /// Returns the display column width for a codepoint.
  static int charWidth(int codepoint) {
    final prop = _lookupProperties(codepoint);
    return prop & UnicodeTable.widthMask;
  }

  /// Returns `true` if the codepoint is an emoji.
  static bool isEmoji(int codepoint) {
    final prop = _lookupProperties(codepoint);
    return (prop & UnicodeTable.emojiFlag) != 0;
  }

  /// Returns `true` if the codepoint is printable.
  static bool isPrintable(int codepoint) {
    final prop = _lookupProperties(codepoint);
    return (prop & UnicodeTable.printableFlag) != 0;
  }

  /// Returns `true` if the codepoint is in a Private Use Area.
  static bool isPrivateUse(int codepoint) {
    final prop = _lookupProperties(codepoint);
    return (prop & UnicodeTable.privateUseFlag) != 0;
  }

  /// Returns `true` if the codepoint has ambiguous width.
  static bool isAmbiguousWidth(int codepoint) {
    final prop = _lookupProperties(codepoint);
    return (prop & UnicodeTable.widthMask) == 3; // 0b11
  }
}
```



inking








Yes! The Unicode ranges are continuous blocks, and you can indeed initialize the _stage2 table directly by iterating over a list of well-known ranges, instead of first filling it with zeros and then replacing values iteratively.
This approach is more efficient and cleaner if:

The ranges are predefined and well-known.
You are okay with explicitly setting every range, including the default.

Refactored Initialization Using Well-Known Ranges
Here’s how you can refactor the initialization to use a list of well-known ranges and set them all at once:
dart
Copy

import 'dart:typed_data';
import 'package:protocol/protocol.dart' show Defaults;

/// Constants for Unicode character properties and table sizes.
final class UnicodeTable {
  const UnicodeTable._();

  // MARK: - Table Sizes
  static const int stage1Length = 0x1100; // 2,752 entries
  static const int stage2Length = 0x10000; // 65,536 entries

  // MARK: - Property Masks
  static const int widthMask = 0x03; // 2 bits for width
  static const int emojiFlag = 0x04;
  static const int printableFlag = 0x08;
  static const int privateUseFlag = 0x10;

  // MARK: - Common Property Combinations
  static const int width0NotPrintable = 0x00;
  static const int width1Printable = 0x09; // 1 + printable
  static const int width2Printable = 0x0A; // 2 + printable
  static const int width2PrintableEmoji = 0x0E; // 2 + printable + emoji
  static const int width1PrintablePrivateUse = 0x19; // 1 + printable + private use

  // MARK: - Well-Known Unicode Ranges
  static const List<(int start, int end, int property)> wellKnownCodepointRanges = [
    // Control characters
    (0x0000, 0x001F, width0NotPrintable),
    (0x007F, 0x007F, width0NotPrintable),
    (0x00AD, 0x00AD, width0NotPrintable),

    // Combining diacritical marks
    (Defaults.codepointCombiningDiacriticalStart, Defaults.codepointCombiningDiacriticalEnd, width0NotPrintable),
    (0x0483, 0x0489, width0NotPrintable),
    (0x0591, 0x05BD, width0NotPrintable),
    // ... (add more as needed)

    // CJK and wide characters
    (0x1100, 0x115F, width2Printable),
    (0x2E80, 0x2EFF, width2Printable),
    (0x3000, 0x303E, width2Printable),
    (0xAC00, 0xD7AF, width2Printable),
    // ... (add more as needed)

    // Emoji
    (0x1F004, 0x1F004, width2PrintableEmoji),
    (0x1F300, 0x1F320, width2PrintableEmoji),
    (0xFE00, 0xFE0F, width2PrintableEmoji),
    // ... (add more as needed)

    // Default: width1, printable (applied last)
    (0x0000, 0x10FFFF, width1Printable),
  ];
}

/// Two-stage lookup table for Unicode character properties.
final class UnicodeLookup {
  const UnicodeLookup._();

  static final Uint8List _stage1 = _initStage1();
  static final Uint8List _stage2 = _initStage2();
  static final bool _initialized = _initTables();

  /// Initializes the stage1 table: direct mapping.
  static Uint8List _initStage1() {
    final stage1 = Uint8List(UnicodeTable.stage1Length);
    for (var i = 0; i < UnicodeTable.stage1Length; i++) {
      stage1[i] = i;
    }
    return stage1;
  }

  /// Initializes the stage2 table using well-known ranges.
  static Uint8List _initStage2() {
    final stage2 = Uint8List(UnicodeTable.stage2Length);
    for (final range in UnicodeTable.wellKnownCodepointRanges) {
      final (start, end, property) = range;
      _setCodepointRange(
        start: start,
        end: end,
        property: property,
        stage1: _stage1,
        stage2: stage2,
      );
    }
    return stage2;
  }

  /// Sets the properties for a range of codepoints.
  static void _setCodepointRange({
    required int start,
    required int end,
    required int property,
    required Uint8List stage1,
    required Uint8List stage2,
  }) {
    if (start < 0) return;
    for (var cp = start; cp <= end && cp <= 0xFFFF; cp++) {
      final high = cp >> 8;
      final low = cp & 0xFF;
      if (high >= UnicodeTable.stage1Length) continue;
      final s2idx = stage1[high] * 256 + low;
      if (s2idx >= UnicodeTable.stage2Length) continue;
      stage2[s2idx] = property;
    }
  }

  /// Initializes the lookup tables.
  static bool _initTables() {
    // No need to fill with zeros; _initStage2 already sets all values.
    return true;
  }

  /// Looks up the properties for a codepoint.
  static int _lookupProperties(int codepoint) {
    if (!_initialized) return UnicodeTable.width1Printable;
    if (codepoint < 0 || codepoint > 0x10FFFF) return 0;

    // Special emoji blocks
    if ((codepoint >= 0x1F004 && codepoint <= 0x1F004) ||
        (codepoint >= 0x1F0CF && codepoint <= 0x1F0CF) ||
        (codepoint >= 0x1F300 && codepoint <= 0x1F320) ||
        // ... (add more emoji blocks as needed)
        (codepoint >= 0x1F9D0 && codepoint <= 0x1F9E6)) {
      return UnicodeTable.width2PrintableEmoji;
    }

    final high = codepoint >> 8;
    if (high >= UnicodeTable.stage1Length) return UnicodeTable.width1Printable;
    final low = codepoint & 0xFF;
    final s2idx = _stage1[high] * 256 + low;
    if (s2idx >= UnicodeTable.stage2Length) return UnicodeTable.width1Printable;
    return _stage2[s2idx];
  }

  // MARK: - Public API

  /// Returns the display column width for a codepoint.
  static int charWidth(int codepoint) {
    final prop = _lookupProperties(codepoint);
    return prop & UnicodeTable.widthMask;
  }

  /// Returns `true` if the codepoint is an emoji.
  static bool isEmoji(int codepoint) {
    final prop = _lookupProperties(codepoint);
    return (prop & UnicodeTable.emojiFlag) != 0;
  }

  /// Returns `true` if the codepoint is printable.
  static bool isPrintable(int codepoint) {
    final prop = _lookupProperties(codepoint);
    return (prop & UnicodeTable.printableFlag) != 0;
  }

  /// Returns `true` if the codepoint is in a Private Use Area.
  static bool isPrivateUse(int codepoint) {
    final prop = _lookupProperties(codepoint);
    return (prop & UnicodeTable.privateUseFlag) != 0;
  }

  /// Returns `true` if the codepoint has ambiguous width.
  static bool isAmbiguousWidth(int codepoint) {
    final prop = _lookupProperties(codepoint);
    return (prop & UnicodeTable.widthMask) == 3; // 0b11
  }
}




Key Improvements
1. Direct Initialization

The _stage2 table is now initialized directly from a list of well-known ranges.
No need to fill with zeros and then replace values.
2. Explicit Default

The default (width1Printable) is now set as a well-known range at the end of the list.
This ensures that all codepoints not in any other range get the correct default.
3. Cleaner Code

The initialization logic is more declarative and easier to maintain.
Adding new ranges is as simple as adding a new tuple to the list.
4. Performance

The initialization is slightly faster because it avoids the extra fill operation.
The logic is more predictable and less error-prone.

Notes

The wellKnownCodepointRanges list must include the default range ((0x0000, 0x10FFFF, width1Printable)) to ensure all codepoints are covered.
You can split the list into multiple lists (e.g., for control characters, CJK, emoji) if it becomes too large, but this is not necessary for most use cases.


#############

import 'dart:typed_data';

extension type const UnicodeWidthProperty._(
  (int start, int end, int width) property
) {
  int get start => property.$1;
  int get end => property.$2;
  int get width => property.$3;

  const UnicodeWidthProperty(int start, int end, int width) 
    : this._((start, end, width));
}

/// Constants for Unicode character properties and table sizes.
final class UnicodeTable {
  const UnicodeTable._();

  // Expanded to include ALL Unicode planes (up to 0x10FFFF)
  static const int maxCodepoint = 0x10FFFF;
  static const int tableLength = maxCodepoint + 1; // 1,114,112 entries

  static const int widthMask = 0x03; 
  static const int emojiFlag = 0x04;
  static const int printableFlag = 0x08;
  static const int privateUseFlag = 0x10;

  static const int width0NotPrintable = 0x00;
  static const int width1Printable = 0x09; 
  static const int width2Printable = 0x0A; 
  static const int width2PrintableEmoji = 0x0E; 
  static const int width1PrintablePrivateUse = 0x19; 

  static const List<UnicodeWidthProperty> wellKnownCodepointRanges = [
    UnicodeWidthProperty(0x0000, 0x001F, width0NotPrintable),
    UnicodeWidthProperty(0x007F, 0x007F, width0NotPrintable),
    UnicodeWidthProperty(0x00AD, 0x00AD, width0NotPrintable),

    // Combining diacritical marks
    UnicodeWidthProperty(0x0300, 0x036F, width0NotPrintable),
    UnicodeWidthProperty(0x0483, 0x0489, width0NotPrintable),
    UnicodeWidthProperty(0x0591, 0x05BD, width0NotPrintable),

    // CJK and wide characters
    UnicodeWidthProperty(0x1100, 0x115F, width2Printable),
    UnicodeWidthProperty(0x2E80, 0x2EFF, width2Printable),
    UnicodeWidthProperty(0x3000, 0x303E, width2Printable),
    UnicodeWidthProperty(0xAC00, 0xD7AF, width2Printable),

    // Emoji (Now all fully unified right here!)
    UnicodeWidthProperty(0xFE00, 0xFE0F, width2PrintableEmoji),
    UnicodeWidthProperty(0x1F004, 0x1F004, width2PrintableEmoji),
    UnicodeWidthProperty(0x1F0CF, 0x1F0CF, width2PrintableEmoji),
    UnicodeWidthProperty(0x1F300, 0x1F320, width2PrintableEmoji),
    UnicodeWidthProperty(0x1F9D0, 0x1F9E6, width2PrintableEmoji),

    // Default fallback: width1, printable (applied last)
    UnicodeWidthProperty(0x0000, maxCodepoint, width1Printable),
  ];
}

/// Single-stage lookup table for Unicode character properties.
final class UnicodeLookup {
  const UnicodeLookup._();

  static final Uint8List _propertyTable = () {
    final table = Uint8List(UnicodeTable.tableLength);
    
    // Process ranges in order. Later ranges overwrite earlier ones.
    for (final range in UnicodeTable.wellKnownCodepointRanges) {
      final start = range.start;
      final end = range.end;
      final property = range.width;

      if (start < 0) continue;
      
      // Loops safely through the entire expanded plane size
      for (var cp = start; cp <= end && cp < UnicodeTable.tableLength; cp++) {
        table[cp] = property;
      }
    }
    return UnmodifiableUint8ListView(table);
  }();

  /// Looks up the properties for a codepoint.
  static int _lookupProperties(int codepoint) =>
    (codepoint < 0 || codepoint > UnicodeTable.maxCodepoint) ? 0 : _propertyTable[codepoint];


  // MARK: - Public API

  static int charWidth(int codepoint) => _lookupProperties(codepoint) & UnicodeTable.widthMask;
  static bool isEmoji(int codepoint) => (_lookupProperties(codepoint) & UnicodeTable.emojiFlag) != 0;
  static bool isPrintable(int codepoint) => (_lookupProperties(codepoint) & UnicodeTable.printableFlag) != 0;
  static bool isPrivateUse(int codepoint) => (_lookupProperties(codepoint) & UnicodeTable.privateUseFlag) != 0;
  static bool isAmbiguousWidth(int codepoint) => (_lookupProperties(codepoint) & UnicodeTable.widthMask) == 3;
}
