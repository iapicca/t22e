# task-5-2-1

## Identity

| Field        | Value                |
|--------------|----------------------|
| Type         | Task                 |
| Title        | Implement Text Widget Class |
| Parent Story | task-5-2             |

## Objective

Create the public `Text` widget class that holds a string and optional style attributes.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/src/view/components/text.dart`:
  - Define a `Text` widget extending the base `Widget` class.
  - Store the string content and optional foreground/background/style flags.
  - Implement the widget-to-node compile method.

Out of scope (to be handled in later tasks):

- Layout and paint implementation for text.
- Text wrapping, truncation, and overflow.
- Multi-line and rich text support.

## API References

- Project: `Widget` base class from task-5-1-1.
- Project: `Cell` style attributes from Milestone 1.

## Acceptance Criteria

- `Text` is a const-immutable widget.
- It accepts a non-null string and optional style fields.
- It compiles to a dedicated `TextNode` or equivalent runtime node.
- All new code follows the existing project style and passes static analysis.
- Unit tests added or updated and passing, if applicable.

## How

Create `lib/src/view/components/text.dart`. Define `class Text extends Widget` with final fields for the string and style attributes (e.g., foreground color, background color, bold, italic). Provide a `const Text(...)` constructor. Override the compile method to return a `TextNode` initialized with the text content and style. Keep the style model aligned with the immutable `Cell` definition from Milestone 1.

## Why

`Text` is the simplest concrete widget and proves that the base widget abstraction can support real UI elements. It also gives application code a way to display data in the terminal.
