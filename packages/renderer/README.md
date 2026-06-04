# renderer

Terminal rendering engine with frame diffing.

## Purpose

Converts widget-rendered Surfaces into optimized ANSI escape sequences.
Minimizes output by sending only changed rows or cells.

## Exports

- **Frame** — rendered frame with plain and styled line representations
- **diff()** — compares frames, returns changed row indices
- **LineRenderer** — cursor-positions to changed rows only
- **SyncRenderer** — wraps LineRenderer with synchronized update markers
- **CellRenderer** — per-cell diff for granular output

## Usage

Create a `Frame` from a `Surface`, diff against the previous frame, then use a
renderer to produce ANSI output. Prefer `SyncRenderer` when the terminal
supports synchronized updates to prevent tearing.
