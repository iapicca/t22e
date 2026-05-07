import '../core/cell.dart';
import '../core/style.dart';
import '../core/color.dart' show Color;

class VirtualTerminal {
  int width;
  int height;
  late List<List<Cell>> _grid;
  int _cursorX = 0;
  int _cursorY = 0;
  TextStyle _currentStyle = TextStyle.empty;
  bool _altScreen = false;
  List<List<Cell>>? _normalScreenBuffer;

  VirtualTerminal({this.width = 80, this.height = 24}) {
    _resetGrid();
  }

  void write(String ansi) {
    var i = 0;
    while (i < ansi.length) {
      final c = ansi.codeUnitAt(i);
      if (c == 0x1B && i + 1 < ansi.length) {
        final next = ansi.codeUnitAt(i + 1);
        if (next == 0x5B) {
          i = _handleCsi(ansi, i + 2);
        } else if (next == 0x5D) {
          i = _handleOsc(ansi, i + 2);
        } else if (next == 0x63) {
          _resetGrid();
          i += 2;
        } else if (next == 0x37) {
          _cursorX = _savedCursorX;
          _cursorY = _savedCursorY;
          i += 2;
        } else if (next == 0x38) {
          _savedCursorX = _cursorX;
          _savedCursorY = _cursorY;
          i += 2;
        } else {
          i += 2;
        }
      } else if (c == 0x0A) {
        _newline();
        i++;
      } else if (c == 0x0D) {
        _cursorX = 0;
        i++;
      } else if (c >= 0x20) {
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
      if (c >= 0x30 && c <= 0x39) {
        numStr += String.fromCharCode(c);
      } else if (c == 0x3B) {
        params.add(numStr.isEmpty ? 0 : int.parse(numStr));
        numStr = '';
      } else if (c >= 0x40 && c <= 0x7E) {
        params.add(numStr.isEmpty ? 0 : int.parse(numStr));
        final fb = c;
        _dispatchCsi(params, fb);
        return i + 1;
      } else if (c == 0x3F) {
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
      if (c == 0x07 || c == 0x9C) return i + 1;
      i++;
    }
    return i;
  }

  void _dispatchCsi(List<int> params, int fb) {
    switch (fb) {
      case 0x48: // CUP
        _cursorY = (params.length > 0 ? params[0] : 1) - 1;
        _cursorX = (params.length > 1 ? params[1] : 1) - 1;
        _clampCursor();
      case 0x41: // CUU
        _cursorY = (_cursorY - (params.isEmpty ? 1 : params[0])).clamp(0, height - 1);
      case 0x42: // CUD
        _cursorY = (_cursorY + (params.isEmpty ? 1 : params[0])).clamp(0, height - 1);
      case 0x43: // CUF
        _cursorX = (_cursorX + (params.isEmpty ? 1 : params[0])).clamp(0, width - 1);
      case 0x44: // CUB
        _cursorX = (_cursorX - (params.isEmpty ? 1 : params[0])).clamp(0, width - 1);
      case 0x4A: // ED
        _eraseDisplay(params.isEmpty ? 0 : params[0]);
      case 0x4B: // EL
        _eraseLine(params.isEmpty ? 0 : params[0]);
      case 0x6D: // SGR
        _applySgr(params);
      case 0x68 when params.contains(1049): // DECSET - alt screen
        _altScreen = true;
      case 0x6C when params.contains(1049): // DECRST - alt screen
        _altScreen = false;
      case 0x68 when params[0] == 1049: // alt screen
        _altScreen = true;
      case 0x6C when params[0] == 1049:
        _altScreen = false;
    }
  }

  void _applySgr(List<int> params) {
    if (params.isEmpty || params[0] == 0) {
      _currentStyle = TextStyle.empty;
      return;
    }
    var i = 0;
    while (i < params.length) {
      final p = params[i];
      switch (p) {
        case 0:
          _currentStyle = TextStyle.empty;
        case 1:
          _currentStyle = TextStyle(bold: true).merge(_currentStyle);
        case 2:
          _currentStyle = TextStyle(dim: true).merge(_currentStyle);
        case 3:
          _currentStyle = TextStyle(italic: true).merge(_currentStyle);
        case 4:
          _currentStyle = TextStyle(underline: true).merge(_currentStyle);
        case 5:
          _currentStyle = TextStyle(blink: true).merge(_currentStyle);
        case 7:
          _currentStyle = TextStyle(reverse: true).merge(_currentStyle);
        case 9:
          _currentStyle = TextStyle(strikethrough: true).merge(_currentStyle);
        case 22:
          _currentStyle = TextStyle(bold: false, dim: false).merge(_currentStyle);
        case 23:
          _currentStyle = TextStyle(italic: false).merge(_currentStyle);
        case 24:
          _currentStyle = TextStyle(underline: false).merge(_currentStyle);
        case 25:
          _currentStyle = TextStyle(blink: false).merge(_currentStyle);
        case 27:
          _currentStyle = TextStyle(reverse: false).merge(_currentStyle);
        case 29:
          _currentStyle = TextStyle(strikethrough: false).merge(_currentStyle);
        case 30:
        case 31:
        case 32:
        case 33:
        case 34:
        case 35:
        case 36:
        case 37:
          _currentStyle = TextStyle(foreground: Color.ansi(p - 30)).merge(_currentStyle);
        case 38:
          if (i + 1 < params.length) {
            if (params[i + 1] == 5 && i + 2 < params.length) {
              _currentStyle = TextStyle(foreground: Color.indexed(params[i + 2])).merge(_currentStyle);
              i += 2;
            } else if (params[i + 1] == 2 && i + 4 < params.length) {
              _currentStyle = TextStyle(foreground: Color.rgb(params[i + 2], params[i + 3], params[i + 4])).merge(_currentStyle);
              i += 4;
            }
          }
        case 39:
          _currentStyle = TextStyle(foreground: null).merge(_currentStyle);
        case 40:
        case 41:
        case 42:
        case 43:
        case 44:
        case 45:
        case 46:
        case 47:
          _currentStyle = TextStyle(background: Color.ansi(p - 40)).merge(_currentStyle);
        case 48:
          if (i + 1 < params.length) {
            if (params[i + 1] == 5 && i + 2 < params.length) {
              _currentStyle = TextStyle(background: Color.indexed(params[i + 2])).merge(_currentStyle);
              i += 2;
            } else if (params[i + 1] == 2 && i + 4 < params.length) {
              _currentStyle = TextStyle(background: Color.rgb(params[i + 2], params[i + 3], params[i + 4])).merge(_currentStyle);
              i += 4;
            }
          }
        case 49:
          _currentStyle = TextStyle(background: null).merge(_currentStyle);
        case 53:
          _currentStyle = TextStyle(overline: true).merge(_currentStyle);
        case 55:
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

  Cell cellAt(int row, int col) {
    if (row < 0 || row >= height || col < 0 || col >= width) {
      return const Cell();
    }
    return _grid[row][col];
  }

  String plainText() {
    return _grid.map((row) {
      return row.map((c) => c.wideContinuation ? '' : c.char).join();
    }).join('\n');
  }
}
