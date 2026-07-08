# Code Standards — t22e

## Architecture

- **Riverpod DI**: Dependency injection and lifecycle management throughout
- **Freezed immutability**: All data classes use `@freezed` for immutable records

## Package Structure

- Implementation files under `lib/src/`
- Generated files (`.freezed.dart`, `.g.dart`) co-locate with source

## Naming Conventions

- **Classes**: PascalCase 
- **Functions/methods**: camelCase
- **Values**: camelCase
- **Files**: snake_case
- **Enums**: PascalCase with camelCase values
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

- Prefer built-in helpers from the Dart standard library over hand-written equivalents if possible
(eg: `dart:math` Use `max` instead of ternary comparisons
```dart
  // Good — use dart:math
  final maxRows = max(previous.height, current.height);

  // Bad — hand-written ternary
  final maxRows = previous.height > current.height
      ? previous.height
      : current.height;
  ```
)

## Research Sources

- When resolving questions about Dart or a package API, consult the official
  documentation first (e.g. `https://dart.dev`, `https://pub.dev/packages/<pkg>`).
- Do not rely on local package cache source files as authoritative references.
- It is **FORBIDDEN** to read, search, or list files under `~/.pub-cache/`
  (or any local package cache). Treat the cache as off-limits for all file
  operations (read, glob, grep, bash `cat`/`ls`/`find`). The cache is an
  unpublished build artifact; official docs and the project's own
  `pubspec.yaml` / lockfile are the only authoritative sources.

## Riverpod Providers

- Use plain `package:riverpod` only. Do **not** use `riverpod_generator`,
  `riverpod_annotation`, or `@riverpod`. Declare providers as
  `final myProvider = Provider<T>((ref) => ...)` (or `NotifierProvider`,
  `FutureProvider`, `StreamProvider` as needed).
- Use non-autoDispose providers only. Do **not** use `Provider.autoDispose`
  and do **not** pass `isAutoDispose: true`. The host's
  `ProviderContainer.dispose()` is the lifecycle safeguard.
- **Never use `ref.watch`.** It is a Flutter reactivity primitive and is
  not used in this Dart-only project. Use `ref.read` for one-shot
  dependency values and `ref.listen` for side-effects on change.
- All classes (except "data-classes") and functions have provider wrappers
  and must be marked `@internal`.
- Always export providers from package barrel files.
- When a class or function is exposed through a provider, that provider
  must be defined in a dedicated file following the naming scheme:
  `my_class.dart` → `my_class_provider.dart`.
- Data structures do not need providers.

## Riverpod Provider Lifecycle (pure-Dart)

t22e is pure-Dart: there is no `ProviderScope`. The `ProviderContainer`
created by the host (`main`, a binding, or a test) is the **lifecycle
root**. Providers hold no state; state lives in the container. The
container owns the provider graph — `container.dispose()` disposes every
mounted provider and fires its `ref.onDispose` callbacks.

### Critical: `ref.read` / `container.read` are NOT ephemeral

This is the single most misunderstood part of Riverpod in a pure-Dart,
non-autoDispose project. **Read it carefully. Do not gloss over it. Do
not run a counter-test to "verify" it — this is settled behavior.**

A `ProviderContainer` owns every provider that has been *materialized*
(had its element mounted). For a **non-autoDispose** provider — which is
all of them in t22e — the provider stays mounted and **alive until
`container.dispose()` is called**, regardless of how many listeners it
has. Listener count is irrelevant to the lifetime of a non-autoDispose
provider. Only `container.dispose()` destroys it.

`ref.read` and `container.read` are the same read (`Ref.read` delegates
to `ProviderContainer.read`, with only a debug-only dependency assertion
added). Internally the call does `listen` → read the value →
`sub.close()`: a subscription is added and removed within the same call,
so the *net* listener delta is zero. **But the call materializes the
target provider**, and once materialized the provider is alive for the
life of the container.

The past-instance mistake to avoid: believing "`ref.read`/
`container.read` are fire-and-forget and dispose the provider
immediately." **That is false in this project.** With non-autoDispose
providers, a read pins the provider to the container's lifetime. A read
is the correct and sufficient mechanism for wiring the dependency graph;
the container, disposed by the host, is the safeguard.

(The momentary-listen mechanic inside `read` only matters for
*autoDispose* providers, which t22e does not use. For an autoDispose
provider a read would let it be destroyed ~one frame later because
listeners hit zero. Since t22e mandates non-autoDispose, that case never
applies here.)

### `ref.read` inside a provider does link disposal

When provider A's create body calls `ref.read(B)`, B is materialized.
Both A and B are now mounted in the same container, so
`container.dispose()` disposes both and fires both `ref.onDispose`
callbacks — there is no leak of B even though A only read it. Wires
fine. Do not rely on a particular *order* of those two disposals (it
follows the container's iteration order, not a dependency cascade); rely
only on the guarantee that both are disposed before `container.dispose()`
returns.

### Rules for t22e

- **Outside providers** (entry points, host binding, tests): go through
  the container. `container.read` for one-shot reads, `container.listen`
  to subscribe and receive changes. Always pair with
  `container.dispose()` (`finally`, or `ProviderContainer.test()` in
  tests) — this owns the graph and cascades disposal.
- **Inside a provider**: `ref.read` for one-shot dependency values;
  `ref.listen` for side-effects on dependency change. Never `ref.watch`.
- Always register cleanup with `ref.onDispose` (close controllers,
  cancel timers/subscriptions, dispose notifiers). Register one
  `onDispose` per disposable object, next to its creation.

## Constant Classes (`...Symbols`)

Pure byte/value constant classes are **data**, not lifecycle participants.
They therefore do **not** get a Riverpod provider, a `*_provider.dart` file, or
a barrel re-export. They are declared `@internal` and consumed via `lib/src/`
imports only.

### Naming and placement

- Constants used by **more than one** `lib/src/` file live in a `final class`
  named `'project name' + Symbols` (e.g. `t22eSymbols`), in a dedicated
  `...symbols.dart` file under the most appropriate `lib/src/` subfolder.
- Constants used by **exactly one** file live in a `final class` named
  `'file name' + Symbols` (PascalCase; snake_case file stem converted, e.g.
  `ansi_parser.dart` → `AnsiParserSymbols`), in a sibling `..._symbols.dart`
  file.

### Promotion rule

When a file-scoped `...Symbols` constant gains a second consumer, promote it
(move it) to the project-scoped `t22eSymbols` class and update both call sites.

### Scope boundary

Treat boolean predicates as **logic, not constants** — do not extract their
range bounds into `...Symbols` unless the bound is itself a meaningful terminal
symbol independent of the predicate. Predicate extraction is a separate task
that lives on its own and may pull selected bounds out at that time.

### Comment convention

Doc comments on `...Symbols` classes and members follow the standard rules in
§Comment Style: class doc describes what the class holds and the file/project
boundary; member docs are single-line and describe the value, not how callers
use it.

## Code Generation

- `freezed` for immutable data classes (`@freezed` annotation)
- Run `dart run build_runner build` before analysis or tests to generate files
- Generated files (`.freezed.dart`) are committed to the repository

## Dependencies
- External deps: `riverpod`, `freezed_annotation`, `meta`
- Dev deps: `build_runner`, `freezed`, `lints`, `test`
- No circular dependencies between packages
