# Project Notes — t22e

This document is the bird's-eye view of the `t22e` project. It is meant to be
read by both humans and AI agents before touching the codebase. It is the
single source of truth for *what the project is*, *how the implementation is
laid out*, *the strategy behind the non-obvious decisions*, and *the history of
how the first phase was delivered*.

For the operative rules, see:

- `.ai/coding-standards.md` — style, naming, and comment conventions.
- `.ai/ai-guidelines.md` — rules for AI contributors.

Where this document and a memory of an earlier spec conflict, this document
records the rework explicitly (see "Implementation divergences from the
original spec").

---

## 1. What t22e is

`t22e` is a **pure-Dart Terminal User Interface (TUI) framework**. It exposes a
declarative widget layer backed by immutable state, managed through Riverpod
providers, and rendered to a terminal through a flat cell buffer and diff
engine. There is **no Flutter dependency**; the framework targets the latest
stable Dart SDK only.

The completed first phase delivers a **full-screen text widget** rendered
through the entire pipeline and updated by `stdin` events. Advanced terminal
features (raw mode, mouse, alternate buffer, resize detection) are intentionally
deferred — see "Known risks and deferred work".

The phase is considered done: `dart analyze` is clean and the full test suite
(161 tests, including `test/smoke_test.dart` and `test/providers_test.dart`)
passes. Both end-to-end tests import only `package:t22e/t22e.dart`.

### 1.1 Core design decisions

| Topic | Decision |
|---|---|
| **Language & runtime** | Pure Dart, latest stable SDK. No Flutter. |
| **State management** | **Riverpod + Freezed** mandatory; code generation runs inside the package; framework users do not interact with `build_runner`. |
| **Stream semantics** | Normal async `StreamController`. The "synchronous" guarantee applies only to the listener→`ValueNotifier` path (same event-loop turn). |
| **AsyncValue** | No local clone. Riverpod's native `AsyncValue` from `package:riverpod` is used directly. |
| **Raw terminal mode** | Not used. Only `dart:io` stdin/stdout. Input may be line-buffered/echoed. |
| **Cell model** | Immutable Freezed `Cell` values; the flat buffer stores and copies them frame-to-frame. GC pressure is a measured hypothesis. |
| **Layout model** | Simplified box model (constraints down, sizes up); a full Flutter-style constraint engine is deferred. |
| **Public API surface** | Exposed primarily through Riverpod providers. Internal engine classes are `@internal` from `package:meta`. |
| **Testing** | Unit tests + a smoke test for this phase. Integration tests deferred. |
| **First deliverable** | A runnable full-screen text widget reading stdin and rendering to stdout via the diff engine. |

---

## 2. Architecture at a glance

The framework follows Flutter's three-tree rendering architecture, with one
strict dependency direction:

```
view (Widget / Element)  →  engine (RenderObject / Pipeline)  →  io / models
```

**No file under `lib/src/engine/` imports anything from `lib/src/view/`.** The
widget/element layer builds and drives the render tree; the engine never knows
that widgets exist. This boundary is the most important architectural invariant
in the codebase.

### 2.1 The three trees

| Tree              | Lives in                          | Role                                                         |
|-------------------|-----------------------------------|--------------------------------------------------------------|
| **Widget tree**   | `lib/src/view/`                   | Immutable *configuration* describing what to show.          |
| **Element tree**  | `lib/src/view/`                   | Long-lived *lifecycle* objects that own render objects.     |
| **Render tree**   | `lib/src/engine/`                 | Mutable *layout/paint* objects (`RenderObject`).            |

Widgets compile (`Widget.compile`) into Elements; `RenderObjectElement`s create
and own `RenderObject`s. The element tree is the bridge that turns short-lived
widget configurations into a long-lived render tree the pipeline can render.

### 2.2 Layer responsibilities

- **Model layer** — Immutable Freezed records holding pure application data. No
  business logic, layout, or terminal attributes.
- **ViewModel layer** — Riverpod `Notifier`s that consume input events, run
  business logic, and emit new immutable models. They never touch stdin/stdout
  or ANSI codes.
- **View layer** — Immutable widget configurations that read model snapshots
  and compile a structural UI representation.
- **Engine layer** — Reads terminal input, manages frame scheduling, runs
  build/layout/paint/diff/flush, and writes to stdout. It operates outside the
  application state graph except for reading model snapshots.

### 2.3 The rendering pipeline (engine)

`Pipeline` (`lib/src/engine/pipeline.dart`) orchestrates one frame:

```
layout → paint → diff → ANSI generation → stdout flush
```

1. **Build pass** — Widgets compile into lightweight elements that own render
   objects. Nodes carry immutable configuration and may read model snapshots
   through the `Context` provider container.
2. **Layout pass** — `RenderObject.layout(Constraints)` runs a simplified
   two-pass box model: the root defines the full terminal size, parents pass
   available size downward, children report their exact size upward. All
   dimensions are integer terminal cells; there are no fractional sizes.
3. **Paint pass** — render objects write immutable `Cell` values into a
   `CellBufferBuilder`, which produces an immutable target `CellBuffer`.
4. **Diff pass** — `DiffEngine` compares the target buffer against the
   *current display buffer* (kept by `Pipeline._current`) and emits minimal
   `DiffOp`s: `DiffOpMove`, `DiffOpStyle`, `DiffOpWrite`.
5. **ANSI pass** — `AnsiWriter` converts `DiffOp`s into escape sequences,
   emitting cursor moves only when needed and style (SGR) changes only when
   the active style differs.
6. **Flush pass** — `StdoutWriter` writes the string to `dart:io` `stdout`
   and flushes; the target buffer is then value-copied into the current
   buffer (value copy, not reference copy, because cells are immutable).

Double buffering is real: the engine keeps `_current` across frames so only
changed cells produce output.

### 2.4 The state bridge (MVVM + Riverpod)

The "synchronous" guarantee applies to the **listener-to-state path**, not to
OS I/O (which remains async in Dart). Unidirectional flow:

1. **Ingress** — `dart:io` stdin feeds bytes into `StdinReader`.
2. **Dispatch** — `AnsiParser` emits typed `InputEvent`s into an async
   `StreamController`.
3. **Synchronous state bridge** — a stream listener updates a
   `ValueNotifier<AsyncValue<T>>` on the same event-loop turn.
4. **State transformation** — Riverpod ViewModels receive the event, run
   business logic, and emit a new immutable model.
5. **Tree invalidation** — dependent widgets are notified and request a frame.
6. **Egress loop** — the host binding triggers the engine: build, layout,
   paint into a target buffer, diff against the current buffer, and flush
   minimal ANSI sequences to stdout.

In the shipped code:

- Stdin bytes are parsed by `AnsiParser` into a sealed `InputEvent` union
  (`CharEvent`, `KeyEvent`, `UnknownEvent`) and exposed as a `Stream` via
  **`inputEventStreamProvider`** — the only genuinely public provider.
- ViewModels are plain Riverpod `Notifier`s that `ref.watch` the input stream
  and emit immutable model snapshots (see `test/smoke_test.dart`'s `_Display`).
- `Consumer` widgets `ref.watch` a provider; provider changes call
  `markNeedsBuild`, which calls `Context.requestFrame`, which the host binding
  coalesces into a single microtask-scheduled re-render.

There is **no scheduler and no polling frame loop**. Frames are exclusively
reactive, triggered by provider change or an explicit `requestFrame`.

---

## 3. Package layout

All framework code lives in a single package. Internal-only modules live under
`lib/src/`; the supported entry point is `lib/t22e.dart`.

```
lib/
├── t22e.dart                          # Public barrel (see §5)
└── src/
    ├── engine/                        # Render tree + pipeline (@internal-ish)
    │   ├── render_object.dart         # RenderObject, ParentData, SingleChildRenderObject
    │   ├── render_root.dart           # Full-terminal root render object
    │   ├── render_text.dart           # Leaf render object painting a string
    │   ├── cell.dart                  # Freezed immutable cell
    │   ├── cell_buffer.dart           # Freezed flat 1D buffer of cells
    │   ├── cell_buffer_builder.dart   # Mutable accumulator → CellBuffer
    │   ├── diff_engine.dart           # Target/current compare → DiffOp list
    │   ├── ansi_writer.dart           # DiffOp → ANSI escape sequences
    │   ├── pipeline.dart              # layout/paint/diff/flush orchestrator
    │   ├── stdout_interface.dart      # StdoutInterface mixin + StdoutWriter
    │   ├── color.dart                 # Color / AnsiColor / IndexedColor
    │   ├── cell_style.dart            # CellStyle enum
    │   └── *_extensions.dart          # Traversal, layout, batch, conversion helpers
    ├── models/                        # Geometry + constraints (value types)
    │   ├── offset.dart  size.dart  rect.dart  constraints.dart
    ├── io/                            # dart:io boundary (@internal)
    │   ├── stdin_reader.dart          # Broadcast byte stream from stdin
    │   ├── ansi_parser.dart           # VT100/CSI/SS3 subset → InputEvent
    │   └── *_provider.dart            # Provider wiring for the input chain
    ├── async_value/
    │   └── stdin_value_notifier_provider.dart  # ValueNotifier holding last bytes
    ├── notifier/                      # Local ChangeNotifier/ValueNotifier clone
    │   ├── change_notifier.dart  value_notifier.dart
    │   ├── disposable.dart  disposed.dart  init_mixin.dart
    └── view/                          # Declarative widget + element layer
        ├── widget.dart                # @internal Widget base
        ├── element.dart               # @internal Element base (markNeedsBuild)
        ├── render_object_element.dart # Element owning a RenderObject
        ├── single_child_render_object_element.dart
        ├── context.dart               # App Context = ProviderContainer + requestFrame
        ├── context_provider.dart
        ├── widget_ref.dart            # WidgetRef contract (read/watch)
        ├── pipeline_widget_binding.dart  # Build-pass bridge (view → Pipeline)
        └── components/
            ├── text.dart  root.dart  consumer.dart
```

Every framework class/function that participates in lifecycle or wiring has a
generated Riverpod provider (one file per provider, `foo.dart` →
`foo_provider.dart`). `build_runner` generates `.g.dart` / `.freezed.dart`;
generated files are committed and **must not be edited by hand** (see
`.ai/ai-guidelines.md`).

---

## 4. Key implementation strategy

### 4.1 Engine ↔ view layering and the build-pass bridge

The original plan scoped a pipeline that could accept a widget builder
directly. That would have made `engine/pipeline.dart` import `lib/src/view/`,
breaking the layering rule. The rework keeps the engine widget-free and moves
the build-pass bridge into the **view layer**:

`lib/src/view/pipeline_widget_binding.dart` defines an `@internal` extension
`PipelineWidgetBinding on Pipeline` with `renderWidget(appChild,
terminalSize, {Context})`. It wraps `appChild` in a full-screen `Root`,
compiles and mounts the element tree, extracts the root `RenderObject`, and
delegates to `Pipeline.render`. The engine stays free of widget knowledge
while the task's acceptance criteria are still satisfied.

### 4.2 Geometry as `extension type const`

`Offset`, `Size`, and `Rect` are lightweight `extension type const` records
(not Freezed), keeping terminal geometry allocation-cheap and const-creatable.
`Size implements Offset`. `Constraints` is a Freezed record with `tight` /
`loose` factories plus the `@internal` `ConstraintExtensions.constrain` helper
used by `RenderText`. All dimensions are integer terminal cells.

### 4.3 Buffer management

**Flat 1D buffer.** A `CellBuffer` is a pre-allocated `List<Cell>` of size
`width * height`. Indexing:

- `index = (y * width) + x`
- `y = index ~/ width`
- `x = index % width`

**Double buffering.** Two flat buffers are maintained across frames:

- **Target buffer** — mutable in the sense that cells are overwritten each
  frame (via `CellBufferBuilder`, then frozen into a `CellBuffer`).
- **Current display buffer** — kept by `Pipeline._current`; an exact copy of
  what the terminal currently shows. After diffing, the target is value-copied
  (shallow list copy of immutable cell references, safe and cheap) into the
  current buffer.

**GC hypothesis.** The project assumes modern Dart GC can handle the allocation
rate of immutable `Cell` objects during active rendering. This is a measurable
hypothesis; if profiling shows unacceptable pause times, mutable cells are the
fallback.

### 4.4 Colors and the diff/paint contract

`Color` (RGB), `AnsiColor` (16-color), and `IndexedColor` (256-color) are
`extension type const`. Conversions use a redmean-distance nearest-color
search (`color_extensions.dart`). The diff engine compares cells by value
equality (Freezed), so identity is irrelevant and the paint pass can freely
allocate new `Cell`s per frame.

### 4.5 Provider-driven rebuilds without a scheduler

`Context` (the "app context") wraps a `ProviderContainer` plus an optional
`requestFrame` callback. `Element.markNeedsBuild` delegates to
`context.requestFrame()`. `ConsumerElement.watch` subscribes via
`container.listen` and calls `markNeedsBuild` on change. The host binding (the
app, or `PipelineWidgetBinding`, or a test harness) supplies `requestFrame`
and microtask-batches multiple requests in one event-loop turn so a burst of
provider changes produces exactly one re-render.

For the first phase the host re-renders by **recompiling the whole tree**:
`renderWidget` disposes the previous element tree and remounts a fresh one.
Element reuse (`Widget.canUpdate`) and selective dirty-tracking are deferred —
see "Known risks and deferred work".

### 4.6 Consumer mirrors flutter_riverpod

Instead of a single-provider `Consumer<P, T>`, the implementation mirrors
`flutter_riverpod`: `Consumer` takes a `ConsumerBuilder = Widget
Function(Context, WidgetRef)` and the builder reads whichever providers it
needs via `ref.read` / `ref.watch`. The concrete `WidgetRef` is the
`ConsumerElement` itself (`@internal`). `Consumer` owns no `RenderObject` and
is transparent to layout and paint; a single-child render element descends
past it to find the real render-tree child. Selective element reuse is
deferred; a full recompile is acceptable for the first phase.

---

## 5. Public API surface

The supported import is `package:t22e/t22e.dart`. The barrel has an intentional
`// ignore_for_file: invalid_export_of_internal_element` so that `@internal`
symbols can still be re-exported as **override-seams** — developers can reach
engine internals *at their own risk* (inject a fake stdin, construct a
`Pipeline` in tests, mount an element tree manually) without importing `src/`.
`@internal` from `package:meta` is the stability marker; the barrel re-export
is the access point.

### 5.1 Supported public symbols

`Size`, `Offset`, `Rect`, `Constraints`, `CellStyle`, `AnsiColor`, `Color`,
`IndexedColor` (+ conversion extensions), `Context`, `Text`, `Root`,
`Consumer`, `ConsumerBuilder`, `WidgetRef`, `Key`, `InputEvent`, `CharEvent`,
`KeyEvent`, `UnknownEvent`, and **`inputEventStreamProvider`** (the only public
provider).

Developers are encouraged to import only `package:t22e/t22e.dart`; direct
imports of `src/` files are possible but unsupported.

### 5.2 Internal override-seam symbols (exported, `@internal`, at own risk)

`Cell`, `CellBuffer(Builder)`, `AnsiWriter`, `DiffEngine` (+ `DiffOp*`),
`Pipeline`, `StdoutWriter`, the `RenderObject` family, `RenderRoot`,
`RenderText` (+ extensions), `terminalSizeProvider`, `StdinReader`, the parser
providers, `Widget`, `Element`, `RenderObjectElement`,
`SingleChildRenderObjectElement`, `PipelineWidgetBinding`, `contextProvider`,
`stdinValueNotifierProvider`, and the local `ChangeNotifier` /
`ValueNotifier` notifier family.

`@internal` is a documentation marker; it does not prevent import. Users
importing `src/` files do so at their own risk.

---

## 6. Implementation divergences from the original spec

The original architectural spec was written before the implementation. The
code is the source of truth; the spec predates several decisions.

- **No local `AsyncValue` clone.** The spec planned a local Riverpod
  `AsyncValue<T>` clone plus a `StreamValueNotifier<T>`. The shipped code uses
  Riverpod's native `AsyncValue` from `package:riverpod` and a local
  Flutter-style `ChangeNotifier` / `ValueNotifier<T>` (in
  `lib/src/notifier/`, `@internal`) for synchronous byte holding
  (`stdinValueNotifierProvider`). The t22e barrel does not re-export
  `AsyncValue`; application code imports it from `package:riverpod` directly.
- **`TuiContext` renamed to `Context`.** A single app-context class replaces
  the planned app/widget-context split; tree-local data is deferred. A future
  split is intentionally left open: when tree-local data (parent constraints,
  theme, inherited style) needs to flow down the tree, a separate *widget
  context* (analogous to Flutter's `BuildContext`) can be introduced without
  changing existing `compile` signatures.
- **`Consumer.watch` follows the WidgetRef model.** Instead of a single
  provider field, `Consumer` hands a `WidgetRef` to its builder, so multiple
  providers can be read per build.
- **`terminalSizeProvider` and `contextProvider` are `@internal`**, not
  public. Only `inputEventStreamProvider` is genuinely public. They remain
  re-exported from the barrel as override-seams.
- **`@internal` symbols remain re-exported from the barrel.** This retracts a
  literal acceptance criterion that "no `@internal` class is re-exported".
  The `// ignore_for_file: invalid_export_of_internal_element` suppression is
  intentional and is the documented Dart idiom for "exported but unsupported".
- **Whole-tree recompile on rebuild.** `Widget.canUpdate` element reuse,
  `StatefulWidget`/`State`/`markNeedsBuild` as a dirty-flag (rather than the
  current delegate-to-`requestFrame`), and selective rebuild optimization are
  deferred. See "Known risks and deferred work".

---

## 7. History — how the first phase was delivered

The first phase was built in seven milestones. They are summarized here so the
incremental structure of the codebase is understandable without the original
task files.

**M0 — Project bootstrap.** `pubspec.yaml` with `riverpod`, `freezed`,
`freezed_annotation`, `build_runner`, `meta`, `test`; `analysis_options.yaml`;
the `lib/src/` directory structure; the public barrel `lib/t22e.dart`. No
widgets or engine logic.

**M1 — Immutable core primitives.** Freezed `Cell` with character, foreground,
background, and style flags; geometry primitives (`Offset`, `Size`, `Rect`);
`Constraints` with integer min/max width and height; flat 1D `CellBuffer` with
value-copy semantics and coordinate helpers. Color representation covers ANSI
16, ANSI 256, and RGB.

**M2 — Synchronous state bridge.** Planned a local `AsyncValue<T>` clone and a
`StreamValueNotifier<T>`. *Diverged*: the shipped code uses Riverpod's native
`AsyncValue` and a local `ChangeNotifier`/`ValueNotifier` clone for synchronous
byte holding. Provider integration for the bridge is wired through
`stdinValueNotifierProvider`.

**M3 — Rendering pipeline.** `RenderObject` base class; two-pass constraint
layout (`constraints down`, `sizes up`); `RenderObject.paint(CellBuffer,
Offset)`; concrete `RenderText` and `RenderRoot`; single-child render object
protocol; `DiffEngine`, `AnsiWriter`, and `StdoutWriter` flush. The render
tree and pipeline are the core output path, modeled after Flutter's
`RenderObject` architecture so the future widget/element layer is a natural
extension rather than a rewrite.

**M4 — Terminal I/O without raw mode.** `StdinReader` wrapping `stdin` as an
async byte stream; basic ANSI/VT100 parser emitting typed `InputEvent`s
(`CharEvent`, `KeyEvent`, `UnknownEvent`); `StdoutWriter` flushing to `stdout`.
Raw mode, mouse, focus, and resize events are explicitly out of scope.

**M5 — Declarative widgets.** Base `Widget` and `Element` abstractions;
`RenderObjectElement` and `SingleChildRenderObjectElement`; `Text` widget;
full-screen `Root` widget; `Context` (renamed from `TuiContext`) with provider
access; `Consumer` widget mirroring `flutter_riverpod`. M3 built the render
layer; M5 built the widget/element layer that drives it. The build-pass bridge
`PipelineWidgetBinding` lives in the view layer to preserve the engine layer
boundary.

**M6 — Public API and smoke test.** Riverpod providers promoted to the primary
public API; `inputEventStreamProvider` is the only genuinely public provider;
engine internals marked `@internal` and re-exported as override-seams;
end-to-end smoke test wiring stdin → parser → ViewModel → Consumer → render
pipeline → stdout with minimal-diff assertions; barrel cleanup. Closes the
first phase and proves the architecture is real and usable.

---

## 8. Known risks and deferred work

These are accepted limitations of the first phase. AI agents must **not** delete
existing `TODO` markers (see `.ai/ai-guidelines.md`).

- **No raw terminal mode.** Only `dart:io` stdin/stdout; input may be
  line-buffered and echoed; no reliable single-keypress read, no alternate
  buffer, no mouse/focus/resize events.
- **Async OS I/O remains async.** The "synchronous" guarantee applies only to
  the listener-to-state path, not to the underlying stdin read.
- **Stdout buffering latency.** Without raw mode, stdout may be line-buffered,
  causing frame timing issues.
- **No terminal capability detection.** Color depth, resize handling, and
  feature detection are deferred.
- **Rebuild recompiles the whole tree.** No `Widget.canUpdate` element reuse,
  no selective dirty-tracking, no formal `StatefulWidget` / `State` /
  `markNeedsBuild` dirty-flag base (the current `Element.markNeedsBuild` just
  delegates to `context.requestFrame()`). A future `StatefulWidget` /
  `StatefulElement` with a dirty flag and per-element subscription management
  (`_dependencies` / `_oldDependencies` like `flutter_riverpod`) is the
  planned path.
- **`Cell.character` is a plain `String`.** No grapheme-cluster enforcement,
  no multi-cell width handling (emoji, CJK). TODO in `cell.dart`.
- **GC pressure from immutable cells is an unvalidated hypothesis.** Mutable
  cells are the fallback if profiling shows pause-time problems.
- **Layout is the simplified box model.** No Flex / Row / Column yet; a more
  complete constraint engine may be introduced if widget variety demands it.
- **ANSI parser covers a VT100/CSI/SS3 subset.** SS3 function-key sequences are
  not mapped; unknown sequences surface as `UnknownEvent`. Mouse, focus, and
  bracketed paste are out of scope.
- **No integration tests / example app / docs site.** Unit tests + the smoke
  test are the first-phase verification. Performance benchmarking and GC
  hypothesis validation are deferred.
- **Internal API leakage.** `@internal` is a documentation marker; it does not
  prevent import. Users importing `src/` files do so at their own risk.
- **Open structural TODOs** flagged in code: `stdout_interface.dart` folder
  organization, `stdin_value_notifier_provider.dart` naming/folder, a
  `ColorSgr` extension for ANSI SGR sequence generation, and a diff-engine
  approach revisiting (`diff_engine.dart`).

---

## 9. Definition of done for this phase

The first phase is complete when:

- A developer can import `package:t22e/t22e.dart`.
- They can define a Riverpod-backed model and a full-screen `Text` widget.
- Running the program reads stdin via `dart:io`, updates state, and renders
  text to stdout through the diff engine.
- All unit tests pass.
- Static analysis passes.

All four conditions are met as of this writing.

---

## 10. Working in this codebase (quick reference)

- Before planning or building, read `.ai/ai-guidelines.md`.
- Never edit `*.g.dart` / `*.freezed.dart`; run
  `dart run build_runner build` to regenerate.
- Preserve all `TODO` comments.
- Keep the engine ↔ view dependency direction one-way (no `view` imports under
  `engine/`).
- Every lifecycle/wiring class gets a `*_provider.dart`; exported providers go
  in `lib/t22e.dart`.
- After changes: `dart run build_runner build` → `dart analyze` → `dart test`.
- Do **not** append to `.ai/project.md` or `.ai/coding-standards.md` directly;
  propose additions to the user and wait for approval (per `ai-guidelines.md`).