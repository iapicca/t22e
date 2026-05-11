

C) create a package t22e_ui ispired by flutter's dart:ui (https://api.flutter.dev/flutter/dart-ui/) classes and types useful to this project
eg: (including, but not limited to)
- https://api.flutter.dev/flutter/dart-ui/GlyphInfo-class.html
- https://api.flutter.dev/flutter/dart-ui/Offset-class.html
- https://api.flutter.dev/flutter/dart-ui/Color-class.html

### it's very important that ONLY the functionality that we need are implemented

keeping in mind to adapt the classes to our use cases (eg probably colors won't have opacity)

then replace the newly created classes where it makes sense
(eg: lib/src/ansi/color.dart or wherever the file has landed after the monorepo refactor can probably use the newly created "Color" class)