# Protocol Refactor Plan

Split `packages/protocol/lib/src/defaults.dart` (1060 lines, single class
`Defaults` with ~27 groups of static const) into domain-specific classes.

---

## Phase 1: Split within `protocol`

Create domain class files under `packages/protocol/lib/src/`.

### Domain classes and their files

| # | New File | Class Name | Constants |
|---|----------|-----------|-----------|
| 1 | `control_bytes.dart` | `ControlBytes` | C0/C1 bytes, ESC/CSI/OSC/DCS/ST/BEL strings, entry bytes, delimiters |
| 2 | `byte_ranges.dart` | `ByteRanges` | All `byteRange*` classification constants |
| 3 | `sgr_codes.dart` | `SgrCodes` | SGR params, color base codes, extended codes, `csiFinalSgr` |
| 4 | `csi_finals.dart` | `CsiFinals` | CSI final bytes (cursor, display, modes, input events, intermediates) |
| 5 | `esc_finals.dart` | `EscFinals` | ESC/SS3 final bytes |
| 6 | `dec_modes.dart` | `DecModes` | DEC private modes, cursor styles, erase modes |
| 7 | `osc_codes.dart` | `OscCodes` | OSC PSN codes |
| 8 | `dcs_codes.dart` | `DcsCodes` | DCS final/intermediate bytes |
| 9 | `modifiers.dart` | `Modifiers` | Key modifier bitmasks |
| 10 | `mouse_codes.dart` | `MouseCodes` | Mouse parsing constants |
| 11 | `kitty_codes.dart` | `KittyCodes` | Kitty keyboard protocol |
| 12 | `internal_events.dart` | `InternalEvents` | `internalEvent*` strings |
| 13 | `da1_codes.dart` | `Da1Codes` | DA1 terminal ID + attributes |
| 14 | `unicode_codepoints.dart` | `UnicodeCodepoints` | Individual codepoint constants |
| 15 | `unicode_ranges.dart` | `UnicodeRanges` | Codepoint range boundaries |
| 16 | `grapheme_properties.dart` | `GraphemeProperties` | `graphemeProp*` + `wideCharWidth`/`zeroCharWidth` |
| 17 | `color_constants.dart` | `ColorConstants` | `colorProfile*`, `indexedColor*`, `ansi*`, `linkColor*`, `rgb*` |
| 18 | `termios.dart` | `Termios` | termios flags, offsets, size, VMIN/VTIME, `tcsaNow`, `stdinFd`, libc names |
| 19 | `environment.dart` | `Environment` | `envKey*`, `env*` constants |
| 20 | `size_defaults.dart` | `SizeDefaults` | Terminal/viewport/progress/scrollbar sizes, `unbounded` |
| 21 | `timing_defaults.dart` | `TimingDefaults` | Duration constants |
| 22 | `rendering_defaults.dart` | `RenderingDefaults` | `defaultFps`, `microsecondsPerSecond` |
| 23 | `widget_chars.dart` | `WidgetChars` | Box-drawing glyphs, border sets |
| 24 | `spinner_frames.dart` | `SpinnerFrames` | `spinnerFrames` list |
| 25 | `dialog_layout.dart` | `DialogLayout` | `dialog*` constants |
| 26 | `text_input_defaults.dart` | `TextInputDefaults` | `textInputNoMaxLength` |
| 27 | `signal_defaults.dart` | `SignalDefaults` | `exitCodeOk` |

### Multi-consumer classes (stay in `protocol`)

| Class | Consumers |
|-------|-----------|
| `ControlBytes` | ansi, parser, renderer, capability, core (5) |
| `SgrCodes` | ansi, core, renderer, widgets (4) |
| `DecModes` | ansi, capability (2) |
| `OscCodes` | parser, ansi, capability (3) |
| `KittyCodes` | parser, capability (2) |
| `UnicodeCodepoints` | unicode, parser, widgets, example (4) |
| `GraphemeProperties` | unicode, core (2) |
| `SizeDefaults` | widgets, capability, core (3) |
| `TimingDefaults` | widgets, capability (2) |
| `WidgetChars` | widgets, core, example (3) |

### Single-consumer classes (candidates to move out)

| Class | Consumer | Move To |
|-------|----------|---------|
| `ByteRanges` | parser | packages/parser |
| `CsiFinals` | parser | packages/parser |
| `EscFinals` | parser | packages/parser |
| `DcsCodes` | parser | packages/parser |
| `Modifiers` | parser | packages/parser |
| `MouseCodes` | parser | packages/parser |
| `InternalEvents` | parser | packages/parser |
| `Da1Codes` | capability | packages/capability |
| `Environment` | capability | packages/capability |
| `UnicodeRanges` | unicode | packages/unicode |
| `ColorConstants` | core | packages/core |
| `Termios` | terminal | packages/terminal |
| `SpinnerFrames` | widgets | packages/widgets |
| `DialogLayout` | widgets | packages/widgets |
| `TextInputDefaults` | widgets | packages/widgets |

### Dead code to delete

| Constant | Reason |
|----------|--------|
| `libcMacOS`, `libcLinux6`, `libcLinux7` (in Defaults) | Duplicated in `terminal/lib/src/symbols_ffi.dart` |
| `sosIntroducerByte`, `pmIntroducerByte`, `apcIntroducerByte` | Unreferenced |
| `lineFeedByte` | Unreferenced |
| `sgrNoStrikethrough` | Unreferenced |
| `csiFinalSgr`, `csiFinalDecset`, `csiFinalDecrst`, `csiFinalSaveCursor`, `csiFinalRestoreCursor`, `csiFinalDsr` | Callers use string literals |
| `kittyEventUp`, `kittyEventRepeat`, `kittyAllEvents` | Unreferenced |
| `mouseButtonLeft`, `mouseButtonMiddle`, `mouseButtonRight` | Unreferenced |
| `colorProfileAnsiCount` | Unreferenced |
| `rgbRedShift`, `rgbGreenShift`, `rgbBlueMask` | Unreferenced |
| `defaultFps`, `microsecondsPerSecond` | Unreferenced |
| `escDisambiguationDelay`, `eventLoopSleep` | Unreferenced |
| `exitCodeOk` | Unreferenced |

---

## Phase 2: Update `protocol` barrel exports

Update `lib/protocol.dart` to export all new domain class files.  Keeps the
existing `export 'src/defaults.dart';` alongside new exports until consumers
are migrated.

---

## Phase 3: Update consumer imports

Change ~40 import sites from:

```dart
import 'package:protocol/protocol.dart' show Defaults;
```

to import only the specific domain classes each file uses.

---

## Phase 4: Move single-consumer classes

Relocate the 16 single-consumer classes to their target packages:
- Update the importing files in the target package
- Add barrel exports in the target package
- Remove the moved file from `protocol`
- Update `lib/protocol.dart`

---

## Phase 5: Final cleanup

- Remove commented-out/empty lines left in `defaults.dart`
- Remove dead constants
- Run `melos analyze` and `melos test` to confirm zero regressions
- Remove the compatibility shim if no longer needed

---

## Impact summary

- 27 new domain class files in `protocol/lib/src/`
- 40 import sites updated across 9 packages + example
- Up to 16 files relocated to other packages
- ~23 dead constants removed
