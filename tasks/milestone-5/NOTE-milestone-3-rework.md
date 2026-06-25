# Note: Milestone 5 scope after Milestone 3 three-tree alignment

## What changed in Milestone 3

Milestone 3 has been aligned with Flutter's rendering architecture, but it intentionally implements only the **Render Tree** and the **rendering pipeline**.

The following concepts are introduced in Milestone 3 at the planning level and as implementation targets:

- `RenderObject` base class.
- Two-pass constraint layout (`constraints down`, `sizes up`).
- `RenderObject.paint(CellBuffer, Offset)`.
- Concrete render objects: `RenderText` and `RenderRoot`.
- Single-child render object protocol.
- Diff engine, ANSI writer, and stdout flush pipeline.

The following abstractions remain **owned by Milestone 5** and are explicitly out of scope for Milestone 3:

- `Widget` tree and immutable widget configuration.
- `Element` tree and `BuildContext`.
- `StatelessWidget`, `StatefulWidget`, `State`, and `setState`.
- Widget-to-element inflation and reconciliation (`Widget.canUpdate`).
- `Consumer`-style widgets for reading providers.

## Relationship between Milestone 3 and Milestone 5

Milestone 3 produces a working render tree and pipeline. Milestone 5 will introduce the Widget and Element layers on top of that render tree. The render objects defined in Milestone 3 will be created and updated by Elements in Milestone 5, exactly as Flutter's `RenderObjectElement` creates and updates `RenderObject`s.

Milestone 5 is therefore the **declarative widget and stateful UI layer**:

- Base `Widget` and `Element` classes.
- `BuildContext` as a handle to the Element.
- `StatelessWidget` / `StatelessElement`.
- `RenderObjectWidget` / `RenderObjectElement`.
- `StatefulWidget`, `State`, and `setState`.
- `Consumer`-style widget for Riverpod provider reads.
- Public full-screen root / scaffold widget.
- First multi-child widget (e.g., `Row`, `Column`, or `Flex`).

## Implementation stays here

The *implementation tasks* for the items above remain in the existing Milestone 5 task files. This note only documents the architectural boundary so it is clear that Milestone 3 builds the render layer and Milestone 5 builds the widget/element layer that drives it.
