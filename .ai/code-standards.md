# Code Standards — t22e

## Architecture

- **TEA (The Elm Architecture)**: All state management follows Model/Msg/Cmd pattern
- **Layered design**: protocol → ansi/unicode/parser → core → renderer → widgets
- **Riverpod DI**: Dependency injection and lifecycle management throughout
- **Freezed immutability**: All data classes use `@freezed` for immutable records

## Package Structure

- Each package lives under `packages/<name>/`
- Barrel export at `lib/<package>.dart` or `lib/<name>.dart`
- Implementation files under `lib/src/`
- Generated files (`.freezed.dart`, `.g.dart`) co-locate with source
- `publish_to: none` — all packages are internal, not published

## Naming Conventions

- **Classes**: PascalCase (`Vt500Engine`, `TerminalRunner`)
- **Functions/methods**: camelCase (`splitHorizontal()`, `advance()`)
- **Constants**: camelCase in `Defaults` class (`escapeByte`, `csiFinalSgr`)
- **Files**: snake_case (`terminal_parser.dart`, `color_profile.dart`)
- **Enums**: PascalCase with camelCase values (`KeyCode.none`, `MouseAction.press`)

## Comment Style

- Doc comments (`///`) for all public APIs
- Max 3 lines, 80 chars per line
- No code samples in comments
- Describe *what* and *why*, not *how* (code shows how)
- Inline comments (`//`) for internal notes only

## Error Handling

- Use `StateError` for lifecycle violations (use-before-init, use-after-dispose)
- Guards via `check` and `checkInit` patterns in `notifier` package
- `ErrorEvent` for parser-level errors
- Terminal restoration guaranteed via `TerminalGuard` on any exit path

## Testing

- Virtual terminal interprets ANSI output for headless assertions
- `WidgetTester` drives widgets with simulated input events
- Tests assert on `expectCell()` and `expectPlainText()`
- No real terminal required for test execution

## Code Generation

- `freezed` for immutable data classes (`@freezed` annotation)
- `riverpod_generator` for providers (`@riverpod` annotation)
- Run `melos build` before analysis or tests to generate files
- Generated files are committed to the repository

## Dependencies

- Workspace resolution — all internal packages use `path:` references
- External deps: `riverpod`, `freezed_annotation`, `meta`, `ffi`
- Dev deps: `build_runner`, `freezed`, `riverpod_generator`, `lints`, `test`
- No circular dependencies between packages

## Terminal I/O

- FFI-first approach: `FfiRawModeBackend` via libc `tcgetattr`/`tcsetattr`
- IO fallback: `IoRawModeBackend` via `dart:io` stdin modes
- `TerminalRunner` orchestrates backends with automatic fallback
- Raw mode state is always restored on disposal

## Rendering Pipeline

1. Widget tree → `WidgetRenderer.render()` → `Surface`
2. `Surface` → `Frame.fromSurface()` → `Frame`
3. `diff(previous, current)` → `DiffResult`
4. `LineRenderer` or `CellRenderer` → ANSI output
5. `SyncRenderer` wraps with DEC 2026 markers when supported

## Input Pipeline

1. Raw bytes → `Vt500Engine.advance()` → `SequenceData`
2. `SequenceData` → semantic parsers (`parseCsi`, `parseEsc`, etc.) → `Event`
3. `Event` → wrapped as `Msg` → `Model.update()` → `(newModel, Cmd?)`

## Cascade Notation

- Use cascade notation (`..`) when chaining multiple operations on the same object
- Prefer cascades over repeated variable references for builder-style APIs
- Example:
  ```dart
  final buffer = StringBuffer()
    ..write('Hello')
    ..write(' ')
    ..write('World');
  ```

## Riverpod Providers

- All lifecycle-managed objects must be exposed as `@riverpod` providers
- Raw implementation classes that have provider wrappers must be marked `@internal`
- Consumers **must** read providers via `ProviderContainer` or `ref.watch()` — never instantiate raw classes directly
- Always import and re-export providers from package barrel files
- Each package barrel file must export its `providers.dart` (or equivalent)
- Example:
  ```dart
  // Good — read from provider
  final container = ProviderContainer();
  final runner = container.read(terminalRunnerProvider);

  // Bad — manual instantiation of a class that has a provider
  final runner = TerminalRunner(backends: [...]);
  ```
- Stateless utilities (`SyncRenderer`, `Vt500Engine`) and widget classes
  (`Text`, `Box`, `Row`) do not need providers — they are created on-demand
- Data structures (`Surface`, `Cell`, `TextStyle`, `Color`) do not need providers

## AI Agent Rules

- After completing any implementation, AI agents **must** run `melos analyze`, `melos format`, and `melos test` (in that order) before considering the task complete
- All three commands must pass without errors
- If any command fails, fix the issues and re-run until all pass
