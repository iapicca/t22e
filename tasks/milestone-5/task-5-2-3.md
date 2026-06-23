# task-5-2-3

## Identity

| Field        | Value                |
|--------------|----------------------|
| Type         | Task                 |
| Title        | Implement Text Paint |
| Parent Story | task-5-2             |

## Objective

Implement paint for the text node so it writes immutable cells into the target buffer.

## Scope Boundary

This task is intentionally scoped to a single focused session. It must only cover:

- `lib/src/view/components/text.dart`:
  - Implement `TextNode.paint`.
  - Iterate over the string and write one `Cell` per character.
  - Apply configured style attributes to each cell.
  - Clip characters that exceed the allocated width.

Out of scope (to be handled in later tasks):

- Multi-line rendering.
- Background fill beyond the text characters.
- Text alignment and padding.

## API References

- Project: `CellBuffer` from Milestone 1.
- Project: `Cell` from Milestone 1.

## Acceptance Criteria

- `TextNode.paint` writes cells into the buffer at the node's offset.
- Each written cell contains the correct character and style.
- Characters beyond the allocated width are skipped.
- All new code follows the existing project style and passes static analysis.
- Unit tests added or updated and passing, if applicable.

## How

In `TextNode.paint`, iterate over the characters of the text string. For each character within the allocated width, create an immutable `Cell` with the character and the widget's style attributes, then write it into the `CellBuffer` at `offset + (index, 0)`. Stop once the allocated width is reached. Use the `CellBuffer` coordinate helpers from Milestone 1.

## Why

Paint is the final step that turns a widget's configuration into visible terminal cells. Implementing it for `Text` closes the end-to-end path from widget declaration to buffer content.
