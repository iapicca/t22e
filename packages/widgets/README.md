# widgets

Declarative widget library with TEA architecture.

## Purpose

High-level UI framework — declarative widgets with The Elm Architecture
(Model/Msg/Cmd) for state management, layout primitives, and built-in
components.

## Exports

- **TEA**: `Model<M>`, `Msg` sealed class (KeyMsg, MouseMsg, QuitMsg, etc.),
  `Cmd` sealed class (Tick, Every, Batch, Sequence, Exec, NoCmd)
- **Widget system**: `Widget` abstract class, `PaintingContext`,
  `WidgetRenderer`
- **Basic**: `Text`, `Hyperlink`, `Box`, `Spacer`
- **Container**: `Row`, `Column` — flexbox layout
- **Interactive**: `Scrollable`, `TextInput`, `ListView`, `ListItem`
- **Visual**: `ProgressBar`, `Spinner`, `Table`, `Dialog`, `DialogButton`
- **Enums**: `TextAlign`, `MainAxisAlignment`, `CrossAxisAlignment`, `Axis`,
  `EchoMode`, `BorderStyle`

## Usage

Extend `Model` with your state, implement `update()` and `view()`. Compose
widgets in the view. Use `WidgetRenderer.render()` to paint the widget tree
onto a surface.
