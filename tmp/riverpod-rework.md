# Rework: remove riverpod_generator / riverpod_annotation

This rework switches t22e from code-generated providers
(`riverpod_generator` + `riverpod_annotation` + `@riverpod`) back to
plain `package:riverpod`. It is forced by instability of
`riverpod_generator` observed independently; the project standard is now
plain `Provider<T>((ref) => ...)`.

The companion rule in `.ai/coding-standards.md` ("Riverpod Provider
Lifecycle (pure-Dart)") must be read before doing this rework. Two
non-obvious facts it establishes and that this rework must *preserve*:

1. **`ref.read` / `container.read` are NOT ephemeral.** A read
   *materializes* a non-autoDispose provider and keeps it alive until
   `container.dispose()`. The past-instance mistake of treating
   `ref.read` as fire-and-forget is wrong; do not "fix" provider wiring
   by switching `ref.read` to `ref.watch`.
2. **`ref.watch` is banned.** All current `ref.watch` usages must
   become `ref.read` (one-shot value) or `ref.listen` (side-effect on
   change) — never `ref.watch`. The rework does not introduce
   `Provider.autoDispose`, `isAutoDispose`, `keepAlive`, or
   `@Riverpod(keepAlive: true)`.

## Files using code-gen today (15 source files, 12 generated)

Source files that `import 'package:riverpod_annotation/riverpod_annotation.dart';`:

- `lib/src/engine/pipeline_provider.dart`
- `lib/src/engine/ansi_writer_provider.dart`
- `lib/src/engine/diff_engine_provider.dart`
- `lib/src/engine/render_root_provider.dart`
- `lib/src/engine/render_text_provider.dart`
- `lib/src/engine/stdout_interface_provider.dart`
- `lib/src/engine/cell_buffer_builder_provider.dart`
- `lib/src/io/input_stream_provider.dart`
- `lib/src/io/ansi_parser_provider.dart`
- `lib/src/io/input_value_notifier_provider.dart`
- `lib/src/view/context_provider.dart`
- `lib/src/models/size_provider.dart`

Other imports of `package:riverpod_annotation/riverpod_annotation.dart`
(no `@riverpod`, just bringing in `Ref`/annotations — needs cleanup too):

- `lib/src/view/context.dart`
- `lib/src/view/widget_ref.dart`
- `lib/src/view/components/consumer.dart`

Generated files to delete (12):

- `lib/src/engine/pipeline_provider.g.dart`
- `lib/src/engine/ansi_writer_provider.g.dart`
- `lib/src/engine/diff_engine_provider.g.dart`
- `lib/src/engine/render_root_provider.g.dart`
- `lib/src/engine/render_text_provider.g.dart`
- `lib/src/engine/stdout_interface_provider.g.dart`
- `lib/src/engine/cell_buffer_builder_provider.g.dart`
- `lib/src/io/input_stream_provider.g.dart`
- `lib/src/io/ansi_parser_provider.g.dart`
- `lib/src/io/input_value_notifier_provider.g.dart`
- `lib/src/view/context_provider.g.dart`
- `lib/src/models/size_provider.g.dart`

## Per-file transformation

Each `*_provider.dart` follows one of two shapes.

### Shape A — functional provider (most files)

Before (example, `pipeline_provider.dart`):

```dart
import 'package:meta/meta.dart' show internal;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'ansi_writer_provider.dart' show ansiWriterProvider;
import 'diff_engine_provider.dart' show diffEngineProvider;
import 'pipeline.dart' show Pipeline;
import 'stdout_interface_provider.dart' show stdoutInterfaceProvider;

part 'pipeline_provider.g.dart';

/// Provides a default [Pipeline] instance with injected engine dependencies.
@riverpod
@internal
Pipeline pipeline(Ref ref) => Pipeline(
      ansiWriter: ref.read(ansiWriterProvider),
      diffEngine: ref.read(diffEngineProvider),
      stdoutInterface: ref.read(stdoutInterfaceProvider),
    );
```

After:

```dart
import 'package:meta/meta.dart' show internal;
import 'package:riverpod/riverpod.dart';

import 'ansi_writer_provider.dart' show ansiWriterProvider;
import 'diff_engine_provider.dart' show diffEngineProvider;
import 'pipeline.dart' show Pipeline;
import 'stdout_interface_provider.dart' show stdoutInterfaceProvider;

/// Provides a default [Pipeline] instance with injected engine dependencies.
@internal
final pipelineProvider = Provider<Pipeline>(
  (ref) => Pipeline(
    ansiWriter: ref.read(ansiWriterProvider),
    diffEngine: ref.read(diffEngineProvider),
    stdoutInterface: ref.read(stdoutInterfaceProvider),
  ),
);
```

Notes that apply to every Shape A file:
- Replace `import 'package:riverpod_annotation/riverpod_annotation.dart';`
  with `import 'package:riverpod/riverpod.dart';`.
- Remove the `part '..._provider.g.dart';` directive.
- Remove `@riverpod`.
- Convert the function `T name(Ref ref) => ...` into a top-level
  `final nameProvider = Provider<T>((ref) => ...)`. **The provider
  variable name is `<functionName>Provider`** — this matches what the
  generator previously emitted and what every caller already imports.
- Preserve the existing `ref.read`/`ref.listen`/`ref.onDispose` calls
  verbatim. Do **not** convert any `ref.read` to `ref.watch`.
- Keep `@internal` on the provider variable.
- Keep the existing `show`/`as` import combinators and the doc comment.

### Shape B — Notifier class (if any)

If a file uses `class Foo extends _$Foo` + `@override build()`, convert
to `NotifierProvider<FooNotifier, T>`:

Before:

```dart
@riverpod
class count extends _$count {
  @override
  int build() => 0;
  void increment() => state++;
}
```

After:

```dart
final countProvider = NotifierProvider<CountNotifier, int>(CountNotifier.new);

class CountNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void increment() => state++;
}
```

(Audit each `*_provider.dart` to determine which shape it is. Most in
t22e appear to be Shape A — functional `Provider`, not Notifier classes.
Use `NotifierProvider` / `AsyncNotifierProvider` / `StreamProvider` /
`FutureProvider` as the return type demands.)

### Non-provider files importing riverpod_annotation

For `lib/src/view/context.dart`, `lib/src/view/widget_ref.dart`, and
`lib/src/view/components/consumer.dart`, replace the
`package:riverpod_annotation/riverpod_annotation.dart` import with
`package:riverpod/riverpod.dart`. These files use `Ref`/`ProviderContainer`
symbols only; no `@riverpod` annotation and no `part` directive to
remove there (verify during the edit).

## pubspec.yaml

- Remove from `dependencies:`: `riverpod_annotation`.
  `riverpod` stays at the current version.
- Remove from `dev_dependencies:`: `riverpod_generator`.
  Keep `freezed`, `freezed_annotation`, `build_runner`, `meta`, `lints`,
  `test`.

## analysis_options.yaml

- Run `dart run build_runner build` after edits. `build_runner` is still
  needed for `freezed`. Confirm no `*.provider.g.dart` are referenced
  anywhere after deletion.
- If `analysis_options.yaml` has any `exclude:` entries for
  `*.g.dart` that were provider-specific, leave the generic `*.g.dart`
  exclude alone (freezed still generates `*.freezed.dart`; `*.g.dart`
  may still apply to freezed internals — verify, do not assume).

## Build & verify (in order)

1. Delete the 12 `*_provider.g.dart` files listed above.
2. Rewrite the 15 source files per Shape A/B.
3. Update `pubspec.yaml` (remove the two code-gen deps).
4. Update the 3 non-provider view files' imports.
5. `dart pub get`
6. `dart run build_runner build` (regenerate freezed `*.freezed.dart`
   only; expect no new `*_provider.g.dart`).
7. `dart analyze` — must be clean.
8. `dart test` — all 161 tests must pass. If a test referenced a
   generated `*Provider` symbol, update the import to the hand-written
   provider variable of the same name (no symbol rename should be
   necessary because the manual `final <name>Provider` matches the
   generator's old output).
9. `grep -r "riverpod_annotation\|riverpod_generator\|@riverpod\|part.*_provider.g.dart" lib/ test/` — must return zero matches.

## Acceptance criteria

- `dart analyze` clean.
- `dart test` green (161 tests).
- No file under `lib/` or `test/` imports `riverpod_annotation` or
  `riverpod_generator`.
- No `@riverpod` / `@Riverpod` annotations remain.
- No `*_provider.g.dart` files remain on disk.
- No `ref.watch` usages introduced (separate tracked todo handles
  existing ones — do not introduce new ones here).
- `pubspec.yaml` `dependencies` contains `riverpod` (no
  `riverpod_annotation`); `dev_dependencies` contains no
  `riverpod_generator`.