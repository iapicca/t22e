# Barrel Export Audit — task-6-4-1

Audit of every `export` directive in `lib/t22e.dart` against the intended
public surface for the first phase. Consumed by task-6-4-2 (barrel update)
and task-6-4-3 (smoke-test verification).

## Governing decisions

These decisions were confirmed with the project owner while planning
task-6-4 and override conflicting guidance from earlier stories:

1. **Riverpod providers are the primary API.** Framework services and
   application-state entry points are exposed as Riverpod providers, not as
   bare engine classes.
2. **`@internal` symbols stay exported from the barrel.** Developers can
   reach engine/io internals and internal providers *at their own risk* to
   override or wire the framework (e.g. inject a fake stdin, construct a
   `Pipeline`, mount an element tree in tests). `@internal` from
   `package:meta` is the stability/risk marker; the barrel re-export is the
   access point.
3. **`// ignore_for_file: invalid_export_of_internal_element` in the barrel
   is intentional and stays.** It is the documented Dart idiom for "exported
   but unsupported." Its presence is the mechanism that implements decision 2.
   This intentionally does **not** satisfy task-6-4-2's literal acceptance
   criterion "No `@internal` class or function is re-exported from the public
   barrel"; that criterion is retracted by decision 2.
4. **`contextProvider` and `terminalSizeProvider` remain `@internal`.** This
   retracts the `NOTE-public-api-audit.md` classification of these two as
   public. They are internal wiring providers, accessible at own risk per
   decision 2. The genuinely-public provider surface for the first phase is
   `inputEventStreamProvider`.
5. **No local `AsyncValue` clone.** `task-6-4-2` mentions "the AsyncValue
   clone," but none exists in `lib/src/`. Application code imports
   `AsyncValue` from `package:riverpod/riverpod.dart` directly. The t22e
   barrel does not (and need not) re-export it.

## Disposition rule

| Disposition               | Meaning                                                                 |
|---------------------------|-------------------------------------------------------------------------|
| **Public**                | Not annotated `@internal`; part of the supported API.                  |
| **Internal override-seam**| Annotated `@internal` **and** re-exported from the barrel; use at own risk. |

## Audit table

Every `export` line in `lib/t22e.dart` is listed below with the disposition
of each exported symbol.

### Public (supported)

| Symbol                        | Source file                              | Category   |
|-------------------------------|------------------------------------------|------------|
| `Size`                        | `src/models/size.dart`                   | Model      |
| `Offset`                      | `src/models/offset.dart`                 | Model      |
| `Rect`                        | `src/models/rect.dart`                   | Model      |
| `Constraints`                 | `src/models/constraints.dart`            | Model      |
| `CellStyle`                   | `src/engine/cell_style.dart`             | Enum       |
| `AnsiColor`, `Color`, `IndexedColor` | `src/engine/color.dart`            | Value type |
| `AnsiToColor`, `ColorAnsi`, `ColorIndex`, `IndexedToColor` | `src/engine/color_extensions.dart` | Extension |
| `Context`                     | `src/view/context.dart`                  | App context|
| `Text`                        | `src/view/components/text.dart`          | Widget     |
| `Root`                        | `src/view/components/root.dart`          | Widget     |
| `Consumer`, `ConsumerBuilder`| `src/view/components/consumer.dart`      | Widget     |
| `WidgetRef`                   | `src/view/widget_ref.dart`               | Contract   |
| `Key`                         | `src/io/ansi_parser.dart`                | Enum       |
| `InputEvent`, `CharEvent`, `KeyEvent`, `UnknownEvent` | `src/io/ansi_parser.dart` | Event type |
| `inputEventStreamProvider`    | `src/io/input_event_stream_provider.dart`| Provider   |

### Internal override-seam (exported, `@internal`, at own risk)

| Symbol                                                                 | Source file                                        |
|------------------------------------------------------------------------|----------------------------------------------------|
| `Cell`                                                                 | `src/engine/cell.dart`                             |
| `CellBuffer`                                                           | `src/engine/cell_buffer.dart`                      |
| `CellBufferBuilder`                                                    | `src/engine/cell_buffer_builder.dart`              |
| `CellBufferBuilderBatch`                                               | `src/engine/cell_buffer_builder_extensions.dart`   |
| `CellBufferExtensions`                                                 | `src/engine/cell_buffer_extensions.dart`           |
| `cellBufferBuilderProvider`                                            | `src/engine/cell_buffer_builder_provider.dart`     |
| `AnsiWriter`                                                           | `src/engine/ansi_writer.dart`                      |
| `ansiWriterProvider`                                                   | `src/engine/ansi_writer_provider.dart`             |
| `DiffEngine`, `DiffOp`, `DiffOpMove`, `DiffOpStyle`, `DiffOpWrite`     | `src/engine/diff_engine.dart`                      |
| `diffEngineProvider`                                                   | `src/engine/diff_engine_provider.dart`             |
| `Pipeline`                                                             | `src/engine/pipeline.dart`                         |
| `pipelineProvider`                                                     | `src/engine/pipeline_provider.dart`                |
| `StdoutWriter`                                                         | `src/engine/stdout_interface.dart`                 |
| `stdoutInterfaceProvider`                                              | `src/engine/stdout_interface_provider.dart`        |
| `ParentData`, `BoxParentData`, `RenderObject`, `SingleChildRenderObject`| `src/engine/render_object.dart`                   |
| `RenderObjectTraversal`                                                | `src/engine/render_object_extensions.dart`         |
| `RenderRoot`                                                           | `src/engine/render_root.dart`                      |
| `RenderRootBinding`                                                    | `src/engine/render_root_extensions.dart`           |
| `renderRootProvider`                                                   | `src/engine/render_root_provider.dart`             |
| `RenderText`                                                           | `src/engine/render_text.dart`                      |
| `RenderTextLayout`                                                     | `src/engine/render_text_extensions.dart`           |
| `renderTextProvider`                                                   | `src/engine/render_text_provider.dart`             |
| `terminalSizeProvider`                                                 | `src/models/size_provider.dart`                    |
| `StdinReader`                                                          | `src/io/stdin_reader.dart`                         |
| `stdinReaderProvider`                                                  | `src/io/stdin_reader_provider.dart`                |
| `stdinStreamProvider`                                                  | `src/io/stdin_stream_provider.dart`                |
| `AnsiParser`                                                           | `src/io/ansi_parser.dart`                          |
| `ansiParserProvider`                                                   | `src/io/ansi_parser_provider.dart`                 |
| `Widget`                                                               | `src/view/widget.dart`                             |
| `Element`                                                              | `src/view/element.dart`                            |
| `RenderObjectElement`                                                  | `src/view/render_object_element.dart`             |
| `SingleChildRenderObjectElement`                                       | `src/view/single_child_render_object_element.dart` |
| `PipelineWidgetBinding`                                                | `src/view/pipeline_widget_binding.dart`            |
| `contextProvider`                                                      | `src/view/context_provider.dart`                   |
| `stdinValueNotifierProvider`                                           | `src/async_value/stdin_value_notifier_provider.dart`|
| `ChangeNotifier`, `CheckDisposed`, `CheckInitialized`, `Disposable`, `Disposed`, `InitMixin`, `ValueNotifier`, `VoidCallback` | `src/notifier/notifier.dart` (re-exports; classes `@internal` in their files) |

## Notes and inconsistencies

- **Geometry set reconciled to public.** `Size`, `Offset`, `Rect`, and
  `Constraints` are all Public (the task-6-2 `@internal` annotations on the
  latter three were removed during task-6-4 so the geometry set is uniform).
  `terminalSizeProvider` (the provider) stays `@internal` per decision 4.
- **Public widgets extend an internal base.** `Text`, `Root`, `Consumer`
  extend `Widget`, which is `@internal`. This is allowed and intentional:
  subclassing `Widget` directly is an at-own-risk activity, while the three
  shipped widgets are the supported entry points.
- **`WidgetRef` is public; its implementation `ConsumerElement` is
  `@internal`.** The contract is supported; the concrete element is not.
- **Smoke/providers tests.** Both `test/smoke_test.dart` and
  `test/providers_test.dart` already import only `package:t22e/t22e.dart`
  (plus `riverpod`, `test`, and a local `FakeIOSink` helper that does not
  import t22e). They exercise internal override-seams (`stdinStreamProvider`,
  `Pipeline`, `AnsiWriter`, `DiffEngine`, `StdoutWriter`, `Element`,
  `RenderObjectElement`, `contextProvider`, `terminalSizeProvider`) through
  the barrel by design, per decision 2.

## Verification status (final)

- `dart analyze`: clean. The barrel `// ignore_for_file` suppression masks
  the intentional `@internal` re-exports (decision 2); `Offset`, `Rect`, and
  `Constraints` are no longer `@internal` and so are exported without
  suppression.
- `dart test` (full suite, 161 tests): all pass, including
  `test/smoke_test.dart` and `test/providers_test.dart`, both of which import
  only `package:t22e/t22e.dart`.
- No `package:t22e/src/...` imports exist in `test/`.
