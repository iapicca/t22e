# TODO Plan — t22e

16 `/// TODO` comments found across 6 packages. Phased approach below.

---

## TODO Inventory

### Parser Package (7 TODOs)

| # | File:Line | TODO | Category | Status |
|---|-----------|------|----------|--------|
| 1 | `engine.dart:10` | Separate engine from data classes and enum | Architecture | |
| 2 | `engine.dart:50` | Engine should use ValueNotifier + Init mixin; rename `_oscExpectSt`/`_dcsExpectSt`; refactor to state machine with top-level functions | Architecture | |
| 3 | `engine.dart:112` | Evaluate using switch case in `_onGround` | Code style | |
| 4 | `terminal_parser.dart:8` | `_engine` should be injected with Riverpod | DI | |
| 5 | `events.dart:114` | Why is `MouseEvent` not using freezed? Events should be split in separate files | Refactor | |
| 6 | `esc_parser.dart:20` | Hardcoded values should be in a "Defaults" class | Cleanup | :white_check_mark: Done |
| 7 | `dcs_parser.dart:5` | Hardcoded values should be in a "Defaults" class | Cleanup | :white_check_mark: Done |

### Core Package (4 TODOs)

| # | File:Line | TODO | Category | Status |
|---|-----------|------|----------|--------|
| 8 | `surface.dart:21` | Surface should be: freezed, use Init mixin for lazy grid, use ValueNotifier for grid, move hardcoded chars to Defaults, use Size/Rect classes, Surface as ValueNotifier<Size> | Major refactor | :white_check_mark: Done |
| 9 | `surface.dart:214` | `toAnsiLines()` should be an extension | Refactor | :white_check_mark: Done |
| 10 | `style.dart:48` | `merge()` duplicates `copyWith` work | Optimization | |
| 11 | `cell.dart:18` | Remove `mergeStyle()`, use `copyWith` directly | Cleanup | :white_check_mark: Done |

### Lifecycle Package (1 TODO)

| # | File:Line | TODO | Category | Status |
|---|-----------|------|----------|--------|
| 12 | `process_result.dart:19` | Why is `ProcessTimeout` not using freezed? | Refactor | |

### Capability Package (2 TODOs)

| # | File:Line | TODO | Category | Status |
|---|-----------|------|----------|--------|
| 13 | `color_probe.dart:13` | Move env values to Defaults | Cleanup | :white_check_mark: Done |
| 14 | `color_probe.dart:20` | Move env values to Defaults | Cleanup | :white_check_mark: Done |

### Testing Package (2 TODOs)

| # | File:Line | TODO | Category | Status |
|---|-----------|------|----------|--------|
| 15 | `virtual_terminal.dart:16` | Track alternate screen state for buffer switching | Feature | |
| 16 | `virtual_terminal.dart:20` | Store normal screen buffer when switching to alt screen | Feature | |

---

## Execution Plan

### Phase 1: Quick Wins :white_check_mark:

Move hardcoded strings to `Defaults`, remove dead methods, convert to extension.

### Phase 2: Freezed Conversions

- [#5] Convert `MouseEvent` to freezed, split events into separate files
- [#12] Convert `ProcessTimeout` to freezed properly
- [#10] Optimize `TextStyle.merge()` to avoid redundant `copyWith`

### Phase 3: Riverpod DI

- [#4] Inject `Vt500Engine` via Riverpod in `TerminalParser`

### Phase 4: Engine Refactoring

- [#1] Separate `VtState` enum and `SequenceData` classes from `Vt500Engine` into own files
- [#2] Refactor `Vt500Engine` to use ValueNotifier + Init mixin, rename state flags, extract handlers to top-level functions
- [#3] Evaluate using switch case in `_onGround`

### Phase 5: Surface Major Refactor :white_check_mark:

- [#8] Create `Size` and `Rect` utility classes with `constrain`/`multiply` methods; convert `Surface` to use freezed, Init/Dispose mixins, ValueNotifier<Size>, ValueNotifier for grid; move hardcoded border chars to Defaults

### Phase 6: Testing Features

- [#15] [#16] Implement alternate screen buffer switching in `VirtualTerminal`

---

## Notes

- After each phase, run `melos analyze`, `melos format`, `melos test` per [code standards](../.ai/code-standards.md)
- All constants follow the `Defaults` class convention in `protocol/.../defaults.dart`
- Internal API doc comments should be single line, max 80 chars
