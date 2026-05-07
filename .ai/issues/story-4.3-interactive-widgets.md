# Story 4.3: Interactive Widgets (Scrollable, TextInput, List)

**Feature:** Widget Library
**Estimate:** XL
**Depends on:** TEA Event Loop (3.1), Basic Widgets (4.1), Container Widgets (4.2)

## Description

Implement interactive widgets: Scrollable viewport for scrolling content, TextInput for text entry, and List for selectable item lists. These are TEA model subclasses with their own state, messages, and view.

## Tasks

| # | Task | Est. |
|---|------|------|
| 4.3.1 | Scrollable viewport | L |
| 4.3.2 | TextInput widget | L |
| 4.3.3 | List widget (selectable) | M |

## Acceptance Criteria

- Scrollable: scrolls child content vertically/horizontally, shows scrollbar indicator, supports mouse wheel and keyboard (PageUp/Down)
- TextInput: cursor with blink, character insertion/deletion, selection, clipboard paste, password echo mode, validator callback, cursor movement (Home/End, arrows)
- List: keyboard navigation (up/down), selection highlight, configurable item count, optional multi-select, scrolls to keep selection visible
- All interactive widgets are TEA models (Model subclass with update/view)
- Widgets can be composed (e.g., List inside a Box)
