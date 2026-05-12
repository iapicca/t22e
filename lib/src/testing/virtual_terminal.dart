import '../core/cell.dart';
import '../core/style.dart';
import '../core/color.dart' show Color;
import '../well_known.dart' show WellKnown;

/// Simulates a real terminal: processes ANSI escape codes and maintains cell grid
class VirtualTerminal {
  int width;
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

  VirtualTerminal({this.width = WellKnown.defaultTerminalWidth, this.height = WellKnown.defaultTerminalHeight}) {
    _resetGrid();
  }

  /// Feeds an ANSI string to the virtual terminal, updating its state and grid
  void write(String ansi) {
    var i = 0;
    while (i < ansi.length) {
      final c = ansi.codeUnitAt(i);
      if (c == WellKnown.escapeByte && i + 1 < ansi.length) {
        final next = ansi.codeUnitAt(i + 1);
        if (next == WellKnown.csiEntryByte) {
          i = _handleCsi(ansi, i + 2);
        } else if (next == WellKnown.oscEntryByte) {
          i = _handleOsc(ansi, i + 2);
        } else if (next == WellKnown.escFinalReset) {
          _resetGrid();
          i += 2;
        } else if (next == WellKnown.escFinalSaveCursor) {
          _cursorX = _savedCursorX;
          _cursorY = _savedCursorY;
          i += 2;
        } else if (next == WellKnown.escFinalRestoreCursor) {
          _savedCursorX = _cursorX;
          _savedCursorY = _cursorY;
          i += 2;
        } else {
          i += 2;
        }
      } else if (c == WellKnown.lineFeedByte) {
        _newline();
        i++;
      } else if (c == WellKnown.carriageReturnByte) {
        _cursorX = 0;
        i++;
      } else if (c >= WellKnown.codepointSpace) {
        _putChar(ansi[i]);
        i++;
      } else {
        i++;
      }
    }
  }

  int _savedCursorX = 0;
  int _savedCursorY = 0;

  int _handleCsi(String ansi, int start) {
    final params = <int>[];
    var i = start;
    var numStr = '';

    while (i < ansi.length) {
      final c = ansi.codeUnitAt(i);
      if (c >= WellKnown.byteRangeDigitLow && c <= WellKnown.byteRangeDigitHigh) {
        numStr += String.fromCharCode(c);
      } else if (c == WellKnown.semicolonByte) {
        params.add(numStr.isEmpty ? 0 : int.parse(numStr));
        numStr = '';
      } else if (c >= WellKnown.byteRangeUpperLow && c <= WellKnown.byteRangeUpperHigh) {
        params.add(numStr.isEmpty ? 0 : int.parse(numStr));
        final fb = c;
        _dispatchCsi(params, fb);
        return i + 1;
      } else if (c == WellKnown.decPrivatePrefix) {
        params.add(-1);
        numStr = '';
      } else {
        break;
      }
      i++;
    }
    return i;
  }

  int _handleOsc(String ansi, int start) {
    var i = start;
    while (i < ansi.length) {
      final c = ansi.codeUnitAt(i);
      if (c == WellKnown.bellByte || c == WellKnown.stringTerminatorByte) return i + 1;
      i++;
    }
    return i;
  }

  void _dispatchCsi(List<int> params, int fb) {
    switch (fb) {
      case WellKnown.csiFinalCup:
        _cursorY = (params.isNotEmpty ? params[0] : 1) - 1;
        _cursorX = (params.length > 1 ? params[1] : 1) - 1;
        _clampCursor();
      case WellKnown.csiFinalUp:
        _cursorY = (_cursorY - (params.isEmpty ? 1 : params[0])).clamp(0, height - 1);
      case WellKnown.csiFinalDown:
        _cursorY = (_cursorY + (params.isEmpty ? 1 : params[0])).clamp(0, height - 1);
      case WellKnown.csiFinalRight:
        _cursorX = (_cursorX + (params.isEmpty ? 1 : params[0])).clamp(0, width - 1);
      case WellKnown.csiFinalLeft:
        _cursorX = (_cursorX - (params.isEmpty ? 1 : params[0])).clamp(0, width - 1);
      case WellKnown.csiFinalEd:
        _eraseDisplay(params.isEmpty ? WellKnown.eraseDisplayBelow : params[0]);
      case WellKnown.csiFinalEl:
        _eraseLine(params.isEmpty ? WellKnown.eraseLineRight : params[0]);
      case WellKnown.csiFinalSgr:
        _applySgr(params);
      case WellKnown.csiFinalDecset when params.contains(WellKnown.decModeAltScreen):
        _altScreen = true;
      case WellKnown.csiFinalDecrst when params.contains(WellKnown.decModeAltScreen):
        _altScreen = false;
      case WellKnown.csiFinalDecset when params[0] == WellKnown.decModeAltScreen:
        _altScreen = true;
      case WellKnown.csiFinalDecrst when params[0] == WellKnown.decModeAltScreen:
        _altScreen = false;
    }
  }

  void _applySgr(List<int> params) {
    if (params.isEmpty || params[0] == WellKnown.sgrReset) {
      _currentStyle = TextStyle.empty;
      return;
    }
    var i = 0;
    while (i < params.length) {
      final p = params[i];
      switch (p) {
        case WellKnown.sgrReset:
          _currentStyle = TextStyle.empty;
        case WellKnown.sgrBold:
          _currentStyle = TextStyle(bold: true).merge(_currentStyle);
        case WellKnown.sgrFaint:
          _currentStyle = TextStyle(dim: true).merge(_currentStyle);
        case WellKnown.sgrItalic:
          _currentStyle = TextStyle(italic: true).merge(_currentStyle);
        case WellKnown.sgrUnderline:
          _currentStyle = TextStyle(underline: true).merge(_currentStyle);
        case WellKnown.sgrBlink:
          _currentStyle = TextStyle(blink: true).merge(_currentStyle);
        case WellKnown.sgrReverse:
          _currentStyle = TextStyle(reverse: true).merge(_currentStyle);
        case WellKnown.sgrStrikethrough:
          _currentStyle = TextStyle(strikethrough: true).merge(_currentStyle);
        case WellKnown.sgrNoBoldFaint:
          _currentStyle = TextStyle(bold: false, dim: false).merge(_currentStyle);
        case WellKnown.sgrNoItalic:
          _currentStyle = TextStyle(italic: false).merge(_currentStyle);
        case WellKnown.sgrNoUnderline:
          _currentStyle = TextStyle(underline: false).merge(_currentStyle);
        case WellKnown.sgrNoBlink:
          _currentStyle = TextStyle(blink: false).merge(_currentStyle);
        case WellKnown.sgrNoReverse:
          _currentStyle = TextStyle(reverse: false).merge(_currentStyle);
        case WellKnown.sgrNoStrikethrough:
          _currentStyle = TextStyle(strikethrough: false).merge(_currentStyle);
        case WellKnown.sgrFgAnsiBase:
        case WellKnown.sgrFgAnsiBase + 1:
        case WellKnown.sgrFgAnsiBase + 2:
        case WellKnown.sgrFgAnsiBase + 3:
        case WellKnown.sgrFgAnsiBase + 4:
        case WellKnown.sgrFgAnsiBase + 5:
        case WellKnown.sgrFgAnsiBase + 6:
        case WellKnown.sgrFgAnsiBase + 7:
          _currentStyle = TextStyle(foreground: Color.ansi(p - WellKnown.sgrFgAnsiBase)).merge(_currentStyle);
        case WellKnown.sgrFgExtended:
          if (i + 1 < params.length) {
            if (params[i + 1] == WellKnown.sgrColor256 && i + 2 < params.length) {
              _currentStyle = TextStyle(foreground: Color.indexed(params[i + 2])).merge(_currentStyle);
              i += 2;
            } else if (params[i + 1] == WellKnown.sgrColorRgb && i + 4 < params.length) {
              _currentStyle = TextStyle(foreground: Color.rgb(params[i + 2], params[i + 3], params[i + 4])).merge(_currentStyle);
              i += 4;
            }
          }
        case WellKnown.sgrFgReset:
          _currentStyle = TextStyle(foreground: null).merge(_currentStyle);
        case WellKnown.sgrBgAnsiBase:
        case WellKnown.sgrBgAnsiBase + 1:
        case WellKnown.sgrBgAnsiBase + 2:
        case WellKnown.sgrBgAnsiBase + 3:
        case WellKnown.sgrBgAnsiBase + 4:
        case WellKnown.sgrBgAnsiBase + 5:
        case WellKnown.sgrBgAnsiBase + 6:
        case WellKnown.sgrBgAnsiBase + 7:
          _currentStyle = TextStyle(background: Color.ansi(p - WellKnown.sgrBgAnsiBase)).merge(_currentStyle);
        case WellKnown.sgrBgExtended:
          if (i + 1 < params.length) {
            if (params[i + 1] == WellKnown.sgrColor256 && i + 2 < params.length) {
              _currentStyle = TextStyle(background: Color.indexed(params[i + 2])).merge(_currentStyle);
              i += 2;
            } else if (params[i + 1] == WellKnown.sgrColorRgb && i + 4 < params.length) {
              _currentStyle = TextStyle(background: Color.rgb(params[i + 2], params[i + 3], params[i + 4])).merge(_currentStyle);
              i += 4;
            }
          }
        case WellKnown.sgrBgReset:
          _currentStyle = TextStyle(background: null).merge(_currentStyle);
        case WellKnown.sgrOverline:
          _currentStyle = TextStyle(overline: true).merge(_currentStyle);
        case WellKnown.sgrNoOverline:
          _currentStyle = TextStyle(overline: false).merge(_currentStyle);
      }
      i++;
    }
  }

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

  void _clearRegion(int r1, int c1, int r2, int c2) {
    for (var r = r1; r <= r2 && r < height; r++) {
      for (var c = c1; c <= c2 && c < width; c++) {
        _grid[r][c] = const Cell();
      }
    }
  }

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

  void _newline() {
    _cursorY++;
    _cursorX = 0;
    if (_cursorY >= height) {
      _scrollUp();
      _cursorY = height - 1;
    }
  }

  void _scrollUp() {
    for (var r = 0; r < height - 1; r++) {
      _grid[r] = List<Cell>.of(_grid[r + 1]);
    }
    _grid[height - 1] = List.filled(width, const Cell(), growable: false);
  }

  void _clampCursor() {
    _cursorX = _cursorX.clamp(0, width - 1);
    _cursorY = _cursorY.clamp(0, height - 1);
  }

  void _resetGrid() {
    _grid = List.generate(
      height,
      (_) => List.filled(width, const Cell(), growable: false),
      growable: false,
    );
  }

  /// Resizes the virtual terminal grid, preserving existing cells where possible
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

  /// Returns the cell at the given row and column
  Cell cellAt(int row, int col) {
    if (row < 0 || row >= height || col < 0 || col >= width) {
      return const Cell();
    }
    return _grid[row][col];
  }

  /// Returns the entire grid as a plain text string with line breaks
  String plainText() {
    return _grid.map((row) {
      return row.map((c) => c.wideContinuation ? '' : c.char).join();
    }).join('\n');
  }
}
