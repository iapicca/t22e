# Public API Surface Audit — task-6-1-1

Inventory of framework services reachable through Riverpod providers, and the
public/internal decision for each. Consumed by task-6-1-2 (provider definition)
and task-6-4 (barrel cleanup).

## Decision rule

A provider is **public** when application code (widgets or ViewModels) needs to
read or watch it. A provider is **internal** when it is only an implementation
detail wired by the framework or by the engine layer.

## Public providers

| Provider                      | Service exposed          | Rationale                                                    |
|-------------------------------|--------------------------|--------------------------------------------------------------|
| `inputEventStreamProvider`    | Parsed stdin event stream | Application ViewModels need the typed `InputEvent` stream.   |
| `terminalSizeProvider`        | Terminal `Size` value     | Widgets/ViewModels read the render size; tests update it.    |
| `contextProvider`             | App `Context` (container) | ViewModels with only `Ref` obtain the shared app `Context`. |

## Internal-only providers (not part of the public contract)

These remain engine/io wiring details and are hidden in task-6-2 (e.g. marked
`@internal`) and/or removed from the barrel in task-6-4:

- `stdinReaderProvider` — raw `dart:io` stdin wrapper.
- `stdinStreamProvider` — raw byte stream, consumed by the parser chain.
- `ansiParserProvider` — parser instance, owned by the input pipeline.
- `stdinValueNotifierProvider` — internal byte notifier bridge detail.
- `pipelineProvider`, `ansiWriterProvider`, `diffEngineProvider`,
  `stdoutInterfaceProvider`, `renderRootProvider`, `renderTextProvider`,
  `cellBufferBuilderProvider` — engine pipeline composition.

## Notes

- `terminalSizeProvider` defaults to `Size(80, 24)`.
- `contextProvider` is built from `Ref.container` so ViewModels can reach the
  shared `Context` without holding the `ProviderContainer` directly.
- Consumer rebuild-on-watch wiring is **not** implemented in this story; it is
  documented in `NOTE-consumer-rebuild-wiring.md` and tracked separately.