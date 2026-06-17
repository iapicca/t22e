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

## Workspace

- Root `pubspec.yaml` defines workspace using glob pattern `packages/*` plus explicit entries (e.g. `example`)
- All workspace members must declare `resolution: workspace` in their `pubspec.yaml`
- Single shared `pubspec.lock` and `.dart_tool/package_config.json` at repository root
- Stray lock-files and package configs in subdirectories are deleted by `dart pub get`
- Interdependencies between workspace packages resolve to local versions automatically
- Run `dart pub workspace list` to see all resolved packages
- Example apps and non-library packages are included as workspace members, not excluded

## Naming Conventions

- **Classes**: PascalCase (`Vt500Engine`, `TerminalRunner`)
- **Functions/methods**: camelCase (`splitHorizontal()`, `advance()`)
- **Constants**: camelCase in `Defaults` class (`escapeByte`, `csiFinalSgr`)
- **Files**: snake_case (`terminal_parser.dart`, `color_profile.dart`)
- **Enums**: PascalCase with camelCase values (`KeyCode.none`, `MouseAction.press`)
- **Private named parameters**: Use `this._field` for initializing formals with private backing fields (Dart 3.12+). The constructor parameter and call site use the public name `field:` (without underscore). See https://dart.dev/blog/announcing-dart-3-12#private-named-parameters

## Comment Style

- Doc comments (`///`) for all classes, functions, and methods
- **Public APIs** (exported from barrel files): max 3 lines, 80 chars per line
- **Internal APIs** (not exported, in `lib/src/`): single line, max 80 chars
- **Private members** (prefixed with `_`): single line, max 80 chars
- No code samples in comments
- Describe *what* and *why*, not *how* (code shows how)
- Inline comments (`//`) for internal notes only
- TODO comments are allowed but should be resolved before release

## Error Handling

- Use `StateError` for lifecycle violations (use-before-init, use-after-dispose)
- Guards via `check` and `checkInit` patterns in `notifier` package
- `ErrorEvent` for parser-level errors
- Terminal restoration guaranteed via `TerminalGuard` on any exit path

## Testing

- Standard `package:test` for all unit and widget tests
- Widget tests assert on rendered output via `Surface`/`Frame` snapshots
- Terminal-dependent tests use `script -q /dev/null` to fake a TTY
- No real terminal required for most test execution

## Code Generation

- `freezed` for immutable data classes (`@freezed` annotation)
- `riverpod_generator` for providers (`@riverpod` annotation)
- Run `melos build` before analysis or tests to generate files
- Generated files are committed to the repository

## Dependencies

- Workspace resolution via `resolution: workspace` — single shared lockfile
- Internal packages use `path:` references (resolved to local versions automatically)
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
3. `diff(previous, current)` → `DiffResult` (extension type over `List<int>`)
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

## Collection Expressions

- Prefer collection-for with null-aware elements (`?expression`) over mutable list
  accumulation for filter-map operations (iterate → transform to nullable → collect
  non-null results)
- Prefer collection-for over mutable list accumulation for collect-all operations
  (iterate → unconditionally add to list)
- Use expression body (`=>`) when the method body is a single collection literal

- Filter-map pattern (null-aware):
  ```dart
  // Good — collection-for with null-aware
  List<T> method(Iterable<S> source) => [
    for (final item in source) ?transform(item)
  ];

  // Bad — mutable list accumulation with null check
  List<T> method(Iterable<S> source) {
    final results = <T>[];
    for (final item in source) {
      final result = transform(item);
      if (result != null) results.add(result);
    }
    return results;
  }
  ```

- Collect-all pattern (no filtering):
  ```dart
  // Good — collection-for
  List<Widget> buildRows(List<String> items) => [
    for (final item in items) Text(item)
  ];

  // Bad — mutable list accumulation
  List<Widget> buildRows(List<String> items) {
    final widgets = <Widget>[];
    for (final item in items) {
      widgets.add(Text(item));
    }
    return widgets;
  }
  ```

## Standard Library Helpers

- Prefer built-in helpers from the Dart standard library over hand-written equivalents
- Use `max` / `min` from `dart:math` instead of ternary comparisons
- Use `clamp` from `dart:math` instead of manual range clamping
- Example:
  ```dart
  // Good — use dart:math
  final maxRows = max(previous.height, current.height);

  // Bad — hand-written ternary
  final maxRows = previous.height > current.height
      ? previous.height
      : current.height;
  ```

## Riverpod Providers

- All lifecycle-managed objects must be exposed as `@riverpod` providers
- Raw implementation classes that have provider wrappers must be marked `@internal`
- Consumers **must** read providers via `ProviderContainer` or `ref.watch()` — never instantiate raw classes directly
- Always import and re-export providers from package barrel files
- When a class or function is exposed through a provider, that provider must
  be defined in a dedicated file following the naming scheme:
  `my_class.dart` → `my_class_provider.dart`
- Each package barrel file must export all its provider files
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
