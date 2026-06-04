# protocol

Terminal protocol constants and byte-level definitions.

## Purpose

Single source of truth for all terminal escape sequence constants, byte values,
and protocol-level knowledge. Every other package imports from here.

## Exports

- `Defaults` class — C0/C1 control bytes, SGR parameters, ANSI color codes,
  CSI sequences, DEC modes, Kitty keyboard constants, mouse parsing constants,
  termios flags, Unicode ranges, border glyphs, spinner frames, timing values.

## Usage

Import and reference constants from `Defaults` directly. No instantiation
required — all values are static.
