# unicode

Unicode character width and grapheme cluster utilities.

## Purpose

Accurate terminal character width calculation and proper grapheme cluster
segmentation for correct text rendering in a terminal grid.

## Exports

- `charWidth(codepoint)` — display column width (0, 1, or 2)
- `stringWidth(string)` — total column width of a string
- `isWide()`, `isZeroWidth()`, `isEmoji()`, `isPrintable()`, `isPrivateUse()`
- `graphemeClusters(string)` — segments text into grapheme clusters
- `stringWidthGrapheme(string)` — width respecting grapheme clusters
- `truncate(string, maxWidth)` — truncates to max display width

## Usage

Use `stringWidth` or `stringWidthGrapheme` to measure text before rendering.
Use `graphemeClusters` when iterating over user-visible characters.
