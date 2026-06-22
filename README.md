# t22e

A declarative terminal user interface framework for Dart.

## Architecture

Built on The Elm Architecture (TEA) with a layered rendering pipeline:

```
Model → View → Layout → Paint → Diff → ANSI Output
```

## Packages

| Package | Purpose |
|---------|---------|
| `protocol` | Terminal escape sequence constants and byte-level definitions |
| `ansi` | ANSI escape sequence builders |
| `unicode` | Character width calculation and grapheme cluster segmentation |
| `parser` | VT500 input parser — converts raw bytes to structured events |
| `terminal` | Raw mode management via FFI with IO fallback |
| `core` | Data structures: cells, styles, surfaces, geometry, layout |
| `renderer` | Frame diffing and optimized terminal output |
| `capability` | Terminal capability probing (color, sync, keyboard) |
| `lifecycle` | Signal handling, alt screen, terminal restoration |
| `notifier` | Observable objects with disposal lifecycle |
| `widgets` | Declarative widget library with TEA state management |

## Quick Start

```bash
melos analyze   # static analysis
melos test      # run all tests
```

## Design Principles

- **TEA architecture**: Pure functional state management with Model/Msg/Cmd
- **Diff-based rendering**: Only changed rows/cells are sent to terminal
- **Capability probing**: Adapts to terminal features (truecolor, sync, Kitty)
- **Riverpod DI**: Dependency injection and lifecycle management throughout
- **Freezed immutability**: All data classes are immutable with code generation
