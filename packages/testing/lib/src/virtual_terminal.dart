import 'package:core/core.dart';
import 'package:protocol/protocol.dart' show Defaults;

/// Simulates a terminal grid in memory, interpreting ANSI escape sequences.
class VirtualTerminal {
  /// Current terminal width in columns.
  int width;
  /// Current terminal height in rows.
  int height;
  late List<List<Cell>> _grid;
  int _cursorX = 0;
  int _cursorY = 0;
  TextStyle _currentStyle = TextStyle.empty;

  /// TODO: Track alternate screen state for buffer switching
  // ignore: unused_field
  bool _altScreen = false;

  /// TODO: Store the normal screen buffer when switching to alt screen
  // ignore: unused_field
  List<List<Cell>>? _normalScreenBuffer;

  VirtualTerminal({
    this.width = Defaults.defaultTerminalWidth,
    this.height = Defaults.defaultTerminalHeight,
  }) {
    _resetGrid();
  }

  /// Writes an ANSI-escaped string into the virtual terminal grid.
  void write(String ansi) {
    var i = 0;
    while (i < ansi.length) {
      final c = ansi.codeUnitAt(i);
      if (c == Defaults.escapeByte && i + 1 < ansi.length) {
        final next = ansi.codeUnitAt(i + 1);
        if (next == Defaults.csiEntryByte) {
          i = _handleCsi(ansi, i + 2);
        } else if (next == Defaults.oscEntryByte) {
          i = _handleOsc(ansi, i + 2);
        } else if (next == Defaults.escFinalReset) {
          _resetGrid();
          i += 2;
        } else if (next == Defaults.escFinalSaveCursor) {
          _cursorX = _savedCursorX;
          _cursorY = _savedCursorY;
          i += 2;
        } else if (next == Defaults.escFinalRestoreCursor) {
          _savedCursorX = _cursorX;
          _savedCursorY = _cursorY;
          i += 2;
        } else {
          i += 2;
        }
      } else if (c == Defaults.lineFeedByte) {
        _newline();
        i++;
      } else if (c == Defaults.carriageReturnByte) {
        _cursorX = 0;
        i++;
      } else if (c >= Defaults.codepointSpace) {
        _putChar(ansi[i]);
        i++;
      } else {
        i++;
      }
    }
  }

  /// Saved cursor X position.
  int _savedCursorX = 0;
  /// Saved cursor Y position.
  int _savedCursorY = 0;

  /// Parses a CSI sequence starting at [start] index in the string.
  int _handleCsi(String ansi, int start) {
    final params = <int>[];
    var i = start;
    var numStr = '';

    while (i < ansi.length) {
      final c = ansi.codeUnitAt(i);
      if (c >= Defaults.byteRangeDigitLow && c <= Defaults.byteRangeDigitHigh) {
        numStr += String.fromCharCode(c);
      } else if (c == Defaults.semicolonByte) {
        params.add(numStr.isEmpty ? 0 : int.parse(numStr));
        numStr = '';
      } else if (c >= Defaults.byteRangeUpperLow &&
          c <= Defaults.byteRangeUpperHigh) {
        params.add(numStr.isEmpty ? 0 : int.parse(numStr));
        final fb = c;
        _dispatchCsi(params, fb);
        return i + 1;
      } else if (c == Defaults.decPrivatePrefix) {
        params.add(-1);
        numStr = '';
      } else {
        break;
      }
      i++;
    }
    return i;
  }

  /// Skips over an OSC sequence (BEL or ST terminated).
  int _handleOsc(String ansi, int start) {
    var i = start;
    while (i < ansi.length) {
      final c = ansi.codeUnitAt(i);
      if (c == Defaults.bellByte || c == Defaults.stringTerminatorByte)
        return i + 1;
      i++;
    }
    return i;
  }

  /// Dispatches a parsed CSI sequence by final byte.
  void _dispatchCsi(List<int> params, int fb) {
    switch (fb) {
      case Defaults.csiFinalCup:
        _cursorY = (params.isNotEmpty ? params[0] : 1) - 1;
        _cursorX = (params.length > 1 ? params[1] : 1) - 1;
        _clampCursor();
      case Defaults.csiFinalUp:
        _cursorY = (_cursorY - (params.isEmpty ? 1 : params[0])).clamp(
          0,
          height - 1,
        );
      case Defaults.csiFinalDown:
        _cursorY = (_cursorY + (params.isEmpty ? 1 : params[0])).clamp(
          0,
          height - 1,
        );
      case Defaults.csiFinalRight:
        _cursorX = (_cursorX + (params.isEmpty ? 1 : params[0])).clamp(
          0,
          width - 1,
        );
      case Defaults.csiFinalLeft:
        _cursorX = (_cursorX - (params.isEmpty ? 1 : params[0])).clamp(
          0,
          width - 1,
        );
      case Defaults.csiFinalEd:
        _eraseDisplay(params.isEmpty ? Defaults.eraseDisplayBelow : params[0]);
      case Defaults.csiFinalEl:
        _eraseLine(params.isEmpty ? Defaults.eraseLineRight : params[0]);
      case Defaults.csiFinalSgr:
        _applySgr(params);
      case Defaults.csiFinalDecset
          when params.contains(Defaults.decModeAltScreen):
        _altScreen = true;
      case Defaults.csiFinalDecrst
          when params.contains(Defaults.decModeAltScreen):
        _altScreen = false;
      case Defaults.csiFinalDecset when params[0] == Defaults.decModeAltScreen:
        _altScreen = true;
      case Defaults.csiFinalDecrst when params[0] == Defaults.decModeAltScreen:
        _altScreen = false;
    }
  }

  /// Applies SGR parameters to the current text style.
  void _applySgr(List<int> params) {
    if (params.isEmpty || params[0] == Defaults.sgrReset) {
      _currentStyle = TextStyle.empty;
      return;
    }
    var i = 0;
    while (i < params.length) {
      final p = params[i];
      switch (p) {
        case Defaults.sgrReset:
          _currentStyle = TextStyle.empty;
        case Defaults.sgrBold:
          _currentStyle = TextStyle(bold: true).merge(_currentStyle);
        case Defaults.sgrFaint:
          _currentStyle = TextStyle(dim: true).merge(_currentStyle);
        case Defaults.sgrItalic:
          _currentStyle = TextStyle(italic: true).merge(_currentStyle);
        case Defaults.sgrUnderline:
          _currentStyle = TextStyle(underline: true).merge(_currentStyle);
        case Defaults.sgrBlink:
          _currentStyle = TextStyle(blink: true).merge(_currentStyle);
        case Defaults.sgrReverse:
          _currentStyle = TextStyle(reverse: true).merge(_currentStyle);
        case Defaults.sgrStrikethrough:
          _currentStyle = TextStyle(strikethrough: true).merge(_currentStyle);
        case Defaults.sgrNoBoldFaint:
          _currentStyle = TextStyle(
            bold: false,
            dim: false,
          ).merge(_currentStyle);
        case Defaults.sgrNoItalic:
          _currentStyle = TextStyle(italic: false).merge(_currentStyle);
        case Defaults.sgrNoUnderline:
          _currentStyle = TextStyle(underline: false).merge(_currentStyle);
        case Defaults.sgrNoBlink:
          _currentStyle = TextStyle(blink: false).merge(_currentStyle);
        case Defaults.sgrNoReverse:
          _currentStyle = TextStyle(reverse: false).merge(_currentStyle);
        case Defaults.sgrNoStrikethrough:
          _currentStyle = TextStyle(strikethrough: false).merge(_currentStyle);
        case Defaults.sgrFgAnsiBase:
        case Defaults.sgrFgAnsiBase + 1:
        case Defaults.sgrFgAnsiBase + 2:
        case Defaults.sgrFgAnsiBase + 3:
        case Defaults.sgrFgAnsiBase + 4:
        case Defaults.sgrFgAnsiBase + 5:
        case Defaults.sgrFgAnsiBase + 6:
        case Defaults.sgrFgAnsiBase + 7:
          _currentStyle = TextStyle(
            foreground: Color.ansi(p - Defaults.sgrFgAnsiBase),
          ).merge(_currentStyle);
        case Defaults.sgrFgExtended:
          if (i + 1 < params.length) {
            if (params[i + 1] == Defaults.sgrColor256 &&
                i + 2 < params.length) {
              _currentStyle = TextStyle(
                foreground: Color.indexed(params[i + 2]),
              ).merge(_currentStyle);
              i += 2;
            } else if (params[i + 1] == Defaults.sgrColorRgb &&
                i + 4 < params.length) {
              _currentStyle = TextStyle(
                foreground: Color.rgb(
                  params[i + 2],
                  params[i + 3],
                  params[i + 4],
                ),
              ).merge(_currentStyle);
              i += 4;
            }
          }
        case Defaults.sgrFgReset:
          _currentStyle = TextStyle(foreground: null).merge(_currentStyle);
        case Defaults.sgrBgAnsiBase:
        case Defaults.sgrBgAnsiBase + 1:
        case Defaults.sgrBgAnsiBase + 2:
        case Defaults.sgrBgAnsiBase + 3:
        case Defaults.sgrBgAnsiBase + 4:
        case Defaults.sgrBgAnsiBase + 5:
        case Defaults.sgrBgAnsiBase + 6:
        case Defaults.sgrBgAnsiBase + 7:
          _currentStyle = TextStyle(
            background: Color.ansi(p - Defaults.sgrBgAnsiBase),
          ).merge(_currentStyle);
        case Defaults.sgrBgExtended:
          if (i + 1 < params.length) {
            if (params[i + 1] == Defaults.sgrColor256 &&
                i + 2 < params.length) {
              _currentStyle = TextStyle(
                background: Color.indexed(params[i + 2]),
              ).merge(_currentStyle);
              i += 2;
            } else if (params[i + 1] == Defaults.sgrColorRgb &&
                i + 4 < params.length) {
              _currentStyle = TextStyle(
                background: Color.rgb(
                  params[i + 2],
                  params[i + 3],
                  params[i + 4],
                ),
              ).merge(_currentStyle);
              i += 4;
            }
          }
        case Defaults.sgrBgReset:
          _currentStyle = TextStyle(background: null).merge(_currentStyle);
        case Defaults.sgrOverline:
          _currentStyle = TextStyle(overline: true).merge(_currentStyle);
        case Defaults.sgrNoOverline:
          _currentStyle = TextStyle(overline: false).merge(_currentStyle);
      }
      i++;
    }
  }

  /// Erases a region of the display by mode.
  void _eraseDisplay(int mode) {
    switch (mode) {
      case 0:
        _clearRegion(_cursorY, _cursorX, height - 1, width - 1);
      case 1:
        _clearRegion(0, 0, _cursorY, _cursorX);
      case 2:
      case 3:
        _resetGrid();
    }
  }

  /// Erases part of the current line by mode.
  void _eraseLine(int mode) {
    switch (mode) {
      case 0:
        _clearRegion(_cursorY, _cursorX, _cursorY, width - 1);
      case 1:
        _clearRegion(_cursorY, 0, _cursorY, _cursorX);
      case 2:
        _clearRegion(_cursorY, 0, _cursorY, width - 1);
    }
  }

  /// Clears a rectangular region of cells.
  void _clearRegion(int r1, int c1, int r2, int c2) {
    for (var r = r1; r <= r2 && r < height; r++) {
      for (var c = c1; c <= c2 && c < width; c++) {
        _grid[r][c] = const Cell();
      }
    }
  }

  /// Places a character at the current cursor position.
  void _putChar(String ch) {
    if (_cursorX >= width || _cursorY >= height) return;
    _grid[_cursorY] = List<Cell>.of(_grid[_cursorY]);
    _grid[_cursorY][_cursorX] = Cell(char: ch, style: _currentStyle);
    _cursorX++;
    if (_cursorX >= width) {
      _cursorX = 0;
      _newline();
    }
  }

  /// Moves to the next line, scrolling if at the bottom.
  void _newline() {
    _cursorY++;
    _cursorX = 0;
    if (_cursorY >= height) {
      _scrollUp();
      _cursorY = height - 1;
    }
  }

  /// Scrolls the grid up by one row.
  void _scrollUp() {
    for (var r = 0; r < height - 1; r++) {
      _grid[r] = List<Cell>.of(_grid[r + 1]);
    }
    _grid[height - 1] = List.filled(width, const Cell(), growable: false);
  }

  /// Clamps cursor position to grid bounds.
  void _clampCursor() {
    _cursorX = _cursorX.clamp(0, width - 1);
    _cursorY = _cursorY.clamp(0, height - 1);
  }

  /// Resets the grid to all blank cells.
  void _resetGrid() {
    _grid = List.generate(
      height,
      (_) => List.filled(width, const Cell(), growable: false),
      growable: false,
    );
  }

  /// Resizes the virtual terminal, preserving overlapping content.
  void resize(int newWidth, int newHeight) {
    final oldGrid = _grid;
    width = newWidth;
    height = newHeight;
    _resetGrid();
    for (var r = 0; r < oldGrid.length && r < height; r++) {
      for (var c = 0; c < oldGrid[r].length && c < width; c++) {
        _grid[r][c] = oldGrid[r][c];
      }
    }
    _clampCursor();
  }

  /// Returns the cell at the given row/col, or a blank cell if out of bounds.
  Cell cellAt(int row, int col) {
    if (row < 0 || row >= height || col < 0 || col >= width) {
      return const Cell();
    }
    return _grid[row][col];
  }

  /// Returns the entire grid content as plain text.
  String plainText() {
    return _grid
        .map((row) {
          return row.map((c) => c.wideContinuation ? '' : c.char).join();
        })
        .join('\n');
  }
}
